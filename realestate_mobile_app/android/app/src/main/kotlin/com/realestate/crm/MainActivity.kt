package com.realestate.crm

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import android.os.Build
import com.realestate.crm.overlay.FloatingWindowService

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.realestate.crm/native_bridge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkOverlayPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        result.success(Settings.canDrawOverlays(this))
                    } else {
                        result.success(true)
                    }
                }
                "requestOverlayPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                        result.success(true)
                    } else {
                        result.success(true)
                    }
                }
                "showFloatingOverlay" -> {
                    val clientName = call.argument<String>("clientName") ?: "Unknown Contact"
                    val clientStage = call.argument<String>("clientStage") ?: "New Lead"
                    val lastSummary = call.argument<String>("lastSummary") ?: "No past records found"
                    val icebreaker = call.argument<String>("icebreaker") ?: "Ask for current property requirement"

                    val serviceIntent = Intent(this, FloatingWindowService::class.java).apply {
                        putExtra("CLIENT_NAME", clientName)
                        putExtra("CLIENT_STAGE", clientStage)
                        putExtra("LAST_SUMMARY", lastSummary)
                        putExtra("ICEBREKER", icebreaker)
                    }
                    startService(serviceIntent)
                    result.success(true)
                }
                "hideFloatingOverlay" -> {
                    val serviceIntent = Intent(this, FloatingWindowService::class.java)
                    stopService(serviceIntent)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
