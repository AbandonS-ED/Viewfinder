# B10 视觉扫荡 Diff 报告 — muban.html vs 当前代码

> **目的**：把 `D:\桌面\muban\muban.html` 作为视觉权威，对照当前 Flutter 实现的色板 / 字体 / 间距 / 圆角 / 字号 / 页面布局，输出「应该改 vs 现状」清单。本文档**只读不改**，用户拍板后另起 commit 实施。
>
> **生成日期**：2026-07-26
> **关联文件**：
> - 模板：`D:\桌面\muban\muban.html` (5 套主题 × 4 个 page + pill 切换器)
> - 当前：`lib/features/shared/theme_palette.dart` + `app_theme.dart` + 4 个 page widget

---

## 1. 颜色 Token Diff (5 套主题)

### 1.1 Amber

| Token | muban.html | 当前 amberPalette | 一致? |
|---|---|---|---|
| `bg` | #F9F9F8 | #F9F9F8 | ✅ |
| `card` | #FFFFFF | #FFFFFF | ✅ |
| `bdr` | **#E8E4DD** (solid) | **0x12000000** (rgba 黑 0.07) | ❌ |
| `t1` | **#2D2D2D** | **#1A1A1A** | ❌ |
| `t2` | **#7A756E** | **#6B7079** | ❌ |
| `tm` | #B5AFA6 | #B5AFA6 | ✅ |
| `a` | #D4A24E | #D4A24E | ✅ |
| `aL` | #F5E6C8 | #F5E6C8 | ✅ |
| `ok` | #5B8C5A | #5B8C5A | ✅ |
| `er` | **#C45B4A** | **#DB262E** | ❌ |
| `btn` | #1A1A1A | #1A1A1A | ✅ |
| `btnT` | #FFFFFF | #FFFFFF | ✅ |
| `nbBg` | #FFFFFF | #FFFFFF | ✅ |
| `nbBdr` | **#E8E4DD** | **0x12000000** | ❌ |
| `niC` | #B5AFA6 | #B5AFA6 | ✅ |

**Amber 4 项不一致**：`bdr` / `t1` / `t2` / `er` / `nbBdr` (5 项)

### 1.2 Forest (dark)

| Token | muban.html | 当前 forestPalette | 一致? |
|---|---|---|---|
| `bg` | #111F14 | #111F14 | ✅ |
| `card` | #1A2E1E | #1A2E1E | ✅ |
| `bdr` | **#2A4A30** (solid) | **0x1AFFFFFF** (rgba 白 0.10) | ❌ |
| `t1` | #D8E8D8 | #D8E8D8 | ✅ |
| `t2` | #7A9A7A | #7A9A7A | ✅ |
| `tm` | #4A6A4A | #4A6A4A | ✅ |
| `a` | **#7CC9A0** | **#5A8A5A** | ❌ |
| `aL` | **rgba(124,201,160,0.15)** | **#B8D8B8** (solid) | ❌ |
| `aS` | **#5BB088** | **#6AA86A** | ❌ |
| `ok` | #7CC9A0 | #72B872 | ⚠️ close |
| `er` | **#D47A6A** | **#EF6B6B** | ❌ |
| `btn` | **#7CC9A0** (同 a) | **#5A8A5A** | ❌ |
| `btnT` | **#111F14** (深绿) | **#FFFFFF** (白) | ❌ |
| `nbBg` | #1A2E1E | #1A2E1E | ✅ |
| `niC` | #4A6A4A | #4A6A4A | ✅ |

**Forest 7 项不一致**

### 1.3 Slate (light)

| Token | muban.html | 当前 slatePalette | 一致? |
|---|---|---|---|
| `bg` | #F0F1F3 | #F0F1F3 | ✅ |
| `card` | #FAFBFC | #FAFBFC | ✅ |
| `bdr` | **#DDE0E4** | **0x0F000000** | ❌ |
| `t1` | #2C3E50 | #2C3E50 | ✅ |
| `t2` | #7F8C9B | #7F8C9B | ✅ |
| `tm` | #A8B2BC | #A8B2BC | ✅ |
| `a` | **#6B8DAD** | **#3D5A80** | ❌ |
| `aL` | **rgba(107,141,173,0.12)** | **#B8CCE0** (solid) | ❌ |
| `aS` | **#557FA0** | **#5A88B0** | ⚠️ close |
| `er` | **#C0574A** | **#D04040** | ❌ |
| `btn` | #2C3E50 | #2C3E50 | ✅ |
| `nbBg` | #FAFBFC | #FAFBFC | ✅ |
| `niC` | #A8B2BC | #A8B2BC | ✅ |

