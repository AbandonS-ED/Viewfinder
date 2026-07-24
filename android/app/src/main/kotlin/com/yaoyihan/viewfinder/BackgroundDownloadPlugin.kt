package com.yaoyihan.viewfinder

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BackgroundDownloadPlugin(engine: FlutterEngine) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(
        engine.dartExecutor.binaryMessenger,
        "viewfinder/background_download"
    )

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "begin" -> {
                // flutter_background_service 已在 Dart 层处理前台服务
                // 此处只需返回一个虚拟 taskId（iOS 兼容）
                result.success(1)
            }
            "end" -> {
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}
