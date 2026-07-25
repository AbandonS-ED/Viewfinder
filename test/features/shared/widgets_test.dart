import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/camera_workflow_state.dart';
import 'package:viewfinder/features/shared/theme_palette.dart';
import 'package:viewfinder/features/shared/viewfinder_theme.dart';
import 'package:viewfinder/features/shared/widgets/haptics.dart';
import 'package:viewfinder/features/shared/widgets/lens_glow_view.dart';
import 'package:viewfinder/features/shared/widgets/shimmer_view.dart';

void main() {
  group('Haptics', () {
    late List<MethodCall> log;

    setUp(() {
      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        log.add(call);
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('impactLight 触发 platform channel 调用', () {
      Haptics.impactLight();
      expect(log.length, 1);
      // 注：Flutter test 环境会把 light/medium/heavy/selectionClick 都映射成 vibrate
      expect(log.first.method, startsWith('HapticFeedback.'));
    });

    test('impactMedium 触发 platform channel 调用', () {
      Haptics.impactMedium();
      expect(log.length, 1);
      expect(log.first.method, startsWith('HapticFeedback.'));
    });

    test('impactHeavy 触发 platform channel 调用', () {
      Haptics.impactHeavy();
      expect(log.length, 1);
      expect(log.first.method, startsWith('HapticFeedback.'));
    });

    test('selection 触发 platform channel 调用', () {
      Haptics.selection();
      expect(log.length, 1);
      expect(log.first.method, startsWith('HapticFeedback.'));
    });

    test('vibrate 调用 HapticFeedback.vibrate', () {
      Haptics.vibrate();
      expect(log.length, 1);
      expect(log.first.method, 'HapticFeedback.vibrate');
    });

    test('notificationSuccess/Warning/Error 都触发 vibrate', () {
      Haptics.notificationSuccess();
      Haptics.notificationWarning();
      Haptics.notificationError();
      expect(log.length, 3);
      expect(log.every((c) => c.method == 'HapticFeedback.vibrate'), isTrue);
    });
  });

  group('ShimmerView', () {
    testWidgets('渲染时不抛异常', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(body: ShimmerView(width: 100, height: 20)),
        ),
      );
      await tester.pump();
      expect(find.byType(ShimmerView), findsOneWidget);
    });

    testWidgets('pumpAndSettle 后 dispose 不挂 timer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(body: ShimmerView(width: 100, height: 20)),
        ),
      );
      await tester.pump(const Duration(seconds: 3));
      // 切换到空 tree 触发 dispose
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('LensGlowView', () {
    testWidgets('waitingForWifi 状态渲染静态光圈', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(
            body: LensGlowView(state: CameraWorkflowState.waitingForWifi),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(LensGlowView), findsOneWidget);
    });

    testWidgets('connecting 状态渲染脉冲光圈（带 AnimatedBuilder）', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(
            body: LensGlowView(state: CameraWorkflowState.connecting),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byType(AnimatedBuilder), findsWidgets);
      expect(find.byType(LensGlowView), findsOneWidget);
    });

    testWidgets('connected 状态渲染相机图标（filled）', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(
            body: LensGlowView(state: CameraWorkflowState.connected),
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('所有 searching 状态都触发动画', (tester) async {
      for (final state in [
        CameraWorkflowState.connecting,
        CameraWorkflowState.loadingPhotos,
        CameraWorkflowState.downloading,
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: viewfinderTheme(amberPalette),
            home: Scaffold(body: LensGlowView(state: state)),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(AnimatedBuilder), findsWidgets,
            reason: '$state 应渲染 AnimatedBuilder');
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('dispose 不挂 timer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(
            body: LensGlowView(state: CameraWorkflowState.connecting),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}