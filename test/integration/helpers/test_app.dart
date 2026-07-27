import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viewfinder/features/downloads/download_manager_view_model.dart';
import 'package:viewfinder/features/settings/settings_container.dart';
import 'package:viewfinder/features/settings/settings_view_model.dart';
import 'package:viewfinder/features/shared/theme_palette.dart';
import 'package:viewfinder/features/shared/viewfinder_theme.dart';
import 'package:viewfinder/services/asset_thumbnail_service.dart';
import 'package:viewfinder/services/download_store.dart';
import 'package:viewfinder/services/log_file_store.dart';

import '../../helpers/stubs.dart';

/// 构造测试应用 widget。用 stub 替换所有 platform channel 服务
Widget buildTestApp(
  Widget child, {
  List<Override> extraOverrides = const [],
  ThemePalette? palette,
}) {
  final p = palette ?? amberPalette;
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(_sp),
      logFileStoreProvider.overrideWithValue(_logStore),
      downloadStoreProvider.overrideWithValue(_downloadStore),
      notificationServiceProvider.overrideWithValue(StubNotificationService()),
      backgroundRunnerProvider.overrideWithValue(StubBackgroundRunner()),
      photoLibraryChannelProvider.overrideWithValue(StubPhotoLibraryChannel()),
      assetThumbnailServiceProvider.overrideWithValue(AssetThumbnailService()),
      ...extraOverrides,
    ],
    child: MaterialApp(theme: viewfinderTheme(p), home: child),
  );
}

/// 在 widget test 中初始化全局 SharedPreferences + temp dir + stub services.
/// 用法：setUp(...) async { await initTestEnv(); }
late SharedPreferences _sp;
late FileLogStore _logStore;
late DownloadStore _downloadStore;

Future<void> initTestEnv() async {
  SharedPreferences.setMockInitialValues({});
  _sp = await SharedPreferences.getInstance();
  final tempDir =
      Directory.systemTemp.createTempSync('phase4c_test_${DateTime.now().millisecondsSinceEpoch}_');
  _logStore = FileLogStore(rootDirectory: tempDir);
  _downloadStore = DownloadStore(rootDirectory: tempDir);
}

SharedPreferences get testSharedPreferences => _sp;
FileLogStore get testLogStore => _logStore;
DownloadStore get testDownloadStore => _downloadStore;

/// cleanup test env
void tearDownTestEnv() {
  // Delete temp dir lazily in next run
}