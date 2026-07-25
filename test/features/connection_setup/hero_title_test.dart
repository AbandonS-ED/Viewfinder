import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/camera_workflow_state.dart';
import 'package:viewfinder/features/connection_setup/hero_title.dart';
import 'package:viewfinder/features/shared/theme_palette.dart';
import 'package:viewfinder/features/shared/viewfinder_theme.dart';

void main() {
  group('HeroTitleStateMachine.titleFor', () {
    test('waitingForWifi 返 Viewfinder', () {
      expect(
        HeroTitleStateMachine.titleFor(CameraWorkflowState.waitingForWifi),
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

    test('6 个 state 都有自己的 title（不重复）', () {
      final titles = CameraWorkflowState.values
          .map(HeroTitleStateMachine.titleFor)
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
    testWidgets('waitingForWifi 显示 Viewfinder 标题', (tester) async {
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
  });
}