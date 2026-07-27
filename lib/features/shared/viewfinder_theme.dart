import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme_palette.dart';

/// ThemeExtension：将 ThemePalette 注册进 ThemeData，通过
/// ViewfinderTheme.of(context).bg 快捷访问。
class ViewfinderTheme extends ThemeExtension<ViewfinderTheme> {
  const ViewfinderTheme(this.palette);

  final ThemePalette palette;

  /// 从 context 取 ViewfinderTheme 实例
  static ViewfinderTheme of(BuildContext context) {
    final ext = Theme.of(context).extension<ViewfinderTheme>();
    assert(ext != null, 'ViewfinderTheme not registered. Wrap MaterialApp with viewfinderTheme().');
    return ext!;
  }

  // ── 22 个便捷 getter ──
  Color get bg => palette.bg;
  Color get card => palette.card;
  Color get surfaceElevated => palette.surfaceElevated;
  Color get surfaceMuted => palette.surfaceMuted;
  Color get controlBg => palette.controlBg;
  Color get bdr => palette.bdr;
  Color get div => palette.div;
  Color get sep => palette.sep;
  Color get shadow => palette.shadow;
  Color get t1 => palette.t1;
  Color get t2 => palette.t2;
  Color get tm => palette.tm;
  Color get a => palette.a;
  Color get aL => palette.aL;
  Color get aS => palette.aS;
  Color get ok => palette.ok;
  Color get er => palette.er;
  Color get btn => palette.btn;
  Color get btnT => palette.btnT;
  Color get nbBg => palette.nbBg;
  Color get nbBdr => palette.nbBdr;
  Color get niC => palette.niC;

  @override
  ViewfinderTheme copyWith({ThemePalette? palette}) =>
      ViewfinderTheme(palette ?? this.palette);

  @override
  ViewfinderTheme lerp(covariant ViewfinderTheme? other, double t) =>
      this; // 色板是离散切换，lerp 不做插值
}

/// 字体策略（muban.html 1:1）：
/// - **正文（中文）**：Noto Sans SC — 中文 fallback 一致
/// - **标题（英文/数字）**：Instrument Serif — 衬线古典感
/// - **等宽**：DM Mono — 在 3 个已有 widget 显式 `GoogleFonts.dmMono(...)` 使用
///
/// Instrument Serif 出现在 display + headline + titleLarge（覆盖 hero 标题 +
/// page title 22px + 卡片标题 18px 等所有衬线场景）。其他用 Noto Sans SC。
TextTheme _buildTextTheme(Brightness brightness) {
  final base = ThemeData(brightness: brightness).textTheme;
  TextStyle sc(TextStyle? s) => GoogleFonts.notoSansSc(textStyle: s);
  TextStyle serif(TextStyle? s) => GoogleFonts.instrumentSerif(textStyle: s);
  return base.copyWith(
    displayLarge: serif(base.displayLarge),
    displayMedium: serif(base.displayMedium),
    displaySmall: serif(base.displaySmall),
    headlineLarge: serif(base.headlineLarge),
    headlineMedium: serif(base.headlineMedium),
    headlineSmall: serif(base.headlineSmall),
    titleLarge: serif(base.titleLarge),
    titleMedium: sc(base.titleMedium),
    titleSmall: sc(base.titleSmall),
    bodyLarge: sc(base.bodyLarge),
    bodyMedium: sc(base.bodyMedium),
    bodySmall: sc(base.bodySmall),
    labelLarge: sc(base.labelLarge),
    labelMedium: sc(base.labelMedium),
    labelSmall: sc(base.labelSmall),
  );
}

/// 将 ThemePalette 注册进 ThemeData
ThemeData viewfinderTheme(ThemePalette p) {
  final brightness = p.isDark ? Brightness.dark : Brightness.light;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: p.a,
      brightness: brightness,
    ),
    textTheme: _buildTextTheme(brightness),
    extensions: [ViewfinderTheme(p)],
  );
}

/// 别名：保护 app_theme_test.dart L100-111 不破坏
@Deprecated('Use viewfinderTheme(amberPalette) instead')
ThemeData amberTheme() => viewfinderTheme(amberPalette);
