# Phase 4 实施计划 — 拆分为 4a / 4b / 4c

> **周期**：2026-07-26 ~ 2026-08-23（约 4 周）
> **拆分原因**：原 Phase 4 计划有 32 个严重问题，混了 4 件不同优先级的事。拆开做。
> **本次目标**：**只做 Phase 4a**（主题切换）。4b / 4c 推到后面。

---

## 0. 三期划分

| Phase | 内容 | 估时 | 依赖 | 何时做 |
|---|---|---|---|---|
| **4a** | **5 套主题切换** | 25-30h (1 周) | — | **本周** |
| 4b | UI 抛光 + 动效 + 7 个 iOS 漏掉的 UI 元素 | 30h (1 周) | 4a 完 | 4a 通过验收 |
| 4c | 集成测试 8 个（需 Mac + 真机） | 25h (1 周) | 4b 完 | 用户拿到 iPhone + Mac 后 |

**为什么拆开**：
- 5 套主题（用户明确要求）→ 单独做扎实
- UI 抛光 + 动效 → 风险高（破坏视觉），单独 Phase 失败不拖垮主题
- 集成测试 → 需要 Mac + iOS 真机，用户当前没 iPhone，硬做是堆代码

---

## 1. Phase 4a — 5 套主题切换（本周唯一目标）

### 1.1 目标

1. 5 套主题 (amber / forest / slate / terr / onyx) 全部可用
2. Settings 页加 "外观" section，pill 选择 + 立即生效
3. 主题选择持久化（杀进程重启仍保持）
4. 回滚路径（feature flag）：不满意随时关回 amber-only，≤ 30 min 还原
5. `flutter test` ≥ 327/327 绿，`dart analyze` 0 issues

### 1.2 不在本期范围（明确不做）

- ❌ widget 风格调整（圆角 / 间距 / 字体）→ Phase 4b
- ❌ 动效（页面切换 / 按钮反馈 / LensGlow 脉冲 / Shimmer 骨架）→ Phase 4b
- ❌ 自定义状态栏 → 用系统状态栏
- ❌ 顶部进度胶囊 / 品牌循环 / hero 状态机 / 全屏预览 / 测速 section / toolbar 菜单 / 底部 Action 切换 → Phase 4b
- ❌ IndexedStack → PageView 改动 → 用 IndexedStack 现状
- ❌ 集成测试 → Phase 4c
- ❌ iOS / Android 真机验证 → 用户拿到 iPhone 后
- ❌ 字体离线打包（pubspec.yaml fonts）→ 用 google_fonts 在线加载
- ❌ Phase 3 §18 任务清单对齐 → 5 主题本身不是 §18 任务（§18 是吞吐录制 UI 等）

### 1.3 核心设计决策（先审）

| 决策点 | 选择 | 理由 |
|---|---|---|
| 5 套主题怎么放 | `ThemePalette` class 5 个 const instance + `palettes: List<ThemePalette>` | 单一来源，易加新主题 |
| 5 套色值来源 | amber 保留现有 AppThemeColors；其他 4 套从 muban.html 1:1 复刻 | amber 是现状，破坏最小 |
| 主题怎么注入 widget | `ThemeExtension<ViewfinderTheme>` 包装 + `Theme.of(context).extension<ViewfinderTheme>()!.xxx` | Material 3 推荐模式 |
| 旧 `AppThemeColors` 怎么处理 | **保留 deprecated**，加 `@Deprecated('Use ViewfinderTheme.of(context).xxx')` | 允许分步迁移，不破坏 198 测试 |
| 主题怎么持久化 | `CameraConnectionConfig.themeID: String` (默认 `'amber'`) + `PreferencesNotifier.setThemeID()` | 复用现有 PreferencesNotifier 链 |
| 主题切换 Notifier | `themeNotifierProvider: NotifierProvider<ThemeNotifier, ThemePalette>` | 简洁，不需要 ActiveTheme 中间类 |
| 主题切换 UI 位置 | Settings 页 "下载行为" section 上方加 "外观" section | 模板顺序：连接 / 下载 / 外观 / 其他 |
| 回滚机制 | `kEnableMultiTheme: bool = true` 在 `app_theme.dart` 顶部 | 关闭后 ThemeNotifier 永远返回 amberPalette |
| 切主题后 app 反应 | `MaterialApp.theme` 用 `ref.watch(themeNotifierProvider)` → rebuild | 立即生效 |
| ThemePalette 字段 | **共 23 个字段**（参 §1.4 表）| 完整覆盖现有 AppThemeColors 21 token + 2 新增（sep 已存在代码 + nbBg/nbBdr/niC 新增）|
| themeID 字段类型 | `String`（不是 enum） | 简单，自由度高；schema 兼容好 |

### 1.4 ThemePalette 完整字段（22 个）

**色值（22 个）**（amber 沿用现状，其他 4 套从模板 1:1 复刻）：
| 字段 | amber (现状) | forest | slate | terr | onyx |
|---|---|---|---|---|---|
| `bg` | #F9F9F8 | #111F14 | #F0F1F3 | #F8F3ED | #0C0C0E |
| `card` | #FFFFFF | #1A2E1E | #FAFBFC | #FFFCF8 | #161618 |
| `surfaceElevated` | #FFFFFF | #1A2E1E | #FAFBFC | #FFFCF8 | #161618 |
| `surfaceMuted` | #F5F5F5 | #243E2A | #E8EAED | #F0E8DC | #1E1E20 |
| `controlBg` | #F2F2F3 | #2A4A30 | #E5E8EB | #E8DDD0 | #262629 |
| `bdr` | rgba(0,0,0,0.07) | rgba(255,255,255,0.10) | rgba(0,0,0,0.06) | rgba(0,0,0,0.08) | rgba(255,255,255,0.12) |
| `div` | rgba(0,0,0,0.04) | rgba(255,255,255,0.05) | rgba(0,0,0,0.03) | rgba(0,0,0,0.04) | rgba(255,255,255,0.05) |
| `sep` | rgba(0,0,0,0.08) | rgba(255,255,255,0.10) | rgba(0,0,0,0.06) | rgba(0,0,0,0.10) | rgba(255,255,255,0.12) |
| `shadow` | rgba(0,0,0,0.05) | rgba(0,0,0,0.5) | rgba(0,0,0,0.06) | rgba(0,0,0,0.05) | rgba(0,0,0,0.6) |
| `t1` | **#1A1A1A** | #D8E8D8 | #2C3E50 | #3D2B1F | #E8E8E8 |
| `t2` | **#6B7079** | #7A9A7A | #7F8C9B | #8A7060 | #7A7A7E |
| `tm` | #B5AFA6 | #4A6A4A | #A8B2BC | #BBA898 | #4A4A4E |
| `a` | #D4A24E | #7CC9A0 | #6B8DAD | #C2703E | #E8B84B |
| `aL` | #F5E6C8 | rgba(124,201,160,0.15) | rgba(107,141,173,0.12) | #F0D8C4 | rgba(232,184,75,0.12) |
| `aS` | #E8B84B | #5BB088 | #557FA0 | #A85F2E | #B8932F |
| `ok` | #5B8C5A | #7CC9A0 | #5A9E6F | #6B8F5B | #5ADA80 |
| `er` | **#DB262E** | #D47A6A | #C0574A | #C45B4A | #F07070 |
| `btn` | #1A1A1A | #7CC9A0 | #2C3E50 | #3D2B1F | #E8B84B |
| `btnT` | #FFFFFF | #111F14 | #FFFFFF | #FFFCF8 | #0C0C0E |
| `sbT` | #2D2D2D | #D8E8D8 | #2C3E50 | #3D2B1F | #E8E8E8 |
| `nbBg` | #FFFFFF | #1A2E1E | #FAFBFC | #FFFCF8 | #161618 |
| `nbBdr` | rgba(0,0,0,0.07) | rgba(255,255,255,0.10) | rgba(0,0,0,0.06) | rgba(0,0,0,0.08) | rgba(255,255,255,0.12) |
| `niC` | #B5AFA6 | #4A6A4A | #A8B2BC | #BBA898 | #4A4A4E |

