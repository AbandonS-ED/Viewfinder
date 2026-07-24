import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class DownloadNotificationService {
  Future<void> show({
    required int notificationId,
    required String title,
    required String body,
    int progress = -1,
    String? channelId,
    String? categoryId,
    String? payload,
  });
  Future<void> update({
    required int notificationId,
    String? title,
    String? body,
    int? progress,
  });
  Future<void> cancel({required int notificationId});
  Future<void> cancelAll();
}

class FlutterDownloadNotificationService implements DownloadNotificationService {
  FlutterDownloadNotificationService({
    required this._plugin,
  });

  final FlutterLocalNotificationsPlugin _plugin;
  final Map<int, String> _titles = {};
  final Map<int, String> _bodies = {};
  final Map<int, int> _progresses = {};

  static const _channelId = 'download_progress';

  @override
  Future<void> show({
    required int notificationId,
    required String title,
    required String body,
    int progress = -1,
    String? channelId,
    String? categoryId,
    String? payload,
  }) async {
    _titles[notificationId] = title;
    _bodies[notificationId] = body;
    _progresses[notificationId] = progress;

    final androidDetails = AndroidNotificationDetails(
      channelId ?? _channelId,
      '下载进度',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: progress >= 0,
      maxProgress: progress >= 0 ? 100 : 0,
      progress: progress >= 0 ? progress : 0,
    );
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
      categoryIdentifier: categoryId,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(notificationId, title, body, details, payload: payload);
  }

  @override
  Future<void> update({
    required int notificationId,
    String? title,
    String? body,
    int? progress,
  }) async {
    final t = title ?? _titles[notificationId] ?? '';
    final b = body ?? _bodies[notificationId] ?? '';
    final p = progress ?? _progresses[notificationId] ?? -1;

    _titles[notificationId] = t;
    _bodies[notificationId] = b;
    _progresses[notificationId] = p;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      '下载进度',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: p >= 0,
      maxProgress: p >= 0 ? 100 : 0,
      progress: p >= 0 ? p : 0,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(notificationId, t, b, details, payload: null);
  }

  @override
  Future<void> cancel({required int notificationId}) async {
    _titles.remove(notificationId);
    _bodies.remove(notificationId);
    _progresses.remove(notificationId);
    await _plugin.cancel(notificationId);
  }

  @override
  Future<void> cancelAll() async {
    _titles.clear();
    _bodies.clear();
    _progresses.clear();
    await _plugin.cancelAll();
  }
}
