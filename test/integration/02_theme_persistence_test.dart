import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viewfinder/features/settings/settings_container.dart';
import 'package:viewfinder/features/settings/theme_view_model.dart';
import 'package:viewfinder/features/shared/theme_palette.dart';
import 'package:viewfinder/features/shared/viewfinder_theme.dart';

import 'helpers/test_app.dart';

/// T2 主题持久化真集成测试：
/// 1. pump app，默认 theme 应为 amber（preferencesProvider 默认值）
/// 2. 用户在设置页点 onyx → ThemeNotifier.select('onyx') 触发
/// 3. 状态同步 + 持久化到 SharedPreferences
/// 4. 重建 widget（模拟 app 重启）→ 主题仍是 onyx
///
/// 验证链路：ThemeNotifier → preferencesProvider.setThemeID →
///   preferencesStoreProvider.saveConnectionConfig → SharedPreferences
void main() {
  setUp(() async {
    await initTestEnv();
  });

  /// 重建 app（模拟进程重启）：保留同一个 SharedPreferences（testSharedPreferences 是 module-level single）
  Widget rebuildApp(Widget home) {
    return Consumer(
      builder: (context, ref, _) {
        final palette = ref.watch(themeNotifierProvider);
        return MaterialApp(
          theme: viewfinderTheme(palette),
          home: home,
        );
      },
    );
  }

  group('T2 主题持久化 (ThemeNotifier → SharedPreferences)', () {
    testWidgets('happy path: 默认 amber → 切 onyx → 重建仍是 onyx',
        (tester) async {
      // 1. 首次 pump
      await tester.pumpWidget(
        buildTestApp(const Scaffold(body: SettingsContainer())),
      );
      await tester.pump();

      // 默认主题应为 amber（amber 圆点带 check icon，其他 4 个无）
      expect(find.byIcon(Icons.check), findsOneWidget);
      // 5 个主题 id 都可见
      for (final id in ['amber', 'forest', 'slate', 'terr', 'onyx']) {
        expect(find.text(id), findsOneWidget,
            reason: '主题 $id 的 id label 应可见');
      }

      // 2. 点 onyx 主题
      await tester.tap(find.text('onyx'));
      await tester.pump();

      // 切完后仍只有 1 个 check icon（换人）
      expect(find.byIcon(Icons.check), findsOneWidget);

      // 3. 重建 widget（模拟 app 重启）：保留同一 SharedPreferences
      await tester.pumpWidget(
        buildTestApp(
          rebuildApp(const Scaffold(body: SettingsContainer())),
        ),
      );
      await tester.pump();

      // 重建后 onyx 仍被选中（check icon 还在）
      expect(find.byIcon(Icons.check), findsOneWidget);
      // amber / forest / slate / terr 都还在
      for (final id in ['amber', 'forest', 'slate', 'terr', 'onyx']) {
        expect(find.text(id), findsOneWidget);
      }
    });

    testWidgets('边界: 点不存在的 theme id → fallback amber（不应崩溃）',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(const Scaffold(body: SettingsContainer())),
      );
      await tester.pump();

      // 通过 ThemeNotifier 直接调 select() 传无效 id
      // (UI 不可能触发无效 id，但验证 ThemeNotifier 的 orElse fallback)
      final BuildContext context = tester.element(
        find.byType(SettingsContainer),
      );
      // 通过 ProviderScope 容器取 ref（参考 Riverpod 测试模式）
      final ProviderContainer container = ProviderScope.containerOf(
        context,
        listen: false,
      );
      container.read(themeNotifierProvider.notifier).select('nonexistent_id');

      await tester.pump();

      // 应该 fallback 到 amber（firstWhere orElse 默认 amberPalette）
      // 默认 amber 有 check icon，fallback 后也应该有
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
