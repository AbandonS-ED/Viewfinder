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

### 1.4 ThemePalette 完整字段（23 个）

**色值（23 个）**（amber 沿用现状，其他 4 套从模板 1:1 复刻）：
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

  // 23 个色 token（参 §1.4 表）
  final Color bg, card, surfaceElevated, surfaceMuted, controlBg;
  final Color bdr, div, sep, shadow;
  final Color t1, t2, tm;
  final Color a, aL, aS;
  final Color ok, er;
  final Color btn, btnT;
  final Color sbT;
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
// lib/features/shared/widgets/theme_picker_row.dart
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
| `lib/features/shared/widgets/theme_picker_row.dart` | 🆕 新增 widget | +60 |
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
| `test/features/shared/theme_palette_test.dart` 🆕 | **115** | 23 token × 5 palette = 115 色值断言 |
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

| 文件 | 当前 | Phase 4a 后 | 限制 | OK? |
|---|---|---|---|---|
| `shared/theme_palette.dart` | — | 210 | 无限制（新建） | ✅ |
| `shared/viewfinder_theme.dart` | — | 50 | 无限制（新建） | ✅ |
| `shared/widgets/theme_picker_row.dart` | — | 60 | 无限制（新建 widget） | ✅ |
| `shared/app_theme.dart` | 161 | 151 | 无限制（theme 文件） | ✅ |
| `settings/theme_view_model.dart` | — | 50 | Notifier ≤ 250 | ✅ |
| `settings/settings_view_model.dart` | 58 | 66 | Notifier ≤ 250 | ✅ |
| `settings/settings_page.dart` | 299 | **349** | Page ≤ 300 | ⚠️ **超 49 行** |

**Page 超限应对**：拆 "外观" section 到独立 widget `lib/features/settings/widgets/appearance_section.dart` (~70 行)，settings_page.dart 加 1 行 import + 1 行 widget 调用 → 仍是 299 行。**纳入任务 #5**。

### 1.18 Commit 计划（3 个 commit）

**Commit 1：实现主题 token 系统**
- 新增 `theme_palette.dart` (5 palette + `kEnableMultiTheme` flag)
- 新增 `viewfinder_theme.dart` (ThemeExtension + factory + `amberTheme()` 别名)
- 新增 `theme_view_model.dart` (ThemeNotifier + provider)
- `CameraConnectionConfig` 加 `themeID` 字段
- `PreferencesNotifier` 加 `setThemeID()` setter
- `preferences_store.dart` 加 themeID JSON 字段读写
- 新增 121 个测（115 palette + 4 notifier + 1 v4 regression + 1 preferences store）
- 现有 198 测试不动

**Commit 2：widget + page 接入 ThemeExtension + MaterialApp 接入**
- 改 13 widget + 4 page 从 `AppThemeColors.xxx` → `ViewfinderTheme.of(context).xxx` (78 处引用)
- `AppThemeColors` 标记 deprecated
- 8 个 widget smoke 测试更新（加 `theme: viewfinderTheme(amberPalette)` 参数）
- `app.dart` `MaterialApp(theme:)` 接受外部传入
- `main.dart` 用 `Consumer` 包 `ViewfinderApp` 接 `themeNotifierProvider`

**Commit 3：主题切换 UI**
- 新增 `theme_picker_row.dart` widget
- `settings_page.dart` 加 "外观" section + 拆出 `appearance_section.dart`
- 跑全套 + 手动验证 5 套主题切换

---

## 2. Phase 4b — UI 抛光 + 动效（暂定，不立即做）

### 2.1 内容

- 圆角 / 间距 / 字体 微调对齐模板 muban.html
- 4 类动效（页面切换 / 按钮反馈 / LensGlowView 脉冲 / ShimmerView 骨架）
- 自定义 StatusBarWidget（不替换系统状态栏，作为 page 顶部装饰条）
- 7 个 iOS 漏掉的 UI 元素：
  - 顶部全局进度胶囊（globalActivityTitle overlay）
  - 品牌循环文字（hero section 轮播）
  - heroTitle 状态机（6 个状态文案）
  - 全屏预览屏 + ZoomablePhotoPreview（双击缩放 + 拖动平移）
  - ThroughputDiagnostics 测速 section
  - Top toolbar 菜单（标准/紧凑网格 + 全选/清空）
  - 底部 Action Bar 文本切换
- 拆 `shared_components.dart` 到子目录

### 2.2 估时

约 30h（1 周）

### 2.3 依赖

需要 iOS 真机或 Mac 验证视觉细节（特别是动态效果）

---

## 3. Phase 4c — 集成测试（暂定，不立即做）

### 3.1 内容

- 8 个 `integration_test/` 用例
- `fake_nikon_server.dart` (mock PTP/IP server)
- `test_app.dart` (override 8 个 provider)

### 3.2 估时

约 25h（1 周）

### 3.3 依赖

**用户当前没有 iPhone**（用户原话），所以：
- 集成测试代码可以写（不依赖真机）
- 但**无法跑 `flutter test integration_test/`** 验证（需要 Mac + iPhone）
- 推到用户拿到 iPhone + Mac 后再跑
- Phase 4c 完成度 = "代码到位 + 用户验证后跑通"

### 3.4 推荐顺序

等用户拿到 iPhone + Mac 后，先做 Phase 4b（UI 抛光依赖 iOS 视觉验证），再做 Phase 4c（集成测试）。

---

## 4. 总结

**这次（Phase 4a）只做 1 件事**：5 套主题切换。

**预计时间**：30h = 1 周
**新增文件**：4 个（theme_palette.dart / viewfinder_theme.dart / theme_view_model.dart / theme_picker_row.dart）
**修改文件**：7 个（app_theme.dart / settings_view_model.dart / settings_page.dart / preferences_store.dart / main.dart / camera_connection_config.dart / app.dart）
**新增测试**：129 个（115 palette + 4 notifier + 1 v4 regression + 1 preferences store + 8 widget smoke 主题参数）
**总测试**：198 → **327**
**风险**：低（widget 改动量大但有 deprecated 兼容层 + feature flag 回滚）
**可回滚**：是（`kEnableMultiTheme = false` ≤ 5 min）

**Phase 4b / 4c 暂不启动**，等 4a 完成 + 你决定后再做。

---

## 5. 待你确认的 5 个决策点

1. ✅ Amber 保留现状色值（er=#DB262E, t1=#1A1A1A）— 其他 4 套从模板 1:1 复刻？
2. ✅ ThemePalette 用 23 字段（22 色 token + 1 标识信息）— 状态色不进 palette，所有主题共享？
3. ✅ AppThemeColors 保留 deprecated 而不是删除？
4. ✅ themeID 用 String 而非 enum（schema 兼容 + 简单）？
5. ✅ Feature flag `kEnableMultiTheme = true` 默认开启？

5 个都 OK 就开始 Commit 1。