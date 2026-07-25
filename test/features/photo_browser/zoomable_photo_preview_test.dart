import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/features/photo_browser/zoomable_photo_preview.dart';
import 'package:viewfinder/features/shared/theme_palette.dart';
import 'package:viewfinder/features/shared/viewfinder_theme.dart';

void main() {
  group('ZoomablePhotoPreview', () {
    Widget wrap(Widget child) => MaterialApp(
          theme: viewfinderTheme(amberPalette),
          home: child,
        );

    testWidgets('渲染时不抛异常', (tester) async {
      await tester.pumpWidget(
        wrap(
          ZoomablePhotoPreview(
            image: const ColoredBox(color: Colors.blue, child: SizedBox.expand()),
            onClose: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ZoomablePhotoPreview), findsOneWidget);
    });

    testWidgets('包含 InteractiveViewer', (tester) async {
      await tester.pumpWidget(
        wrap(
          ZoomablePhotoPreview(
            image: const ColoredBox(color: Colors.blue, child: SizedBox.expand()),
            onClose: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('右上角关闭按钮', (tester) async {
      await tester.pumpWidget(
        wrap(
          ZoomablePhotoPreview(
            image: const ColoredBox(color: Colors.blue, child: SizedBox.expand()),
            onClose: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('点关闭按钮触发 onClose', (tester) async {
      var closed = false;
      await tester.pumpWidget(
        wrap(
          ZoomablePhotoPreview(
            image: const ColoredBox(color: Colors.blue, child: SizedBox.expand()),
            onClose: () => closed = true,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(closed, isTrue);
    });

    testWidgets('点中心也触发 onClose（tap to close）', (tester) async {
      var closed = false;
      await tester.pumpWidget(
        wrap(
          ZoomablePhotoPreview(
            image: const ColoredBox(color: Colors.blue, child: SizedBox.expand()),
            onClose: () => closed = true,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(ZoomablePhotoPreview));
      await tester.pump();
      expect(closed, isTrue);
    });
  });
}