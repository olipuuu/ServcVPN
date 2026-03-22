package com.servcvpn.servc_vpn

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.TrafficStats
import android.net.VpnService
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.net.InetSocketAddress
import java.net.Proxy
import java.net.URL
import kotlin.concurrent.thread

object VpnMethodChannel {
    private const val METHOD_CHANNEL = "com.servcvpn/vpn"
    private const val EVENT_CHANNEL = "com.servcvpn/vpn_status"
    private const val VPN_PERMISSION_REQUEST = 24

    private var activity: Activity? = null
    private var pendingConfigJson: String? = null
    private var pendingServerAddress: String? = null
    private var pendingResult: MethodChannel.Result? = null
    private var statusSink: EventChannel.EventSink? = null

    fun register(flutterEngine: FlutterEngine, activity: Activity) {
        this.activity = activity

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                handleMethodCall(call, result)
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    statusSink = events
                }
                override fun onCancel(arguments: Any?) {
                    statusSink = null
                }
            })
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "connect" -> {
                val configJson = call.argument<String>("config_json")
                val serverAddress = call.argument<String>("server_address")
                if (configJson == null || serverAddress == null) {
                    result.error("ARGS", "Missing config_json or server_address", null)
                    return
                }

                // Check VPN permission
                val vpnIntent = VpnService.prepare(activity)
                if (vpnIntent != null) {
                    pendingConfigJson = configJson
                    pendingServerAddress = serverAddress
                    pendingResult = result
                    activity?.startActivityForResult(vpnIntent, VPN_PERMISSION_REQUEST)
                } else {
                    startVpn(configJson, serverAddress)
                    result.success(true)
                }
            }
            "disconnect" -> {
                val service = ServcVpnService.instance
                if (service != null) {
                    service.disconnect()
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "isRunning" -> {
                result.success(ServcVpnService.isRunning)
            }
            "getTrafficStats" -> {
                val uid = activity?.applicationInfo?.uid ?: -1
                val rx = TrafficStats.getUidRxBytes(uid) - ServcVpnService.baseRxBytes
                val tx = TrafficStats.getUidTxBytes(uid) - ServcVpnService.baseTxBytes
                result.success(mapOf("rx" to if (rx > 0) rx else 0L, "tx" to if (tx > 0) tx else 0L))
            }
            "fetchVpnIp" -> {
                // Fetch public IP through SOCKS5 proxy (goes through VPN tunnel)
                thread {
                    val ip = fetchIpViaSocks5()
                    activity?.runOnUiThread {
                        result.success(ip)
                    }
                }
            }
            "fetchDnsServers" -> {
                // Fetch DNS servers through SOCKS5 proxy
                thread {
                    val servers = fetchDnsViaSocks5()
                    activity?.runOnUiThread {
                        result.success(servers)
                    }
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int) {
        if (requestCode == VPN_PERMISSION_REQUEST) {
            if (resultCode == Activity.RESULT_OK) {
                val config = pendingConfigJson
                val addr = pendingServerAddress
                if (config != null && addr != null) {
                    startVpn(config, addr)
                    pendingResult?.success(true)
                }
            } else {
                pendingResult?.error("DENIED", "VPN permission denied", null)
            }
            pendingConfigJson = null
            pendingServerAddress = null
            pendingResult = null
        }
    }

    private fun startVpn(configJson: String, serverAddress: String) {
        val ctx = activity ?: return

        // Save last config for Quick Settings Tile
        saveLastConfig(ctx, configJson, serverAddress)

        val intent = Intent(ctx, ServcVpnService::class.java).apply {
            action = ServcVpnService.ACTION_CONNECT
            putExtra("config_json", configJson)
            putExtra("server_address", serverAddress)
        }
        ctx.startForegroundService(intent)
    }

    fun saveLastConfig(context: Context, configJson: String, serverAddress: String) {
        context.getSharedPreferences("vpn_tile", Context.MODE_PRIVATE)
            .edit()
            .putString("last_config_json", configJson)
            .putString("last_server_address", serverAddress)
            .apply()
    }

    fun getLastConfig(context: Context): Pair<String, String>? {
        val prefs = context.getSharedPreferences("vpn_tile", Context.MODE_PRIVATE)
        val config = prefs.getString("last_config_json", null)
        val address = prefs.getString("last_server_address", null)
        if (config != null && address != null) return Pair(config, address)
        return null
    }

    private fun fetchDnsViaSocks5(): List<String> {
        val servers = mutableListOf<String>()
        val socks = Proxy(Proxy.Type.SOCKS, InetSocketAddress("127.0.0.1", 11808))
        // Cloudflare trace
        try {
            val conn = URL("https://1.1.1.1/cdn-cgi/trace").openConnection(socks) as java.net.HttpURLConnection
            conn.connectTimeout = 10000
            conn.readTimeout = 10000
            val body = conn.inputStream.bufferedReader().readText()
            conn.disconnect()
            for (line in body.split("\n")) {
                if (line.startsWith("ip=")) {
                    servers.add(line.substring(3).trim())
                }
            }
        } catch (e: Exception) {
            Log.w("VpnMethodChannel", "DNS CF trace failed: ${e.message}")
        }
        // Google DNS resolver
        try {
            val conn = URL("https://dns.google/resolve?name=o-o.myaddr.l.google.com&type=TXT")
                .openConnection(socks) as java.net.HttpURLConnection
            conn.connectTimeout = 10000
            conn.readTimeout = 10000
            val body = conn.inputStream.bufferedReader().readText()
            conn.disconnect()
            // Simple JSON parse for Answer[].data
            val regex = Regex(""""data"\s*:\s*"([^"]+)"""")
            for (match in regex.findAll(body)) {
                val ip = match.groupValues[1].replace("\"", "").trim()
                if (ip.matches(Regex("""\d+\.\d+\.\d+\.\d+"""))) {
                    servers.add(ip)
                }
            }
        } catch (e: Exception) {
            Log.w("VpnMethodChannel", "DNS Google resolve failed: ${e.message}")
        }
        return servers
    }

    private fun fetchIpViaSocks5(): String? {
        val apis = listOf(
            "https://api.ipify.org",
            "https://ifconfig.me/ip",
            "https://icanhazip.com"
        )
        val socks = Proxy(Proxy.Type.SOCKS, InetSocketAddress("127.0.0.1", 11808))
        for (api in apis) {
            try {
                val conn = URL(api).openConnection(socks) as java.net.HttpURLConnection
                conn.connectTimeout = 10000
                conn.readTimeout = 10000
                conn.setRequestProperty("User-Agent", "curl/7.68.0")
                val ip = conn.inputStream.bufferedReader().readText().trim()
                conn.disconnect()
                if (ip.matches(Regex("""\d+\.\d+\.\d+\.\d+"""))) {
                    return ip
                }
            } catch (e: Exception) {
                Log.w("VpnMethodChannel", "fetchIpViaSocks5 failed for $api: ${e.message}")
            }
        }
        return null
    }

    fun sendStatus(state: String, message: String) {
        activity?.runOnUiThread {
            statusSink?.success(mapOf("state" to state, "message" to message))
        }
        // Update Quick Settings Tile
        VpnTileService.instance?.updateTile()
    }
}
