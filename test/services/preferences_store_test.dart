import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viewfinder/domain/camera_connection_config.dart';
import 'package:viewfinder/domain/camera_transport_mode.dart';
import 'package:viewfinder/services/preferences_store.dart';

void main() {
  group('AppPreferencesStore.loadConnectionConfig', () {
    test('SharedPreferences 为空时返回 const default', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final store = AppPreferencesStore(sharedPreferences: sp);

      final config = store.loadConnectionConfig();
      expect(config.host, '192.168.1.1');
      expect(config.port, 15740);
      expect(config.transportMode, CameraTransportMode.experimentalNikon);
      expect(config.autoExportToPhotoLibrary, isFalse);
      expect(config.prioritizeJPEGDownloads, isFalse);
    });

    test('完整 JSON round-trip：保存后再 load 回一致', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final store = AppPreferencesStore(sharedPreferences: sp);

      const original = CameraConnectionConfig(
        host: '10.0.0.42',
        port: 11570,
        transportMode: CameraTransportMode.experimentalNikon,
        autoExportToPhotoLibrary: true,
        prioritizeJPEGDownloads: true,
      );
      await store.saveConnectionConfig(original);
      final loaded = store.loadConnectionConfig();
      expect(loaded.host, '10.0.0.42');
      expect(loaded.port, 11570);
      expect(loaded.autoExportToPhotoLibrary, isTrue);
      expect(loaded.prioritizeJPEGDownloads, isTrue);
    });

    test('schema 兼容：缺失字段走 default 值', () async {
      SharedPreferences.setMockInitialValues({
        'camera_connection_config': jsonEncode({'host': '10.0.0.99'}),
      });
      final sp = await SharedPreferences.getInstance();
      final store = AppPreferencesStore(sharedPreferences: sp);

      final config = store.loadConnectionConfig();
      expect(config.host, '10.0.0.99');
      expect(config.port, 15740);
      expect(config.transportMode, CameraTransportMode.experimentalNikon);
      expect(config.autoExportToPhotoLibrary, isFalse);
    });

    test('error path：JSON 损坏时不抛，返回 default', () async {
      SharedPreferences.setMockInitialValues({
        'camera_connection_config': '{not valid json',
      });
      final sp = await SharedPreferences.getInstance();
      final store = AppPreferencesStore(sharedPreferences: sp);

      final config = store.loadConnectionConfig();
      expect(config.host, '192.168.1.1');
      expect(config.port, 15740);
    });
  });

  group('AppPreferencesStore.saveConnectionConfig', () {
    test('保存后 key 为 camera_connection_config', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final store = AppPreferencesStore(sharedPreferences: sp);
      const config = CameraConnectionConfig(host: '1.2.3.4', port: 15740);

      await store.saveConnectionConfig(config);
      final raw = sp.getString('camera_connection_config');
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded['host'], '1.2.3.4');
      expect(decoded['port'], 15740);
    });
  });
}