**Slate 4 项不一致**

### 1.4 Terr (light)

| Token | muban.html | 当前 terrPalette | 一致? |
|---|---|---|---|
| `bg` | #F8F3ED | #F8F3ED | ✅ |
| `card` | #FFFCF8 | #FFFCF8 | ✅ |
| `bdr` | **#E8DDD0** | **0x14000000** | ❌ |
| `t1` | #3D2B1F | #3D2B1F | ✅ |
| `t2` | #8A7060 | #8A7060 | ✅ |
| `tm` | #BBA898 | #BBA898 | ✅ |
| `a` | **#C2703E** | **#C0693A** | ⚠️ 1 digit |
| `aL` | **#F0D8C4** | **#E8C8A8** | ❌ |
| `aS` | **#A85F2E** | **#D88550** | ❌ |
| `er` | **#C45B4A** | **#CC3333** | ❌ |
| `btn` | #3D2B1F | #3D2B1F | ✅ |
| `nbBg` | #FFFCF8 | #FFFCF8 | ✅ |
| `niC` | #BBA898 | #BBA898 | ✅ |

**Terr 4 项不一致**

### 1.5 Onyx (dark)

| Token | muban.html | 当前 onyxPalette | 一致? |
|---|---|---|---|
| `bg` | #0C0C0E | #0C0C0E | ✅ |
| `card` | #161618 | #161618 | ✅ |
| `bdr` | **#262629** | **0x1EFFFFFF** | ❌ |
| `t1` | #E8E8E8 | #E8E8E8 | ✅ |
| `t2` | #7A7A7E | #7A7A7E | ✅ |
| `tm` | #4A4A4E | #4A4A4E | ✅ |
| `a` | **#E8B84B** (暗金) | **#9A9AAA** (银灰) | ❌ |
| `aL` | **rgba(232,184,75,0.12)** | **#C8C8D8** | ❌ |
| `aS` | **#B8932F** | **#B0B0C0** | ❌ |
| `ok` | #5ADA80 | #6A9A6A | ⚠️ |
| `er` | **#F07070** | **#EE6666** | ⚠️ close |
| `btn` | **#E8B84B** | **#9A9AAA** | ❌ |
| `btnT` | **#0C0C0E** | **#FFFFFF** | ❌ |
| `nbBg` | #161618 | #161618 | ✅ |
| `niC` | #4A4A4E | #4A4A4E | ✅ |

**Onyx 7 项不一致**

### 颜色 Token 总计

| 主题 | 不一致项数 |
|---|---|
| Amber | 5 |
| Forest | 7 |
| Slate | 4 |
| Terr | 4 |
| Onyx | 7 |
| **总计** | **27 处不一致** |

---

## 2. 字体 Diff

| 项 | muban.html | 当前代码 | 一致? |
|---|---|---|---|
| 标题 | `Instrument Serif` 26/30/22/18px | `Theme.textTheme.displayLarge` (Instrument Serif) | ⚠️ 部分 |
| **正文 (中文)** | **`Noto Sans SC`** 11/12/13/14/15px | **Roboto 默认** (Material fallback) | ❌ |
| 等宽 | `DM Mono` 11/12/13/14px | `GoogleFonts.dmMono` (3 处) | ✅ |
| 强调 (status badge) | `DM Mono` 9/10px | `GoogleFonts.dmMono` (部分) | ⚠️ |

**关键问题**：当前**没有声明中文正文字体**。Flutter 默认 Roboto 对中文 fallback 到系统字体（Android 端），跨设备渲染不一致。muban 强制使用 Noto Sans SC。

