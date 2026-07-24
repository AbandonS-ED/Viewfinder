import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/downloads/download_manager_view_model.dart';
import 'features/settings/settings_container.dart';
import 'features/settings/settings_view_model.dart';
import 'platform/photo_library_channel.dart';
import 'services/asset_thumbnail_service.dart';
import 'services/background_download_runner.dart';
import 'services/download_notification_service.dart';
import 'services/download_store.dart';
import 'services/log_file_store.dart';
import 'services/logger.dart' as log_util;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;

  final sp = await SharedPreferences.getInstance();
  final appDir = await getApplicationDocumentsDirectory();
  final logStore = FileLogStore(rootDirectory: appDir);
  final downloadStore = DownloadStore(rootDirectory: appDir);

  log_util.setupLogging(logStore);

  final notificationService = FlutterDownloadNotificationService(
    plugin: _createNotificationsPlugin(),
  );

  unawaited(_requestRuntimePermissions(notificationService));

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        logFileStoreProvider.overrideWithValue(logStore),
        downloadStoreProvider.overrideWithValue(downloadStore),
        notificationServiceProvider.overrideWithValue(notificationService),
        backgroundRunnerProvider.overrideWithValue(
          AndroidBackgroundDownloadRunner(),
        ),
        photoLibraryChannelProvider.overrideWithValue(
          PhotoLibraryChannel(),
        ),
        assetThumbnailServiceProvider.overrideWithValue(
          AssetThumbnailService(),
        ),
      ],
      child: const ViewfinderApp(),
    ),
  );
}

FlutterLocalNotificationsPlugin _createNotificationsPlugin() {
  final plugin = FlutterLocalNotificationsPlugin();
  plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: false,
        requestSoundPermission: true,
      ),
    ),
    onDidReceiveNotificationResponse: (response) {
      // deepLink payload
    },
  );
  return plugin;
}

Future<void> _requestRuntimePermissions(
  DownloadNotificationService notificationService,
) async {
  if (!Platform.isAndroid) {
    return;
  }
  final notification = await Permission.notification.request();
  if (!notification.isGranted) {
    log_util.appLogger.warning('通知权限被拒绝，进度通知将不会显示。');
  }
  final location = await Permission.locationWhenInUse.request();
  if (!location.isGranted) {
    log_util.appLogger.warning('位置权限被拒绝，Wi-Fi SSID 检测将退化为低精度模式。');
  }
}
