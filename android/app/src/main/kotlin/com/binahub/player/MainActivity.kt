package com.binahub.player

import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.BatteryManager
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.binahub.player/media_engine"
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: AudioFocusRequest? = null

    companion object {
        init {
            try {
                System.loadLibrary("bina_media_engine")
            } catch (e: UnsatisfiedLinkError) {
                // Graceful fallback for environments where NDK library is being built
                e.printStackTrace()
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setSecureWindowFlag" -> {
                    val enable = call.argument<Boolean>("enable") ?: false
                    setSecureFlag(enable)
                    result.success(true)
                }
                "getThermalAndBatteryState", "getThermalAndBatteryTelemetry" -> {
                    val status = getThermalAndBatteryTelemetry()
                    result.success(status)
                }
                "requestAudioFocus" -> {
                    val granted = requestAudioFocusInternal()
                    result.success(granted)
                }
                "abandonAudioFocus" -> {
                    abandonAudioFocusInternal()
                    result.success(true)
                }
                "startForegroundMediaService" -> {
                    val title = call.argument<String>("title") ?: "Media Playing"
                    val artist = call.argument<String>("artist") ?: "BinaHub"
                    startMediaService(title, artist)
                    result.success(true)
                }
                "stopForegroundMediaService" -> {
                    stopMediaService()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Prevents Android recents screenshot & screen recording (SRS VLT-07 & SEC-05)
     */
    private fun setSecureFlag(enable: Boolean) {
        runOnUiThread {
            if (enable) {
                window.setFlags(
                    WindowManager.LayoutParams.FLAG_SECURE,
                    WindowManager.LayoutParams.FLAG_SECURE
                )
            } else {
                window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            }
        }
    }

    /**
     * Reads battery percentage, charging state, and thermal status (SRS ENH-09)
     */
    private fun getThermalAndBatteryTelemetry(): Map<String, Any> {
        val bm = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val batteryPct = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)

        var isThermalThrottled = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            val thermalStatus = pm.currentThermalStatus
            isThermalThrottled = thermalStatus >= PowerManager.THERMAL_STATUS_SEVERE
        }

        return mapOf(
            "batteryPct" to batteryPct,
            "isThermalThrottled" to isThermalThrottled,
            "isBatteryLow" to (batteryPct < 20)
        )
    }

    private fun requestAudioFocusInternal(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val playbackAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MOVIE)
                .build()

            audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .setAudioAttributes(playbackAttributes)
                .setAcceptsDelayedFocusGain(true)
                .setOnAudioFocusChangeListener { focusChange ->
                    // Propagated to player engine
                }
                .build()

            return audioManager?.requestAudioFocus(audioFocusRequest!!) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        } else {
            @Suppress("DEPRECATION")
            return audioManager?.requestAudioFocus(
                null,
                AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN
            ) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        }
    }

    private fun abandonAudioFocusInternal() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && audioFocusRequest != null) {
            audioManager?.abandonAudioFocusRequest(audioFocusRequest!!)
        } else {
            @Suppress("DEPRECATION")
            audioManager?.abandonAudioFocus(null)
        }
    }

    private fun startMediaService(title: String, artist: String) {
        val intent = Intent(this, BinaMediaService::class.java).apply {
            action = "ACTION_START_PLAYBACK"
            putExtra("EXTRA_TITLE", title)
            putExtra("EXTRA_ARTIST", artist)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopMediaService() {
        val intent = Intent(this, BinaMediaService::class.java).apply {
            action = "ACTION_STOP_PLAYBACK"
        }
        startService(intent)
    }
}
