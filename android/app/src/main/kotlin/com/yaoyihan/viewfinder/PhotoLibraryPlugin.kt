package com.yaoyihan.viewfinder

import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class PhotoLibraryPlugin(
    private val context: Context,
    engine: FlutterEngine,
) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(
        engine.dartExecutor.binaryMessenger,
        "viewfinder/photo_library"
    )

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestPermission" -> result.success("granted")
            "exportFile" -> handleExportFile(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleExportFile(call: MethodCall, result: MethodChannel.Result) {
        val filePath = call.argument<String>("filePath")
        if (filePath == null) {
            result.error("INVALID_ARGS", "filePath required", null)
            return
        }
        try {
            val file = File(filePath)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "File not found: $filePath", null)
                return
            }
            exportToMediaStore(file)
            result.success(null)
        } catch (e: Exception) {
            result.error("EXPORT_FAILED", e.message, null)
        }
    }

    private fun exportToMediaStore(file: File) {
        val fileName = file.name
        val mimeType = when {
            fileName.endsWith(".jpg", ignoreCase = true) ||
            fileName.endsWith(".jpeg", ignoreCase = true) -> "image/jpeg"
            fileName.endsWith(".png", ignoreCase = true) -> "image/png"
            fileName.endsWith(".nef", ignoreCase = true) ||
            fileName.endsWith(".raw", ignoreCase = true) -> "image/x-nikon-nef"
            fileName.endsWith(".mov", ignoreCase = true) -> "video/quicktime"
            fileName.endsWith(".mp4", ignoreCase = true) -> "video/mp4"
            else -> "application/octet-stream"
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val contentValues = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
                put(MediaStore.Images.Media.MIME_TYPE, mimeType)
                put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_DCIM + "/Viewfinder")
            }
            val uri = context.contentResolver.insert(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                contentValues
            )
            uri?.let {
                context.contentResolver.openOutputStream(it)?.use { output ->
                    FileInputStream(file).use { input ->
                        input.copyTo(output)
                    }
                }
            }
        } else {
            val destDir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DCIM + "/Viewfinder"
            )
            destDir.mkdirs()
            val destFile = File(destDir, fileName)
            file.copyTo(destFile, overwrite = true)
        }
    }
}
