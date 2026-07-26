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

    testWidgets('点中心也触发 onClose（tap to close，1x）', (tester) async {
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
      // GestureDetector.onTap 在 onDoubleTap 共存时走双击检测窗口 (~300ms)
      // pump 等定时器到期，模拟真实手势时间
      await tester.pump(const Duration(milliseconds: 400));
      expect(closed, isTrue);
    });

    testWidgets('初始 scale = 1.0', (tester) async {
      await tester.pumpWidget(
        wrap(
          ZoomablePhotoPreview(
            image: const ColoredBox(color: Colors.blue, child: SizedBox.expand()),
            onClose: () {},
          ),
        ),
      );
      await tester.pump();
      final iv = tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
      expect(iv.transformationController!.value.getMaxScaleOnAxis(), 1.0);
    });

    testWidgets('双击 → scale 变 2.5x', (tester) async {
      await tester.pumpWidget(
        wrap(
          ZoomablePhotoPreview(
            image: const ColoredBox(color: Colors.blue, child: SizedBox.expand()),
            onClose: () {},
          ),
        ),
      );
      await tester.pump();
      // 两次 tap 间隔 50ms（落在 300ms 双击窗口内）
      await tester.tap(find.byType(ZoomablePhotoPreview));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(ZoomablePhotoPreview));
      await tester.pumpAndSettle();
      final iv = tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
      expect(iv.transformationController!.value.getMaxScaleOnAxis(), closeTo(2.5, 0.01));
    });

    testWidgets('缩放后单击中心不触发 onClose', (tester) async {
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
      // 双击进入 2.5x（50ms 间隔，落在 300ms 双击窗口内）
      await tester.tap(find.byType(ZoomablePhotoPreview));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(ZoomablePhotoPreview));
      await tester.pumpAndSettle();
      // 再单击（此时已缩放）+ 等 onTap 检测窗口过期
      await tester.tap(find.byType(ZoomablePhotoPreview));
      await tester.pump(const Duration(milliseconds: 400));
      expect(closed, isFalse);
    });

    testWidgets('1x 时 close 按钮 AnimatedOpacity = 1.0', (tester) async {
      await tester.pumpWidget(
        wrap(
          ZoomablePhotoPreview(
            image: const ColoredBox(color: Colors.blue, child: SizedBox.expand()),
            onClose: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      final opacity = tester.widget<AnimatedOpacity>(
        find.descendant(
          of: find.byType(ZoomablePhotoPreview),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(opacity.opacity, 1.0);
    });

    testWidgets('缩放时 close 按钮 AnimatedOpacity = 0.0', (tester) async {
      await tester.pumpWidget(
        wrap(
          ZoomablePhotoPreview(
            image: const ColoredBox(color: Colors.blue, child: SizedBox.expand()),
            onClose: () {},
          ),
        ),
      );
      await tester.pump();
      // 双击进入 2.5x
      await tester.tap(find.byType(ZoomablePhotoPreview));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(ZoomablePhotoPreview));
      await tester.pumpAndSettle();
      final opacity = tester.widget<AnimatedOpacity>(
        find.descendant(
          of: find.byType(ZoomablePhotoPreview),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(opacity.opacity, 0.0);
    });
  });
}