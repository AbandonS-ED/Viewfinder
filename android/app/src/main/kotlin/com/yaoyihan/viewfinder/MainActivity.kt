package com.yaoyihan.viewfinder

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        PhotoLibraryPlugin(applicationContext, flutterEngine)
        BackgroundDownloadPlugin(flutterEngine)
    }
}
