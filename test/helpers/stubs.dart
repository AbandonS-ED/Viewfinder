import 'package:viewfinder/platform/photo_library_channel.dart';
import 'package:viewfinder/services/background_download_runner.dart';
import 'package:viewfinder/services/download_notification_service.dart';

/// 测试用 NotificationService stub
class StubNotificationService implements DownloadNotificationService {
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

/// 测试用 BackgroundRunner stub
class StubBackgroundRunner implements BackgroundDownloadRunner {
  @override
  Future<void> begin({required String name, void Function()? onExpiration}) async {}

  @override
  Future<void> end() async {}

  @override
  Future<bool> get isActive async => false;
}

/// 测试用 PhotoLibraryChannel stub
class StubPhotoLibraryChannel implements PhotoLibraryChannel {
  @override
  Future<PhotoLibraryPermission> requestPermission() async => PhotoLibraryPermission.granted;

  @override
  Future<void> exportFile({required String filePath}) async {}
}