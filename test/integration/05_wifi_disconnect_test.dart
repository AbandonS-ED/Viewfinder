import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/camera_session.dart';
import 'package:viewfinder/domain/download_queue_state.dart';
import 'package:viewfinder/features/connection_setup/connection_view_model.dart';
import 'package:viewfinder/features/downloads/download_manager_view_model.dart';

import 'helpers/test_app.dart';

/// T5 Wi-Fi 断线 → 下载队列自动暂停 真集成测试（最小切片）：
///
/// app.dart L91-105 完整流程：
/// `ref.listen(connectionProvider.select(activeSession), (prev, next) {
///   if (wasConnected && !isConnected) pauseQueue()
/// })`
///
/// 这里不直接 pump ViewfinderApp（依赖复杂 service 初始化），
/// 而是用 [_WifiDisconnectListener] widget 复刻这段 listen 逻辑，
/// 验证 ref.listen 触发 pauseQueue 的完整链路。
///
/// 完整 ViewfinderApp 端到端 + 真 Wi-Fi 断开验证待 Mac + iPhone 真机。
class _WifiDisconnectListener extends ConsumerWidget {
  const _WifiDisconnectListener({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(connectionProvider.select((s) => s.activeSession),
        (prev, next) {
      final wasConnected = prev != null;
      final isConnected = next != null;
      if (wasConnected && !isConnected) {
        if (ref.read(downloadManagerProvider).status ==
            DownloadQueueStatus.running) {
          ref.read(downloadManagerProvider.notifier).pauseQueue();
        }
      }
    });
    return child;
  }
}

void main() {
  setUp(() async {
    await initTestEnv();
  });

  Future<void> pumpOnce(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('T5 Wi-Fi 断线 → 下载队列暂停', () {
    testWidgets('listener: activeSession 从 non-null → null 触发 pauseQueue',
        (tester) async {
      // Arrange: pump listener wrapper
      await tester.pumpWidget(
        buildTestApp(
          const _WifiDisconnectListener(child: Scaffold(body: SizedBox())),
        ),
      );
      await pumpOnce(tester);

      final BuildContext ctx = tester.element(find.byType(Scaffold));
      final ProviderContainer container =
          ProviderScope.containerOf(ctx, listen: false);

      // 初始: queue idle + activeSession null
      expect(container.read(downloadManagerProvider).status,
          DownloadQueueStatus.idle);
      expect(container.read(connectionProvider).activeSession, isNull);

      // Act 1: 模拟 session 已建立（直接设 ConnectionState.activeSession）
      final session = CameraSession(
        id: 'test-session',
        cameraName: 'Nikon Test',
        connectedAt: DateTime(2026, 7, 27),
      );
      container.read(connectionProvider.notifier).state =
          container.read(connectionProvider).copyWith(activeSession: session);
      await pumpOnce(tester);
      expect(container.read(connectionProvider).activeSession, isNotNull);

      // Act 2: 手动把 queue status 设成 running（模拟 _runQueue 启动）
      container.read(downloadManagerProvider.notifier).state =
          container.read(downloadManagerProvider).copyWith(
        status: DownloadQueueStatus.running,
      );
      await pumpOnce(tester);
      expect(container.read(downloadManagerProvider).status,
          DownloadQueueStatus.running);

      // Act 3: 模拟 session 断开 → activeSession 变 null
      container.read(connectionProvider.notifier).state =
          container.read(connectionProvider).copyWith(activeSession: null);
      await pumpOnce(tester);

      // Assert: listener 触发 pauseQueue
      expect(container.read(connectionProvider).activeSession, isNull);
      expect(container.read(downloadManagerProvider).status,
          DownloadQueueStatus.paused,
          reason: 'activeSession 从非空变 null 后，listener 应触发 pauseQueue');
    });

    testWidgets('listener: activeSession 一直是 null → 不触发 pauseQueue',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const _WifiDisconnectListener(child: Scaffold(body: SizedBox())),
        ),
      );
      await pumpOnce(tester);

      final BuildContext ctx = tester.element(find.byType(Scaffold));
      final ProviderContainer container =
          ProviderScope.containerOf(ctx, listen: false);

      // 初始 activeSession = null，queue idle
      expect(container.read(downloadManagerProvider).status,
          DownloadQueueStatus.idle);

      // 直接 disconnect（activeSession 本来就 null）
      await container.read(connectionProvider.notifier).disconnect();
      await pumpOnce(tester);

      // queue 仍 idle（listener 的 wasConnected 检查会跳过）
      expect(container.read(downloadManagerProvider).status,
          DownloadQueueStatus.idle,
          reason: 'wasConnected=false 应跳过 pauseQueue');
    });
  });
}