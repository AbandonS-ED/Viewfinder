import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/features/shared/theme_palette.dart';

/// 23 色 token 列表（验证时迭代）
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

void main() {
  // ─────────────────────────────────────────
  // 23 token × 5 palette = 115 色值断言
  // ─────────────────────────────────────────
  group('ThemePalette 字段完整性', () {
    test('amber 23 色 token 各自非 null', () {
      for (final t in _tokens) {
        expect(_fieldByName(amberPalette, t), isA<Color>(),
            reason: 'amberPalette.$t 必须是 Color');
      }
    });

    test('forest 23 色 token 各自非 null', () {
      for (final t in _tokens) {
        expect(_fieldByName(forestPalette, t), isA<Color>(),
            reason: 'forestPalette.$t 必须是 Color');
      }
    });

    test('slate 23 色 token 各自非 null', () {
      for (final t in _tokens) {
        expect(_fieldByName(slatePalette, t), isA<Color>(),
            reason: 'slatePalette.$t 必须是 Color');
      }
    });

    test('terr 23 色 token 各自非 null', () {
      for (final t in _tokens) {
        expect(_fieldByName(terrPalette, t), isA<Color>(),
            reason: 'terrPalette.$t 必须是 Color');
      }
    });

    test('onyx 23 色 token 各自非 null', () {
      for (final t in _tokens) {
        expect(_fieldByName(onyxPalette, t), isA<Color>(),
            reason: 'onyxPalette.$t 必须是 Color');
      }
    });
  });

  // amber bg = #F9F9F8
  test('amberPalette.bg == Color(0xFFF9F9F8)', () {
    expect(amberPalette.bg, const Color(0xFFF9F9F8));
  });

  test('amberPalette.card == Color(0xFFFFFFFF)', () {
    expect(amberPalette.card, const Color(0xFFFFFFFF));
  });

  test('amberPalette.surfaceElevated == Color(0xFFFFFFFF)', () {
    expect(amberPalette.surfaceElevated, const Color(0xFFFFFFFF));
  });

  test('amberPalette.surfaceMuted == Color(0xFFF5F5F5)', () {
    expect(amberPalette.surfaceMuted, const Color(0xFFF5F5F5));
  });

  test('amberPalette.controlBg == Color(0xFFF2F2F3)', () {
    expect(amberPalette.controlBg, const Color(0xFFF2F2F3));
  });

  test('amberPalette.bdr == Color(0x12000000)', () {
    expect(amberPalette.bdr, const Color(0x12000000));
  });

  test('amberPalette.div == Color(0x0A000000)', () {
    expect(amberPalette.div, const Color(0x0A000000));
  });

  test('amberPalette.sep == Color(0x14000000)', () {
    expect(amberPalette.sep, const Color(0x14000000));
  });

  test('amberPalette.shadow == Color(0x0D000000)', () {
    expect(amberPalette.shadow, const Color(0x0D000000));
  });

  test('amberPalette.t1 == Color(0xFF1A1A1A)', () {
    expect(amberPalette.t1, const Color(0xFF1A1A1A));
  });

  test('amberPalette.t2 == Color(0xFF6B7079)', () {
    expect(amberPalette.t2, const Color(0xFF6B7079));
  });

  test('amberPalette.tm == Color(0xFFB5AFA6)', () {
    expect(amberPalette.tm, const Color(0xFFB5AFA6));
  });

  test('amberPalette.a == Color(0xFFD4A24E)', () {
    expect(amberPalette.a, const Color(0xFFD4A24E));
  });

  test('amberPalette.aL == Color(0xFFF5E6C8)', () {
    expect(amberPalette.aL, const Color(0xFFF5E6C8));
  });

  test('amberPalette.aS == Color(0xFFE8B84B)', () {
    expect(amberPalette.aS, const Color(0xFFE8B84B));
  });

  test('amberPalette.ok == Color(0xFF5B8C5A)', () {
    expect(amberPalette.ok, const Color(0xFF5B8C5A));
  });

  test('amberPalette.er == Color(0xFFDB262E)', () {
    expect(amberPalette.er, const Color(0xFFDB262E));
  });

  test('amberPalette.btn == Color(0xFF1A1A1A)', () {
    expect(amberPalette.btn, const Color(0xFF1A1A1A));
  });

  test('amberPalette.btnT == Color(0xFFFFFFFF)', () {
    expect(amberPalette.btnT, const Color(0xFFFFFFFF));
  });

  test('amberPalette.nbBg == Color(0xFFFFFFFF)', () {
    expect(amberPalette.nbBg, const Color(0xFFFFFFFF));
  });

  test('amberPalette.nbBdr == Color(0x12000000)', () {
    expect(amberPalette.nbBdr, const Color(0x12000000));
  });

  test('amberPalette.niC == Color(0xFFB5AFA6)', () {
    expect(amberPalette.niC, const Color(0xFFB5AFA6));
  });

  test('amberPalette.id == "amber"', () {
    expect(amberPalette.id, 'amber');
  });

  // forest (dark)
  test('forestPalette.bg == Color(0xFF111F14)', () {
    expect(forestPalette.bg, const Color(0xFF111F14));
  });

  test('forestPalette.card == Color(0xFF1A2E1E)', () {
    expect(forestPalette.card, const Color(0xFF1A2E1E));
  });

  test('forestPalette.surfaceElevated == Color(0xFF1A2E1E)', () {
    expect(forestPalette.surfaceElevated, const Color(0xFF1A2E1E));
  });

  test('forestPalette.surfaceMuted == Color(0xFF243E2A)', () {
    expect(forestPalette.surfaceMuted, const Color(0xFF243E2A));
  });

  test('forestPalette.controlBg == Color(0xFF2A4A30)', () {
    expect(forestPalette.controlBg, const Color(0xFF2A4A30));
  });

  test('forestPalette.bdr == Color(0x1AFFFFFF)', () {
    expect(forestPalette.bdr, const Color(0x1AFFFFFF));
  });

  test('forestPalette.div == Color(0x0DFFFFFF)', () {
    expect(forestPalette.div, const Color(0x0DFFFFFF));
  });

  test('forestPalette.sep == Color(0x1AFFFFFF)', () {
    expect(forestPalette.sep, const Color(0x1AFFFFFF));
  });

  test('forestPalette.shadow == Color(0x80000000)', () {
    expect(forestPalette.shadow, const Color(0x80000000));
  });

  test('forestPalette.t1 == Color(0xFFD8E8D8)', () {
    expect(forestPalette.t1, const Color(0xFFD8E8D8));
  });

  test('forestPalette.t2 == Color(0xFF7A9A7A)', () {
    expect(forestPalette.t2, const Color(0xFF7A9A7A));
  });

  test('forestPalette.tm == Color(0xFF4A6A4A)', () {
    expect(forestPalette.tm, const Color(0xFF4A6A4A));
  });

  test('forestPalette.a == Color(0xFF5A8A5A)', () {
    expect(forestPalette.a, const Color(0xFF5A8A5A));
  });

  test('forestPalette.aL == Color(0xFFB8D8B8)', () {
    expect(forestPalette.aL, const Color(0xFFB8D8B8));
  });

  test('forestPalette.aS == Color(0xFF6AA86A)', () {
    expect(forestPalette.aS, const Color(0xFF6AA86A));
  });

  test('forestPalette.ok == Color(0xFF72B872)', () {
    expect(forestPalette.ok, const Color(0xFF72B872));
  });

  test('forestPalette.er == Color(0xFFEF6B6B)', () {
    expect(forestPalette.er, const Color(0xFFEF6B6B));
  });

  test('forestPalette.btn == Color(0xFF5A8A5A)', () {
    expect(forestPalette.btn, const Color(0xFF5A8A5A));
  });

  test('forestPalette.btnT == Color(0xFFFFFFFF)', () {
    expect(forestPalette.btnT, const Color(0xFFFFFFFF));
  });

  test('forestPalette.nbBg == Color(0xFF1A2E1E)', () {
    expect(forestPalette.nbBg, const Color(0xFF1A2E1E));
  });

  test('forestPalette.nbBdr == Color(0x1AFFFFFF)', () {
    expect(forestPalette.nbBdr, const Color(0x1AFFFFFF));
  });

  test('forestPalette.niC == Color(0xFF4A6A4A)', () {
    expect(forestPalette.niC, const Color(0xFF4A6A4A));
  });

  test('forestPalette.id == "forest"', () {
    expect(forestPalette.id, 'forest');
  });

  // slate (light)
  test('slatePalette.bg == Color(0xFFF0F1F3)', () {
    expect(slatePalette.bg, const Color(0xFFF0F1F3));
  });

  test('slatePalette.card == Color(0xFFFAFBFC)', () {
    expect(slatePalette.card, const Color(0xFFFAFBFC));
  });

  test('slatePalette.surfaceElevated == Color(0xFFFAFBFC)', () {
    expect(slatePalette.surfaceElevated, const Color(0xFFFAFBFC));
  });

  test('slatePalette.surfaceMuted == Color(0xFFE8EAED)', () {
    expect(slatePalette.surfaceMuted, const Color(0xFFE8EAED));
  });

  test('slatePalette.controlBg == Color(0xFFE5E8EB)', () {
    expect(slatePalette.controlBg, const Color(0xFFE5E8EB));
  });

  test('slatePalette.bdr == Color(0x0F000000)', () {
    expect(slatePalette.bdr, const Color(0x0F000000));
  });

  test('slatePalette.div == Color(0x08000000)', () {
    expect(slatePalette.div, const Color(0x08000000));
  });

  test('slatePalette.sep == Color(0x0F000000)', () {
    expect(slatePalette.sep, const Color(0x0F000000));
  });

  test('slatePalette.shadow == Color(0x0F000000)', () {
    expect(slatePalette.shadow, const Color(0x0F000000));
  });

  test('slatePalette.t1 == Color(0xFF2C3E50)', () {
    expect(slatePalette.t1, const Color(0xFF2C3E50));
  });

  test('slatePalette.t2 == Color(0xFF7F8C9B)', () {
    expect(slatePalette.t2, const Color(0xFF7F8C9B));
  });

  test('slatePalette.tm == Color(0xFFA8B2BC)', () {
    expect(slatePalette.tm, const Color(0xFFA8B2BC));
  });

  test('slatePalette.a == Color(0xFF3D5A80)', () {
    expect(slatePalette.a, const Color(0xFF3D5A80));
  });

  test('slatePalette.aL == Color(0xFFB8CCE0)', () {
    expect(slatePalette.aL, const Color(0xFFB8CCE0));
  });

  test('slatePalette.aS == Color(0xFF5A88B0)', () {
    expect(slatePalette.aS, const Color(0xFF5A88B0));
  });

  test('slatePalette.ok == Color(0xFF5A8060)', () {
    expect(slatePalette.ok, const Color(0xFF5A8060));
  });

  test('slatePalette.er == Color(0xFFD04040)', () {
    expect(slatePalette.er, const Color(0xFFD04040));
  });

  test('slatePalette.btn == Color(0xFF2C3E50)', () {
    expect(slatePalette.btn, const Color(0xFF2C3E50));
  });

  test('slatePalette.btnT == Color(0xFFFFFFFF)', () {
    expect(slatePalette.btnT, const Color(0xFFFFFFFF));
  });

  test('slatePalette.nbBg == Color(0xFFFAFBFC)', () {
    expect(slatePalette.nbBg, const Color(0xFFFAFBFC));
  });

  test('slatePalette.nbBdr == Color(0x0F000000)', () {
    expect(slatePalette.nbBdr, const Color(0x0F000000));
  });

  test('slatePalette.niC == Color(0xFFA8B2BC)', () {
    expect(slatePalette.niC, const Color(0xFFA8B2BC));
  });

  test('slatePalette.id == "slate"', () {
    expect(slatePalette.id, 'slate');
  });

  // terr (light)
  test('terrPalette.bg == Color(0xFFF8F3ED)', () {
    expect(terrPalette.bg, const Color(0xFFF8F3ED));
  });

  test('terrPalette.card == Color(0xFFFFFCF8)', () {
    expect(terrPalette.card, const Color(0xFFFFFCF8));
  });

  test('terrPalette.surfaceElevated == Color(0xFFFFFCF8)', () {
    expect(terrPalette.surfaceElevated, const Color(0xFFFFFCF8));
  });

  test('terrPalette.surfaceMuted == Color(0xFFF0E8DC)', () {
    expect(terrPalette.surfaceMuted, const Color(0xFFF0E8DC));
  });

  test('terrPalette.controlBg == Color(0xFFE8DDD0)', () {
    expect(terrPalette.controlBg, const Color(0xFFE8DDD0));
  });

  test('terrPalette.bdr == Color(0x14000000)', () {
    expect(terrPalette.bdr, const Color(0x14000000));
  });

  test('terrPalette.div == Color(0x0A000000)', () {
    expect(terrPalette.div, const Color(0x0A000000));
  });

  test('terrPalette.sep == Color(0x14000000)', () {
    expect(terrPalette.sep, const Color(0x14000000));
  });

  test('terrPalette.shadow == Color(0x0D000000)', () {
    expect(terrPalette.shadow, const Color(0x0D000000));
  });

  test('terrPalette.t1 == Color(0xFF3D2B1F)', () {
    expect(terrPalette.t1, const Color(0xFF3D2B1F));
  });

  test('terrPalette.t2 == Color(0xFF8A7060)', () {
    expect(terrPalette.t2, const Color(0xFF8A7060));
  });

  test('terrPalette.tm == Color(0xFFBBA898)', () {
    expect(terrPalette.tm, const Color(0xFFBBA898));
  });

  test('terrPalette.a == Color(0xFFC0693A)', () {
    expect(terrPalette.a, const Color(0xFFC0693A));
  });

  test('terrPalette.aL == Color(0xFFE8C8A8)', () {
    expect(terrPalette.aL, const Color(0xFFE8C8A8));
  });

  test('terrPalette.aS == Color(0xFFD88550)', () {
    expect(terrPalette.aS, const Color(0xFFD88550));
  });

  test('terrPalette.ok == Color(0xFF7A9060)', () {
    expect(terrPalette.ok, const Color(0xFF7A9060));
  });

  test('terrPalette.er == Color(0xFFCC3333)', () {
    expect(terrPalette.er, const Color(0xFFCC3333));
  });

  test('terrPalette.btn == Color(0xFF3D2B1F)', () {
    expect(terrPalette.btn, const Color(0xFF3D2B1F));
  });

  test('terrPalette.btnT == Color(0xFFFFFFFF)', () {
    expect(terrPalette.btnT, const Color(0xFFFFFFFF));
  });

  test('terrPalette.nbBg == Color(0xFFFFFCF8)', () {
    expect(terrPalette.nbBg, const Color(0xFFFFFCF8));
  });

  test('terrPalette.nbBdr == Color(0x14000000)', () {
    expect(terrPalette.nbBdr, const Color(0x14000000));
  });

  test('terrPalette.niC == Color(0xFFBBA898)', () {
    expect(terrPalette.niC, const Color(0xFFBBA898));
  });

  test('terrPalette.id == "terr"', () {
    expect(terrPalette.id, 'terr');
  });

  // onyx (dark)
  test('onyxPalette.bg == Color(0xFF0C0C0E)', () {
    expect(onyxPalette.bg, const Color(0xFF0C0C0E));
  });

  test('onyxPalette.card == Color(0xFF161618)', () {
    expect(onyxPalette.card, const Color(0xFF161618));
  });

  test('onyxPalette.surfaceElevated == Color(0xFF161618)', () {
    expect(onyxPalette.surfaceElevated, const Color(0xFF161618));
  });

  test('onyxPalette.surfaceMuted == Color(0xFF1E1E20)', () {
    expect(onyxPalette.surfaceMuted, const Color(0xFF1E1E20));
  });

  test('onyxPalette.controlBg == Color(0xFF262629)', () {
    expect(onyxPalette.controlBg, const Color(0xFF262629));
  });

  test('onyxPalette.bdr == Color(0x1EFFFFFF)', () {
    expect(onyxPalette.bdr, const Color(0x1EFFFFFF));
  });

  test('onyxPalette.div == Color(0x0DFFFFFF)', () {
    expect(onyxPalette.div, const Color(0x0DFFFFFF));
  });

  test('onyxPalette.sep == Color(0x1EFFFFFF)', () {
    expect(onyxPalette.sep, const Color(0x1EFFFFFF));
  });

  test('onyxPalette.shadow == Color(0x99000000)', () {
    expect(onyxPalette.shadow, const Color(0x99000000));
  });

  test('onyxPalette.t1 == Color(0xFFE8E8E8)', () {
    expect(onyxPalette.t1, const Color(0xFFE8E8E8));
  });

  test('onyxPalette.t2 == Color(0xFF7A7A7E)', () {
    expect(onyxPalette.t2, const Color(0xFF7A7A7E));
  });

  test('onyxPalette.tm == Color(0xFF4A4A4E)', () {
    expect(onyxPalette.tm, const Color(0xFF4A4A4E));
  });

  test('onyxPalette.a == Color(0xFF9A9AAA)', () {
    expect(onyxPalette.a, const Color(0xFF9A9AAA));
  });

  test('onyxPalette.aL == Color(0xFFC8C8D8)', () {
    expect(onyxPalette.aL, const Color(0xFFC8C8D8));
  });

  test('onyxPalette.aS == Color(0xFFB0B0C0)', () {
    expect(onyxPalette.aS, const Color(0xFFB0B0C0));
  });

  test('onyxPalette.ok == Color(0xFF6A9A6A)', () {
    expect(onyxPalette.ok, const Color(0xFF6A9A6A));
  });

  test('onyxPalette.er == Color(0xFFEE6666)', () {
    expect(onyxPalette.er, const Color(0xFFEE6666));
  });

  test('onyxPalette.btn == Color(0xFF9A9AAA)', () {
    expect(onyxPalette.btn, const Color(0xFF9A9AAA));
  });

  test('onyxPalette.btnT == Color(0xFFFFFFFF)', () {
    expect(onyxPalette.btnT, const Color(0xFFFFFFFF));
  });

  test('onyxPalette.nbBg == Color(0xFF161618)', () {
    expect(onyxPalette.nbBg, const Color(0xFF161618));
  });

  test('onyxPalette.nbBdr == Color(0x1EFFFFFF)', () {
    expect(onyxPalette.nbBdr, const Color(0x1EFFFFFF));
  });

  test('onyxPalette.niC == Color(0xFF4A4A4E)', () {
    expect(onyxPalette.niC, const Color(0xFF4A4A4E));
  });

  test('onyxPalette.id == "onyx"', () {
    expect(onyxPalette.id, 'onyx');
  });

  // ─────────────────────────────────────────
  //  isDark + palettes 列表
  // ─────────────────────────────────────────
  group('isDark 判断', () {
    test('forest isDark == true', () {
      expect(forestPalette.isDark, isTrue);
    });

    test('onyx isDark == true', () {
      expect(onyxPalette.isDark, isTrue);
    });

    test('amber isDark == false', () {
      expect(amberPalette.isDark, isFalse);
    });

    test('slate isDark == false', () {
      expect(slatePalette.isDark, isFalse);
    });

    test('terr isDark == false', () {
      expect(terrPalette.isDark, isFalse);
    });
  });

  group('palettes 列表', () {
    test('长度 == 5', () {
      expect(palettes.length, 5);
    });

    test('顺序：amber → forest → slate → terr → onyx', () {
      expect(palettes[0].id, 'amber');
      expect(palettes[1].id, 'forest');
      expect(palettes[2].id, 'slate');
      expect(palettes[3].id, 'terr');
      expect(palettes[4].id, 'onyx');
    });

    test('5 个 id 互不相同', () {
      final ids = palettes.map((p) => p.id).toSet();
      expect(ids.length, 5);
    });
  });

  group('kEnableMultiTheme flag', () {
    test('默认值为 true', () {
      expect(kEnableMultiTheme, isTrue);
    });
  });
}

/// 反射获取 ThemePalette 的 22 个 Color 字段（避免为每个 palette 写 22 个 assert）
Color _fieldByName(ThemePalette p, String name) {
  switch (name) {
    case 'bg': return p.bg;
    case 'card': return p.card;
    case 'surfaceElevated': return p.surfaceElevated;
    case 'surfaceMuted': return p.surfaceMuted;
    case 'controlBg': return p.controlBg;
    case 'bdr': return p.bdr;
    case 'div': return p.div;
    case 'sep': return p.sep;
    case 'shadow': return p.shadow;
    case 't1': return p.t1;
    case 't2': return p.t2;
    case 'tm': return p.tm;
    case 'a': return p.a;
    case 'aL': return p.aL;
    case 'aS': return p.aS;
    case 'ok': return p.ok;
    case 'er': return p.er;
    case 'btn': return p.btn;
    case 'btnT': return p.btnT;
    case 'nbBg': return p.nbBg;
    case 'nbBdr': return p.nbBdr;
    case 'niC': return p.niC;
  }
  throw ArgumentError('Unknown token: $name');
}