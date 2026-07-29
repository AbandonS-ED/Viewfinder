import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/camera_app_error.dart';
import 'package:viewfinder/domain/camera_session.dart';
import 'package:viewfinder/features/connection_setup/connection_container.dart';
import 'package:viewfinder/features/connection_setup/connection_view_model.dart';

import '../helpers/fake_camera_transport.dart';
import 'helpers/test_app.dart';

/// T3 真机集成测试在 Windows 上不可跑（需 macOS 权限 + raw socket），
/// 所以这里用 [`FakeCameraTransportFactory`] 走 provider override 路径，
/// 验证 **app ↔ transport 集成** 的全链路：
/// 1. `ConnectionContainer` 渲染 + 默认 host/port（preferencesProvider default）
/// 2. 用户点「连接相机」→ notifier.connect() → workflow 转 connected
/// 3. 显示相机名 + 「断开连接」按钮
/// 4. 错误路径：transport 抛 [CameraAppError.notConnected] → 显示错误信息
///
/// 注：ConnectionPage 含 LensGlowView 无限脉冲动画（1.4s repeat reverse），
///   不能用 [WidgetTester.pumpAndSettle]（会超时），改用 [WidgetTester.pump]
///   + 显式 duration 推进 future。
///
/// 端到端 raw socket 版本在 `test/integration/fake_nikon_server.dart`
/// 标注，等用户拿到 Mac + Nikon 真机后再补。
void main() {
  setUp(() async {
    await initTestEnv();
  });

  /// 等 notifier.connect() 这种 single-frame 后异步 complete 的 future 处理
  Future<void> settleAsync(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 200));
  }

  group('T3 假相机连接 (FakeCameraTransport 注入)', () {
    testWidgets('happy path: 点连接 → workflow 切到 connected，显示相机名',
        (tester) async {
      final session = CameraSession(
        id: 'fake-session-1',
        cameraName: 'Nikon Fake Z8',
        connectedAt: DateTime(2026, 7, 27, 10, 0),
      );
      final fakeTransport = FakeCameraTransport(sessionToReturn: session);

      await tester.pumpWidget(
        buildTestApp(
          const ConnectionContainer(),
          extraOverrides: [
            transportFactoryProvider.overrideWithValue(
              FakeCameraTransportFactory(fakeTransport: fakeTransport),
            ),
          ],
        ),
      );

      // 初始：等待 Wi-Fi 状态 + 「连接相机」按钮
      expect(find.text('连接相机'), findsOneWidget);
      expect(find.text('Nikon Fake Z8'), findsNothing);
      expect(find.text('断开连接'), findsNothing);

      // 触发连接
      await tester.tap(find.text('连接相机'));
      await settleAsync(tester);

      // 已连接：显示相机名 + 断开按钮（连接相机按钮消失）
      expect(find.text('Nikon Fake Z8'), findsOneWidget);
      expect(find.text('断开连接'), findsOneWidget);
      expect(find.text('连接相机'), findsNothing);
      // lastSummary 形如 "已连接到 Nikon Fake Z8"
      expect(find.textContaining('已连接到'), findsOneWidget);
    });

    testWidgets('error path: FakeTransport 抛 notConnected → 显示错误信息',
        (tester) async {
      final fakeTransport = FakeCameraTransport(
        errorToThrow: const CameraAppError.notConnected(),
      );

      await tester.pumpWidget(
        buildTestApp(
          const ConnectionContainer(),
          extraOverrides: [
            transportFactoryProvider.overrideWithValue(
              FakeCameraTransportFactory(fakeTransport: fakeTransport),
            ),
          ],
        ),
      );

      expect(find.text('连接相机'), findsOneWidget);

      await tester.tap(find.text('连接相机'));
      await settleAsync(tester);

      // 错误信息应可见（lastSummary = CameraAppError.notConnected().message）
      expect(find.text('当前没有可用的相机会话。'), findsOneWidget);
      // 应仍是「连接相机」按钮（不是断开按钮）
      expect(find.text('连接相机'), findsOneWidget);
      expect(find.text('断开连接'), findsNothing);
    });
  });
}
