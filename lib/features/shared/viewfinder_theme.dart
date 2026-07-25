import 'package:flutter/material.dart';

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
    extensions: [ViewfinderTheme(p)],
  );
}

/// 别名：保护 app_theme_test.dart L100-111 不破坏
@Deprecated('Use viewfinderTheme(amberPalette) instead')
ThemeData amberTheme() => viewfinderTheme(amberPalette);
