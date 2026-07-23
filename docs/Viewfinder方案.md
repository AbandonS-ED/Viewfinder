# Viewfinder (取景器) — Flutter 重写方案

> 把当前 iOS 项目 `NikonConnectIOS` 用 Flutter 推倒重写，新工程命名 **Viewfinder**，路径 `D:\桌面\Nikon_connect\Viewfinder\`。  
> 原 iOS Swift 代码不直接复用，但作为**协议参考文档**保留阅读价值。  
> 计划粒度：tracer bullet 阶段，可直接据此推进。

## 0. 项目元信息

| 项 | 值 |
|---|---|
| 项目名 (英文) | **Viewfinder** |
| 项目名 (中文) | **取景器** (相机取景器 / 摄影师透过它构图) |
| Flutter package 名 | `viewfinder` (Flutter 强制 snake_case lowercase) |
| 工程根路径 | `D:\桌面\Nikon_connect\Viewfinder\` |
| 来源 iOS 项目 | `D:\桌面\Nikon_connect\` (本仓的上级目录) |
| Bundle ID (iOS) | `com.yaoyihan.viewfinder` |
| Application ID (Android) | `com.yaoyihan.viewfinder` |
| 原 iOS bundle id | `com.yaoyihan.NikonConnectIOS` (仅作对照) |

**命名理由**：取景器是相机最核心的交互部件 —— 摄影师透过它「看见」并「取走」画面。这与本 app 的功能高度契合：通过 Wi-Fi 连接相机，把相机取景器背后的照片「取」到手机上。

---

## 1. 目标


一份 Dart / Flutter 代码库，同时产出 iOS + Android 双端可运行的「Nikon 相机 Wi-Fi 照片浏览与批量下载」app。核心交付：

- 通过 PTP/IP (CIPA) 协议连接相机热点 (`192.168.1.1:15740`)，浏览照片列表
- 批量下载 RAW / JPEG / MOV 到设备本地相册
- 下载进度前台可见（Android 通知中心 / iOS Live Activity 或退化方案）
- 后续可扩展到 Sony / Canon / Fujifilm（同一套 transport 抽象）

非目标（明确不做）：

- 不保留现有 Swift 源码（用户已确认）
- 不实现 iOS Live Activity（Android 无等价体验，跨端方案统一为「前台服务 + 持久通知」）
- 不支持 macOS / Windows / Web

---

## 2. 技术栈选型

| 层 | 选型 | 理由 |
|---|---|---|
| 语言 | Dart 3.x | Flutter 默认 |
| Framework | Flutter stable channel | 用户已选 Flutter |
| 最低 iOS | 16.0 | 与原项目对齐 |
| 最低 Android | API 24 (Android 7.0) | 覆盖 `WorkManager` / scoped storage 现代 API |
| 状态管理 | **Riverpod 2.x** (flutter_riverpod) | 编译期安全、对 async 友好、易测试；用户在前一轮已点名 |
| 数据类 | **freezed + json_serializable** | 替代手写 `==` / `hashCode` / `copyWith` / `fromJson` |
| 网络层 | `dart:io` Socket (裸 TCP) | PTP/IP 是二进制协议，无 HTTP 层可用 |
| 序列化 | `dart:convert` + `package:typed_data` | 直接操作 `Uint8List` / `ByteData`，与原 `PTPIPPrimitives` 对位 |
| 本地存储 (KV) | `shared_preferences` | 替代 `UserDefaults` |
| 本地存储 (文件) | `path_provider` + `dart:io` | 替代 `FileManager` |
| 相册写入 | `gal` 或原生 channel | Android 13+ scoped storage 必须处理 |
| 通知 / 进度 | `flutter_local_notifications` + `flutter_background_service` | 双端前台进度提示 |
| Wi-Fi 监听 | `connectivity_plus` + `network_info_plus` | 监听相机热点断线 |
| 日志 | `package:logging` | 替代 `AppLogger` |
| 国际化 | `flutter_localizations` + `intl` | 与原项目中文界面一致 |
| 测试 | `flutter_test` + `mocktail` | 替代 XCTest |
| Lint | `flutter_lints` (官方) + `very_good_analysis` (可选) | 比原项目多一步 lint |
| 依赖版本 | **全部锁主版本号** | 例：`flutter_riverpod: ^2.5.0` / `freezed: ^2.4.0` / `flutter_local_notifications: ^17.0.0` / `flutter_background_service: ^5.0.0` / `gal: ^2.2.0` / `connectivity_plus: ^6.0.0` / `mocktail: ^1.0.0` 等。Phase 0 写 pubspec 时统一锁，避免升级引入 breaking change |
| 格式化 | `dart format` (官方) | 替换 SwiftFormat 缺失 |

---

## 3. 平台能力映射

| 原 iOS 能力 | Flutter / Dart 实现 | 备注 |
|---|---|---|
| `Network.framework` TCP | `dart:io.Socket` | BSD socket 跨端，零桥接 |
| `UserDefaults` JSON | `shared_preferences` + JSON 字符串 | 需手写 codec |
| `FileManager` | `dart:io.File` + `path_provider` | 一致 |
| `PHPhotoLibrary` (写入) | `gal` 包 (Android 13+ 受限) + 自写 channel | Android scoped storage 是难点 |
| `ActivityKit` Live Activity | ❌ 不实现 | Android 无对应，跨端统一降级 |
| `UIImpactFeedbackGenerator` | `HapticFeedback.lightImpact()` 等 | API 较粗，足够用 |
| `Local Network` 权限弹窗 | iOS: `NSLocalNetworkUsageDescription`；Android: `ACCESS_WIFI_STATE` + `CHANGE_WIFI_MULTICAST_STATE` | iOS 一句话；Android 静默 |
| 后台下载 | iOS **当前未实现** (Network.framework 裸 TCP 不支持 background session，需另设计机制)；Android Foreground Service (`dataSync` type, Android 14+) | Android 用 `flutter_background_service` 封装；**iOS 端 Phase 3 待评估** |
| 相机热点网络监测 | `connectivity_plus` + `network_info_plus` | 监听断线重试 |
| XcodeGen / xcodebuild | `flutter build ios / apk / appbundle` | Flutter 自带 |

---

## 4. 工程目录结构

```
Viewfinder/                       # Flutter 工程根 (snake_case lowercase 给 flutter create)
├── lib/
│   ├── main.dart                    # runApp() 入口
│   ├── app.dart                     # MaterialApp + 路由
│   │
│   ├── domain/                      # 纯 Dart 数据模型 (Sendable 等价: freezed)
│   │   ├── camera_connection_config.dart
│   │   ├── camera_transport_mode.dart
│   │   ├── camera_session.dart
│   │   ├── camera_capability.dart    # 独立文件 (freezed 2.5.8 + Dart 3.12 enum getter bug)
│   │   ├── camera_workflow_state.dart
│   │   ├── photo_asset.dart
│   │   ├── photo_asset_merge.dart
│   │   ├── download_job.dart
│   │   ├── download_queue_state.dart
│   │   ├── download_record.dart
│   │   ├── active_download_progress.dart
│   │   ├── download_throughput_diagnostics.dart
│   │   ├── log_entry.dart
│   │   ├── alert_context.dart
│   │   └── camera_app_error.dart
│   │
│   ├── protocol/                    # PTP/IP 协议层 (与 UI 解耦)
│   │   ├── primitives/              # 编解码 (对应 PTPIPPrimitives.swift)
│   │   │   ├── ptpip_data_types.dart        # 枚举 + 常量
│   │   │   ├── ptpip_data_structures.dart   # freezed data class
│   │   │   ├── ptpip_packet_codec.dart      # 编解码器
│   │   │   └── ptpip_error.dart             # sealed error class
│   │   ├── transport/               # 长连接 + socket
│   │   │   ├── ptpip_socket.dart            # abstract 接口
│   │   │   ├── ptpip_socket_io.dart         # IoPtpipSocket 真实实现 + FakePtpipSocket 测试实现
│   │   │   └── ptpip_connection.dart        # 高层连接管理（持有一个 socket 实例）
│   │   ├── session/                 # 会话层 (对应 PTPIPSession+*.swift，single PtpipSession 类)
│   │   │   └── ptpip_session.dart           # 双连接架构，含 lifecycle/traversal/transfers 全部方法
│   │   ├── camera_transport.dart           # 品牌抽象 (对应 CameraTransport)
│   │   ├── experimental_nikon_transport.dart
│   │   └── camera_transport_factory.dart   # 工厂 (返回 ExperimentalNikonTransport)
│   │
│   ├── services/                    # 应用级服务 (Phase 2 已落 3 个，剩余 Phase 3)
│   │   ├── preferences_store.dart   # ✅ Phase 2 (JSON round-trip + schema 兼容)
│   │   ├── logger.dart              # ✅ Phase 2 (包装 package:logging)
│   │   ├── download_asset_prioritizer.dart  # ✅ Phase 2 (JPEG 优先 enum)
│   │   ├── download_store.dart      # ⏳ Phase 3 (本地落盘 + 持久化 JSON)
│   │   ├── asset_thumbnail_service.dart      # ⏳ Phase 3 (简化为单 thumbnail derivative)
│   │   ├── photo_library_export_service.dart  # ⏳ Phase 3 (platform channel)
│   │   ├── download_progress_notifier.dart    # ⏳ Phase 3 (替代 LiveActivityController)
│   │   ├── background_download_runner.dart    # ⏳ Phase 3 (后台下载 + foreground service)
│   │   └── wifi_watcher.dart        # ⏳ Phase 3
│   │
│   ├── features/                    # UI 业务模块 (Phase 2 落地)
│   │   ├── connection_setup/
│   │   │   ├── connection_container.dart   # ConsumerWidget 组合根
│   │   │   ├── connection_page.dart        # Screen (无 ref.watch)
│   │   │   ├── connection_view_model.dart  # ConnectionNotifier (Notifier)
│   │   │   └── connection_state.dart       # freezed ConnectionState (9 字段)
│   │   ├── photo_browser/
│   │   │   ├── gallery_container.dart      # ConsumerWidget 组合根
│   │   │   ├── gallery_page.dart           # Screen
│   │   │   ├── gallery_view_model.dart     # GalleryNotifier (AsyncNotifier<GalleryState>)
│   │   │   └── gallery_state.dart          # freezed GalleryState
│   │   ├── downloads/
│   │   │   ├── downloads_container.dart     # ConsumerWidget
│   │   │   ├── downloads_page.dart          # 5 section 占位
│   │   │   └── download_manager_view_model.dart  # DownloadManagerNotifier
│   │   ├── settings/
│   │   │   ├── settings_container.dart     # ConsumerWidget
│   │   │   ├── settings_page.dart           # 4 section (host/port TextField + 2 Switch + 3 GridRowItem)
│   │   │   └── settings_view_model.dart     # PreferencesNotifier
│   │   ├── app_shell/                      # ✅ Phase 2 新增 (统一为单一 Notifier)
│   │   │   ├── app_shell_state.dart         # freezed AppShellState
│   │   │   └── app_shell_view_model.dart    # AppShellNotifier (ref.listen connection/gallery)
│   │   └── shared/                  # 共享 widget + 主题 (Phase 2 落地)
│   │       ├── app_theme.dart              # 22 色 token + workflowColor() + MetricTile + amberTheme() + GoogleFonts
│   │       ├── status_badge.dart            # StatusBadge
│   │       ├── shared_components.dart      # 9 widget (PrimaryActionButton / SecondaryActionButton / CustomCard / SectionHeader / GridRowItem / DownloadProgressDetails / Haptics / ShimmerView / LensGlowView)
│   │       └── formatters.dart              # fileSize / logTime / captureDate
│   │
│   └── platform/                    # ⏳ Phase 3 才创建 (iOS / Android 桥接)
│       ├── photo_library_channel.dart        # interface
│       ├── photo_library_channel_io.dart     # dart:io stub
│       ├── photo_library_channel_android.dart  # MethodChannel 实现
│       └── photo_library_channel_ios.dart       # MethodChannel 实现
│
├── test/                            # flutter_test (单测 + widget test) — Phase 2 共 102 测
│   ├── protocol/                     # 47 测 (Phase 1)
│   │   ├── primitives_test.dart              # 编解码 round-trip + sealed error + DeviceInfo
│   │   ├── experimental_nikon_transport_test.dart  # 5 测 (错误路径)
│   │   ├── session_test.dart                 # 全部 session 测试 (lifecycle + traversal + transfers)
│   │   └── transport/ptpip_connection_test.dart
│   ├── services/                     # 10 测 (Phase 2)
│   │   ├── preferences_store_test.dart       # 5 测 (JSON round-trip + schema 兼容 + error path + 持久化 key)
│   │   └── download_asset_prioritizer_test.dart  # 5 测 (cameraOrder 不变 + jpegFirst 排序 + PNG/JPEG 同级)
│   ├── features/                     # 29 测 (Phase 2)
│   │   ├── app_shell/app_shell_view_model_test.dart    # 4 测
│   │   ├── connection_setup/connection_view_model_test.dart  # 5 测
│   │   ├── photo_browser/gallery_view_model_test.dart  # 5 测
│   │   ├── downloads/download_manager_view_model_test.dart  # 3 测
│   │   ├── settings/settings_view_model_test.dart  # 4 测
│   │   └── shared/app_theme_test.dart         # 8 测 (workflowColor 6 + formatters.fileSize 4 + captureDate 4 + amberTheme 1)
│   └── helpers/                      # fake helpers
│       ├── fake_ptpip_socket.dart            # 替代 127.0.0.1 测试模式 (Phase 1)
│       └── fake_camera_transport.dart         # Phase 2 新增 (FakeCameraTransport + FakeCameraTransportFactory)
│
├── widget_test.dart                  # App 启动 smoke (1 测)
├── smoke_test.dart                   # 8 测 (4 页面 happy/error widget smoke)
│
├── android/
│   └── app/src/main/kotlin/.../
│       ├── MainActivity.kt
│       ├── PhotoLibraryPlugin.kt             # ⏳ Phase 3
│       └── DownloadForegroundService.kt      # ⏳ Phase 3
│
├── ios/                              # ⏳ Phase 3 (Windows 上创建需借 Mac)
│
├── pubspec.yaml
├── analysis_options.yaml              # Phase 2 11 条 lint 规则
└── README.md
```

与原 iOS 项目**结构对称**：`domain/` ↔ `Domain/`、`protocol/` ↔ `Services/PTPIP*` + `ExperimentalNikonTransport`、`features/` ↔ `Features/**`、`services/` ↔ `Services/` (非协议部分)。命名 1:1 方便迁移期对照参考。

---

## 5. PTP/IP 协议层移植策略

**核心原则：不复制粘贴代码，逐文件读懂后用 Dart 重写。**

### 5.1 参考原文件 (按读取顺序)

| 顺序 | 原文件 | 翻成 Dart 落点 |
|---|---|---|
| 1 | `Services/PTPIPPrimitives.swift` | `lib/protocol/primitives/` |
| 2 | `Services/PTPIPTCPConnection.swift` | `lib/protocol/transport/ptpip_connection.dart` |
| 3 | `Services/PTPIPSession+Lifecycle.swift` | `lib/protocol/session/ptpip_session.dart`（合并到单类） |
| 4 | `Services/PTPIPSession+AssetTraversal.swift` | `lib/protocol/session/ptpip_session.dart`（合并到单类） |
| 5 | `Services/PTPIPSession+Transfers.swift` | `lib/protocol/session/ptpip_session.dart`（合并到单类） |
| 6 | `Services/ExperimentalNikonTransport.swift` | `lib/protocol/experimental_nikon_transport.dart` |
| 7 | `Services/CameraTransport.swift` (协议) | `lib/protocol/camera_transport.dart` (abstract class) |
| 8 | `Services/CameraTransportFactory.swift` | 同名，工厂函数 |

### 5.2 Dart 端关键差异处理

| 原 Swift 写法 | Dart 端做法 |
|---|---|
| `withUnsafeBytes { Data(buffer) }` | `ByteData` + `Uint8List`，小端序用 `ByteData.setUint32(0, v, Endian.little)` |
| `async/await` over `Network.NWConnection` continuation | `Stream` / `Completer` over `Socket` 的 `listen` 回调 |
| 原 Swift 用 `actor` 关键字 (Swift 5.5+) 保证串行访问 | Dart 无需 `actor`；用单 `Completer` + 串行 `await` 链即可，async 调度天然互斥 |
| 错误模型 `CameraAppError` enum | Dart `Sealed class` (3.0+) + `freezed` |
| `Sendable` 标注 | Dart 顶层函数 / immutable class 自动 send-safe；无需标注 |

### 5.3 测试策略

原 iOS 测试用 `127.0.0.1` fake socket。新 Flutter 测试用同思路：

```dart
// test/helpers/fake_ptpip_socket.dart
class FakePtpipSocket implements PtpipSocket {
  final ServerSocket _server;
  // ...
}
```

把原 `Tests/PTPIPSessionAssetTraversalTests.swift` 的 259 行测试案例逐条翻译为 Dart，作为协议正确性的金标准。

---

## 6. 状态管理 (Riverpod 映射)

原 iOS ViewModel 全 `@MainActor` + `@Published`。Dart 端用 Riverpod `Notifier`：

| 原 iOS ViewModel | Flutter Notifier |
|---|---|
| `ConnectionViewModel` | `ConnectionNotifier extends Notifier<ConnectionState>` |
| `GalleryViewModel` | `GalleryNotifier extends AsyncNotifier<GalleryState>`（freezed 包 selectedAssetIDs + isLoading） |
| `DownloadManagerViewModel` | `DownloadManagerNotifier extends Notifier<DownloadQueueState>` |
| `AppShellViewModel` | `AppShellNotifier extends Notifier<AppShellState>`（单一 Notifier，Phase 2 决策改：原方案是"多 Provider 组合"，统一为单一类） |

关键设计：

- **协议层不持有 Riverpod**：`PtpipSession` 是 plain Dart 类；Notifier 注入并订阅
- **`StreamProvider`** 包装 socket 收到的数据事件；UI 用 `ref.watch(streamProvider)` 自动 rebuild
- **`family` modifier** 处理多任务下载队列 (按 `downloadId` 区分)
- **测试用 `ProviderContainer`** 注入 fake，不依赖 Flutter widget 测试框架

---

## 7. 平台差异与权限矩阵

### 7.1 iOS

| 权限 | Info.plist key | 用途 |
|---|---|---|
| Local Network | `NSLocalNetworkUsageDescription` | 首次连相机热点弹窗 |
| Photo Library Add | `NSPhotoLibraryAddUsageDescription` | 保存下载的照片 |
| Background Mode (fetch) | `UIBackgroundModes: [fetch]` | 后台传输延续 (如启用 `URLSession.background`) |
| Bonjour service type | `NSBonjourServices` (按需) | 相机发现 (mDNS) — 当前实现是直连 IP，**暂不需要** |

### 7.2 Android

| 权限 | Manifest 标签 | 备注 |
|---|---|---|
| Internet | `android.permission.INTERNET` | 必装 |
| Wi-Fi 状态 | `ACCESS_WIFI_STATE` | 监听热点断线 |
| 网络状态 | `ACCESS_NETWORK_STATE` | 同上 |
| Wi-Fi 多播 | `CHANGE_WIFI_MULTICAST_STATE` | 仅 mDNS 发现需要；直连 IP 不需要 |
| 通知 | `POST_NOTIFICATIONS` (Android 13+) | 进度通知，**运行时申请** |
| 前台服务 | `<service android:foregroundServiceType="dataSync"/>` | Android 14+ 必须显式声明 type |
| Scoped Storage | 默认 (targetSdk 30+) | 写入相册走 MediaStore，**不需要** `WRITE_EXTERNAL_STORAGE` |

### 7.3 进度通知统一方案 (替代 Live Activity)

```
iOS:    UNUserNotificationCenter 本地通知 (静态文字通知，**不支持 progress bar** — 用户需打开 app 看进度)
Android: Foreground Service + NotificationCompat.Builder.setProgress()
        + 通知点击 → deep link 回 app 当前下载页
```

> ⚠️ **iOS 用户进度体验降级**：原 iOS 用 Live Activity 显示锁屏进度条，但 Live Activity Android 无对应且本项目不实现，所以 iOS 端退化为静态文字通知。这一降级在 `产品需求.md` §3 F3 已标注。

`flutter_local_notifications` 包双端都能用，但 Android 端进度条需要 service 保活 — 用 `flutter_background_service` 包装。

---

## 8. 实施分阶段 (Tracer Bullets)

**总预估 4-6 周单人**，每阶段独立可演示、可回滚。

### Phase 0 — 工程骨架 (1-2 天)

- `flutter create viewfinder --org com.yaoyihan --platforms=ios,android`
- **Spike (半天)**：调研 `gal` 包对 RAW (.NEF) 写入相册的支持；不支持则写一个 `MediaStore` 原生 channel 备选方案。**结论作为 Phase 3 准入条件**
- 配置 `pubspec.yaml`：Riverpod / freezed / connectivity_plus / flutter_local_notifications / flutter_background_service / gal
- 配置 `analysis_options.yaml` (启用 `flutter_lints` + `public_member_api_docs`)
- 落地 `lib/domain/` 14 个 freezed model 文件 (机械翻译原 iOS `Domain/` 下的 14 个普通 Swift 文件)
- ✅ 验收：`flutter analyze` 零警告；`dart run build_runner build` 生成成功

### Phase 1 — 协议层 + Dart 协议层单测 (5-7 天) — ✅ **已完成**

- ✅ `lib/protocol/primitives/` 全部编解码 (4 文件)
- ✅ `lib/protocol/transport/` (PtpipSocket 抽象 + IoPtpipSocket 真实实现 + PtpipConnection)
- ✅ `lib/protocol/session/ptpip_session.dart`（单 PtpipSession 类，双连接架构）
- ✅ `ExperimentalNikonTransport` + `CameraTransport` 抽象 + Factory
- ✅ 6 个测试文件、47 个测试用例全部通过
- ✅ 异常场景覆盖：camera error / unexpected packet / txId mismatch / timeout / connectionClosed / invalidPacket / notConnected / missingHost / invalidPort
- ✅ `dart analyze` 干净
- ✅ 审计报告 18 个问题全部修正

**Phase 1 已完成，协议层已稳定。Phase 2 不再动协议层。**

### Phase 2 — UI 骨架阶段 (19-21 天) — ✅ **已完成 (2026-07-23)**

**目标**：搭好 UI 骨架（Riverpod Provider 拓扑 + 4 个 Tab + Shared 包），Phase 3 真机验证时直接填肉。

**为什么 Phase 2 优先 UI 骨架**：UI 骨架一次写好 Phase 4 只填肉；真机验证推到 Phase 3（与下载/进度通知一起做）。

**交付清单**：

1. Riverpod Provider 拓扑（7 个 Provider 全链路打通）
   - `preferencesStoreProvider` (Provider)
   - `transportFactoryProvider` (Provider)
   - `connectionProvider` (NotifierProvider)
   - `galleryProvider` (AsyncNotifierProvider<GalleryNotifier, GalleryState>，freezed 包 selectedAssetIDs + isLoading)
   - `downloadManagerProvider` (NotifierProvider，弱依赖 `connectionProvider`)
   - `preferencesProvider` (NotifierProvider)
   - `appShellProvider` (NotifierProvider<AppShellNotifier, AppShellState>，freezed)
2. App Shell + NavigationBar 4 个 Tab，`ViewfinderApp` ref.watch(appShellProvider) 弹 AlertDialog + global overlay
3. Connection / Gallery / Downloads / Settings 四页 UI；Settings 页含 host/port 可编辑（TextField + onChanged/onSubmitted）
4. Shared 包：`app_theme.dart`（暖白 #F9F9F8 + 琥珀金 + GoogleFonts InstrumentSerif/DMMono）+ `shared_components.dart`（11 widget）+ `formatters.dart`（fileSize/logTime/captureDate）+ `status_badge.dart`
5. 5 widget smoke + 21 Notifier 单测 + workflowColor 6 色 + formatters 8 测 + AppPreferencesStore 5 测 + DownloadAssetPrioritizer 5 测 = 共 102 测试全绿
6. `pubspec.yaml` 加 `shared_preferences` + `google_fonts` + `logging`
7. `analysis_options.yaml` 加强（11 条 lint 规则，dart analyze 0 issues）
8. DI 装配：`main.dart` → `app.dart` → 各 Page

**Phase 2 关键决策**：
- `downloadManagerProvider` 不依赖 gallery（iOS 原设计已弱化）
- AppShell 改为单一 Notifier（iOS 原"多 Provider 组合"统一为 `AppShellNotifier`）
- `GalleryNotifier` 用 `AsyncValue<GalleryState>` 包装 freezed，因为 selectedAssetIDs 不能直接进 AsyncValue

**不在本 Phase 范围**（明确切边）：
- ❌ 真机连 Nikon 验证（Phase 3）
- ❌ 下载完整文件（Phase 3）
- ❌ 进度通知 / Foreground Service（Phase 3）
- ❌ 触觉 / 动画 / Claude-style 微动效（Phase 4）
- ❌ iOS 平台代码（Phase 3 一并创建 ios/ 目录）

**任务切片**（16 个原子任务，按依赖顺序）：

| # | 任务 | 估时 |
|---|---|---|
| 2.0 | 准备 features/ 目录骨架 | 30 分钟 |
| 2.1 | pubspec.yaml 加 shared_preferences | 5 分钟 |
| 2.2 | lib/services/preferences_store.dart | 1 小时 |
| 2.3 | PreferencesNotifier + 4 单测 | 1.5 小时 |
| 2.4 | ConnectionNotifier + 5 单测 | 2 小时 |
| 2.5 | GalleryNotifier + 5 单测 | 2 小时 |
| 2.6 | DownloadManagerNotifier + 3 单测 | 1.5 小时 |
| 2.7 | Shared 包 | 2 小时 |
| 2.8 | Connection 页 UI | 1.5 小时 |
| 2.9 | Gallery 页 UI | 2 小时 |
| 2.10 | Downloads 页 UI（占位） | 1 小时 |
| 2.11 | Settings 页 UI | 1.5 小时 |
| 2.12 | app.dart + main.dart 装配 | 1 小时 |
| 2.13 | 4 widget smoke test | 1.5 小时 |
| 2.14 | analysis_options.yaml 加强 | 30 分钟 |
| 2.15 | 验收 commit + push | 1 小时 |

**验收标准**：
1. `flutter build apk --debug` 能装
2. `dart analyze` 零警告
3. `flutter test` 全绿（新增 ≥ 21 测试，总数 ≥ 68）
4. `flutter run` 起 app 4 个 Tab 切换正常
5. Settings 页能改 host/port 并保存

### Phase 3 — 真机验证 + 下载 + 进度通知 (5-7 天)

**目标**：在 Android 真机上跑通端到端：连接 + 浏览 + 下载 + 进度通知。

**任务**：
- Android 真机：连相机热点 → 启动 app → 看到照片缩略图列表 → 下载几张 → 通知中心看进度
- iOS 真机（**前提：借到 macOS**）：同上
- 补 `_parseDeviceInfo` / `_parseObjectInfo` 完整 dataset 解析（对照 iOS）
- 单张下载通路：`GetObject` → 写本地 → MediaStore / PhotoLibrary 入库
- 批量队列：参考 `DownloadAssetPrioritizer` (JPEG 优先)
- `flutter_local_notifications` 进度条；`flutter_background_service` 保活（Android）
- Wi-Fi 断线检测 + 暂停 / 重试
- 本地日志文件写入 + Settings 页提供「导出日志」按钮
- 创建 ios/ 目录（macOS 上 `flutter create . --platforms=ios`）

**不在本 Phase 范围**：
- ❌ UI 抛光 / 触觉 / 动效（Phase 4）
- ❌ 多品牌（Phase 5）

✅ 验收：
- Android 真机批量下载 50 张 RAW+JPEG 混合，进程被杀后通知仍可恢复
- 日志可导出
- 缩略图无延迟，下载进度实时更新

### Phase 4 — UI 抛光 + 触觉 + 动效 (5-6 天)

- 复刻原 `LensGlowView` / `ShimmerView` / 品牌滚轮标题动画 (用 Flutter `AnimationController`)
- 触觉：`HapticFeedback.lightImpact()` 等封装到 `SharedComponents`
- 主题：Claude-style 暖白底 (`#F9F9F8`) + 琥珀金强调色
- ✅ 验收：iOS / Android 真机**功能完整 + 视觉合格**（精细打磨放到 v1.1，原估时 3-4 天偏紧）

### Phase 5 — 多品牌扩展 (可选，预留 1-2 周)

- 当前 `cameraTransportMode` 只有 `experimentalNikon`；设计成可扩展
- Sony / Canon / Fujifilm 各加一个 transport 实现，UI 无需改动
- 此阶段仅占位，**不实现**

---

## 9. 风险与未决项

| 风险 | 影响 | 缓解 |
|---|---|---|
| Android 13+ scoped storage 下，相机下载的 RAW (.NEF) 写入相册可能失败 | 下载到 app sandbox OK，但用户相册看不到 | 评估 `gal` 包是否支持 RAW；不支持就降级到「下载到 `Pictures/NikonConnect/` 公开目录」 |
| Foreground service 在 Android 14+ 需要特定 type，type 选错被系统杀 | 后台下载中断 | 选 `dataSync` (传输类)，并在通知里明示用途 |
| PTP/IP 是相机厂商扩展协议，Nikon 特定 opcode 在不同机身上表现不一 | 某些相机连不上 / 列表为空 | Phase 2 真机测试覆盖多机型；不兼容机型降级为只读缩略图 |
| Flutter engine 包大小 (~7MB) | 对国内渠道敏感 | 启用 `--split-per-abi` 出多个 APK |
| Riverpod 3.x 还在演进 | API 可能变 | 锁版本 `flutter_riverpod: ^2.5.0`，不追 3.x |
| Dart `freezed` 代码生成慢 | 大型项目编译延迟 | 接受；目前规模下不构成问题 |
| iOS Live Activity 降级为通知，部分用户会觉得「变低端了」 | 体验降级 | README 明确说明；后续按需加回 Live Activity (在 iOS 平台用 platform channel) |

---

Phase 2 详细任务切片见 [`Phase2实施计划.md`](Phase2实施计划.md)。

## 10. 验证策略

每阶段结束跑一组 check：

```bash
# 静态检查
flutter analyze
dart format --set-exit-if-changed lib/ test/

# 单元测试
flutter test --coverage

# 集成测试 (Phase 2+)
flutter test integration_test/

# 构建验证
flutter build apk --debug      # Android
flutter build ios --no-codesign # iOS (需 macOS)
```

CI 未规划，可后续补 GitHub Actions；本地开发依赖以上命令。

---

## 11. 与原 iOS 文件的映射表

| 原 iOS 文件 | Flutter 端落点 |
|---|---|
| `App/NikonConnectApp.swift` | `lib/main.dart` + `lib/app.dart` |
| `App/AppShellViewModel.swift` | `lib/features/app_shell/app_shell_view_model.dart`（Phase 2 决策：合并到单一 `AppShellNotifier`） |
| `App/AppTheme.swift` | `lib/features/shared/app_theme.dart` |
| `App/CameraSessionCoordinator.swift` | `lib/services/wifi_watcher.dart` + Riverpod 协调 |
| `App/RootTabView.swift` | `lib/app.dart` 的 `NavigationBar` |
| `App/StatusBadgeView.swift` | `lib/features/shared/status_badge.dart` |
| `Domain/*.swift` (15 个 = 14 普通 + 1 特殊) | `lib/domain/*.dart` (freezed) |
| `Features/ConnectionSetup/*` | `lib/features/connection_setup/*` |
| `Features/PhotoBrowser/*` | `lib/features/photo_browser/*` |
| `Features/Downloads/*` | `lib/features/downloads/*` |
| `Features/Settings/*` | `lib/features/settings/*` |
| `Features/Shared/SharedComponents.swift` | `lib/features/shared/shared_components.dart` |
| `Infrastructure/AppLogger.swift` | `lib/services/logger.dart` (包装 `package:logging`) |
| `Infrastructure/Formatters.swift` | `lib/features/shared/formatters.dart` |
| `Services/AppPreferencesStore.swift` | `lib/services/preferences_store.dart` |
| `Services/AssetThumbnailService.swift` | `lib/services/asset_thumbnail_service.dart` |
| `Services/BackgroundDownloadExecutionService.swift` | `lib/services/background_download_runner.dart` |
| `Services/CameraTransport*.swift` | `lib/protocol/camera_transport.dart` + factory |
| `Services/DownloadLiveActivityController.swift` | ❌ 删除，改为 `lib/services/download_progress_notifier.dart` |
| `Services/DownloadStore.swift` | `lib/services/download_store.dart` |
| `Services/ExperimentalNikonTransport.swift` | `lib/protocol/experimental_nikon_transport.dart` |
| `Services/PhotoLibraryExportService.swift` | `lib/platform/photo_library_channel_*.dart` |
| `Services/PTPIPPrimitives.swift` | `lib/protocol/primitives/*.dart` |
| `Services/PTPIPSession+Lifecycle.swift` | `lib/protocol/session/ptpip_session.dart`（单类） |
| `Services/PTPIPSession+AssetTraversal.swift` | `lib/protocol/session/ptpip_session.dart`（单类） |
| `Services/PTPIPSession+Transfers.swift` | `lib/protocol/session/ptpip_session.dart`（单类） |
| `Services/PTPIPSession.swift` | `lib/protocol/session/ptpip_session.dart` |
| `Services/PTPIPTCPConnection.swift` | `lib/protocol/transport/ptpip_connection.dart` |
| `DownloadActivityWidget/*` | ❌ 删除 (跨端不实现 Live Activity) |
| `Tests/*.swift` (7 个) | `test/**/*.dart` (重写为 Dart 单测) |

### 11.1 补充映射 (嵌套类型 + 接口协议)

iOS 的 Swift 单文件常包含多个类型，且 Service 实现都有对应接口协议。映射补全：

| 原 iOS 内容 | 所在文件 | Flutter 端落点 |
|---|---|---|
| `PhotoAssetKind` enum (raw/jpeg/png/movie) | `Domain/PhotoAsset.swift` | `lib/domain/photo_asset.dart` 同文件 |
| `PhotoAssetThumbnailInfo` struct | `Domain/PhotoAsset.swift` | 同上 |
| `PhotoAssetPage` struct (分页返回) | `Domain/PhotoAsset.swift` | 同上 |
| `CameraCapability` enum | `Domain/CameraSession.swift` | `lib/domain/camera_session.dart` 同文件 |
| `DownloadJobStatus` enum (queued/running/.../failed) | `Domain/DownloadJob.swift` | `lib/domain/download_job.dart` 同文件 |
| `DownloadQueueStatus` enum | `Domain/DownloadQueueState.swift` | 同文件 |
| `DownloadThroughputTransferMode` enum (fullObject/partialObject/unknown) | `Domain/DownloadThroughputDiagnostics.swift` | 同文件 |
| `DownloadTransferProgress` struct (进度回调类型) | `Services/CameraTransport.swift` | `lib/protocol/camera_transport.dart` 同文件 |
| `DownloadAssetPrioritizer` enum (JPEG 优先排序) | `Features/Downloads/DownloadManagerViewModel.swift` | `lib/services/download_asset_prioritizer.dart` 单独抽出 |
| `CameraTransportFactoryProtocol` (工厂接口) | `Services/CameraTransportFactoryProtocol.swift` | `lib/protocol/camera_transport_factory.dart` (abstract class) |
| `AppPreferencesStoring` (接口) | `Services/AppPreferencesStoring.swift` | `lib/services/preferences_storing.dart` (abstract class) |
| `DownloadStoring` (接口) | `Services/DownloadStoring.swift` | `lib/services/download_storing.dart` (abstract class) |
| `AssetThumbnailServing` (接口) | `Services/AssetThumbnailServing.swift` | `lib/services/asset_thumbnail_serving.dart` (abstract class) |
| `DownloadActivityAttributes` (特殊) | `Domain/DownloadActivityAttributes.swift` | **折叠**到 `lib/services/download_progress_notifier.dart` 内部私有 state class（无 widget 后无需独立文件） |

---

## 12. 立即下一步

如果你接受这个方案，建议执行顺序：

1. **本周**：跑 `flutter create` 落地工程骨架 → 把 `lib/domain/` 14 个文件全部 freezed 化 → `flutter analyze` 干净
2. **下周**：Phase 1 协议层开干，先实现 `PTPIPPrimitives` 的 Dart 版 + 单测
3. **第三周起**：拿到真机 + 真 Nikon 相机，按 Phase 2/3 推进

如果你要先讨论某一块 (比如 freezed 用法、Riverpod 模式选择、或 Phase 1 协议层具体某个文件的 Dart 翻译思路)，告诉我具体哪一块。