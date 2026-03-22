package com.servcvpn.servc_vpn

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var flutterMethodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        VpnMethodChannel.register(flutterEngine, this)

        flutterMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.servcvpn/vpn")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleQuickConnect(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleQuickConnect(intent)
    }

    private fun handleQuickConnect(intent: Intent?) {
        if (intent?.getStringExtra("action") == "quick_connect") {
            // Send quick_connect action to Flutter side
            intent.removeExtra("action") // prevent re-triggering
            // Wait for Flutter engine to be ready, then invoke
            flutterMethodChannel?.invokeMethod("quick_connect", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        VpnMethodChannel.onActivityResult(requestCode, resultCode)
    }
}
