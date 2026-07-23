import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/camera_workflow_state.dart';
import 'package:viewfinder/features/shared/app_theme.dart';
import 'package:viewfinder/features/shared/formatters.dart';

void main() {
  group('workflowColor', () {
    test('waitingForWifi → info 蓝', () {
      expect(
        workflowColor(CameraWorkflowState.waitingForWifi),
        AppThemeColors.info,
      );
    });

    test('connecting → warn 橙', () {
      expect(
        workflowColor(CameraWorkflowState.connecting),
        AppThemeColors.warn,
      );
    });

    test('loadingPhotos → warn 橙', () {
      expect(
        workflowColor(CameraWorkflowState.loadingPhotos),
        AppThemeColors.warn,
      );
    });

    test('downloading → warn 橙', () {
      expect(
        workflowColor(CameraWorkflowState.downloading),
        AppThemeColors.warn,
      );
    });

    test('connected → ok 绿', () {
      expect(
        workflowColor(CameraWorkflowState.connected),
        AppThemeColors.ok,
      );
    });

    test('error → er 红', () {
      expect(
        workflowColor(CameraWorkflowState.error),
        AppThemeColors.er,
      );
    });

    test('6 个 state 映射到 4 色（中间过渡共用 warn）', () {
      const states = CameraWorkflowState.values;
      final colors = states.map(workflowColor).toSet();
      expect(colors.length, 4, reason: 'connecting/loadingPhotos/downloading 共用 warn');
    });
  });

  group('formatters.fileSize', () {
    test('< 1024 B', () {
      expect(fileSize(900), '900 B');
    });

    test('KB', () {
      expect(fileSize(2048), '2.0 KB');
    });

    test('MB', () {
      expect(fileSize(5 * 1024 * 1024), '5.0 MB');
    });

    test('GB', () {
      expect(fileSize(2 * 1024 * 1024 * 1024), '2.00 GB');
    });
  });

  group('formatters.captureDate', () {
    final now = DateTime(2026, 7, 23, 14, 30);

    test('今天', () {
      final dt = DateTime(2026, 7, 23, 9, 15);
      expect(captureDate(dt, now: now), '今天 09:15');
    });

    test('昨天', () {
      final dt = DateTime(2026, 7, 22, 21, 0);
      expect(captureDate(dt, now: now), '昨天 21:00');
    });

    test('本年内', () {
      final dt = DateTime(2026, 1, 5, 8, 0);
      expect(captureDate(dt, now: now), '01-05 08:00');
    });

    test('跨年', () {
      final dt = DateTime(2025, 12, 31, 23, 59);
      expect(captureDate(dt, now: now), '2025-12-31');
    });
  });

  group('amberTheme', () {
    testWidgets('渲染时不抛异常', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: amberTheme(),
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
