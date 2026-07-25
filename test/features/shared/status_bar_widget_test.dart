import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/features/shared/theme_palette.dart';
import 'package:viewfinder/features/shared/viewfinder_theme.dart';
import 'package:viewfinder/features/shared/widgets/status_bar_widget.dart';

void main() {
  group('StatusBarWidget', () {
    testWidgets('无 title 时不显示文字', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(body: StatusBarWidget()),
        ),
      );
      await tester.pump();
      expect(find.byType(StatusBarWidget), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('有 title 时显示 title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(
            body: StatusBarWidget(title: '相册'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('相册'), findsOneWidget);
    });

    testWidgets('高度默认 24', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: const Scaffold(body: StatusBarWidget()),
        ),
      );
      await tester.pump();
      final size = tester.getSize(find.byType(StatusBarWidget));
      expect(size.height, 24);
    });
  });
}