import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:viewfinder/services/wifi_watcher.dart';

class _FakeNetworkInfo implements NetworkInfo {
  _FakeNetworkInfo({this.bssid, this.ssid});

  String? bssid;
  String? ssid;

  @override
  Future<String?> getWifiBSSID() async => bssid;

  @override
  Future<String?> getWifiIP() async => null;

  @override
  Future<String?> getWifiIPv6() async => null;

  @override
  Future<String?> getWifiSubmask() async => null;

  @override
  Future<String?> getWifiGatewayIP() async => null;

  @override
  Future<String?> getWifiName() async => ssid;

  @override
  Future<String?> getWifiBroadcast() async => null;

  @override
  Future<LocationAuthorizationStatus> getLocationServiceAuthorization() =>
      Future.value(LocationAuthorizationStatus.notDetermined);

  @override
  Future<LocationAuthorizationStatus> requestLocationServiceAuthorization({
    bool iOS17OrNewer = false,
    bool requestAlwaysLocationUsage = false,
  }) =>
      Future.value(LocationAuthorizationStatus.authorizedWhenInUse);
}

class _FakeConnectivity implements Connectivity {
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  void emit(List<ConnectivityResult> result) => _controller.add(result);

  void close() => _controller.close();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [];
}

void main() {
  group('DefaultWifiWatcher', () {
    test('初始状态 false', () {
      final watcher = DefaultWifiWatcher(
        networkInfo: _FakeNetworkInfo(bssid: null, ssid: null),
        connectivity: _FakeConnectivity(),
      );
      expect(watcher.isCameraWifiConnected, false);
      watcher.dispose();
    });

    test('BSSID 匹配 Nikon 前缀', () async {
      final networkInfo = _FakeNetworkInfo(bssid: 'Nikon_Camera_01', ssid: null);
      final watcher = DefaultWifiWatcher(
        networkInfo: networkInfo,
        connectivity: _FakeConnectivity(),
      );
      await Future<void>.delayed(Duration.zero);
      expect(watcher.isCameraWifiConnected, true);
      await watcher.dispose();
    });

    test('SSID 匹配 nikon 前缀（小写）', () async {
      final networkInfo = _FakeNetworkInfo(bssid: null, ssid: 'nikon_wifi');
      final watcher = DefaultWifiWatcher(
        networkInfo: networkInfo,
        connectivity: _FakeConnectivity(),
      );
      await Future<void>.delayed(Duration.zero);
      expect(watcher.isCameraWifiConnected, true);
      await watcher.dispose();
    });

    test('SSID 不匹配时 false', () async {
      final networkInfo = _FakeNetworkInfo(bssid: null, ssid: 'HomeWiFi');
      final watcher = DefaultWifiWatcher(
        networkInfo: networkInfo,
        connectivity: _FakeConnectivity(),
      );
      await Future<void>.delayed(Duration.zero);
      expect(watcher.isCameraWifiConnected, false);
      await watcher.dispose();
    });

    test('connectionStream 在变化时推送', () async {
      final networkInfo = _FakeNetworkInfo(bssid: null, ssid: 'HomeWiFi');
      final connectivity = _FakeConnectivity();
      final watcher = DefaultWifiWatcher(
        networkInfo: networkInfo,
        connectivity: connectivity,
      );
      await Future<void>.delayed(Duration.zero);
      expect(watcher.isCameraWifiConnected, false);

      final changes = <bool>[];
      watcher.connectionStream.listen(changes.add);

      networkInfo.ssid = 'Nikon_Z8';
      connectivity.emit([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);

      expect(changes, [true]);
      await watcher.dispose();
    });

    test('dispose 后 stream 关闭', () async {
      final watcher = DefaultWifiWatcher(
        networkInfo: _FakeNetworkInfo(bssid: null, ssid: null),
        connectivity: _FakeConnectivity(),
      );
      await watcher.dispose();
      expect(watcher.connectionStream, emitsDone);
    });
  });
}
