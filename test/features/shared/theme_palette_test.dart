import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/features/shared/theme_palette.dart';

/// 22 色 token 列表（muban.html 22 个 public 色字段）
const _tokens = <String>[
  'bg',
  'card',
  'surfaceElevated',
  'surfaceMuted',
  'controlBg',
  'bdr',
  'div',
  'sep',
  'shadow',
  't1',
  't2',
  'tm',
  'a',
  'aL',
  'aS',
  'ok',
  'er',
  'btn',
  'btnT',
  'nbBg',
  'nbBdr',
  'niC',
];

/// muban.html 权威色值（5 套主题 × 22 token）
/// 2026-07-26 与 `D:\桌面\muban\muban.html` 1:1 对齐
const Map<String, Map<String, Color>> _mubanColors = {
  'amber': {
    'bg': Color(0xFFF9F9F8),
    'card': Color(0xFFFFFFFF),
    'surfaceElevated': Color(0xFFFFFFFF),
    'surfaceMuted': Color(0xFFF5F5F5),
    'controlBg': Color(0xFFF2F2F3),
    'bdr': Color(0xFFE8E4DD),
    'div': Color(0x0A000000),
    'sep': Color(0x14000000),
    'shadow': Color(0x0D000000),
    't1': Color(0xFF2D2D2D),
    't2': Color(0xFF7A756E),
    'tm': Color(0xFFB5AFA6),
    'a': Color(0xFFD4A24E),
    'aL': Color(0xFFF5E6C8),
    'aS': Color(0xFFE8B84B),
    'ok': Color(0xFF5B8C5A),
    'er': Color(0xFFC45B4A),
    'btn': Color(0xFF1A1A1A),
    'btnT': Color(0xFFFFFFFF),
    'nbBg': Color(0xFFFFFFFF),
    'nbBdr': Color(0xFFE8E4DD),
    'niC': Color(0xFFB5AFA6),
  },
  'forest': {
    'bg': Color(0xFF111F14),
    'card': Color(0xFF1A2E1E),
    'surfaceElevated': Color(0xFF1A2E1E),
    'surfaceMuted': Color(0xFF243E2A),
    'controlBg': Color(0xFF2A4A30),
    'bdr': Color(0xFF2A4A30),
    'div': Color(0x0DFFFFFF),
    'sep': Color(0x1AFFFFFF),
    'shadow': Color(0x80000000),
    't1': Color(0xFFD8E8D8),
    't2': Color(0xFF7A9A7A),
    'tm': Color(0xFF4A6A4A),
    'a': Color(0xFF7CC9A0),
    'aL': Color(0x267CC9A0),
    'aS': Color(0xFF5BB088),
    'ok': Color(0xFF7CC9A0),
    'er': Color(0xFFD47A6A),
    'btn': Color(0xFF7CC9A0),
    'btnT': Color(0xFF111F14),
    'nbBg': Color(0xFF1A2E1E),
    'nbBdr': Color(0xFF2A4A30),
    'niC': Color(0xFF4A6A4A),
  },
  'slate': {
    'bg': Color(0xFFF0F1F3),
    'card': Color(0xFFFAFBFC),
    'surfaceElevated': Color(0xFFFAFBFC),
    'surfaceMuted': Color(0xFFE8EAED),
    'controlBg': Color(0xFFE5E8EB),
    'bdr': Color(0xFFDDE0E4),
    'div': Color(0x08000000),
    'sep': Color(0x0F000000),
    'shadow': Color(0x0F000000),
    't1': Color(0xFF2C3E50),
    't2': Color(0xFF7F8C9B),
    'tm': Color(0xFFA8B2BC),
    'a': Color(0xFF6B8DAD),
    'aL': Color(0x1F6B8DAD),
    'aS': Color(0xFF557FA0),
    'ok': Color(0xFF5A8060),
    'er': Color(0xFFC0574A),
    'btn': Color(0xFF2C3E50),
    'btnT': Color(0xFFFFFFFF),
    'nbBg': Color(0xFFFAFBFC),
    'nbBdr': Color(0xFFDDE0E4),
    'niC': Color(0xFFA8B2BC),
  },
  'terr': {
    'bg': Color(0xFFF8F3ED),
    'card': Color(0xFFFFFCF8),
    'surfaceElevated': Color(0xFFFFFCF8),
    'surfaceMuted': Color(0xFFF0E8DC),
    'controlBg': Color(0xFFE8DDD0),
    'bdr': Color(0xFFE8DDD0),
    'div': Color(0x0A000000),
    'sep': Color(0x14000000),
    'shadow': Color(0x0D000000),
    't1': Color(0xFF3D2B1F),
    't2': Color(0xFF8A7060),
    'tm': Color(0xFFBBA898),
    'a': Color(0xFFC2703E),
    'aL': Color(0xFFF0D8C4),
    'aS': Color(0xFFA85F2E),
    'ok': Color(0xFF7A9060),
    'er': Color(0xFFC45B4A),
    'btn': Color(0xFF3D2B1F),
    'btnT': Color(0xFFFFFFFF),
    'nbBg': Color(0xFFFFFCF8),
    'nbBdr': Color(0xFFE8DDD0),
    'niC': Color(0xFFBBA898),
  },
  'onyx': {
    'bg': Color(0xFF0C0C0E),
    'card': Color(0xFF161618),
    'surfaceElevated': Color(0xFF161618),
    'surfaceMuted': Color(0xFF1E1E20),
    'controlBg': Color(0xFF262629),
    'bdr': Color(0xFF262629),
    'div': Color(0x0DFFFFFF),
    'sep': Color(0x1EFFFFFF),
    'shadow': Color(0x99000000),
    't1': Color(0xFFE8E8E8),
    't2': Color(0xFF7A7A7E),
    'tm': Color(0xFF4A4A4E),
    'a': Color(0xFFE8B84B),
    'aL': Color(0x1FE8B84B),
    'aS': Color(0xFFB8932F),
    'ok': Color(0xFF5ADA80),
    'er': Color(0xFFF07070),
    'btn': Color(0xFFE8B84B),
    'btnT': Color(0xFF0C0C0E),
    'nbBg': Color(0xFF161618),
    'nbBdr': Color(0xFF262629),
    'niC': Color(0xFF4A4A4E),
  },
};

