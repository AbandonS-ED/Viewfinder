import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:viewfinder/app.dart';
import 'package:viewfinder/features/downloads/download_manager_view_model.dart';
import 'package:viewfinder/features/settings/settings_container.dart';
import 'package:viewfinder/features/settings/settings_view_model.dart';
import 'package:viewfinder/platform/photo_library_channel.dart';
import 'package:viewfinder/services/asset_thumbnail_service.dart';
import 'package:viewfinder/services/background_download_runner.dart';
import 'package:viewfinder/services/download_notification_service.dart';
import 'package:viewfinder/services/download_store.dart';
import 'package:viewfinder/services/log_file_store.dart';

void main() {
  testWidgets('App 启动 smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final tempDir = Directory.systemTemp.createTempSync('widget_test_');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final logStore = FileLogStore(rootDirectory: tempDir);
    final downloadStore = DownloadStore(rootDirectory: tempDir);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sp),
          logFileStoreProvider.overrideWithValue(logStore),
          downloadStoreProvider.overrideWithValue(downloadStore),
          notificationServiceProvider.overrideWithValue(
            _StubNotificationService(),
          ),
          backgroundRunnerProvider.overrideWithValue(
            _StubBackgroundRunner(),
          ),
          photoLibraryChannelProvider.overrideWithValue(
            _StubPhotoLibraryChannel(),
          ),
          assetThumbnailServiceProvider.overrideWithValue(
            AssetThumbnailService(),
          ),
        ],
        child: const ViewfinderApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

class _StubNotificationService implements DownloadNotificationService {
  @override
  Future<void> show({
    required int notificationId,
    required String title,
    required String body,
    int progress = -1,
    String? channelId,
    String? categoryId,
    String? payload,
  }) async {}

  @override
  Future<void> update({
    required int notificationId,
    String? title,
    String? body,
    int? progress,
  }) async {}

  @override
  Future<void> cancel({required int notificationId}) async {}

  @override
  Future<void> cancelAll() async {}
}

class _StubBackgroundRunner implements BackgroundDownloadRunner {
  @override
  Future<void> begin({required String name, void Function()? onExpiration}) async {}

  @override
  Future<void> end() async {}

  @override
  Future<bool> get isActive async => false;
}

class _StubPhotoLibraryChannel implements PhotoLibraryChannel {
  @override
  Future<PhotoLibraryPermission> requestPermission() async => PhotoLibraryPermission.granted;

  @override
  Future<void> exportFile({required String filePath}) async {}
}
