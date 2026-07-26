import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/camera_workflow_state.dart';
import 'package:viewfinder/features/connection_setup/hero_title.dart';
import 'package:viewfinder/features/shared/theme_palette.dart';
import 'package:viewfinder/features/shared/viewfinder_theme.dart';

void main() {
  group('HeroTitleStateMachine.titleFor', () {
    test('waitingForWifi + brandIndex 0 返 Viewfinder', () {
      expect(
        HeroTitleStateMachine.titleFor(CameraWorkflowState.waitingForWifi),
        'Viewfinder',
      );
    });

    test('waitingForWifi + brandIndex 1/2 循环 3 个 brand 文本', () {
      expect(
        HeroTitleStateMachine.titleFor(
          CameraWorkflowState.waitingForWifi,
          brandIndex: 0,
        ),
        'Viewfinder',
      );
      expect(
        HeroTitleStateMachine.titleFor(
          CameraWorkflowState.waitingForWifi,
          brandIndex: 1,
        ),
        '取景器',
      );
      expect(
        HeroTitleStateMachine.titleFor(
          CameraWorkflowState.waitingForWifi,
          brandIndex: 2,
        ),
        '为 Nikon 而生',
      );
    });

    test('brandIndex 越界时取模', () {
      expect(
        HeroTitleStateMachine.titleFor(
          CameraWorkflowState.waitingForWifi,
          brandIndex: 3,
        ),
        'Viewfinder',
      );
      expect(
        HeroTitleStateMachine.titleFor(
          CameraWorkflowState.waitingForWifi,
          brandIndex: 4,
        ),
        '取景器',
      );
      expect(
        HeroTitleStateMachine.titleFor(
          CameraWorkflowState.waitingForWifi,
          brandIndex: 99,
        ),
        'Viewfinder',
      );
    });

    test('connecting 返 "搜索相机…"', () {
      expect(
        HeroTitleStateMachine.titleFor(CameraWorkflowState.connecting),
        '搜索相机…',
      );
    });

    test('connected 返 "已连接"', () {
      expect(
        HeroTitleStateMachine.titleFor(CameraWorkflowState.connected),
        '已连接',
      );
    });

    test('非 waitingForWifi 状态忽略 brandIndex', () {
      expect(
        HeroTitleStateMachine.titleFor(
          CameraWorkflowState.connecting,
          brandIndex: 2,
        ),
        '搜索相机…',
      );
    });

    test('6 个 state 都有自己的 title（不重复）', () {
      final titles = CameraWorkflowState.values
          .map((s) => HeroTitleStateMachine.titleFor(s))
          .toSet();
      expect(titles.length, 6, reason: '6 个 state 应各自返回不同 title');
    });
  });

  group('HeroTitleStateMachine.subtitleFor', () {
    test('6 个 state 都有自己的 subtitle', () {
      final subs = CameraWorkflowState.values
          .map(HeroTitleStateMachine.subtitleFor)
          .toSet();
      expect(subs.length, 6);
    });
  });

  group('HeroTitle widget', () {
    testWidgets('waitingForWifi 初始显示 Viewfinder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(
            body: HeroTitle(state: CameraWorkflowState.waitingForWifi),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Viewfinder'), findsOneWidget);
      expect(find.text('准备好后点连接'), findsOneWidget);
    });

    testWidgets('connecting 显示 "搜索相机…" 标题', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(
            body: HeroTitle(state: CameraWorkflowState.connecting),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('搜索相机…'), findsOneWidget);
      expect(find.text('正在握手'), findsOneWidget);
    });

    testWidgets('waitingForWifi 状态每 3s 轮播 brand 文本', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(
            body: HeroTitle(state: CameraWorkflowState.waitingForWifi),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Viewfinder'), findsOneWidget);

      // 推进 ~3s，应切到第 2 个 brand
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('取景器'), findsOneWidget);

      // 再 3s，切到第 3 个
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('为 Nikon 而生'), findsOneWidget);

      // 再 3s，循环回到第 1 个
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Viewfinder'), findsOneWidget);
    });

    testWidgets('切到 connecting 后 timer 取消，title 不再变',
        (tester) async {
      Widget buildApp(CameraWorkflowState state) => MaterialApp(
            theme: viewfinderTheme(amberPalette),
            home: Scaffold(
              body: HeroTitle(state: state),
            ),
          );

      await tester.pumpWidget(
        buildApp(CameraWorkflowState.waitingForWifi),
      );
      await tester.pump();
      expect(find.text('Viewfinder'), findsOneWidget);

      // 切到 connecting
      await tester.pumpWidget(
        buildApp(CameraWorkflowState.connecting),
      );
      await tester.pump();
      expect(find.text('搜索相机…'), findsOneWidget);

      // 推进 6s（2 个轮播周期），title 应保持搜索相机… 不变
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      expect(find.text('搜索相机…'), findsOneWidget);
    });

    testWidgets('切回 waitingForWifi timer 重启，brandIndex 从 0 开始',
        (tester) async {
      Widget buildApp(CameraWorkflowState state) => MaterialApp(
            theme: viewfinderTheme(amberPalette),
            home: Scaffold(
              body: HeroTitle(state: state),
            ),
          );

      await tester.pumpWidget(
        buildApp(CameraWorkflowState.connecting),
      );
      await tester.pump();
      expect(find.text('搜索相机…'), findsOneWidget);

      // 切到 waitingForWifi — 应回到 brandIndex 0 ('Viewfinder')
      await tester.pumpWidget(
        buildApp(CameraWorkflowState.waitingForWifi),
      );
      await tester.pump();
      expect(find.text('Viewfinder'), findsOneWidget);

      // 推进 3s → '取景器' (说明 timer 重启)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('取景器'), findsOneWidget);
    });
  });
}