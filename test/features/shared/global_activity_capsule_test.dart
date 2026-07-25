import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/features/shared/theme_palette.dart';
import 'package:viewfinder/features/shared/viewfinder_theme.dart';
import 'package:viewfinder/features/shared/widgets/global_activity_capsule.dart';

void main() {
  group('GlobalActivityCapsule', () {
    testWidgets('显示 title 文字', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(
            body: GlobalActivityCapsule(title: '正在连接相机…'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('正在连接相机…'), findsOneWidget);
    });

    testWidgets('显示 subtitle（可选）', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(
            body: GlobalActivityCapsule(
              title: '加载中',
              subtitle: '50%',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('加载中'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('含 CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(
            body: GlobalActivityCapsule(title: '测试'),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}