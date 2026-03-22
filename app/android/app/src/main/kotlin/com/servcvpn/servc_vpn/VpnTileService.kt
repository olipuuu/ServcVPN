package com.servcvpn.servc_vpn

import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.util.Log

class VpnTileService : TileService() {
    companion object {
        const val TAG = "ServcVPN-Tile"
        var instance: VpnTileService? = null
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
    }

    override fun onDestroy() {
        instance = null
        super.onDestroy()
    }

    override fun onStartListening() {
        super.onStartListening()
        updateTile()
    }

    override fun onClick() {
        super.onClick()

        if (ServcVpnService.isRunning) {
            // Disconnect
            Log.i(TAG, "Tile clicked: disconnecting")
            val intent = Intent(this, ServcVpnService::class.java)
            intent.action = ServcVpnService.ACTION_DISCONNECT
            startService(intent)
        } else {
            // Connect using saved config
            Log.i(TAG, "Tile clicked: connecting")

            // Check VPN permission first
            val vpnIntent = VpnService.prepare(this)
            if (vpnIntent != null) {
                // Need VPN permission — must open app
                Log.i(TAG, "VPN permission needed, launching app")
                val appIntent = Intent(this, MainActivity::class.java)
                appIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                appIntent.putExtra("action", "quick_connect")
                startActivityAndCollapse(appIntent)
                return
            }

            // Permission granted — try to connect directly
            val lastConfig = VpnMethodChannel.getLastConfig(this)
            if (lastConfig != null) {
                Log.i(TAG, "Starting VPN from tile with saved config")
                val intent = Intent(this, ServcVpnService::class.java).apply {
                    action = ServcVpnService.ACTION_CONNECT
                    putExtra("config_json", lastConfig.first)
                    putExtra("server_address", lastConfig.second)
                }
                startForegroundService(intent)
            } else {
                // No saved config — open app
                Log.i(TAG, "No saved config, launching app")
                val appIntent = Intent(this, MainActivity::class.java)
                appIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivityAndCollapse(appIntent)
            }
        }
    }

    fun updateTile() {
        val tile = qsTile ?: return
        if (ServcVpnService.isRunning) {
            tile.state = Tile.STATE_ACTIVE
            tile.label = "ServcVPN"
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                tile.subtitle = "Connected"
            }
        } else {
            tile.state = Tile.STATE_INACTIVE
            tile.label = "ServcVPN"
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                tile.subtitle = "Disconnected"
            }
        }
        tile.updateTile()
    }
}
