import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/features/shared/theme_palette.dart';
import 'package:viewfinder/features/shared/viewfinder_theme.dart';

void main() {
  group('ViewfinderTheme ThemeExtension', () {
    testWidgets('注册到 ThemeData 后可 from context 取', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: Builder(
            builder: (context) {
              final ext = ViewfinderTheme.of(context);
              expect(ext.palette, amberPalette);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('22 个 getter 各自返 palette 对应字段', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: viewfinderTheme(forestPalette),
          home: Builder(
            builder: (context) {
              final ext = ViewfinderTheme.of(context);
              expect(ext.bg, forestPalette.bg);
              expect(ext.card, forestPalette.card);
              expect(ext.surfaceElevated, forestPalette.surfaceElevated);
              expect(ext.surfaceMuted, forestPalette.surfaceMuted);
              expect(ext.controlBg, forestPalette.controlBg);
              expect(ext.bdr, forestPalette.bdr);
              expect(ext.div, forestPalette.div);
              expect(ext.sep, forestPalette.sep);
              expect(ext.shadow, forestPalette.shadow);
              expect(ext.t1, forestPalette.t1);
              expect(ext.t2, forestPalette.t2);
              expect(ext.tm, forestPalette.tm);
              expect(ext.a, forestPalette.a);
              expect(ext.aL, forestPalette.aL);
              expect(ext.aS, forestPalette.aS);
              expect(ext.ok, forestPalette.ok);
              expect(ext.er, forestPalette.er);
              expect(ext.btn, forestPalette.btn);
              expect(ext.btnT, forestPalette.btnT);
              expect(ext.nbBg, forestPalette.nbBg);
              expect(ext.nbBdr, forestPalette.nbBdr);
              expect(ext.niC, forestPalette.niC);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('amberTheme() deprecated 别名仍可调用（保护旧测试）', (tester) async {
      // ignore: deprecated_member_use_from_same_package
      final theme = amberTheme();
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, amberPalette.bg);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('viewfinderTheme(p) 工厂 brightness 正确（forest/onyx=dark, 其他=light）', (tester) async {
      // forest (dark)
      expect(viewfinderTheme(forestPalette).brightness, Brightness.dark);
      // onyx (dark)
      expect(viewfinderTheme(onyxPalette).brightness, Brightness.dark);
      // amber (light)
      expect(viewfinderTheme(amberPalette).brightness, Brightness.light);
      // slate (light)
      expect(viewfinderTheme(slatePalette).brightness, Brightness.light);
      // terr (light)
      expect(viewfinderTheme(terrPalette).brightness, Brightness.light);
    });
  });
}