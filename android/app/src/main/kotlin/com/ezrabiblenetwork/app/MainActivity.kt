package com.ezrabiblenetwork.app

import android.app.PictureInPictureParams
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Native glue for things the Flutter plugins don't cover:
 * picture-in-picture (manual + auto on leaving the app), the media-playback
 * foreground service, and the battery-optimisation settings screen.
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var autoPipEnabled = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "isPipSupported" -> result.success(isPipSupported())
                    "enterPip" -> result.success(enterPip())
                    "setAutoPip" -> {
                        autoPipEnabled = call.argument<Boolean>("enabled") ?: false
                        applyPipParams()
                        result.success(null)
                    }
                    "startPlaybackService" -> {
                        PlaybackService.start(
                            this@MainActivity,
                            call.argument<String>("title") ?: "Ezra Bible Network",
                        )
                        result.success(null)
                    }
                    "stopPlaybackService" -> {
                        PlaybackService.stop(this@MainActivity)
                        result.success(null)
                    }
                    "isIgnoringBatteryOptimizations" -> result.success(isIgnoringBatteryOptimizations())
                    "openBatteryOptimizationSettings" -> {
                        result.success(openBatteryOptimizationSettings())
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun isPipSupported(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)

    private fun pipParams(): PictureInPictureParams? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return null
        val builder = PictureInPictureParams.Builder().setAspectRatio(Rational(16, 9))
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setAutoEnterEnabled(autoPipEnabled)
            builder.setSeamlessResizeEnabled(true)
        }
        return builder.build()
    }

    private fun applyPipParams() {
        if (!isPipSupported()) return
        pipParams()?.let { setPictureInPictureParams(it) }
    }

    private fun enterPip(): Boolean {
        if (!isPipSupported()) return false
        return try {
            pipParams()?.let { enterPictureInPictureMode(it) } ?: false
        } catch (e: IllegalStateException) {
            false
        }
    }

    // Android 8–11: no auto-enter flag, so enter PiP when the user presses Home.
    // Android 12+ handles this through setAutoEnterEnabled.
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (autoPipEnabled && Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            enterPip()
        }
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        channel?.invokeMethod("pipChanged", isInPictureInPictureMode)
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        val pm = getSystemService(POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    // Opens the system list rather than ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
    // which needs a permission Google Play restricts.
    private fun openBatteryOptimizationSettings(): Boolean = try {
        startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
        true
    } catch (e: Exception) {
        false
    }

    override fun onDestroy() {
        PlaybackService.stop(this)
        channel?.setMethodCallHandler(null)
        super.onDestroy()
    }

    companion object {
        private const val CHANNEL = "com.ezrabiblenetwork.app/native"
    }
}
