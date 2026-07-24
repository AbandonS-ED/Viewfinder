import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';

/// Phase 3 §9. 热点检测服务。BSSID 优先，SSID fallback。
abstract class WifiWatcher {
  bool get isCameraWifiConnected;
  Stream<bool> get connectionStream;
  Future<void> dispose();
}

/// BSSID + SSID 双层匹配的默认实现。
class DefaultWifiWatcher implements WifiWatcher {
  DefaultWifiWatcher({
    NetworkInfo? networkInfo,
    Connectivity? connectivity,
  })  : _networkInfo = networkInfo ?? NetworkInfo(),
        _connectivity = connectivity ?? Connectivity() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (_) => _refresh(),
      onError: (_) {},
    );
    _refresh();
  }

  final NetworkInfo _networkInfo;
  final Connectivity _connectivity;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isCameraWifi = false;

  @override
  bool get isCameraWifiConnected => _isCameraWifi;

  @override
  Stream<bool> get connectionStream => _controller.stream;

  Future<void> _refresh() async {
    try {
      final bssid = await _networkInfo.getWifiBSSID();
      if (_matchesNikonPattern(bssid)) {
        _setConnected(true);
        return;
      }
      final ssid = await _networkInfo.getWifiName();
      _setConnected(_matchesNikonPattern(ssid));
    } catch (_) {
      _setConnected(false);
    }
  }

  bool _matchesNikonPattern(String? s) {
    if (s == null) return false;
    return s.contains('Nikon') || s.contains('nikon') || s.contains('NIKON');
  }

  void _setConnected(bool v) {
    if (_isCameraWifi == v) return;
    _isCameraWifi = v;
    _controller.add(v);
  }

  /// 测试专用：手动注入当前值（绕过平台 API），方便单元测试不依赖真实 Wi-Fi。
  @visibleForTesting
  void debugSetConnected(bool v) => _setConnected(v);

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}

/// Riverpod 反应式 Provider：把 `connectionStream` 转成 `NotifierProvider<bool>`，
/// 让 `ref.listen` 在内部 `_setConnected` 翻转时真正触发。
/// Phase 3 §9.4 + §16 验收 4 行: "Wi-Fi 已断开 → 队列自动暂停"。
class CameraWifiConnectionNotifier extends Notifier<bool> {
  late final WifiWatcher _watcher;

  @override
  bool build() {
    _watcher = ref.watch(wifiWatcherProvider);
    final sub = _watcher.connectionStream.listen((v) => state = v);
    ref.onDispose(sub.cancel);
    return _watcher.isCameraWifiConnected;
  }
}

final wifiWatcherProvider = Provider<WifiWatcher>((ref) {
  final watcher = DefaultWifiWatcher();
  ref.onDispose(watcher.dispose);
  return watcher;
});

final cameraWifiConnectedProvider =
    NotifierProvider<CameraWifiConnectionNotifier, bool>(
  CameraWifiConnectionNotifier.new,
);