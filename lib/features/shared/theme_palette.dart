import 'package:flutter/material.dart';

/// Feature flag：关闭后 ThemeNotifier.build() 永远返回 amberPalette
const bool kEnableMultiTheme = true;

/// 主题色板：22 色 + 1 标识 (id)
class ThemePalette {
  const ThemePalette({
    required this.id,
    required this.bg,
    required this.card,
    required this.surfaceElevated,
    required this.surfaceMuted,
    required this.controlBg,
    required this.bdr,
    required this.div,
    required this.sep,
    required this.shadow,
    required this.t1,
    required this.t2,
    required this.tm,
    required this.a,
    required this.aL,
    required this.aS,
    required this.ok,
    required this.er,
    required this.btn,
    required this.btnT,
    required this.nbBg,
    required this.nbBdr,
    required this.niC,
  });

  final String id;

  // ── 背景 (5) ──
  final Color bg;
  final Color card;
  final Color surfaceElevated;
  final Color surfaceMuted;
  final Color controlBg;

  // ── 边框 (4) ──
  final Color bdr;
  final Color div;
  final Color sep;
  final Color shadow;

  // ── 文字 (3) ──
  final Color t1;
  final Color t2;
  final Color tm;

  // ── 强调 (3) ──
  final Color a;
  final Color aL;
  final Color aS;

  // ── 状态 (2) ──
  final Color ok;
  final Color er;

  // ── 按钮 (2) ──
  final Color btn;
  final Color btnT;

  // ── 导航栏 (3) ──
  final Color nbBg;
  final Color nbBdr;
  final Color niC;

  bool get isDark => id == 'forest' || id == 'onyx';
}

// ────────────────────────────────────────────────────────
//  Amber — 暖白底 + 琥珀金（muban.html 1:1）
// ────────────────────────────────────────────────────────
const amberPalette = ThemePalette(
  id: 'amber',
  bg: Color(0xFFF9F9F8),
  card: Color(0xFFFFFFFF),
  surfaceElevated: Color(0xFFFFFFFF),
  surfaceMuted: Color(0xFFF5F5F5),
  controlBg: Color(0xFFF2F2F3),
  bdr: Color(0xFFE8E4DD),
  div: Color(0x0A000000),
  sep: Color(0x14000000),
  shadow: Color(0x0D000000),
  t1: Color(0xFF2D2D2D),
  t2: Color(0xFF7A756E),
  tm: Color(0xFFB5AFA6),
  a: Color(0xFFD4A24E),
  aL: Color(0xFFF5E6C8),
  aS: Color(0xFFE8B84B),
  ok: Color(0xFF5B8C5A),
  er: Color(0xFFC45B4A),
  btn: Color(0xFF1A1A1A),
  btnT: Color(0xFFFFFFFF),
  nbBg: Color(0xFFFFFFFF),
  nbBdr: Color(0xFFE8E4DD),
  niC: Color(0xFFB5AFA6),
);

// ────────────────────────────────────────────────────────
//  Forest — 深绿底 + 翠绿强调 (dark, muban.html 1:1)
// ────────────────────────────────────────────────────────
const forestPalette = ThemePalette(
  id: 'forest',
  bg: Color(0xFF111F14),
  card: Color(0xFF1A2E1E),
  surfaceElevated: Color(0xFF1A2E1E),
  surfaceMuted: Color(0xFF243E2A),
  controlBg: Color(0xFF2A4A30),
  bdr: Color(0xFF2A4A30),
  div: Color(0x0DFFFFFF),
  sep: Color(0x1AFFFFFF),
  shadow: Color(0x80000000),
  t1: Color(0xFFD8E8D8),
  t2: Color(0xFF7A9A7A),
  tm: Color(0xFF4A6A4A),
  a: Color(0xFF7CC9A0),
  aL: Color(0x267CC9A0),
  aS: Color(0xFF5BB088),
  ok: Color(0xFF7CC9A0),
  er: Color(0xFFD47A6A),
  btn: Color(0xFF7CC9A0),
  btnT: Color(0xFF111F14),
  nbBg: Color(0xFF1A2E1E),
  nbBdr: Color(0xFF2A4A30),
  niC: Color(0xFF4A6A4A),
);

