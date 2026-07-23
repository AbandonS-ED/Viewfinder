import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/camera_connection_config.dart';
import '../domain/camera_transport_mode.dart';

class AppPreferencesStore {
  AppPreferencesStore({required this._sharedPreferences});

  final SharedPreferences _sharedPreferences;
  static const _configKey = 'camera_connection_config';

  CameraConnectionConfig loadConnectionConfig() {
    final raw = _sharedPreferences.getString(_configKey);
    if (raw == null) return const CameraConnectionConfig();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return CameraConnectionConfig(
        host: (json['host'] as String?) ?? '192.168.1.1',
        port: (json['port'] as int?) ?? 15740,
        transportMode: switch (json['transportMode'] as String?) {
          'experimentalNikon' => CameraTransportMode.experimentalNikon,
          _ => CameraTransportMode.experimentalNikon,
        },
        autoExportToPhotoLibrary:
            (json['autoExportToPhotoLibrary'] as bool?) ?? false,
        prioritizeJPEGDownloads:
            (json['prioritizeJPEGDownloads'] as bool?) ?? false,
      );
    } catch (_) {
      return const CameraConnectionConfig();
    }
  }

  Future<void> saveConnectionConfig(CameraConnectionConfig config) async {
    final json = {
      'host': config.host,
      'port': config.port,
      'transportMode': config.transportMode.name,
      'autoExportToPhotoLibrary': config.autoExportToPhotoLibrary,
      'prioritizeJPEGDownloads': config.prioritizeJPEGDownloads,
    };
    await _sharedPreferences.setString(_configKey, jsonEncode(json));
  }
}
