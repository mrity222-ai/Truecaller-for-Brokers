package com.realestate.crm.telephony

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.telephony.TelephonyManager
import com.realestate.crm.overlay.FloatingWindowService

class CallStateReceiver : BroadcastReceiver() {

    companion object {
        private var lastState = TelephonyManager.CALL_STATE_IDLE
        private var savedNumber: String? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            val stateStr = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)

            var state = TelephonyManager.CALL_STATE_IDLE
            if (stateStr == TelephonyManager.EXTRA_STATE_RINGING) {
                state = TelephonyManager.CALL_STATE_RINGING
            } else if (stateStr == TelephonyManager.EXTRA_STATE_OFFHOOK) {
                state = TelephonyManager.CALL_STATE_OFFHOOK
            }

            onCustomCallStateChanged(context, state, number)
        }
    }

    private fun onCustomCallStateChanged(context: Context, state: Int, incomingNumber: String?) {
        if (lastState == state) {
            return
        }

        when (state) {
            TelephonyManager.CALL_STATE_RINGING -> {
                savedNumber = incomingNumber
                showOverlayIfPermitted(context, incomingNumber ?: "Unknown Caller")
            }
            TelephonyManager.CALL_STATE_OFFHOOK -> {
                // Call answered
                val serviceIntent = Intent(context, FloatingWindowService::class.java).apply {
                    action = FloatingWindowService.ACTION_CALL_CONNECTED
                }
                context.startService(serviceIntent)
            }
            TelephonyManager.CALL_STATE_IDLE -> {
                // Call ended
                val serviceIntent = Intent(context, FloatingWindowService::class.java).apply {
                    action = FloatingWindowService.ACTION_CALL_ENDED
                }
                context.startService(serviceIntent)
                savedNumber = null
            }
        }
        lastState = state
    }

    private fun showOverlayIfPermitted(context: Context, phoneNumber: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(context)) {
            // Cannot show overlay without permission
            return
        }

        val serviceIntent = Intent(context, FloatingWindowService::class.java).apply {
            action = FloatingWindowService.ACTION_SHOW
            putExtra(FloatingWindowService.EXTRA_PHONE_NUMBER, phoneNumber)
            putExtra(FloatingWindowService.EXTRA_CLIENT_NAME, "Client ($phoneNumber)")
            putExtra(FloatingWindowService.EXTRA_CLIENT_STAGE, "Active Prospect")
            putExtra(FloatingWindowService.EXTRA_LAST_SUMMARY, "Budget ~85L, inquiry for 2BHK/3BHK.")
            putExtra(FloatingWindowService.EXTRA_ICEBREAKER, "Confirm preferred site visit date.")
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
    }
}