**修复方案**：
- `pubspec.yaml` 加 `google_fonts: ^6.2.1` (已有) + ThemeData.textTheme 全套套 `GoogleFonts.notoSansSC()`
- 需要评估 google_fonts 离线打包 vs 在线加载的取舍

---

## 3. 间距 Token Diff

| muban.html 常用 | 当前 AppThemeSpacing | 覆盖? |
|---|---|---|
| 2px | × 无 | ❌ |
| 4px | 4 (xs) | ✅ |
| 6px | × 无 | ❌ |
| 8px | 8 (s) | ✅ |
| 10px | × 无 | ❌ |
| 12px | 12 (m) | ✅ |
| 16px | 16 (l) | ✅ |
| 18px | × 无 | ❌ |
| 20px | × 无 | ❌ |
| 24px | 24 (xl) | ✅ |
| 26px | × 无 | ❌ |
| 32px | × 无 | ❌ |
| 34px | × 无 | ❌ |
| 36px | 36 (xxl) | ✅ |

**缺 7 个间距 token**（2/6/10/18/20/26/32/34）。

---

## 4. 圆角 Token Diff

| muban.html | 当前 AppThemeRadius | 覆盖? |
|---|---|---|
| 3px (small label) | × 无 | ❌ |
| 4px (swatch) | × 无 | ❌ |
| 8px (dthumb) | 8 (s) | ✅ |
| 12px (icon bg) | 12 (m) | ✅ |
| 18px (card) | 18 (l) | ✅ |
| 20px (h-pill) | × 无 | ❌ |
| 40px (phone) | × 无 | ❌ |
| 100px (pill button) | 100 (pill) | ✅ |

**缺 4 个圆角**（3/4/20/40）。

---

## 5. 字号 Token Diff

| muban.html | 当前使用 | 一致? |
|---|---|---|
| 9px (badge) | 局部 widget 硬编码 (varying 9-13) | ❌ 无统一 token |
| 10px (section label) | 10/11/12/13 各处硬编码 | ❌ |
| 11px (subtle text) | 11/12 各处硬编码 | ❌ |
| 12px (body small) | 12/13/14 各处硬编码 | ❌ |
| 13px (body) | 13/14 各处硬编码 | ❌ |
| 14px (status bar) | 14/15 各处硬编码 | ❌ |
| 15px (button) | 14/15/16 各处硬编码 | ❌ |
| 18px (h2) | 18/22 在 displayLarge | ❌ |
| 22px (page title) | 22/24 in displayLarge | ❌ |
| 26px (top h1) | 26 in displayLarge | ✅ |
| 30px (hero h1) | 30 in displayLarge | ✅ |

**缺 11 档字号 token**。当前 widget 散落 9-30px 各处硬编码。

---

## 6. 页面布局 Diff

### 6.1 Status Bar (顶)
| muban.html | 当前代码 | 一致? |
|---|---|---|
| 50px 高 | Material 系统状态栏 (28-32px) | ❌ |
| 不替换原生 | 已有 `StatusBarWidget` 24px scaffold 但**未接入 4 page** | ❌ |

### 6.2 Nav Bar (底)
| muban.html | 当前代码 | 一致? |
|---|---|---|
| 78px 高 | Material `NavigationBar` (80px 默认) | ✅ |
| 6px padding-top | × 无 | ❌ |
| 22px icon | Material default 24px | ⚠️ |
| 10px label | Material default 12px | ⚠️ |
| 3px gap (icon → label) | × 无 | ❌ |

### 6.3 Connection Page
| muban.html | 当前 ConnectionPage | 一致? |
|---|---|---|
| 150px lens circle | `LensGlowView` 动画 (50h 集合 view) | ❌ 大小不一致 |
| 30px 标题 serif | `HeroTitle` displayLarge 30px | ✅ |
| 12px subtitle mono | 13px | ⚠️ |
| 14px 34px pad button | 18px 32px pad | ⚠️ |
| 192.168.1.1 : 15740 chip | Settings 显示, Connection 不显示 | ❌ |

