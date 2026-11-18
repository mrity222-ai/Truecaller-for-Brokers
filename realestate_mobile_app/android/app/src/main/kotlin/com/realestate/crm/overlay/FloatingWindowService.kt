package com.realestate.crm.overlay

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.CheckBox
import android.widget.TextView
import androidx.core.app.NotificationCompat
import com.realestate.crm.R

class FloatingWindowService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var layoutParams: WindowManager.LayoutParams? = null

    companion object {
        const val ACTION_SHOW = "ACTION_SHOW"
        const val ACTION_CALL_CONNECTED = "ACTION_CALL_CONNECTED"
        const val ACTION_CALL_ENDED = "ACTION_CALL_ENDED"
        const val ACTION_DISMISS = "ACTION_DISMISS"

        const val EXTRA_CLIENT_NAME = "CLIENT_NAME"
        const val EXTRA_CLIENT_STAGE = "CLIENT_STAGE"
        const val EXTRA_LAST_SUMMARY = "LAST_SUMMARY"
        const val EXTRA_ICEBREAKER = "ICEBREAKER"
        const val EXTRA_PHONE_NUMBER = "PHONE_NUMBER"

        var isClientMarkedLive: Boolean = false
        var currentCallerNumber: String = ""
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        startForegroundServiceNotification()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createOverlayView()
    }

    private fun startForegroundServiceNotification() {
        val channelId = "realestate_call_overlay_channel"
        val channelName = "RealEstate Call Intelligence"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                channelName,
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }

        val notification: Notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("RealEstate Smart Call Assistant")
            .setContentText("Active call assistant is ready")
            .setSmallIcon(android.R.drawable.ic_menu_call)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        startForeground(1001, notification)
    }

    private fun createOverlayView() {
        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        overlayView = inflater.inflate(R.layout.floating_overlay_card, null)

        val overlayType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            WindowManager.LayoutParams.TYPE_PHONE
        }

        layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            overlayType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
            WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            y = 140
        }

        setupDragHandling()
        setupListeners()

        try {
            windowManager?.addView(overlayView, layoutParams)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun setupListeners() {
        overlayView?.findViewById<TextView>(R.id.btnDismiss)?.setOnClickListener {
            stopSelf()
        }

        val cbClientCall = overlayView?.findViewById<CheckBox>(R.id.cbClientCall)
        val tvRecording = overlayView?.findViewById<TextView>(R.id.tvRecordingIndicator)

        cbClientCall?.setOnCheckedChangeListener { _, isChecked ->
            isClientMarkedLive = isChecked
            tvRecording?.visibility = if (isChecked) View.VISIBLE else View.GONE
        }
    }

    private fun setupDragHandling() {
        val dragHandle = overlayView?.findViewById<View>(R.id.viewDragHandle)
        var initialY = 0
        var initialTouchY = 0f

        dragHandle?.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialY = layoutParams?.y ?: 0
                    initialTouchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val deltaY = (initialTouchY - event.rawY).toInt()
                    layoutParams?.y = initialY + deltaY
                    windowManager?.updateViewLayout(overlayView, layoutParams)
                    true
                }
                else -> false
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_DISMISS -> {
                stopSelf()
            }
            ACTION_CALL_CONNECTED -> {
                val cb = overlayView?.findViewById<CheckBox>(R.id.cbClientCall)
                cb?.isEnabled = true
            }
            ACTION_CALL_ENDED -> {
                // Trigger post-call logic to Flutter if client was marked
                stopSelf()
            }
            else -> {
                // Populate data from Intent
                val name = intent?.getStringExtra(EXTRA_CLIENT_NAME) ?: "New Inquiry"
                val stage = intent?.getStringExtra(EXTRA_CLIENT_STAGE) ?: "Prospect"
                val summary = intent?.getStringExtra(EXTRA_LAST_SUMMARY) ?: "No previous conversation found"
                val icebreaker = intent?.getStringExtra(EXTRA_ICEBREAKER) ?: "Ask about budget and property requirements"
                currentCallerNumber = intent?.getStringExtra(EXTRA_PHONE_NUMBER) ?: ""

                overlayView?.findViewById<TextView>(R.id.tvCallerName)?.text = name
                overlayView?.findViewById<TextView>(R.id.tvStageBadge)?.text = stage
                overlayView?.findViewById<TextView>(R.id.tvPastSummary)?.text = summary
                overlayView?.findViewById<TextView>(R.id.tvIcebreaker)?.text = "💡 $icebreaker"
            }
        }
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        if (overlayView != null) {
            try {
                windowManager?.removeView(overlayView)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            overlayView = null
        }
    }
}
