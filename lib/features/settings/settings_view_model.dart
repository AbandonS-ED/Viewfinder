import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/camera_connection_config.dart';
import '../../domain/camera_transport_mode.dart';
import '../../services/preferences_store.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('override in main.dart');
});

final preferencesStoreProvider = Provider<AppPreferencesStore>((ref) {
  return AppPreferencesStore(sharedPreferences: ref.watch(sharedPreferencesProvider));
});

final preferencesProvider = NotifierProvider<PreferencesNotifier, CameraConnectionConfig>(
  PreferencesNotifier.new,
);

class PreferencesNotifier extends Notifier<CameraConnectionConfig> {
  @override
  CameraConnectionConfig build() {
    final store = ref.watch(preferencesStoreProvider);
    return store.loadConnectionConfig();
  }

  void setHost(String host) {
    state = state.copyWith(host: host);
    unawaited(_save());
  }

  void setPort(int port) {
    state = state.copyWith(port: port);
    unawaited(_save());
  }

  void setTransportMode(CameraTransportMode mode) {
    state = state.copyWith(transportMode: mode);
    unawaited(_save());
  }

  void setAutoExportToPhotoLibrary(bool value) {
    state = state.copyWith(autoExportToPhotoLibrary: value);
    unawaited(_save());
  }

  void setPrioritizeJPEGDownloads(bool value) {
    state = state.copyWith(prioritizeJPEGDownloads: value);
    unawaited(_save());
  }

  Future<void> _save() async {
    final store = ref.read(preferencesStoreProvider);
    await store.saveConnectionConfig(state);
  }
}
