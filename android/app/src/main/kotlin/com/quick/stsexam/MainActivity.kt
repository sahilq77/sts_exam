package com.quick.stsexam

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.ContentResolver
import android.database.ContentObserver
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.quick.stsexam/screenshot"
    private var methodChannel: MethodChannel? = null
    private var screenshotObserver: ContentObserver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Create and store the MethodChannel once here (flutterEngine is non-null)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        methodChannel?.setMethodCallHandler { call, result ->
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
                    methodChannel?.invokeMethod("screenshotDetected", null)
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
        // Optionally clear the channel reference
        methodChannel = null
    }
}