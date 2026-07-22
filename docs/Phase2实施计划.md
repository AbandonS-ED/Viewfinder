# Phase 2 实施计划 — UI 骨架阶段

> 本文档是 Phase 2（UI 骨架）的工作说明书。每个任务完成后用 `dart analyze` 验证再进下一个。

---

## 0. 背景

Phase 0（Domain）+ Phase 1（PTP/IP 协议层）已完成。Phase 2 搭 UI 骨架，Phase 3 真机验证 + 下载。

**为什么 Phase 2 先做 UI 骨架**：UI 骨架一次写好，Phase 3/4 只填肉，不做重复功。

---

## 1. 总体目标

| 交付 | 说明 |
|---|---|
| Riverpod Provider 拓扑 | 6 个 Provider 全链路打通，注入 fake 可单测 |
| 4 个 Tab 页面 | 连接 / 相册 / 下载 / 设置 — 占位 UI |
| Shared 包 | 主题 + 主按钮 + 卡片 + 空状态 |
| pubspec | 加 `shared_preferences` |
| lint | `analysis_options.yaml` 加强 |
| 测试 | 17 Notifier 单测 + 4 widget smoke = 21 新增 |
| DI 装配 | `main.dart` → `app.dart` → ProviderScope → 各 Page |

---

## 2. 主题决策 — 暖阳琥珀 (Amber)

源自原 iOS `NikonConnectIOS` 的 Claude-style 设计，HTML 原型第一套。

### 2.1 色板

| Token | Hex | 用途 |
|---|---|---|
| `--bg` | `#F9F9F8` | 全局背景暖白 |
| `--card` | `#FFFFFF` | 卡片底色 |
| `--bdr` | `#E8E4DD` | 卡片/列表分隔线 |
| `--div` | `rgba(0,0,0,0.04)` | 列表项分隔 |
| `--t1` | `#2D2D2D` | 主文字（近黑） |
| `--t2` | `#7A756E` | 次要文字 |
| `--tm` | `#B5AFA6` | 时间戳/辅助文字 |
| `--a` | `#D4A24E` | 强调色琥珀金 |
| `--a-l` | `#F5E6C8` | 强调色浅底 |
| `--ok` | `#5B8C5A` | 成功/完成绿 |
| `--er` | `#C45B4A` | 错误红 |
| `--btn` | `#1A1A1A` | 按钮底色（黑） |
| `--btn-t` | `#FFFFFF` | 按钮文字白 |

### 2.2 字体

| 名 | Dart | 备注 |
|---|---|---|
| 默认 | `Theme.of(context).textTheme` (系统) | iOS 苹方 / Android 思源 |
| 等宽 | `GoogleFonts.dmMono()` | 端口/大小/格式标签 |

---

## 3. Provider 拓扑

```
preferencesStoreProvider (Provider<AppPreferencesStore>)
    └── transportFactoryProvider (Provider<CameraTransportFactory>)
            └── connectionProvider (NotifierProvider<ConnectionNotifier, ConnectionState>)
                    └── galleryProvider (AsyncNotifierProvider<GalleryNotifier, List<PhotoAsset>>)
                            └── downloadManagerProvider (NotifierProvider<DownloadManagerNotifier, DownloadQueueState>)

preferencesProvider (NotifierProvider<PreferencesNotifier, CameraConnectionConfig>)
    └── preferencesStoreProvider （复用）
```

| Provider | 类型 | 依赖 | 测试注入 |
|---|---|---|---|
| `preferencesStoreProvider` | `Provider` | — | `SharedPreferences.setMockInitialValues` |
| `transportFactoryProvider` | `Provider` | preferencesStore | 直接 `CameraTransportFactory()` |
| `connectionProvider` | `NotifierProvider` | transportFactory | `ProviderContainer.override` 注入 fake transport |
| `galleryProvider` | `AsyncNotifierProvider` | connection | 同上 |
| `downloadManagerProvider` | `NotifierProvider` | gallery | 同上 |
| `preferencesProvider` | `NotifierProvider` | preferencesStore | `SharedPreferences` mock |

---

## 4. 目录结构（新建的加粗）

