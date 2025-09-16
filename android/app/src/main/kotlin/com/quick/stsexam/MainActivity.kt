package com.quick.stsexam

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import dev.fluttercommunity.workmanager.WorkmanagerPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        WorkmanagerPlugin.setPluginRegistrantCallback { engine ->
            // Register additional plugins if needed
        }
    }
}
