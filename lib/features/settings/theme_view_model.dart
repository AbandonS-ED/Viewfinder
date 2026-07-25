import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/theme_palette.dart';
import 'settings_view_model.dart';

/// 主题 Notifier：读取用户保存的 themeID，返回对应 ThemePalette
class ThemeNotifier extends Notifier<ThemePalette> {
  @override
  ThemePalette build() {
    if (!kEnableMultiTheme) return amberPalette;
    final id = ref.watch(preferencesProvider.select((c) => c.themeID));
    return palettes.firstWhere(
      (p) => p.id == id,
      orElse: () => amberPalette,
    );
  }

  /// 切换主题并持久化到 SharedPreferences
  void select(String id) {
    if (!kEnableMultiTheme) return;
    final next = palettes.firstWhere(
      (p) => p.id == id,
      orElse: () => amberPalette,
    );
    state = next;
    ref.read(preferencesProvider.notifier).setThemeID(id);
  }
}

final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemePalette>(
  ThemeNotifier.new,
);
