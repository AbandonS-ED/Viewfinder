import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

final FlutterBackgroundService _bgService = FlutterBackgroundService();

void _bgOnStart(ServiceInstance service) {
  service.on('stopService').listen((_) {
    service.stopSelf();
  });
}

abstract class BackgroundDownloadRunner {
  Future<void> begin({required String name, void Function()? onExpiration});
  Future<void> end();
  Future<bool> get isActive;
}

class AndroidBackgroundDownloadRunner implements BackgroundDownloadRunner {
  static bool _configured = false;

  static Future<void> ensureConfigured() async {
    if (_configured) return;
    await _bgService.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _bgOnStart,
        autoStart: false,
        autoStartOnBoot: false,
        isForegroundMode: true,
        notificationChannelId: 'download_foreground',
        initialNotificationContent: '准备下载',
        initialNotificationTitle: 'Viewfinder',
        foregroundServiceNotificationId: 1001,
        foregroundServiceTypes: [AndroidForegroundType.dataSync],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
      ),
    );
    _configured = true;
  }

  @override
  Future<void> begin({required String name, void Function()? onExpiration}) async {
    await ensureConfigured();
    await _bgService.startService();
  }

  @override
  Future<void> end() async {
    _bgService.invoke('stopService');
  }

  @override
  Future<bool> get isActive => _bgService.isRunning();
}

class IosBackgroundDownloadRunner implements BackgroundDownloadRunner {
  static const _channel = MethodChannel('viewfinder/background_download');
  int _taskId = -1;

  @override
  Future<void> begin({required String name, void Function()? onExpiration}) async {
    if (_taskId != -1) return;
    _taskId = (await _channel.invokeMethod<int>('begin', {'name': name})) ?? -1;
  }

  @override
  Future<void> end() async {
    if (_taskId == -1) return;
    await _channel.invokeMethod<void>('end', {'taskId': _taskId});
    _taskId = -1;
  }

  @override
  Future<bool> get isActive async => _taskId != -1;
}