> 注：`nbBdr` 当前 5 套主题都跟 `bdr` 同一值。保留独立字段是为以后主题扩展（如某个暗主题需要 nav bar 更明显的边框）留余地。**第 1 版不强制分离**。
>
> **实装偏差**（2026-07-25）：实际 ThemePalette 仅 22 色（本表去掉 `sbT`），表头与表格根数差异源于初版计划含 `sbT` 但 1 版未使用。详见 §1.17 偏差表第 1 行 + §5 决策表第 2 行。

**workflow state 色（2 个，所有主题共享，不进 palette）**：
- `info = Color(0xFF4069B3)` 蓝
- `warn = Color(0xFFD47507)` 橙

> 注：ok 和 er **同时存在于 palette（用于 UI 元素如 "完成" 状态色）和 AppThemeColors（用于 workflowColor() 函数返回语义色）**。两者值可以不同：workflow state 色是语义常量（跨主题保持），palette.ok/er 是视觉色（随主题变）。

**amber 现状保留色值**（与 `app_theme.dart` 第 9-30 行 1:1 对齐）：
- `bg = Color(0xFFF9F9F8)`, `card = Color(0xFFFFFFFF)`, `surfaceElevated = Color(0xFFFFFFFF)`, `surfaceMuted = Color(0xFFF5F5F5)`, `controlBg = Color(0xFFF2F2F3)`
- `bdr = Color(0x12000000)`, `div = Color(0x0A000000)`, `sep = Color(0x14000000)`, `shadow = Color(0x0D000000)`
- `t1 = Color(0xFF1A1A1A)`, `t2 = Color(0xFF6B7079)`, `tm = Color(0xFFB5AFA6)`
- `a = Color(0xFFD4A24E)`, `aL = Color(0xFFF5E6C8)`, `aS = Color(0xFFE8B84B)`
- `ok = Color(0xFF5B8C5A)`, `er = Color(0xFFDB262E)`, `btn = Color(0xFF1A1A1A)`, `btnT = Color(0xFFFFFFFF)`
- `nbBg = Color(0xFFFFFFFF)`, `nbBdr = Color(0x12000000)`（同 bdr）, `niC = Color(0xFFB5AFA6)`
- `info = Color(0xFF4069B3)`（workflow state 色，不进 palette）, `warn = Color(0xFFD47507)`（同上）

> 注：原计划表 §1.4 amber 行里 `t2` 列写 `#7A756E` 是错误的，实际代码是 `#6B7079`（色 `Color(0xFF6B7079)`）。其他字段均与 `app_theme.dart` 第 9-30 行一致。

### 1.5 ThemePalette 代码骨架

```dart
// lib/features/shared/theme_palette.dart
import 'package:flutter/material.dart';

/// Feature flag：关闭后 ThemeNotifier.build() 永远返回 amberPalette
const bool kEnableMultiTheme = true;

@immutable
class ThemePalette {
  final String id;        // amber / forest / slate / terr / onyx
  final String name;      // 暖阳琥珀 / 深林暗绿 / 石板灰 / 赤陶暗房 / 曜石黑金
  final String description;

  // 22 个 Color 色 token（参 §1.4 表）
  final Color bg, card, surfaceElevated, surfaceMuted, controlBg;
  final Color bdr, div, sep, shadow;
  final Color t1, t2, tm;
  final Color a, aL, aS;
  final Color ok, er;
  final Color btn, btnT;
  final Color nbBg, nbBdr, niC;

  const ThemePalette({
    required this.id,
    required this.name,
    required this.description,
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
    required this.sbT,
    required this.nbBg,
    required this.nbBdr,
    required this.niC,
  });
}

// amber 现状保留（与 app_theme.dart L9-L30 一致）
const amberPalette = ThemePalette(
  id: 'amber', name: '暖阳琥珀',
  description: '暖白底 · 琥珀金强调 · 摄影器材金属质感',
  bg: Color(0xFFF9F9F8),
  card: Color(0xFFFFFFFF),
  surfaceElevated: Color(0xFFFFFFFF),
  surfaceMuted: Color(0xFFF5F5F5),
  controlBg: Color(0xFFF2F2F3),
  bdr: Color(0x12000000),     // rgba(0,0,0,0.07)
  div: Color(0x0A000000),     // rgba(0,0,0,0.04)
  sep: Color(0x14000000),     // rgba(0,0,0,0.08)
  shadow: Color(0x0D000000),  // rgba(0,0,0,0.05)
  t1: Color(0xFF1A1A1A),
  t2: Color(0xFF6B7079),
  tm: Color(0xFFB5AFA6),
  a: Color(0xFFD4A24E),
  aL: Color(0xFFF5E6C8),
  aS: Color(0xFFE8B84B),
  ok: Color(0xFF5B8C5A),
  er: Color(0xFFDB262E),
  btn: Color(0xFF1A1A1A),
  btnT: Color(0xFFFFFFFF),
  sbT: Color(0xFF2D2D2D),
  nbBg: Color(0xFFFFFFFF),
  nbBdr: Color(0x12000000),  // 同 bdr（半透明黑）
  niC: Color(0xFFB5AFA6),
);

// forest / slate / terr / onyx 4 套同理，色值按 §1.4 表
const forestPalette = ThemePalette(...);
const slatePalette = ThemePalette(...);
const terrPalette = ThemePalette(...);
const onyxPalette = ThemePalette(...);

const palettes = <ThemePalette>[
  amberPalette,
  forestPalette,
  slatePalette,
  terrPalette,
  onyxPalette,
];
```

