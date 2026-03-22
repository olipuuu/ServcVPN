package com.servcvpn.servc_vpn

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.net.TrafficStats
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.system.Os
import android.system.OsConstants
import android.util.Log
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader

class ServcVpnService : VpnService() {
    companion object {
        const val TAG = "ServcVPN"
        const val NOTIFICATION_CHANNEL_ID = "servcvpn_channel"
        const val NOTIFICATION_ID = 1
        const val ACTION_CONNECT = "com.servcvpn.CONNECT"
        const val ACTION_DISCONNECT = "com.servcvpn.DISCONNECT"

        var isRunning = false
        var xrayProcess: Process? = null
        var vpnInterface: ParcelFileDescriptor? = null
        var instance: ServcVpnService? = null
        var baseRxBytes: Long = 0
        var baseTxBytes: Long = 0

        init {
            System.loadLibrary("tun2socks_jni")
        }
    }

    // JNI: fork+exec tun2socks with fd inherited
    private external fun nativeStartTun2Socks(tunFd: Int, binaryPath: String, proxyAddr: String): Int
    private external fun nativeStopTun2Socks()

    override fun onCreate() {
        super.onCreate()
        instance = this
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_DISCONNECT -> {
                disconnect()
                return START_NOT_STICKY
            }
            ACTION_CONNECT -> {
                val configJson = intent.getStringExtra("config_json") ?: return START_NOT_STICKY
                val serverAddress = intent.getStringExtra("server_address") ?: return START_NOT_STICKY
                startForeground(NOTIFICATION_ID, buildNotification("Connecting..."))
                Thread {
                    try {
                        connect(configJson, serverAddress)
                    } catch (e: Exception) {
                        Log.e(TAG, "Connection failed", e)
                        VpnMethodChannel.sendStatus("disconnected", e.message ?: "Unknown error")
                        disconnect()
                    }
                }.start()
                return START_STICKY
            }
        }
        return START_NOT_STICKY
    }

    private fun connect(configJson: String, serverAddress: String) {
        // 1. Find xray binary
        val xrayPath = findNativeBinary("xray")
        Log.i(TAG, "xray binary: $xrayPath")

        // 2. Write xray config
        val configFile = File(filesDir, "xray_config.json")
        configFile.writeText(configJson)
        Log.i(TAG, "Config written to: ${configFile.absolutePath}")

        // 3. Kill old processes
        killProcesses()

        // 4. Start xray
        val xrayPb = ProcessBuilder(xrayPath, "run", "-c", configFile.absolutePath)
            .directory(filesDir)
            .redirectErrorStream(true)
        xrayProcess = xrayPb.start()
        Log.i(TAG, "xray started")
        logProcess("xray", xrayProcess!!)

        // 5. Wait for SOCKS5 port
        if (!waitForPort(11808, 20)) {
            throw Exception("xray failed to start on port 11808")
        }
        Log.i(TAG, "xray ready on port 11808")

        // 6. Create VPN TUN interface
        val builder = Builder()
            .setSession("ServcVPN")
            .setMtu(1500)
            .addAddress("10.0.85.1", 24)
            .addRoute("0.0.0.0", 0)
            .addDnsServer("1.1.1.1")
            .addDnsServer("8.8.8.8")
            .addDisallowedApplication(packageName)

        vpnInterface = builder.establish()
            ?: throw Exception("Failed to establish VPN interface")

        val tunFd = vpnInterface!!.fd
        Log.i(TAG, "VPN interface established, fd=$tunFd")

        // 7. Start tun2socks via JNI fork+exec (bypasses ProcessBuilder fd closing)
        val tun2socksPath = findNativeBinary("tun2socks")
        Log.i(TAG, "Starting tun2socks via JNI fork: binary=$tun2socksPath fd=$tunFd")

        val result = nativeStartTun2Socks(tunFd, tun2socksPath, "socks5://127.0.0.1:11808")
        if (result <= 0) {
            throw Exception("tun2socks fork failed with code=$result")
        }
        Log.i(TAG, "tun2socks running with pid=$result")

        isRunning = true
        val uid = applicationInfo.uid
        baseRxBytes = TrafficStats.getUidRxBytes(uid)
        baseTxBytes = TrafficStats.getUidTxBytes(uid)
        updateNotification("Connected to ServcVPN")
        VpnMethodChannel.sendStatus("connected", "Connected")
        startHealthMonitor()
    }

    fun disconnect() {
        isRunning = false

        // Stop tun2socks via JNI
        try { nativeStopTun2Socks() } catch (_: Exception) {}

        killProcesses()

        try { vpnInterface?.close() } catch (_: Exception) {}
        vpnInterface = null

        VpnMethodChannel.sendStatus("disconnected", "Disconnected")
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun killProcesses() {
        try { xrayProcess?.destroyForcibly() } catch (_: Exception) {}
        xrayProcess = null
    }

    private fun findNativeBinary(name: String): String {
        val nativeLibDir = applicationInfo.nativeLibraryDir
        val binaryFile = File(nativeLibDir, "lib${name}.so")
        if (binaryFile.exists()) {
            binaryFile.setExecutable(true)
            return binaryFile.absolutePath
        }
        throw Exception("Binary '$name' not found at ${binaryFile.absolutePath}")
    }

    private fun waitForPort(port: Int, attempts: Int): Boolean {
        for (i in 0 until attempts) {
            Thread.sleep(500)
            try {
                val socket = java.net.Socket()
                socket.connect(java.net.InetSocketAddress("127.0.0.1", port), 1000)
                socket.close()
                return true
            } catch (_: Exception) {}
        }
        return false
    }

    private fun logProcess(name: String, process: Process) {
        Thread {
            try {
                val reader = BufferedReader(InputStreamReader(process.inputStream))
                var line: String?
                while (reader.readLine().also { line = it } != null) {
                    Log.d(TAG, "[$name] $line")
                }
            } catch (_: Exception) {}
        }.start()
    }

    private fun startHealthMonitor() {
        Thread {
            var failCount = 0
            while (isRunning) {
                Thread.sleep(15000)
                if (!isRunning) return@Thread
                try {
                    val socket = java.net.Socket()
                    socket.connect(java.net.InetSocketAddress("127.0.0.1", 11808), 5000)
                    socket.close()
                    failCount = 0
                } catch (_: Exception) {
                    failCount++
                    Log.w(TAG, "Health check failed ($failCount/3)")
                    if (failCount >= 3) {
                        Log.e(TAG, "xray unreachable, disconnecting")
                        disconnect()
                        return@Thread
                    }
                }
            }
        }.start()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "ServcVPN Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply { description = "VPN connection status" }
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }

    private fun buildNotification(text: String): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        return Notification.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("ServcVPN")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    private fun updateNotification(text: String) {
        getSystemService(NotificationManager::class.java)
            .notify(NOTIFICATION_ID, buildNotification(text))
    }

    override fun onDestroy() {
        disconnect()
        instance = null
        super.onDestroy()
    }
}
