import 'package:flutter/services.dart';
import 'dart:io';

enum PhotoLibraryPermission { granted, limited, denied, neverAskAgain }

abstract class PhotoLibraryChannel {
  Future<PhotoLibraryPermission> requestPermission();
  Future<void> exportFile({required String filePath});

  /// Platform-aware factory. 测试用 [IoPhotoLibraryChannel]。
  factory PhotoLibraryChannel({bool isTest = false}) {
    if (isTest) return IoPhotoLibraryChannel();
    if (Platform.isAndroid) return AndroidPhotoLibraryChannel();
    if (Platform.isIOS) return IosPhotoLibraryChannel();
    return IoPhotoLibraryChannel();
  }
}

/// IO 实现：写到 temp 目录（桌面开发 / 测试用，无需权限）。
class IoPhotoLibraryChannel implements PhotoLibraryChannel {
  @override
  Future<PhotoLibraryPermission> requestPermission() async =>
      PhotoLibraryPermission.granted;

  @override
  Future<void> exportFile({required String filePath}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('文件不存在: $filePath');
    }
  }
}

/// Android 实现：MethodChannel + permission_handler。
class AndroidPhotoLibraryChannel implements PhotoLibraryChannel {
  static const _channel = MethodChannel('viewfinder/photo_library');

  @override
  Future<PhotoLibraryPermission> requestPermission() async {
    final result = await _channel.invokeMethod<String>('requestPermission');
    return switch (result) {
      'granted' => PhotoLibraryPermission.granted,
      'limited' => PhotoLibraryPermission.limited,
      'denied' => PhotoLibraryPermission.denied,
      'never_ask_again' => PhotoLibraryPermission.neverAskAgain,
      _ => PhotoLibraryPermission.denied,
    };
  }

  @override
  Future<void> exportFile({required String filePath}) async {
    await _channel.invokeMethod('exportFile', {'filePath': filePath});
  }
}

/// iOS 实现：MethodChannel（PHPhotoLibrary .addOnly）。
class IosPhotoLibraryChannel implements PhotoLibraryChannel {
  static const _channel = MethodChannel('viewfinder/photo_library');

  @override
  Future<PhotoLibraryPermission> requestPermission() async {
    final result = await _channel.invokeMethod<String>('requestPermission');
    return switch (result) {
      'authorized' => PhotoLibraryPermission.granted,
      'limited' => PhotoLibraryPermission.limited,
      'denied' => PhotoLibraryPermission.denied,
      'restricted' => PhotoLibraryPermission.denied,
      _ => PhotoLibraryPermission.denied,
    };
  }

  @override
  Future<void> exportFile({required String filePath}) async {
    await _channel.invokeMethod('exportFile', {'filePath': filePath});
  }
}