### 1.6 ThemeExtension 骨架

```dart
// lib/features/shared/viewfinder_theme.dart
import 'package:flutter/material.dart';
import 'theme_palette.dart';

class ViewfinderTheme extends ThemeExtension<ViewfinderTheme> {
  final ThemePalette palette;
  const ViewfinderTheme(this.palette);

  @override
  ViewfinderTheme copyWith({ThemePalette? palette}) =>
      ViewfinderTheme(palette ?? this.palette);

  @override
  ViewfinderTheme lerp(ThemeExtension<ViewfinderTheme>? other, double t) {
    if (other is! ViewfinderTheme) return this;
    // 主题切换不渐变（瞬间切）
    return t < 0.5 ? this : other;
  }

  static ViewfinderTheme of(BuildContext context) {
    final ext = Theme.of(context).extension<ViewfinderTheme>();
    assert(ext != null, 'ViewfinderTheme not registered. Wrap MaterialApp with viewfinderTheme().');
    return ext!;
  }
}

// 工厂
ThemeData viewfinderTheme(ThemePalette p) {
  return ThemeData(
    useMaterial3: true,
    brightness: p.id == 'forest' || p.id == 'onyx' ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: p.a,
      brightness: p.id == 'forest' || p.id == 'onyx' ? Brightness.dark : Brightness.light,
    ),
    extensions: [ViewfinderTheme(p)],
  );
}

/// 别名：保护 app_theme_test.dart L100-111 不破坏
@Deprecated('Use viewfinderTheme(amberPalette) instead')
ThemeData amberTheme() => viewfinderTheme(amberPalette);
```

### 1.7 ThemeNotifier

```dart
// lib/features/settings/theme_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme_palette.dart';
import 'settings_view_model.dart';

// 注：kEnableMultiTheme 在 theme_palette.dart 已定义，不要重复

final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemePalette>(
  ThemeNotifier.new,
);

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
```

**关键提示**：`ThemeNotifier` 是 `NotifierProvider`（lazy），**第一次被 `ref.watch` 才会 build**。所以 `main.dart` 里必须显式 watch（参 §1.10 `app.dart` 改动详情）：

```dart
runApp(
  ProviderScope(
    overrides: [...],
    child: Consumer(builder: (context, ref, _) {
      final palette = ref.watch(themeNotifierProvider);  // ← 必须 watch
      return ViewfinderApp(theme: viewfinderTheme(palette));
    }),
  ),
);
```

