import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/services/download_notification_service.dart';

class _FakeNotificationService implements DownloadNotificationService {
  final shown = <int>{};
  final updates = <int, int>{};
  final cancelled = <int>{};
  bool allCancelled = false;

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
    shown.add(notificationId);
    if (progress >= 0) updates[notificationId] = progress;
  }

  @override
  Future<void> update({
    required int notificationId,
    String? title,
    String? body,
    int? progress,
  }) async {
    if (progress != null) updates[notificationId] = progress;
  }

  @override
  Future<void> cancel({required int notificationId}) async {
    cancelled.add(notificationId);
    updates.remove(notificationId);
  }

  @override
  Future<void> cancelAll() async {
    allCancelled = true;
    shown.clear();
    updates.clear();
    cancelled.clear();
  }
}

void main() {
  group('DownloadNotificationService 接口', () {
    late _FakeNotificationService service;

    setUp(() {
      service = _FakeNotificationService();
    });

    test('show(progress: 50) 创建进度通知', () async {
      await service.show(
        notificationId: 1,
        title: '下载中',
        body: 'DSC_001.JPG',
        progress: 50,
      );
      expect(service.shown, {1});
      expect(service.updates[1], 50);
    });

    test('update(progress: 80) 更新进度', () async {
      await service.show(
        notificationId: 2,
        title: '下载中',
        body: 'DSC_002.NEF',
        progress: 30,
      );
      await service.update(
        notificationId: 2,
        progress: 80,
      );
      expect(service.updates[2], 80);
    });

    test('cancel 取消单个通知', () async {
      await service.show(notificationId: 3, title: 't', body: 'b');
      await service.cancel(notificationId: 3);
      expect(service.cancelled, {3});
      expect(service.updates.containsKey(3), isFalse);
    });

    test('cancelAll 批量清空', () async {
      await service.show(notificationId: 4, title: 't', body: 'b');
      await service.show(notificationId: 5, title: 't', body: 'b');
      await service.cancelAll();
      expect(service.allCancelled, isTrue);
      expect(service.shown, isEmpty);
      expect(service.updates, isEmpty);
    });
  });
}