```
lib/
├── main.dart                          ← runApp(ProviderScope(child: ViewfinderApp()))
├── app.dart                           ← MaterialApp + NavigationBar + 4 Tab
│
├── domain/                            ← 不变
│
├── protocol/                          ← 不变
│
├── services/
│   └── preferences_store.dart         ← AppPreferencesStore (shared_preferences)
│
├── features/
│   ├── connection_setup/
│   │   ├── connection_page.dart       ← 连接页 UI
│   │   └── connection_view_model.dart ← ConnectionNotifier
│   ├── photo_browser/
│   │   ├── gallery_page.dart          ← 缩略图网格
│   │   └── gallery_view_model.dart    ← GalleryNotifier
│   ├── downloads/
│   │   ├── downloads_page.dart        ← 队列页（占位）
│   │   └── download_manager_view_model.dart ← DownloadManagerNotifier
│   ├── settings/
│   │   ├── settings_page.dart         ← 设置页
│   │   └── settings_view_model.dart   ← PreferencesNotifier
│   └── shared/
│       ├── app_theme.dart             ← 暖白 + 琥珀金
│       ├── shared_components.dart     ← CapsuleButton / EmptyState
│       └── formatters.dart            ← byteSize / date 格式化
```

---

## 5. 任务切片（16 个，按顺序）

| # | 任务 | 估时 | 产出 |
|---|---|---|---|
| 2.0 | 创建 features/ 目录 + `app_theme.dart` 色码 | 30 分钟 | 暖白 + 琥珀金主题 |
| 2.1 | `pubspec.yaml` 加 `shared_preferences` | 5 分钟 | `flutter pub get` |
| 2.2 | `services/preferences_store.dart` | 1 小时 | AppPreferencesStore |
| 2.3 | `settings_view_model.dart` + 4 单测 | 1.5 小时 | PreferencesNotifier |
| 2.4 | `connection_view_model.dart` + 5 单测 | 2 小时 | ConnectionNotifier |
| 2.5 | `gallery_view_model.dart` + 5 单测 | 2 小时 | GalleryNotifier |
| 2.6 | `download_manager_view_model.dart` + 3 单测 | 1.5 小时 | DownloadManagerNotifier 占位 |
| 2.7 | `shared_components.dart` + `formatters.dart` | 1.5 小时 | CapsuleButton / EmptyState |
| 2.8 | `connection_page.dart` | 1.5 小时 | 连接页 UI |
| 2.9 | `gallery_page.dart` | 2 小时 | 缩略图网格 + 3 态 |
| 2.10 | `downloads_page.dart` | 1 小时 | 队列页（占位文字） |
| 2.11 | `settings_page.dart` | 1.5 小时 | 设置页 |
| 2.12 | `app.dart` + `main.dart` 装配 | 1.5 小时 | ProviderScope + Tab |
| 2.13 | 4 widget smoke test | 1.5 小时 | 每页 1 个 |
| 2.14 | `analysis_options.yaml` 加强 | 30 分钟 | 全套 lint |
| 2.15 | 验收 + commit + push + 更新 docs | 1 小时 | git + 项目状态.md |

**总估时**：~19 小时（实际约 4 周，因单任务之间有用户验收）

---

## 6. 验收标准

```bash
cd "D:\桌面\Nikon_connect\Viewfinder"

dart analyze                     # No issues found!
flutter test                     # All tests passed (≥ 68 total)
flutter build apk --debug        # BUILD SUCCESSFUL
```

1. `dart analyze` 零警告
2. `flutter test` 全绿（现存 47 + 新增 21 = 68）
3. `flutter build apk --debug` 能装到 Android 真机
4. `flutter run` 起 app，4 个 Tab 切换正常
5. Settings 页改 host/port 保存后重现不变
6. 连接页显示网络图标 + 状态文字 + 连接按钮
7. 相册页显示 12 个彩色占位缩略图（模拟数据）
8. 下载页显示"下载功能 Phase 3 实现"占位

---

## 7. 不在本 Phase 范围

- ❌ 真机连 Nikon 验证（Phase 3）
- ❌ 缩略图从相机拉取（Phase 3 才接 `downloadThumbnail`）
- ❌ 下载完整文件（Phase 3）
- ❌ 进度通知 / Foreground Service（Phase 3）
- ❌ 触觉 / 动画 / 动效（Phase 4）
- ❌ iOS 平台创建（Phase 3）

---

## 8. 提交规范

格式：`<动词><对象>：<一句话说明>`

例：
```
实现 features/shared 包：app_theme + shared_components + formatters
实现 PreferencesNotifier + settings_page 设置页读写
实现 connection_page + ConnectionNotifier 连接页 UI
实现 app.dart Tab 装配 + ProviderScope 全链路打通
```

---

## 9. 完成后

Phase 2 结束后，本工程就有了完整的 UI 骨架（4 Tab + Provider + 主题）。Phase 3 在骨架上填肉：真机验证 + 下载 + 进度通知。

**这份文档 = Phase 2 的工作说明书。**