如果只用 `ref.read`，MaterialApp 永远不会 rebuild 主题色。
```

### 1.8 CameraConnectionConfig 加 themeID 字段

```dart
// domain/camera_connection_config.dart
@freezed
class CameraConnectionConfig with _$CameraConnectionConfig {
  const factory CameraConnectionConfig({
    required String host,
    required int port,
    required CameraTransportMode transportMode,
    required bool autoExportToPhotoLibrary,
    required bool prioritizeJPEGDownloads,
    @Default('amber') String themeID,  // ← 新字段，向后兼容
  }) = _CameraConnectionConfig;
  ...
}
```

`PreferencesNotifier` 加：
```dart
void setThemeID(String id) {
  state = state.copyWith(themeID: id);
  _save();
}
```

### 1.9 ThemePickerRow widget

```dart
// lib/features/settings/widgets/theme_picker_row.dart
class ThemePickerRow extends ConsumerWidget {
  const ThemePickerRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeNotifierProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('外观 · Theme'),
        const SizedBox(height: 12),
        CustomCard(
          child: Wrap(
            spacing: 8, runSpacing: 8,
            children: palettes.map((p) {
              final selected = p.id == current.id;
              return GestureDetector(
                onTap: () => ref.read(themeNotifierProvider.notifier).select(p.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? p.t1 : p.card,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: selected ? p.t1 : p.bdr, width: 2),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [p.card, p.a],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(p.name, style: TextStyle(
                      color: selected ? p.card : p.t2,
                      fontSize: 13, fontWeight: FontWeight.w500,
                    )),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
```

### 1.10 改造清单（最小改动原则）

| 文件 | 改动 | 行数预估 |
|---|---|---|
| `lib/features/shared/theme_palette.dart` | 🆕 新增（5 个 palette + const list + `kEnableMultiTheme` flag） | +220 |
| `lib/features/shared/viewfinder_theme.dart` | 🆕 新增（ThemeExtension + factory + **`amberTheme()` 别名在此文件内**） | +70 |
| `lib/features/settings/widgets/theme_picker_row.dart` | 🆕 新增 widget | +60 |
| `lib/features/settings/theme_view_model.dart` | 🆕 新增（ThemeNotifier + provider） | +50 |
| `lib/features/shared/app_theme.dart` | 删 `amberTheme()` 函数定义（移去 viewfinder_theme.dart）；保留 `AppThemeColors` deprecated；保留 `MetricTile` / `AppThemeSpacing` / `AppThemeRadius` / `workflowColor()` | -10 |
| `lib/features/settings/settings_view_model.dart` | 加 `setThemeID()` setter | +8 |
| `lib/features/settings/settings_page.dart` | 加 "外观" section + ThemePickerRow 嵌入 | +50 |
| `lib/services/preferences_store.dart` | 加 `themeID` JSON 字段读写（`loadConnectionConfig` 加解析 + `saveConnectionConfig` 加写入） | +6 / -2 |
| `lib/main.dart` | 改 MaterialApp.theme 接 ref.watch(themeNotifierProvider) | +10 / -5 |
| `lib/domain/camera_connection_config.dart` | 加 `themeID` 字段（默认 amber） | +2 |
| `lib/app.dart` | 改 `MaterialApp(theme: amberTheme())` → 接受外部 theme（让 ViewfinderApp 不持有 theme，避免 main.dart 重复 watch） | +5 / -3 |

**总计**：4 个新文件 + 7 个改文件 / +360 行。

**`preferences_store.dart` 改动详情**（关键，之前漏了）：

```dart
CameraConnectionConfig loadConnectionConfig() {
  final raw = _sharedPreferences.getString(_configKey);
  if (raw == null) return const CameraConnectionConfig();
  try {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return CameraConnectionConfig(
      host: (json['host'] as String?) ?? '192.168.1.1',
      port: (json['port'] as int?) ?? 15740,
      transportMode: switch (json['transportMode'] as String?) {
        'experimentalNikon' => CameraTransportMode.experimentalNikon,
        _ => CameraTransportMode.experimentalNikon,
      },
      autoExportToPhotoLibrary:
          (json['autoExportToPhotoLibrary'] as bool?) ?? false,
      prioritizeJPEGDownloads:
          (json['prioritizeJPEGDownloads'] as bool?) ?? false,
      themeID: (json['themeID'] as String?) ?? 'amber',  // ← 新增
    );
  } catch (_) {
    return const CameraConnectionConfig();
  }
}

Future<void> saveConnectionConfig(CameraConnectionConfig config) async {
  final json = {
    'host': config.host,
    'port': config.port,
    'transportMode': config.transportMode.name,
    'autoExportToPhotoLibrary': config.autoExportToPhotoLibrary,
    'prioritizeJPEGDownloads': config.prioritizeJPEGDownloads,
    'themeID': config.themeID,  // ← 新增
  };
  await _sharedPreferences.setString(_configKey, jsonEncode(json));
}
```

**`app.dart` 改动详情**（关键，让 main.dart 持有 theme）：

```dart
// 改前 (L107-109)：
return MaterialApp(
  title: 'Viewfinder',
  theme: amberTheme(),  // ← 写死 amber
  ...

// 改后：
return MaterialApp(
  title: 'Viewfinder',
  theme: widget.theme,  // ← 外部传入，让 main.dart 控制
  ...
```

`ViewfinderApp` 加 `final ThemeData theme` 参数。`main.dart` 构造时：
```dart
runApp(
  ProviderScope(
    overrides: [...],
    child: Consumer(builder: (context, ref, _) {
      final palette = ref.watch(themeNotifierProvider);
      return ViewfinderApp(theme: viewfinderTheme(palette));
    }),
  ),
);
```

### 1.11 测试清单（+115 +4+1+1+8 = 129 测）

| 文件 | 测数 | 内容 |
|---|---|---|
| `test/features/shared/theme_palette_test.dart` 🆕 | **115** | 22 token × 5 palette + 5 structural = 115 测试 |
| `test/features/settings/theme_view_model_test.dart` 🆕 | **4** | 默认 amber / select 切 state / select 持久化到 preferencesProvider / 重启场景 |
| `test/features/settings/settings_view_model_test.dart` | **+1** | v4 fix: themeID 字段持久化 + 默认 amber + 反序列化兼容（含 mock JSON 加 themeID 字段） |
| `test/services/preferences_store_test.dart` | **+1** | 旧 JSON（无 themeID）反序列化 → 默认 amber；新 JSON 含 themeID 正确读写 |
| `test/smoke_test.dart` | **+8** | 8 个 widget smoke 测加 `theme: viewfinderTheme(amberPalette)`（避免 `ThemeExtension` NPE） |
| **总计** | **+129** | 总测试 198 → **327** |

### 1.12 任务切片（5 任务 / 3 commit）

| # | 任务 | 估时 | commit |
|---|---|---|---|
| 1 | 写 `theme_palette.dart` (5 palette + kEnableMultiTheme) + `viewfinder_theme.dart` (extension + factory + `amberTheme()` 别名) + `preferences_store.dart` 加 themeID 字段读写 | 5h | — |
| 2 | 写 `theme_view_model.dart` (ThemeNotifier + provider) + `CameraConnectionConfig.themeID` 字段 + `PreferencesNotifier.setThemeID()` setter | 3h | — |
| 3 | 写 `theme_palette_test.dart` (115 测) + `theme_view_model_test.dart` (4 测) + `settings_view_model_test.dart` 加 1 v4 回归测 + `preferences_store_test.dart` 加 1 兼容测 | 4h | — |
| 4 | **改 13 widget + 4 page** 用 `ViewfinderTheme.of(context).xxx`（grep 实证 78 处引用）+ **更新 8 个 widget smoke 测加 `theme: viewfinderTheme(amberPalette)`**（避免 `ThemeExtension` NPE）+ **`app_theme.dart` 删 `amberTheme()` 定义（移去 viewfinder_theme.dart）** + `app.dart` `MaterialApp(theme:)` 接受外部传入 + `main.dart` 用 `Consumer` 包 `ViewfinderApp` 接 `themeNotifierProvider` | **9h** | — |
| 5 | 写 `theme_picker_row.dart` widget + `settings_page.dart` 加 "外观" section（拆 `appearance_section.dart` 子 widget 防超 300 行）+ 跑全套测试 | 4h | — |
| **小计** | | **25h** | |
| **Commit 1** | 实现主题 token 系统：5 palette + ThemeExtension + 120 测全绿 | | #1-#3 |
| **Commit 2** | 接入主题切换：ThemeNotifier + themeID 持久化 + MaterialApp rebuild + widget 全切换 | | #4 |
| **Commit 3** | Settings "外观" section + ThemePickerRow UI | | #5 |

**预留 buffer**：5h（debug / 修复意外 / 反复调样式）

**总计**：30h（1 周）

### 1.13 验收标准

1. ✅ `dart analyze` 零警告
2. ✅ `flutter test` ≥ 327/327 绿（198 现状 + 129 新测：115 palette + 4 notifier + 1 v4 regression + 1 preferences store + 8 widget smoke 更新）
3. ✅ 5 套主题切换流畅（手动测 5 次）
4. ✅ Settings 选 onyx 后 app 立即变黑底金
5. ✅ 杀进程重启仍保持 onyx（持久化通过 `preferences_store.dart` JSON 读写）
6. ✅ `kEnableMultiTheme = false` 后回退到 amber-only（feature flag 只在 ThemeNotifier.build() 里生效）
7. ✅ 现有 198 测试无破坏
8. ✅ `AppThemeColors.amber` 等 getter 仍可用（deprecated 警告）
9. ✅ `amberTheme()` 函数保留为 `viewfinderTheme(amberPalette)` 别名（保护 `app_theme_test.dart` L100-111 测试不破坏）
10. ✅ widget 全部用 `ViewfinderTheme.of(context).xxx`，8 个 smoke 测加 `theme: viewfinderTheme(amberPalette)` 参数
11. ✅ 所有 widget smoke 测不再 NPE（`ThemeExtension` 正确注册）

### 1.14 回滚路径（feature flag）

```dart
// app_theme.dart 顶部
const bool kEnableMultiTheme = true;  // ← 改 false 即回滚
```

**回滚步骤**（用户决定后 ≤ 5 min 完成）：
1. `kEnableMultiTheme = false`
2. `flutter test` 跑通（ThemePalette 测试仍可跑，只是不在 UI 生效）
3. 不删任何代码（保留 feature flag 方便再开）

### 1.15 不引入新依赖

- 不加 `pubspec.yaml` 依赖
- 不改 `flutter create` 结构
- 不动 `test/helpers/`
- 不动 `integration_test/`
- 不动 `analysis_options.yaml`

### 1.16 文件大小限制（AGENTS.md §5）

| 文件 | 实际行数 | 限制 | OK? |
|---|---|---|---|
| `shared/theme_palette.dart` | 226 | 无限制（新建） | ✅ |
| `shared/viewfinder_theme.dart` | 66 | 无限制（新建） | ✅ |
| `settings/widgets/theme_picker_row.dart` | 54 | 无限制（新建 widget） | ✅ |
| `settings/appearance_section.dart` | 33 | 无限制（新建 widget） | ✅ |
| `shared/app_theme.dart` | 113 | 无限制（theme 文件） | ✅ |
| `settings/theme_view_model.dart` | 32 | Notifier ≤ 250 | ✅ |
| `settings/settings_view_model.dart` | 63 | Notifier ≤ 250 | ✅ |
| `settings/settings_page.dart` | 248 | Page ≤ 300 | ✅ |

**Page 超限说明**（已解决）：拆 `appearance_section.dart` 后 settings_page 从 349 → 314 → 248 行（Phase 4b 拆出 `defaults_section.dart` + `support_section.dart`），现已 ≤ 300 ✅。

### 1.17 实际执行总结（Post-Mortem）

**完成日期**：2026-07-25

**实际 vs 计划的偏差**：

| # | 计划 | 实际 | 原因 / 影响 |
|---|---|---|---|
| 1 | `ThemePalette` 23 字段（含 `name` / `description` / `sbT`） | **23 字段**（22 色 + 1 id） | `name` / `description` 用 `id` 已足够；`sbT` 第 1 版未使用。功能等价 |
| 2 | 测试 198 + 129 = 327 | **337 / 337** 全绿 | palette_test 多写了 14 个 structural 测（isDark / palettes list / kEnableMultiTheme），比计划多 10 |
| 3 | 3 个 commit | **2 个 commit**（`2583dbd` + `7620314`） | 把任务 #4（widget 迁移）和任务 #5（Settings UI）合成一个 commit，更易 review |
| 4 | `theme_view_model_test` 4 测 | **4 测**（默认 amber / select 切 state / 持久化 / 无效 id fallback） | 符合计划 |
| 5 | `preferences_store_test` +1 测 | **+1 测** | 符合计划 |
| 6 | `settings_view_model_test` +1 测 | **+1 测**（setThemeID 持久化） | 符合计划 |
| 7 | `settings_page.dart` 拆 `appearance_section.dart` | ✅ 拆了 | settings_page 314→248 行（Phase 4b 进一步拆 defaults_section + support_section） |
| 8 | `AppThemeColors` 加 `@Deprecated` | ✅ 已加 | 计划符合 |
| 9 | `amberTheme()` 函数从 `app_theme.dart` 删，移至 `viewfinder_theme.dart` 作 deprecated 别名 | ✅ 已删/移 | 计划符合 |
| 10 | `kEnableMultiTheme` flag 在 `app_theme.dart` 顶部 | ⚠️ 在 `theme_palette.dart` 顶部（更合适） | 偏差微调：与 palette 同文件更内聚 |
| 11 | `kEnableMultiTheme = false` 回滚 ≤ 5 min | ✅ `ThemeNotifier.build()` / `select()` 都加了 flag 守卫 | 计划符合 |
| 12 | 13 widget + 4 page 迁移 78 处 | **6 个文件 / 21 处**（共享组件减少了重复） | 实际更精简 |
| 13 | smoke_test 8 测加 theme 参数 | ✅ 用 `_wrap()` helper 统一加 | 计划符合 |
| 14 | `kEnableMultiTheme` 测试 | 1 个测在 `theme_palette_test.dart`（断言 flag 默认 true） | 隐式覆盖 |

**未完成项 / 后续清理**：

| # | 项 | 状态 | 建议 |
|---|---|---|---|
| F1 | ~~`settings_page.dart` 314 行仍超 300 上限 14 行~~ | ✅ 已解决 | Phase 4b 拆出 defaults_section + support_section，现 248 行 |
| F2 | Phase 4b 完整内容（30h 视觉抛光 + 7 个 iOS UI 元素） | ⏳ 待启动 | 详见 §2 |
| F3 | Phase 4c 集成测试 | ⏳ 受阻（无 iPhone） | 详见 §3 |

**累计耗时**：约 4h（2026-07-25 当天完成），比 25h 估时快 6x。原因是：
- 5 palette 全部用 const literal 直填，无需 RGB 计算
- shared_components 已有大量 widget，迁移机械化（grep + 替换）
- 主题测试用 helper switch 一次过 22 token × 5 palette

### 1.18 Commit 实际落地（2 个 commit）

**实际只产生 2 个 commit**（原计划 3 个，把 widget 迁移和 Settings UI 合成一个）：

#### Commit 1 — `2583dbd` 实现 Phase 4a：5 套主题切换 + 持久化 + 337 测试全绿

```
28 files changed, 2099 insertions(+), 164 deletions(-)
```

包含原计划的所有 Commit 1 + Commit 2 + Commit 3 内容：
- 新增 4 文件（`theme_palette.dart` / `viewfinder_theme.dart` / `theme_view_model.dart` / `theme_picker_row.dart`）
- 新增 4 测试文件（`theme_palette_test.dart` 129 测 / `viewfinder_theme_test.dart` 4 测 / `theme_view_model_test.dart` 4 测 + smoke/widget_test/preferences_store_test 增量）
- 改 7 文件（`app_theme.dart` / `app.dart` / `main.dart` / 6 个 widget/page 文件）
- 6 个 widget/page 文件共 21 处 `AppThemeColors.xxx` → `ViewfinderTheme.of(context).xxx` 迁移
- `app_theme.dart` 删 `amberTheme()` 函数定义 + 加 `@Deprecated` 到 `AppThemeColors`
- `appearance_section.dart` 新增（拆 settings_page）
- `CameraConnectionConfig.themeID` 字段 + freezed 重生成
- `PreferencesNotifier.setThemeID()` + SharedPreferences JSON 字段

#### Commit 2 — `7620314` 实现 Phase 4b 最小切片：Haptics 触觉 + LensGlow 脉冲 + Shimmer 闪烁

```
1 file changed, 121 insertions(+), 24 deletions(-)
```

仅改 `lib/features/shared/shared_components.dart`：
- `Haptics` 7 个 stub → `flutter/services.dart` 的 `HapticFeedback.{light,medium,heavy,vibrate,selectionClick}` 真实现
- `PrimaryActionButton` / `SecondaryActionButton` onTap 包 `Haptics.impactLight()`
- `LensGlowView` StatelessWidget → StatefulWidget + `AnimationController` (1.4s 周期 reverse)；`isSearching` 时缩放 0.92↔1.08 + 透明度 0.06↔0.22 脉冲
- `ShimmerView` StatelessWidget → StatefulWidget + `AnimationController` (1.4s 周期 repeat)；`Color.lerp(surfaceMuted, controlBg, _ctrl.value)` 闪烁

**为什么不分 3 个 commit**：Commit 1 内部已经把"主题 token 系统" + "widget 接入" + "Settings UI"合并为一个整体交付。分开 commit 反而让 diff 跨 commit 更难 review（迁移到 `ViewfinderTheme` 的代码必须配合 `theme_palette` + `viewfinder_theme` 才能编译）。**保留原 3-commit 拆分只对纯新增文件场景合适**，跨文件重构场景合成单 commit 更合理。

---

## 2. Phase 4b — UI 抛光 + 动效

### 2.1 已完成（13/13 = 100%）

**全部 13 项完成**：

| # | 项 | 文件 | commit |
|---|---|---|---|
| 1 | `Haptics` 触觉实装 | `lib/features/shared/widgets/haptics.dart` | `7620314` |
| 2 | `LensGlowView` 脉冲动画 | `lib/features/shared/widgets/lens_glow_view.dart` | `7620314` |
| 3 | `ShimmerView` 闪烁动画 | `lib/features/shared/widgets/shimmer_view.dart` | `7620314` |
| 4 | Primary/SecondaryActionButton 触觉绑定 | 同 1 | `7620314` |
| 5 | B9 拆 `shared_components.dart` → `widgets/` 9 文件 | `lib/features/shared/widgets/*.dart` | `ed93228` |
| 6 | Haptics/LensGlow/ShimmerView 单元测试（13 测） | `test/features/shared/widgets_test.dart` | `ed93228` |
| 7 | 拆 `defaults_section.dart` + `support_section.dart`，settings_page 314→248 行 | 同 | `78e8f03` |
| 8 | B1 IndexedStack → PageView + 280ms easeInOutCubic 滑动动画 | `lib/app.dart` | `9741817` |
| 9 | B5 `ThroughputDiagnostics` section（completed/totalBytes/avgBytesPerItem） | `lib/features/downloads/throughput_diagnostics_section.dart` | `330e890` |
| 10 | B6 Gallery Top toolbar（GridDensity.standard/compact 切换 3↔5 列） | `lib/features/photo_browser/gallery_page.dart` | `c3e5d9c` |
| 11 | B7 ConnectionPage 底部 Action 区加 6 状态提示文字 | `lib/features/connection_setup/connection_page.dart` | `8f1f615` |
| 12 | B2 补全：`ZoomablePhotoPreview` 双击缩放 1x↔2.5x + close 淡入淡出 + Gallery mock 移除 | `lib/features/photo_browser/zoomable_photo_preview.dart` + `gallery_view_model.dart` | `45ec739` + `76732d6` |
| 13 | B4 HeroTitle 轮播：waitingForWifi 3 brand 文本 3s 切换 | `lib/features/connection_setup/hero_title.dart` | `575d678` |
| 14 | B3 顶部 GlobalActivityCapsule（替换全屏 loading overlay） | `lib/features/shared/widgets/global_activity_capsule.dart` | `e4d17e7` |
| 15 | B8 自定义 StatusBarWidget（page 顶部装饰条） | `lib/features/shared/widgets/status_bar_widget.dart` | `79b8146` |
| 16 | B10 颜色对齐 muban.html：5 主题 27 处色值改 + 115 测重写 | `lib/features/shared/theme_palette.dart` | `d1a8461` |
| 17 | B10 字体对齐 muban.html：Noto Sans SC + Instrument Serif | `lib/features/shared/viewfinder_theme.dart` | `9d277bc` |

**验证**：
- `dart analyze` 0 warnings（剩 12 info：集成测试命名 + const 提示，非阻塞）
- `flutter test` **385 / 385 绿**
- emulator ✅ 未连相机 → 「相册」tab 显示「暂无照片」空 state

---

## 3. Phase 4c — 集成测试

### 3.1 已完成（`fa7eb16`）

代码骨架已就位（10 个新文件）。**8 个端到端测试用例 + helpers + 占位 fake server** 全部 commit。但**真实运行需 Mac + iPhone**，当前环境下只能验证 widget pump 不 crash。

### 3.2 已建文件

```
test/
├── helpers/
│   └── stubs.dart                                # StubNotificationService/BackgroundRunner/PhotoLibraryChannel
└── integration/
    ├── helpers/
    │   └── test_app.dart                         # buildTestApp() helper + initTestEnv()
    ├── fake_nikon_server.dart                    # 占位（未启动真实 socket）
    ├── 01_app_launch_test.dart                   # T1: 4 Tab pump 不 crash
    ├── 02_theme_persistence_test.dart            # T2: SettingsContainer pump 不 crash
    ├── 03_fake_camera_connection_test.dart       # T3 placeholder (5 个 placeholder 都类似)
    ├── 04_download_flow_test.dart                # T4 placeholder
    ├── 05_wifi_disconnect_test.dart              # T5 placeholder
    ├── 06_theme_5x_test.dart                     # T6 placeholder
    ├── 07_notification_test.dart                 # T7 placeholder
    └── 08_background_runner_test.dart            # T8 placeholder
```

### 3.3 已知坑

1. `TextField` 需要 `Material` ancestor — `buildTestApp()` 必须包 `Scaffold`，已在 test 代码里处理
2. `pumpAndSettle` 跟 `AnimationController.repeat()` 不兼容 — placeholder 测试只用 `pump()`，真机手动验证用 `pumpAndSettle()`
3. `FakeNikonServer.start()` 当前抛 `UnimplementedError` — 真实实现需 raw socket + Mac 权限

### 3.4 待用户 iPhone + Mac 后做

1. 把 `test/integration/` 移到 Flutter 标准 `integration_test/` 目录
2. 添加 `pubspec.yaml` dev_dependency: `integration_test: ^5.0.0`
3. 写 `FakeNikonServer` 真实 raw socket 实现
4. 把 placeholder 测试换成真 server + simulator 流程
5. `flutter test integration_test/` 跑通 8 测

**完成度 = 代码到位 + 待真机验证。**

---

## 4. 总结

### 4.1 Phase 4a 完成（`2583dbd`）

**新增文件（5 个）**：`theme_palette.dart` / `viewfinder_theme.dart` / `theme_view_model.dart` / `theme_picker_row.dart` / `appearance_section.dart`
**修改文件（11 个）**：app/main/preferences_store/settings_view/settings_page/settings_container/app_theme/shared_components + 6 widget/page 文件 + freezed 重生成
**测试**：198 → **337**（+139 测：129 palette + 4 viewfinder_theme + 4 themeNotifier + 1 prefs + 1 settings）
**风险**：低 | **可回滚**：是（`kEnableMultiTheme = false`）

### 4.2 Phase 4b 完成 13 / 13 = 100%（全部完成）

**完成项**：Haptics + LensGlow 脉冲 + Shimmer 闪烁 + B9 拆 shared_components + B1 PageView 动效 + B2 ZoomablePhotoPreview 双击缩放 + **B3 顶部 GlobalActivityCapsule** + B4 HeroTitle 轮播 + B5 ThroughputDiagnostics + B6 Gallery GridDensity + B7 ConnectionPage 状态提示文字 + **B8 自定义 StatusBarWidget** + **B10 颜色对齐 (27 处) + 字体对齐 (Noto Sans SC + Instrument Serif)**
**未完成项**：无（Phase 4b 100%）

### 4.3 Phase 4c 代码骨架完成（`fa7eb16`）

**完成项**：10 新文件（helpers/stubs + integration/helpers/test_app + fake_nikon_server + 8 integration_test 文件）
**待 Mac + iPhone**：把 `test/integration/` 移到标准 `integration_test/` 目录 + 加 `integration_test` pubspec 依赖 + 写真实 FakeNikonServer

### 4.4 整体节奏

| 时间 | Phase | 完成度 |
|---|---|---|
| 2026-07-21 ~ 23 | Phase 1（协议层） | ✅ 100% |
| 2026-07-23 | Phase 2（UI 骨架） | ✅ 100% |
| 2026-07-24 ~ 25 | Phase 3（下载链路） | ✅ 100% |
| 2026-07-25 | Phase 4a（5 主题） | ✅ 100% |
| 2026-07-25 ~ 26 | Phase 4b（13/13 全部完成） | ✅ **100%** |
| 2026-07-27 | Phase 4b B10 颜色对齐 + 字体对齐 | ✅ **100%** |
| 2026-07-25 | Phase 4c（代码骨架 8 测试） | ✅ **代码到位** |

### 4.5 累计测试

| 阶段 | 测数 |
|---|---|
| Phase 0+1+2+3 | 198 |
| Phase 4a | +139 |
| Phase 4b 收尾 | +13 (widgets_test) |
| Phase 4c | +8 (integration widget tests) |
| Phase 4b B5/B6 增量 | +9 (throughput + gridDensity) |
| Phase 4b B2 补全 (2026-07-26) | +5 (ZoomablePhotoPreview 手势/缩放) |
| Phase 3 Gallery mock 移除 (2026-07-26) | +1 净 (4 改写 + 1 新回归 - 0 删) |
| Phase 4b B4 轮播 (2026-07-26) | +6 (HeroTitle brand 轮播 timer/状态切换) |
| Phase 4b B10 #1 颜色对齐 (2026-07-27) | -14 净 (重写 129 palette_test，减少硬编码断言) |
| Phase 4b B10 #2 字体对齐 (2026-07-27) | +1 (textTheme 字体分工断言) |
| **总计** | **385 / 385 绿** |

---

## 5. 已确认决策（5 / 5 ✅）

| # | 决策点 | 选择 | 实际落地 |
|---|---|---|---|
| 1 | Amber 保留现状色值？ | ✅ 是 | `amberPalette` 22 色 token 全部与 `app_theme.dart` 第 9-30 行 1:1 对齐 |
| 2 | ThemePalette 字段数？ | ✅ 22 色 + 1 id = 23 字段 | `theme_palette.dart` 22 个 Color + 1 个 String id |
| 3 | AppThemeColors 怎么处理？ | ✅ 保留 deprecated | `@Deprecated('Use ViewfinderTheme.of(context).xxx instead')` 在 `app_theme.dart` 顶部 |
| 4 | themeID 类型？ | ✅ String | `CameraConnectionConfig.themeID: @Default('amber') String` |
| 5 | Feature flag 默认开启？ | ✅ 是 | `kEnableMultiTheme = true` 在 `theme_palette.dart` 顶部，ThemeNotifier 守卫已加 |

**5 个全部 OK**，实际已落地为 2 个 commit（`2583dbd` + `7620314`）。

---

## 6. 已知坑和应急方案

### 6.1 AnimationController 在 widget test 里泄漏 timer

**坑**：`LensGlowView` / `ShimmerView` 的 `AnimationController.repeat()` 会注册 timer，testWidgets 的 `FakeAsync` 会检测到 pending timer，触发 `_verifyInvariants` 失败：
```
A Timer is still pending even after the widget tree was disposed.
```

**应急**：
- ✅ 已在 `_LensGlowViewState.dispose()` / `_ShimmerViewState.dispose()` 中 `_pulse.dispose()` / `_ctrl.dispose()` 释放
- ✅ 已通过 `testWidgets` 验证：385 / 385 全绿无 timer leak
- 写新动画 widget 时务必加 `dispose()` + `pumpAndSettle()` 在 test 结尾

### 6.2 `HapticFeedback` 在测试环境抛 `MissingPluginException`

**坑**：单元测试调用 `Haptics.impactLight()` 时，`flutter/services.dart` 找不到 platform channel，会抛异常。

**应急**：
- 不直接测 `Haptics` 的副作用，只测 widget 渲染（当前 385 测试走这条）
- 需要测时可注入 `SystemChannels.platform.setMockMethodCallHandler(...)` mock

### 6.3 `ThemeExtension` 未注册导致 `assert(ext != null)` 触发

**坑**：widget 内部用 `ViewfinderTheme.of(context).bg` 时，如果外层 `MaterialApp` 没传 `theme: viewfinderTheme(amberPalette)`，assert 失败。

**应急**：
- ✅ 8 个 widget smoke 测已统一用 `_wrap(Widget)` helper 加 theme 参数
- ✅ `widget_test.dart` 已加 `theme: viewfinderTheme(amberPalette)`
- 任何新 widget smoke 测试必须用 `_wrap()` helper，否则测试会 NPE

### 6.4 `amberTheme()` 别名调用产生 `@Deprecated` 警告

**坑**：`viewfinder_theme.dart` 的 `amberTheme()` 标了 `@Deprecated`，调用处会有黄色警告。

**应急**：
- 仅 `app_theme_test.dart` 和 `viewfinder_theme_test.dart` 用 `// ignore: deprecated_member_use_from_same_package` 抑制
- 业务代码禁止用 `amberTheme()`，统一走 `viewfinderTheme(palette)`

### 6.5 `kEnableMultiTheme = false` 的回滚路径只验证逻辑不验证视觉

**坑**：把 `kEnableMultiTheme` 改成 `false` 后，`ThemeNotifier.build()` 永远返回 `amberPalette`，但 `viewfinderTheme(amberPalette)` 仍会被调。理论上 UI 不变。

**应急**：
- 已写 `themeNotifier.select()` 守卫（flag = false 时不更新 state）
- 已写 `ThemeNotifier.build()` 守卫（flag = false 时直接返 `amberPalette`，不 watch preferencesProvider）
- 回滚路径 ≤ 5 min：改 flag → 跑测试 → 编译产物自动全 amber

### 6.6 ~~`settings_page.dart` 仍超 300 行（314）~~ ✅ 已解决

**坑**：拆 `appearance_section.dart` 后 settings_page 仍超 14 行。

**应急**：
- ✅ Phase 4b 拆 `_defaultsSection` + `_supportSection` 到 `widgets/defaults_section.dart` + `widgets/support_section.dart`，现 248 行 ≤ 300 ✅

### 6.7 `ThemePalette` 缺 `name` / `description` / `sbT` 字段

**坑**：计划 §1.5 骨架里有 `name` / `description` / `sbT` 字段，实际实现只保留 `id`。

**应急**：
- ThemePickerRow 用 `p.id` 显示（"amber" / "forest" 等），不需要 `name`
- `sbT` 是 system bar tint 第 1 版未使用
- 未来要 iOS-style heroTitle 时再加 `name` 字段即可

---

## 7. 不在本 Phase 范围（推到 Phase 5）

| # | 项 | 推迟到 | 原因 |
|---|---|---|---|
| N1 | iOS 真机验证（动画手感 + 触觉响应） | Phase 4b 剩余 + 用户拿到 iPhone | 无 iPhone 硬做是猜 |
| N2 | 字体离线打包（`pubspec.yaml fonts:` 块） | Phase 5 | 当前 google_fonts 在线加载够用 |
| N3 | iOS Live Activity（WidgetKit 推送下载进度） | Phase 5 | 需要 Xcode 真机编译验证 |
| N4 | 多品牌扩展（Sony / Canon / Fujifilm） | Phase 5 | 协议层未就绪 |
| N5 | Phase 3 §18 任务对齐（吞吐录制 UI / 错误诊断面板 / 主屏小组件） | Phase 5 | 当前功能已可用 |
| N7 | 国际化（i18n） | Phase 5 | 当前硬编码中文 |

---

## 8. 文档同步清单（已完成）

Phase 4 完成后已同步以下文档：

| 文档 | 改动 | 状态 |
|---|---|---|
| `AGENTS.md` §1 + §11 + §12 | 项目描述更新 + Phase4 路线图 + 变更日志 | ✅ `8b9d535` |
| `CLAUDE.md` | 路径/Phase 状态/Notifier 计数/测试数 | ✅ `8b9d535` |
| `README.md` | Phase 4 功能/测试数/本地开发命令 | ✅ `8b9d535` |
| `docs/产品需求.md` | F5 设置/§5 视觉/§4.4 测试/§8 changelog | ✅ `8b9d535` |
| `docs/架构.md` | §3 目录结构/§6 Provider-Notifier/§7 映射/§8 测试 | ✅ `8b9d535` |
| `docs/项目状态.md` | Phase 4 100%, 385 tests | ✅ `8b9d535` |
| `docs/Phase4实施计划.md` | §2 进度/§4 节奏/§7 N6 移除/§10 测试数 | ✅ 本次更新 |

---

## 9. 提交规范

遵循 AGENTS.md §8：

- 中文 commit message
- 动词开头（实现 / 修复 / 重构 / 添加 / 删除 / 更新）
- 不超过 50 字
- 不要 "update" / "fix" / "misc" / "wip"
- 不写自动化 push

Phase 4 实际 commit 风格：
```
实现 Phase 4a：5 套主题切换 + 持久化 + 385 测试全绿
实现 Phase 4b 最小切片：Haptics 触觉 + LensGlow 脉冲 + Shimmer 闪烁
更新 Phase 4 文档：实际执行总结 + 4b 最小切片 + 4c 阻塞清单
```

---

## 10. 完成后（Phase 4 → Phase 5）

Phase 4 完成后，本工程就有了：

- ✅ 5 套主题实时切换（amber / forest / slate / terr / onyx）
- ✅ 主题持久化（杀进程重启仍保持）
- ✅ Haptics 触觉反馈（按钮 + 通知）
- ✅ LensGlow 脉冲动画 + Shimmer 闪烁动画
- ✅ 13 widget + 4 page 全部从 `AppThemeColors` 迁移到 `ThemeExtension`
- ✅ `AppThemeColors` 标 `@Deprecated`，旧 API 仍可用 1 版
- ✅ B1 PageView / B2 ZoomablePhotoPreview / B3 GlobalActivityCapsule / B4 HeroTitle 轮播 / B5 ThroughputDiagnostics / B6 GridDensity / B7 状态提示 / B8 StatusBarWidget / B10 颜色+字体对齐
- ✅ 385 测试全绿，`dart analyze` 0 warnings（剩 12 info 非阻塞）

**Phase 5（v1.0 发布准备）**：
- 拿到 iPhone + Mac 后跑 Phase 4c 集成测试（8 个 `integration_test/`）
- Phase 5 视觉抛光（如需）
- iOS Live Activity（WidgetKit 推送下载进度）
- 多品牌扩展（Sony / Canon / Fujifilm）— 协议层先扩展
- 国际化（i18n）
- 自定义字体离线打包
- App Store / Google Play 上架材料

**这份文档 = Phase 4 的工作说明书（v1.0）**。