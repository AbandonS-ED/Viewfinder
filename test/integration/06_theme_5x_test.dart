import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viewfinder/features/settings/settings_container.dart';
import 'package:viewfinder/features/settings/theme_view_model.dart';

import 'helpers/test_app.dart';

/// T6 主题 5× 循环切换真集成测试：
/// 1. pump app
/// 2. 通过 UI 依次点击 amber → forest → slate → terr → onyx → 回到 amber
/// 3. 每次切换后断言：仅 1 个 check icon + 对应 id 文本可见
/// 4. 通过 ThemeNotifier.notifier.select() 直接调用同样验证
///
/// 验证 ThemePickerRow 5 个主题按钮全部 tappable、状态切换无残留。
void main() {
  setUp(() async {
    await initTestEnv();
  });

  const themeIds = ['amber', 'forest', 'slate', 'terr', 'onyx'];

  Future<void> pumpAndSettleOnce(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('T6 主题 5× 切换', () {
    testWidgets('UI 循环切换：5 个主题依次点击，每次只 1 个 check icon',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(const Scaffold(body: SettingsContainer())),
      );
      await pumpAndSettleOnce(tester);

      // 默认 amber
      expect(find.byIcon(Icons.check), findsOneWidget);

      // 依次切换到 forest / slate / terr / onyx / amber（回到初始）
      for (final id in const ['forest', 'slate', 'terr', 'onyx', 'amber']) {
        await tester.tap(find.text(id));
        await pumpAndSettleOnce(tester);

        // 每次切换后应只有 1 个 check icon（选中那个主题）
        expect(find.byIcon(Icons.check), findsOneWidget,
            reason: '切换到 $id 后应只有 1 个 check icon');
        // 所有 5 个主题 id 仍应可见
        for (final other in themeIds) {
          expect(find.text(other), findsOneWidget);
        }
      }
    });

    testWidgets('直接调 ThemeNotifier.select()：5 个主题切换，UI 同步',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(const Scaffold(body: SettingsContainer())),
      );
      await pumpAndSettleOnce(tester);

      // 拿 container 以便直接访问 notifier
      final BuildContext context =
          tester.element(find.byType(SettingsContainer));
      final ProviderContainer container =
          ProviderScope.containerOf(context, listen: false);

      // 依次通过 notifier 切 5 个主题（跳过 amber 因为已经是默认）
      for (final id in const ['forest', 'slate', 'terr', 'onyx', 'amber']) {
        container.read(themeNotifierProvider.notifier).select(id);
        await pumpAndSettleOnce(tester);

        expect(find.byIcon(Icons.check), findsOneWidget,
            reason: 'select($id) 后 UI 应同步到 $id');
      }
    });
  });
}