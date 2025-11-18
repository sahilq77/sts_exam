package com.quick.vidyasarthi

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.ContentResolver
import android.content.Intent // Added missing import
import android.database.ContentObserver
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.MediaStore
import android.util.Log

class MainActivity : FlutterActivity() {
    private val SCREENSHOT_CHANNEL = "com.quick.vidyasarthi/screenshot"
    private val BATTERY_CHANNEL = "com.quick.vidyasarthi/battery_optimization"
    private var screenshotMethodChannel: MethodChannel? = null
    private var batteryMethodChannel: MethodChannel? = null
    private var screenshotObserver: ContentObserver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Screenshot channel
        screenshotMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREENSHOT_CHANNEL)
        screenshotMethodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "listenForScreenshots" -> {
                    startScreenshotListener()
                    result.success(true)
                }
                "stopScreenshotListener" -> {
                    stopScreenshotListener()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Battery optimization channel
        batteryMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL)
        batteryMethodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isIgnoringBatteryOptimizations" -> {
                    val isIgnoring = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
                        powerManager.isIgnoringBatteryOptimizations(packageName)
                    } else {
                        true // Battery optimization not applicable below Android M
                    }
                    result.success(isIgnoring)
                }
                "requestIgnoreBatteryOptimizations" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(android.provider.Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                        intent.setData(Uri.parse("package:$packageName")) // Fixed syntax
                        startActivity(intent)
                        result.success(true) // Assume success as we can't track user action
                    } else {
                        result.success(true) // No need for optimization below Android M
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startScreenshotListener() {
        try {
            // Check if observer is already running to avoid duplicates
            if (screenshotObserver != null) {
                Log.d("MainActivity", "Screenshot listener already active")
                return
            }

            // Create a ContentObserver to monitor screenshots
            screenshotObserver = object : ContentObserver(Handler(Looper.getMainLooper())) {
                override fun onChange(selfChange: Boolean, uri: Uri?) {
                    super.onChange(selfChange, uri)
                    Log.d("MainActivity", "Screenshot detected at URI: $uri")
                    
                    // Use the stored non-null MethodChannel to notify Flutter
                    screenshotMethodChannel?.invokeMethod("screenshotDetected", null)
                }
            }

            // Register the observer to monitor the MediaStore for screenshots
            contentResolver.registerContentObserver(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                true,
                screenshotObserver!!
            )
            Log.d("MainActivity", "Screenshot listener started")
        } catch (e: Exception) {
            Log.e("MainActivity", "Error starting screenshot listener: ${e.message}")
        }
    }

    private fun stopScreenshotListener() {
        try {
            screenshotObserver?.let {
                contentResolver.unregisterContentObserver(it)
                screenshotObserver = null
                Log.d("MainActivity", "Screenshot listener stopped")
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Error stopping screenshot listener: ${e.message}")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up the observer when the activity is destroyed
        stopScreenshotListener()
        // Optionally clear the channel references
        screenshotMethodChannel = null
        batteryMethodChannel = null
    }
}