### 6.4 Gallery Page
| muban.html | 当前 GalleryPage | 一致? |
|---|---|---|
| 22px 标题 | 22px | ✅ |
| 11px meta mono | 11px | ✅ |
| 11px chip 5px 12px pad | × 当前 12px 22px pad | ⚠️ |
| 3-col grid 2px gap | 3-col 8px gap | ❌ |
| 8px 10px thumb label | 8px 5px pad | ⚠️ |
| 20px 20px circle checkmark | 无 (list 改) | ❌ |
| Shimmer 假数据 | 真实数据 | ✅ muban 是 demo |

### 6.5 Downloads Page
| muban.html | 当前 DownloadsPage | 一致? |
|---|---|---|
| 22px 标题 | 22px | ✅ |
| 11px meta | 11px | ✅ |
| 10px UPPERCASE section label | 10px | ⚠️ 字符间距 1.5px |
| 44px 44px dthumb | 40px 40px | ⚠️ |
| 8px dthumb radius | 8px | ✅ |
| 6px 12px dbg badge | 6px 12px | ✅ |
| 50% progress bar | 3px height | ⚠️ 图规格异 |

### 6.6 Settings Page
| muban.html | 当前 SettingsPage | 一致? |
|---|---|---|
| 22px 标题 | 22px | ✅ |
| 10px UPPERCASE label | 10px | ⚠️ |
| 28px 28px sti icon | 28px | ✅ |
| 6px 8px sti radius | 6px | ⚠️ |
| 14px row text | 14px | ✅ |
| 13px stv mono | 13px | ✅ |
| 42px 26px toggle | × 无 | ❌ |
| 11px mono version | 11px | ✅ |

---

## 7. 估算改动量

| 类别 | 估算 |
|---|---|
| 颜色 27 处 | 1 commit 内一次改 (theme_palette.dart) + 129 个 palette_test 跟着改 |
| 字体 (Noto Sans SC) | 1 commit (pubspec 不动，ThemeData.textTheme 套 googleFonts) |
| 间距 token 7 个 | 1 commit (AppThemeSpacing 加常量) |
| 圆角 token 4 个 | 1 commit (AppThemeRadius 加常量) |
| 字号 token 11 档 | 1 commit (新 ThemeTextSize + 全 widget 替换硬编码) |
| 页面布局微调 | 5-8 commit (按 page 拆) |
| **总计** | **~10-15 commit, 估时 8-12h** |

---

## 8. 优先级建议

按用户价值 / 改动量比例：

1. **HIGH — 颜色 27 处改 (1 commit, 估时 30min)**：mismatch 视觉感知最明显。修完 amber 用户一看就知道颜色对不对。
2. **HIGH — 字体 Noto Sans SC (1 commit, 估时 1h)**：中文渲染一致性。这台机器 Windows 看不出，Android 端可见。
3. **MEDIUM — 间距 + 圆角 + 字号 token (3 commit, 估时 2h)**：为后续视觉扫荡打基础。
4. **LOW — 页面布局微调 (5-8 commit, 估时 4-6h)**：接近 iOS 视觉对齐，但 iOS-only 价值大。Phase 5 拿到 iPhone 后做更有意义。

---

## 9. 拍板建议

**推荐顺序**：
1. 现在做：#1 颜色 27 处 (快速、立竿见影)
2. 下一项：#2 Noto Sans SC (中文一致)
3. Phase 5 拿到 iPhone：#3 + #4 一起做

**风险**：
- #1 改完需要重跑 129 个 palette_test，**每个测试断言具体 color 值**。改色值 = 改测试断言 = 大改动
- #2 google_fonts 引入新字体可能增加 APK 体积（首次在线拉 ~200KB）。如果要离线打包，需要 pubspec.yaml `fonts:` 块 + 字体文件

**不做也行**：
- 当前 5 套主题**视觉上已经够用**（用户没抱怨过颜色）
- Phase 4b 文档明确剩余项为 iOS 视觉对齐，等 iPhone

---

## 10. 关联文档

- `docs/Phase4实施计划.md` §2.2 B10
- `lib/features/shared/theme_palette.dart` — 当前 5 套
- `D:\桌面\muban\muban.html` — 视觉权威