ThemePalette _paletteById(String id) {
  switch (id) {
    case 'amber':
      return amberPalette;
    case 'forest':
      return forestPalette;
    case 'slate':
      return slatePalette;
    case 'terr':
      return terrPalette;
    case 'onyx':
      return onyxPalette;
    default:
      throw ArgumentError('Unknown palette: $id');
  }
}

void main() {
  // ─────────────────────────────────────────
  // 22 token × 5 palette + 5 structural = 115 测试
  // 数据驱动：遍历 _mubanColors 权威表
  // ─────────────────────────────────────────
  group('ThemePalette 字段完整性', () {
    for (final paletteId in _mubanColors.keys) {
      test('$paletteId 22 色 token 各自非 null', () {
        final palette = _paletteById(paletteId);
        for (final t in _tokens) {
          expect(_fieldByName(palette, t), isA<Color>(),
              reason: '$paletteId.$t 必须是 Color');
        }
      });
    }
  });

  group('muban.html 色值 1:1 断言', () {
    for (final paletteId in _mubanColors.keys) {
      final palette = _paletteById(paletteId);
      final expected = _mubanColors[paletteId]!;
      for (final token in _tokens) {
        test('${paletteId}Palette.$token matches muban.html', () {
          expect(_fieldByName(palette, token), expected[token]);
        });
      }
    }
  });
}

/// 通过 token 名字符串取 Color 字段值（仅测试用）
Color _fieldByName(ThemePalette p, String name) {
  switch (name) {
    case 'bg':
      return p.bg;
    case 'card':
      return p.card;
    case 'surfaceElevated':
      return p.surfaceElevated;
    case 'surfaceMuted':
      return p.surfaceMuted;
    case 'controlBg':
      return p.controlBg;
    case 'bdr':
      return p.bdr;
    case 'div':
      return p.div;
    case 'sep':
      return p.sep;
    case 'shadow':
      return p.shadow;
    case 't1':
      return p.t1;
    case 't2':
      return p.t2;
    case 'tm':
      return p.tm;
    case 'a':
      return p.a;
    case 'aL':
      return p.aL;
    case 'aS':
      return p.aS;
    case 'ok':
      return p.ok;
    case 'er':
      return p.er;
    case 'btn':
      return p.btn;
    case 'btnT':
      return p.btnT;
    case 'nbBg':
      return p.nbBg;
    case 'nbBdr':
      return p.nbBdr;
    case 'niC':
      return p.niC;
    default:
      throw ArgumentError('Unknown token: $name');
  }
}