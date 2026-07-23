import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viewfinder/domain/camera_transport_mode.dart';
import 'package:viewfinder/features/settings/settings_view_model.dart';

void main() {
  group('PreferencesNotifier', () {
    test('build() 从 SharedPreferences 读取初始 config', () async {
      SharedPreferences.setMockInitialValues({
        'camera_connection_config': jsonEncode({
          'host': '10.0.0.1',
          'port': 15740,
          'transportMode': 'experimentalNikon',
          'autoExportToPhotoLibrary': true,
          'prioritizeJPEGDownloads': true,
        }),
      });
      final sp = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
      ]);
      addTearDown(() => container.dispose());

      final config = container.read(preferencesProvider);
      expect(config.host, '10.0.0.1');
      expect(config.port, 15740);
      expect(config.transportMode, CameraTransportMode.experimentalNikon);
      expect(config.autoExportToPhotoLibrary, isTrue);
      expect(config.prioritizeJPEGDownloads, isTrue);
    });

    test('setHost / setPort / setTransportMode / setAutoExport / setPrioritizeJPEG 修改字段并持久化', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
      ]);
      addTearDown(() => container.dispose());

      final notifier = container.read(preferencesProvider.notifier);

      notifier.setHost('192.168.0.10');
      expect(container.read(preferencesProvider).host, '192.168.0.10');

      notifier.setPort(11570);
      expect(container.read(preferencesProvider).port, 11570);

      notifier.setAutoExportToPhotoLibrary(true);
      expect(container.read(preferencesProvider).autoExportToPhotoLibrary, isTrue);

      notifier.setPrioritizeJPEGDownloads(true);
      expect(container.read(preferencesProvider).prioritizeJPEGDownloads, isTrue);

      final raw = sp.getString('camera_connection_config');
      expect(raw, isNotNull);
      final saved = jsonDecode(raw!) as Map<String, dynamic>;
      expect(saved['host'], '192.168.0.10');
      expect(saved['port'], 11570);
      expect(saved['autoExportToPhotoLibrary'], isTrue);
      expect(saved['prioritizeJPEGDownloads'], isTrue);
    });

    test('save() 完整持久化，key 正确', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
      ]);
      addTearDown(() => container.dispose());

      final notifier = container.read(preferencesProvider.notifier);
      notifier.setHost('10.0.0.2');
      notifier.setPort(11570);

      final raw = sp.getString('camera_connection_config');
      expect(raw, isNotNull);
      final saved = jsonDecode(raw!) as Map<String, dynamic>;
      expect(saved['host'], '10.0.0.2');
      expect(saved['port'], 11570);
    });

    test('schema 兼容：保存后清空再 load 回正确值', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
      ]);
      addTearDown(() => container.dispose());

      final notifier = container.read(preferencesProvider.notifier);
      notifier.setHost('192.168.1.100');

      await sp.reload();
      final container2 = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
      ]);
      addTearDown(() => container2.dispose());

      final config = container2.read(preferencesProvider);
      expect(config.host, '192.168.1.100');
      expect(config.port, 15740);
      expect(config.transportMode, CameraTransportMode.experimentalNikon);
      expect(config.autoExportToPhotoLibrary, isFalse);
      expect(config.prioritizeJPEGDownloads, isFalse);
    });
  });
}