// ────────────────────────────────────────────────────────
//  Slate — 冷灰底 + 蓝灰强调 (light, muban.html 1:1)
// ────────────────────────────────────────────────────────
const slatePalette = ThemePalette(
  id: 'slate',
  bg: Color(0xFFF0F1F3),
  card: Color(0xFFFAFBFC),
  surfaceElevated: Color(0xFFFAFBFC),
  surfaceMuted: Color(0xFFE8EAED),
  controlBg: Color(0xFFE5E8EB),
  bdr: Color(0xFFDDE0E4),
  div: Color(0x08000000),
  sep: Color(0x0F000000),
  shadow: Color(0x0F000000),
  t1: Color(0xFF2C3E50),
  t2: Color(0xFF7F8C9B),
  tm: Color(0xFFA8B2BC),
  a: Color(0xFF6B8DAD),
  aL: Color(0x1F6B8DAD),
  aS: Color(0xFF557FA0),
  ok: Color(0xFF5A8060),
  er: Color(0xFFC0574A),
  btn: Color(0xFF2C3E50),
  btnT: Color(0xFFFFFFFF),
  nbBg: Color(0xFFFAFBFC),
  nbBdr: Color(0xFFDDE0E4),
  niC: Color(0xFFA8B2BC),
);

// ────────────────────────────────────────────────────────
//  Terr — 暖沙底 + 陶土橙强调 (light, muban.html 1:1)
// ────────────────────────────────────────────────────────
const terrPalette = ThemePalette(
  id: 'terr',
  bg: Color(0xFFF8F3ED),
  card: Color(0xFFFFFCF8),
  surfaceElevated: Color(0xFFFFFCF8),
  surfaceMuted: Color(0xFFF0E8DC),
  controlBg: Color(0xFFE8DDD0),
  bdr: Color(0xFFE8DDD0),
  div: Color(0x0A000000),
  sep: Color(0x14000000),
  shadow: Color(0x0D000000),
  t1: Color(0xFF3D2B1F),
  t2: Color(0xFF8A7060),
  tm: Color(0xFFBBA898),
  a: Color(0xFFC2703E),
  aL: Color(0xFFF0D8C4),
  aS: Color(0xFFA85F2E),
  ok: Color(0xFF7A9060),
  er: Color(0xFFC45B4A),
  btn: Color(0xFF3D2B1F),
  btnT: Color(0xFFFFFFFF),
  nbBg: Color(0xFFFFFCF8),
  nbBdr: Color(0xFFE8DDD0),
  niC: Color(0xFFBBA898),
);

// ────────────────────────────────────────────────────────
//  Onyx — 纯黑底 + 暗金强调 (dark, muban.html 1:1)
// ────────────────────────────────────────────────────────
const onyxPalette = ThemePalette(
  id: 'onyx',
  bg: Color(0xFF0C0C0E),
  card: Color(0xFF161618),
  surfaceElevated: Color(0xFF161618),
  surfaceMuted: Color(0xFF1E1E20),
  controlBg: Color(0xFF262629),
  bdr: Color(0xFF262629),
  div: Color(0x0DFFFFFF),
  sep: Color(0x1EFFFFFF),
  shadow: Color(0x99000000),
  t1: Color(0xFFE8E8E8),
  t2: Color(0xFF7A7A7E),
  tm: Color(0xFF4A4A4E),
  a: Color(0xFFE8B84B),
  aL: Color(0x1FE8B84B),
  aS: Color(0xFFB8932F),
  ok: Color(0xFF5ADA80),
  er: Color(0xFFF07070),
  btn: Color(0xFFE8B84B),
  btnT: Color(0xFF0C0C0E),
  nbBg: Color(0xFF161618),
  nbBdr: Color(0xFF262629),
  niC: Color(0xFF4A4A4E),
);

/// 5 套主题的有序列表（ThemePickerRow 用）
const palettes = <ThemePalette>[
  amberPalette,
  forestPalette,
  slatePalette,
  terrPalette,
  onyxPalette,
];
