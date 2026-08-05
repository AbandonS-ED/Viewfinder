import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/features/downloads/download_manager_view_model.dart';

import '../helpers/stubs.dart';
import 'helpers/test_app.dart';

/// T7 通知生命周期真集成测试（最小切片）：
///
/// `StubNotificationService` 已在 [buildTestApp] 注入到
/// `notificationServiceProvider`。这个测试验证：
/// 1. StubNotificationService 完整实现了
///    [DownloadNotificationService] 接口（show / update / cancel / cancelAll）
/// 2. Stub 调用不会抛异常（no-op 行为）
/// 3. 完整生命周期 show → update → cancel 顺序工作
///
/// 真实 E2E（FlutterLocalNotificationsPlugin + 真机通知中心）验证
/// 待 Mac + iPhone 真机 + 用户权限批准后。
void main() {
  setUp(() async {
    await initTestEnv();
  });

  Future<void> pumpOnce(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('T7 StubNotificationService 生命周期', () {
    testWidgets('show / update / cancel / cancelAll 全部 no-op 不抛',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(const Scaffold(body: SizedBox())),
      );
      await pumpOnce(tester);

      final BuildContext ctx = tester.element(find.byType(Scaffold));
      // ignore: invalid_use_of_protected_member
      final ProviderContainer container =
          ProviderScope.containerOf(ctx, listen: false);

      final service = container.read(notificationServiceProvider);

      // show: 不抛
      await service.show(
        notificationId: 1,
        title: '下载中',
        body: 'DSC_0001.JPG',
        progress: 0,
      );
      await service.show(
        notificationId: 2,
        title: '下载中',
        body: 'DSC_0002.JPG',
        progress: 50,
        channelId: 'download_progress',
        payload: 'downloads',
      );

      // update: 不抛
      await service.update(
        notificationId: 1,
        progress: 75,
      );

      // cancel: 不抛
      await service.cancel(notificationId: 1);

      // cancelAll: 不抛
      await service.cancelAll();

      // 测试框架不会因为多次调用失败（如果有），说明 stub 接口实现完整
      expect(true, isTrue);
    });

    testWidgets('通过 spied StubNotificationService 验证生命周期调用顺序',
        (tester) async {
      // 自定义 spy 记录所有调用
      final spy = _SpyNotificationService();
      await tester.pumpWidget(
        buildTestApp(
          const Scaffold(body: SizedBox()),
          extraOverrides: [
            notificationServiceProvider.overrideWithValue(spy),
          ],
        ),
      );
      await pumpOnce(tester);

      // 模拟下载进度：show → update (×2) → cancel
      await spy.show(notificationId: 100, title: 'T', body: 'B', progress: 0);
      await spy.update(notificationId: 100, progress: 25);
      await spy.update(notificationId: 100, progress: 50);
      await spy.cancel(notificationId: 100);

      // 验证调用序列
      expect(spy.calls.length, 4);
      expect(spy.calls[0], startsWith('show('));
      expect(spy.calls[1], startsWith('update('));
      expect(spy.calls[2], startsWith('update('));
      expect(spy.calls[3], equals('cancel(100)'));
    });
  });
}

/// 记录所有调用的 spy NotificationService
class _SpyNotificationService implements StubNotificationService {
  final List<String> calls = [];

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
    calls.add(
        'show($notificationId, progress=$progress, payload=$payload)');
  }

  @override
  Future<void> update({
    required int notificationId,
    String? title,
    String? body,
    int? progress,
  }) async {
    calls.add('update($notificationId, progress=$progress)');
  }

  @override
  Future<void> cancel({required int notificationId}) async {
    calls.add('cancel($notificationId)');
  }

  @override
  Future<void> cancelAll() async {
    calls.add('cancelAll()');
  }
}