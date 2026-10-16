package com.ezrabiblenetwork.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat

/**
 * Foreground service that keeps the process alive while the live stream plays
 * in the background.
 *
 * better_player_plus already posts a media-style notification (with lock-screen
 * play/pause) but doesn't run a foreground service, so Android may kill the app.
 * This service promotes that same notification (same id) to foreground, which
 * avoids showing two notifications. Until the player notification appears, a
 * minimal fallback notification is used.
 */
class PlaybackService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var adoptAttempts = 0
    private var title = "Ezra Bible Network"

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        title = intent?.getStringExtra(EXTRA_TITLE) ?: title
        val playerNotification = findPlayerNotification()
        if (playerNotification != null) {
            goForeground(PLAYER_NOTIFICATION_ID, playerNotification)
        } else {
            goForeground(FALLBACK_NOTIFICATION_ID, buildFallbackNotification())
            adoptAttempts = 0
            handler.post(adoptRunnable)
        }
        return START_NOT_STICKY
    }

    private val adoptRunnable = object : Runnable {
        override fun run() {
            val n = findPlayerNotification()
            if (n != null) {
                goForeground(PLAYER_NOTIFICATION_ID, n)
                getSystemService(NotificationManager::class.java).cancel(FALLBACK_NOTIFICATION_ID)
            } else if (++adoptAttempts < 20) {
                handler.postDelayed(this, 500)
            }
        }
    }

    private fun findPlayerNotification(): Notification? = try {
        getSystemService(NotificationManager::class.java)
            .activeNotifications
            .firstOrNull { it.id == PLAYER_NOTIFICATION_ID }
            ?.notification
    } catch (e: Exception) {
        null
    }

    private fun goForeground(id: Int, notification: Notification) {
        try {
            val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
            } else {
                0
            }
            ServiceCompat.startForeground(this, id, notification, type)
        } catch (e: Exception) {
            Log.w(TAG, "startForeground failed", e)
            stopSelf()
        }
    }

    private fun buildFallbackNotification(): Notification {
        val nm = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            nm.createNotificationChannel(
                NotificationChannel(FALLBACK_CHANNEL, "Live playback", NotificationManager.IMPORTANCE_LOW)
            )
        }
        val launch = packageManager.getLaunchIntentForPackage(packageName)
        val pending = PendingIntent.getActivity(
            this, 0, launch,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        return NotificationCompat.Builder(this, FALLBACK_CHANNEL)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(title)
            .setContentText("Playing live")
            .setContentIntent(pending)
            .setOngoing(true)
            .setSilent(true)
            .build()
    }

    override fun onDestroy() {
        handler.removeCallbacks(adoptRunnable)
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_DETACH)
        getSystemService(NotificationManager::class.java).cancel(FALLBACK_NOTIFICATION_ID)
        super.onDestroy()
    }

    companion object {
        private const val TAG = "PlaybackService"
        private const val EXTRA_TITLE = "title"
        // Must match NOTIFICATION_ID in better_player_plus's BetterPlayer.kt (1.0.8).
        private const val PLAYER_NOTIFICATION_ID = 20772077
        private const val FALLBACK_NOTIFICATION_ID = 4711
        private const val FALLBACK_CHANNEL = "ezra_playback"

        fun start(context: Context, title: String) {
            val intent = Intent(context, PlaybackService::class.java).putExtra(EXTRA_TITLE, title)
            try {
                ContextCompat.startForegroundService(context, intent)
            } catch (e: Exception) {
                // e.g. ForegroundServiceStartNotAllowedException when started from background.
                Log.w(TAG, "Could not start playback service", e)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, PlaybackService::class.java))
        }
    }
}
