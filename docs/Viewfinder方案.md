# Viewfinder (取景器) — Flutter 重写方案

> 把当前 iOS 项目 `NikonConnectIOS` 用 Flutter 推倒重写，新工程命名 **Viewfinder**，路径 `D:\Nikon_connect\Viewfinder\`（2026-07-27 从 `D:\桌面\Nikon_connect\Viewfinder\` 迁出，绕开 aapt 中文路径 `Illegal byte sequence`）。  
> 原 iOS Swift 代码不直接复用，但作为**协议参考文档**保留阅读价值。  
> 计划粒度：tracer bullet 阶段，可直接据此推进。  
> **当前状态**（2026-07-27）：Phase 0 ~ Phase 4 **全部 100% 完成**，385 单测全绿，零警告。详见 [`项目状态.md`](项目状态.md) 与 [`Phase4实施计划.md`](Phase4实施计划.md)。

## 0. 项目元信息

| 项 | 值 |
|---|---|
| 项目名 (英文) | **Viewfinder** |
| 项目名 (中文) | **取景器** (相机取景器 / 摄影师透过它构图) |
| Flutter package 名 | `viewfinder` (Flutter 强制 snake_case lowercase) |
| 工程根路径 | `D:\Nikon_connect\Viewfinder\` |
| 来源 iOS 项目 | `D:\桌面\Nikon_connect\` (本仓的上级目录，现已不在 active 目录) |
| Bundle ID (iOS) | `com.yaoyihan.viewfinder` |
| Application ID (Android) | `com.yaoyihan.viewfinder` |
| 原 iOS bundle id | `com.yaoyihan.NikonConnectIOS` (仅作对照) |
| GitHub 仓库 | `https://github.com/AbandonS-ED/Viewfinder` |
| Git 用户 | `AbandonS-ED` + 隐私邮箱 `AbandonS-ED@users.noreply.github.com` |

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

> **2026-07-27 校准**：`pubspec.yaml` 是真来源，本节是当初 Phase 0 选型；其中 `gal` / `mocktail` / `json_serializable` / `very_good_analysis` **最终未采用**（Phase 2/3 评估后替代方案见备注），但保留记录便于追溯。

| 层 | 选型 | 实际落地 | 备注 |
|---|---|---|---|
| 语言 | Dart 3.x | ✅ Flutter 默认 | |
| Framework | Flutter stable channel | ✅ | 用户已选 Flutter |
| 最低 iOS | 16.0 | ✅ | 与原项目对齐 |
| 最低 Android | API 24 (Android 7.0) | ✅ | |
| 状态管理 | **Riverpod 2.x** (`flutter_riverpod: ^2.5.0`) | ✅ | 编译期安全、对 async 友好 |
| 数据类 | **freezed** (`^2.4.0`) | ✅ | 替代手写 `==` / `hashCode` / `copyWith`；JSON 手写 codec（见下） |
| 网络层 | `dart:io` Socket (裸 TCP) | ✅ | PTP/IP 是二进制协议 |
| 序列化 | `dart:convert` + `dart:typed_data` (SDK 内置) | ✅ | 直接操作 `Uint8List` / `ByteData`，与 iOS `PTPIPPrimitives` 1:1 |
| 本地存储 (KV) | `shared_preferences` (^2.3.0) | ✅ | 替代 `UserDefaults` |
| 本地存储 (文件) | `path_provider` (^2.1.0) + `dart:io` | ✅ | |
| 相册写入 | ❌ `gal` + ✅ 自写 platform channel | ✅ 自写 | Phase 3 评估 `gal` 不支持 RAW，写 `PhotoLibraryPlugin.kt` (Android MediaStore) + `PhotoLibraryPlugin.swift` (iOS PHPhotoLibrary.addOnly) + Dart 端 IO stub |
| 通知 / 进度 | `flutter_local_notifications` (^17.0.0) + `flutter_background_service` (^5.0.0) | ✅ | Android 进度条 + Foreground Service；iOS 仅静态文字通知 |
| Wi-Fi 监听 | `connectivity_plus` (^6.0.0) + `network_info_plus` (^4.0.0) | ✅ | BSSID + SSID 双指标 |
| 日志 | `logging` (^1.2.0) | ✅ | AppLogger 包装 |
| 国际化 | 暂未实装 | ❌ | Phase 5 评估（不影响首发） |
| 测试 | `flutter_test` (SDK) + 自写 fake | ✅ | ❌ 未装 `mocktail`；用 `test/helpers/fake_ptpip_socket.dart` + `fake_camera_transport.dart` 自写 fake |
| 序列化工具 | ❌ `json_serializable` / ✅ 手写 codec | ✅ 手写 | `DownloadStore` `_encodeRecord`/`_decodeRecord` + `_encodeJob`/`_decodeJob` 手写 |
| Lint | `flutter_lints` (^6.0.0) + 11 条 Phase 2 加强 | ✅ | ❌ 未装 `very_good_analysis`；`analysis_options.yaml` 11 条加强规则 + 排除 `**/*.freezed.dart` 即可 |
| 依赖版本 | **全部锁主版本号** | ✅ | 见 pubspec.yaml |

---

## 3. 平台能力映射

| 原 iOS 能力 | Flutter / Dart 实现 | 备注 |
|---|---|---|
| `Network.framework` TCP | `dart:io.Socket` (`IoPtpipSocket`) | BSD socket 跨端，零桥接 |
| `UserDefaults` JSON | `shared_preferences` + 手写 codec (`AppPreferencesStore`) | 见 §11 |
| `FileManager` | `dart:io.File` + `path_provider` | |
| `PHPhotoLibrary` (写入) | **自写 platform channel**（`PhotoLibraryPlugin.kt` Android + `.swift` iOS + Dart IO stub）；❌ **未用 `gal`** | Phase 3 评估 `gal` 不支持 RAW，自写 channel 已落地 |
| `ActivityKit` Live Activity | ❌ 不实现 | Android 无对应；跨端统一降级为本地通知 |
| `UIImpactFeedbackGenerator` | `HapticFeedback.lightImpact()` 等 + `Haptics` 封装 | API 较粗，足够用 |
| `Local Network` 权限弹窗 | iOS: `NSLocalNetworkUsageDescription`；Android: `ACCESS_WIFI_STATE` + `ACCESS_NETWORK_STATE` | Android `CHANGE_WIFI_MULTICAST_STATE` 注销（无 mDNS 发现） |
| 后台下载 | iOS `IosBackgroundDownloadRunner`（MethodChannel `'viewfinder/background_download'` 占位，需 Mac 真机编）；Android `AndroidBackgroundDownloadRunner` (`dataSync` type, `flutter_background_service`) | iOS 仅占位，**Phase 3 后**真机验证未做 |
| 相机热点网络监测 | `connectivity_plus` + `network_info_plus`（`WifiWatcher` / `DefaultWifiWatcher`）+ 反应式 `cameraWifiConnectedProvider` | BSSID + SSID 双指标检测 Nikon Wi-Fi，含反应式镜像 |
| XcodeGen / xcodebuild | `flutter build ios / apk / appbundle` | Flutter 自带 |
| **错误抽象** | `CameraAppError` sealed class (8 case) + `PTPIPError` sealed class (10 case) | 错误不向上混 |

---

## 4. 工程目录结构

**Phase 4 落地后实际目录**（2026-07-27 快照）：

```
Viewfinder/                           # Flutter 工程根
├── lib/
│   ├── main.dart                      # runApp + ProviderScope + 7 service override
│   ├── app.dart                       # MaterialApp + PageView 4 Tab + GlobalActivityCapsule
│   │
│   ├── domain/                        # 26 个文件 (16 源 + 10 .freezed.dart)
│   │   ├── camera_connection_config.dart
│   │   ├── camera_transport_mode.dart
│   │   ├── camera_session.dart
│   │   ├── camera_capability.dart
│   │   ├── camera_workflow_state.dart
│   │   ├── photo_asset.dart            # 含 PhotoAssetKind enum + ThumbnailInfo + Page (嵌套)
│   │   ├── photo_asset_merge.dart      # 静态工具方法
│   │   ├── download_job.dart           # 含 DownloadJobStatus 7 enum (嵌套)
│   │   ├── download_queue_state.dart   # 含 DownloadQueueStatus 4 enum (嵌套)
│   │   ├── download_record.dart
│   │   ├── active_download_progress.dart
│   │   ├── download_throughput_diagnostics.dart  # 含 3 enum + Recorder class
│   │   ├── download_throughput_stats.dart  # 不进 freezed，纯 data class
│   │   ├── log_entry.dart
│   │   ├── alert_context.dart
│   │   └── camera_app_error.dart       # sealed class, 8 case
│   │
│   ├── protocol/                      # PTP/IP 协议层 (与 UI 解耦)
│   │   ├── primitives/                # 编解码 (对应 PTPIPPrimitives.swift)
│   │   │   ├── ptpip_data_types.dart        # 4 enum (PacketType/OpCode/ResponseCode/DataPhaseInfo) + 常量
│   │   │   ├── ptpip_data_structures.dart   # 4 freezed data class (RawPacket/DeviceInfo/ObjectInfo/Response)
│   │   │   ├── ptpip_packet_codec.dart      # PTPDataReader + PTPIPCodec 小端序
│   │   │   └── ptpip_error.dart             # sealed class PTPIPError 10 case
│   │   ├── transport/                 # 长连接 + socket
│   │   │   ├── ptpip_socket.dart            # abstract 接口
│   │   │   ├── ptpip_socket_io.dart         # IoPtpipSocket 真实实现
│   │   │   └── ptpip_connection.dart        # 高层连接管理
│   │   ├── session/                   # 会话层 (单 PtpipSession 类合并 3 extension)
│   │   │   └── ptpip_session.dart           # 双连接架构 (lifecycle/traversal/transfers)
│   │   ├── camera_transport.dart           # 品牌抽象 (对应 CameraTransport 协议)
│   │   ├── experimental_nikon_transport.dart  # 唯一实现 (Phase 1+3 加 onProgress 流式)
│   │   └── camera_transport_factory.dart   # 工厂 (返回 ExperimentalNikonTransport)
│   │
│   ├── services/                      # 应用级服务 (Phase 2 + 3 共 9 文件 + logger)
│   │   ├── preferences_store.dart     # ✅ Phase 2
│   │   ├── logger.dart                # ✅ Phase 2 (AppLogger + setupLogging)
│   │   ├── download_asset_prioritizer.dart  # ✅ Phase 2
│   │   ├── download_store.dart        # ✅ Phase 3 (JSON 持久化 + Mutex 串行化)
│   │   ├── asset_thumbnail_service.dart      # ✅ Phase 3 (内存 cache + inFlight 去重)
│   │   ├── wifi_watcher.dart          # ✅ Phase 3 (BSSID + SSID 双指标)
│   │   ├── log_file_store.dart        # ✅ Phase 3 (1MB rotation + 3 文件备份)
│   │   ├── download_notification_service.dart  # ✅ Phase 3 (Android 进度条 + _payloads deepLink)
│   │   └── background_download_runner.dart    # ✅ Phase 3 (Android Foreground Service)
│   │
│   ├── features/                      # UI 业务模块 (Phase 2 落地 + Phase 4 扩展)
│   │   ├── connection_setup/
│   │   │   ├── connection_container.dart   # ConsumerWidget 组合根
│   │   │   ├── connection_page.dart        # Screen (Phase 4b B7 加 6 state 提示)
│   │   │   ├── connection_state.dart       # freezed ConnectionState
│   │   │   ├── connection_view_model.dart  # ConnectionNotifier (build() 读 preferencesProvider)
│   │   │   └── hero_title.dart             # Phase 4b B4: 状态机 + brand 轮播
│   │   ├── photo_browser/
│   │   │   ├── gallery_container.dart      # ConsumerWidget (Phase 4b B6 网格密度切换)
│   │   │   ├── gallery_page.dart           # Phase 4b B6: toolbar + 3↔5 列
│   │   │   ├── gallery_state.dart          # freezed GalleryState + GridDensity enum
│   │   │   ├── gallery_view_model.dart     # AsyncNotifier (Phase 4b 移除 mock fallback)
│   │   │   ├── thumbnail_widget.dart       # Phase 3 真实缩略图 FutureBuilder
│   │   │   └── zoomable_photo_preview.dart # Phase 4b B2: 双击缩放 1x↔2.5x
│   │   ├── downloads/
│   │   │   ├── downloads_container.dart
│   │   │   ├── downloads_page.dart          # 5 section (Phase 4b B5 加 ThroughputDiagnostics)
│   │   │   ├── download_manager_view_model.dart  # 13 方法全真实现
│   │   │   └── throughput_diagnostics_section.dart  # Phase 4b B5
│   │   ├── settings/
│   │   │   ├── settings_container.dart
│   │   │   ├── settings_page.dart           # 248 行 (Phase 4b 拆 2 section)
│   │   │   ├── settings_view_model.dart
│   │   │   ├── appearance_section.dart      # Phase 4a 外观
│   │   │   ├── defaults_section.dart        # Phase 4b 拆出
│   │   │   ├── support_section.dart         # Phase 4b 拆出
│   │   │   ├── theme_view_model.dart        # Phase 4a ThemeNotifier
│   │   │   └── widgets/
│   │   │       └── theme_picker_row.dart    # Phase 4a 5 主题选择器
│   │   ├── app_shell/                      # 单一 AppShellNotifier
│   │   │   ├── app_shell_state.dart
│   │   │   └── app_shell_view_model.dart    # ref.listen connection/gallery
│   │   └── shared/                  # 共享 widget + 主题 (Phase 2 + 4 扩展)
│   │       ├── app_theme.dart              # @Deprecated AppThemeColors (Phase 4a 迁移完)
│   │       ├── shared_components.dart      # barrel → widgets/ (11 文件)
│   │       ├── theme_palette.dart          # Phase 4a: 5 palette × 22 色 + kEnableMultiTheme
│   │       ├── viewfinder_theme.dart       # Phase 4a: ThemeExtension + _buildTextTheme
│   │       ├── status_badge.dart
│   │       ├── formatters.dart
│   │       └── widgets/
│   │           ├── section_header.dart
│   │           ├── custom_card.dart
│   │           ├── primary_action_button.dart
│   │           ├── secondary_action_button.dart
│   │           ├── grid_row_item.dart
│   │           ├── download_progress_details.dart
│   │           ├── haptics.dart
│   │           ├── shimmer_view.dart
│   │           ├── lens_glow_view.dart
│   │           ├── global_activity_capsule.dart   # Phase 4b B3
│   │           └── status_bar_widget.dart         # Phase 4b B8
│   │
│   └── platform/                      # ✅ Phase 3 (1 文件含全部实现)
│       └── photo_library_channel.dart        # abstract + IO + Android + iOS + factory
│
├── test/                              # flutter_test — 385 测 (2026-07-27)
│   ├── protocol/                       # PTP/IP 编解码 + 传输 + 会话 + Transport
│   │   ├── primitives_test.dart
│   │   ├── experimental_nikon_transport_test.dart
│   │   ├── session_test.dart
│   │   ├── transport/ptpip_connection_test.dart
│   │   └── get_object_to_temp_file_test.dart
│   ├── domain/                         # DownloadQueueState + DownloadThroughputStats
│   ├── services/                       # PreferencesStore / ThumbnailService / WifiWatcher / LogFileStore / Notification / BackgroundRunner / DownloadStore
│   ├── features/                       # 6 Notifier + 主题 + widgets + Gallery + HeroTitle + Zoomable
│   ├── platform/                       # PhotoLibraryChannel 3 端实现
│   ├── integration/                    # 8 端到端 widget test (Phase 4c 代码骨架)
│   │   ├── 01_app_launch_test.dart
│   │   ├── 02_theme_persistence_test.dart
│   │   ├── 03_fake_camera_connection_test.dart
│   │   ├── 04_download_flow_test.dart
│   │   ├── 05_wifi_disconnect_test.dart
│   │   ├── 06_theme_5x_test.dart
│   │   ├── 07_notification_test.dart
│   │   ├── 08_background_runner_test.dart
│   │   ├── fake_nikon_server.dart
│   │   └── helpers/test_app.dart
│   └── helpers/                        # 共享 fake
│       ├── fake_ptpip_socket.dart
│       ├── fake_camera_transport.dart
│       └── stubs.dart
│
├── widget_test.dart                    # App 启动 smoke
├── smoke_test.dart                     # 4 页面 happy/error widget smoke
│
├── android/
│   └── app/src/main/kotlin/.../
│       ├── MainActivity.kt
│       ├── PhotoLibraryPlugin.kt             # ✅ Phase 3
│       └── BackgroundDownloadPlugin.kt       # ✅ Phase 3
│
├── ios/                                # ✅ Phase 3 (手动创建，需 macOS flutter create 验证编译)
│
├── docs/                               # 项目文档 (中文)
│   ├── 产品需求.md
│   ├── 架构.md
│   ├── 项目状态.md
│   ├── Viewfinder方案.md                  # 本文档
│   ├── Phase1实施计划.md
│   ├── Phase2实施计划.md
│   ├── Phase3实施计划.md
│   ├── Phase4实施计划.md
│   ├── B10_visual_audit.md
│   └── 原项目缺陷诊断报告.md
│
├── pubspec.yaml
├── analysis_options.yaml                # 11 条 lint + analyzer exclude **/*.freezed.dart
├── AGENTS.md                            # AI 工作守则
├── CLAUDE.md                            # Claude Code 项目入口
└── README.md                            # 用户面 + 测试统计 + 链接
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
|---|---|---|
| `ConnectionViewModel` | `ConnectionNotifier extends Notifier<ConnectionState>` |
| `GalleryViewModel` | `GalleryNotifier extends AsyncNotifier<GalleryState>`（freezed 包 selectedAssetIDs + isLoading） |
| `DownloadManagerViewModel` | `DownloadManagerNotifier extends Notifier<DownloadQueueState>`（13 公开方法：enqueueSelected/cancelJob/retryJob/pauseJob/resumeJob/cancelAll/clearFinished/downloadSelected/loadPersistedQueue/pauseAll/resumeAll/unpauseJobsWithWifiActive/runQueue） |
| `AppShellViewModel` | `AppShellNotifier extends Notifier<AppShellState>`（单一 Notifier，Phase 2 决策改：原方案是"多 Provider 组合"，统一为单一类） |

关键设计：

- **协议层不持有 Riverpod**：`PtpipSession` 是 plain Dart 类
- **onProgress 回调链**：`ExperimentalNikonTransport.downloadAsset(onProgress:)` → `DownloadManagerNotifier._handleProgressUpdate()` → `DownloadNotificationService.update()`，不通过 Riverpod 广播进度（避免 UI 不必要 rebuild）
- **Provider 替代 Coordinator**：iOS `CameraSessionCoordinator` 职责由 Riverpod Provider 拓扑 + `WifiWatcher` 替代
- **`unawaited(_save())`** fire-and-forget persistence（lint 规则）

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

**总预估 4-6 周单人**，每阶段独立可演示、可回滚。**当前进度**（2026-07-27）：

| Phase | 状态 | 测试增量 | 说明 |
|---|---|---|---|
| Phase 0 — 工程骨架 + 14 个 Domain freezed model | ✅ 已完成 (2026-07-22) | — | 见下文 §8.0 |
| Phase 1 — PTP/IP 协议层 + Dart 单测 | ✅ 已完成 (2026-07-23) | 47 测 | 见下文 §8.1 |
| Phase 2 — UI 骨架阶段 | ✅ 已完成 (2026-07-23) | +55 → 102 测 | 见下文 §8.2 |
| Phase 3 — Android 端到端 + 下载完整链路 | ✅ 已完成 (2026-07-24; v2/v3 全审修正 2026-07-25) | +96 → 198 测 | 见下文 §8.3 |
| Phase 4 — UI 抛光 + 5 主题 + B10 视觉对齐 | ✅ 已完成 (2026-07-26 ~ 27) | +187 → **385 测** | 见 [`Phase4实施计划.md`](Phase4实施计划.md) |
| Phase 5 — 多品牌扩展 (Sony / Canon / Fujifilm) | ⏳ 未开始 (占位) | — | 详见 [`Phase5实施计划.md`](Phase5实施计划.md)（待 D1~D10 拍板后启动） |

> 各阶段详细测试基线见 [`项目状态.md §3.4 - §3.5 + §5`](项目状态.md)。

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

### Phase 3 — ✅ 已完成 (2026-07-24 初版 / 2026-07-25 v2 全审修正)

**目标**：在 Android 真机上跑通端到端：连接 + 浏览 + 下载 + 进度通知。

🔧 **实际交付**（**198 单测全绿**, `dart analyze` 0 issues）：
- Android APK 构建成功（`flutter build apk --debug`，160 MB）
- 6 个核心 service：DownloadStore / AssetThumbnailService / WifiWatcher / LogFileStore / DownloadNotificationService / BackgroundRunner
- DownloadManagerNotifier 全量 13 公开方法全部真实现（含 v2 修复：refreshDownloads listRecords 对账 + appendTransportDiagnostics _runQueue step 9）
- UI 连线：DownloadsPage 4 section 全功能按钮（pause/resume/cancel/retry/clearFinished）+ GalleryPage `onDownloadSelected` 从 connectionProvider 读用户偏好（v2 修复，v3 真修根因）+ 真实缩略图（AssetThumbnailService FutureBuilder）
- Android 平台代码：PhotoLibraryPlugin.kt（MediaStore）+ BackgroundDownloadPlugin.kt + MainActivity.kt 注册 + AndroidManifest 权限 15 项 + foreground service
- iOS 平台文件手动创建（需 macOS `flutter create --platforms=ios` 验证编译）
- 集成测试 + 平台测试 = **198 单测全绿**，`dart analyze` 零警告

#### 2026-07-25 v2 关键修复（8 项）
| # | 修复 | 章节 | 类型 |
|---|---|---|---|
| 1 | `handleScenePhaseChange` switch 加 3 个 break | §5.5 | CRITICAL BUG |
| 2 | `cameraWifiConnectedProvider` 反应式订阅 `connectionStream` | §9.4 | CRITICAL |
| 3 | `connectionProvider.build()` 改读 `preferencesProvider` (v1→v2 部分修复，v3 修根因) | §5.6 / §6.1 | HIGH |
| 4 | GalleryContainer 改从 connectionProvider 读用户偏好 | §5.6 / §13.4 | HIGH |
| 5 | `refreshDownloads` 真实现 | §5.2 step 11 | HIGH |
| 6 | `appendTransportDiagnostics` + `_runQueue` step 9 | §5.2 step 9 | HIGH |
| 7 | NotificationService `_payloads` Map 保留 payload | §7.4 | MEDIUM |
| 8 | LogFileStore.exportFile() 用 timestamp 命名 | §10.2 | LOW |

#### 2026-07-25 v3 根因修复（1 项 + 1 回归测）

v2 让 GalleryContainer 读 `connectionProvider`, 但 `ConnectionNotifier.build()` 用的是 stable `ref.watch(preferencesStoreProvider)`, Settings 改 toggle 后 `connectionProvider` 不立刻更新 —— **v2 修复没有真正让设置页 toggle 生效**。

| # | 修复 | 章节 | 类型 |
|---|---|---|---|
| 9 | `ConnectionNotifier.build()` 改 `ref.watch(preferencesProvider)` (NotifierProvider 替代 stable `preferencesStoreProvider`) | §5.6 / §6.1 | **HIGH (v2 根因)** |
| 10 | 新增 `connectionProvider 反应式跟随 preferencesProvider` 回归测 | §5.7 / §16 | regression test |

**不在本 Phase 范围**（未变）：
- ❌ UI 抛光 / 触觉 / 动效（Phase 4）
- ❌ 多品牌（Phase 5）

### Phase 4 — UI 抛光 + 触觉 + 动效 (5-6 天) — ✅ **已完成 (2026-07-26 ~ 27)**

**拆分**：4a（5 主题）+ 4b（UI 抛光 + 动效 + 7 iOS 元素补齐）+ 4c（端到端集成测试代码骨架）。

**实际交付**（**+187 测试 → 385/385 全绿**，零警告，详情见 [`Phase4实施计划.md`](Phase4实施计划.md)）：

- **4a 主题（+139 测）**：5 套主题 (amber/forest/slate/terr/onyx) × 22 色 token + `ThemePalette` + `ThemeExtension` (ViewfinderTheme.of(context)) + `ThemeNotifier` 反应式 + themeID 持久化 + `kEnableMultiTheme` 回滚 flag + `AppearanceSection` UI + `AppThemeColors` 标 `@Deprecated` + 6 widget/page 全迁移 (21 处)
- **4b UI 抛光（+31 测）**：
  - B1 IndexedStack → PageView + 280ms easeInOutCubic 滑动
  - B2 ZoomablePhotoPreview 双击缩放 1x↔2.5x + close 淡入淡出 + 单击 1x 关闭
  - B3 GlobalActivityCapsule 顶部胶囊替换全屏 loading overlay
  - B4 HeroTitleStateMachine brand 轮播 (waitingForWifi 3s 切换 3 brand)
  - B5 ThroughputDiagnostics section (totalBytes/completedItems/avgBytesPerItem)
  - B6 Gallery 网格密度 (标准 3 列 ↔ 紧凑 5 列)
  - B7 ConnectionPage 6 workflow state 提示文案
  - B8 自定义 StatusBarWidget
  - B10 #1 颜色对齐 muban.html：5 主题 27 处色值改 + 115 palette_test 重写
  - B10 #2 字体对齐 muban.html：Noto Sans SC (中文正文) + Instrument Serif (衬线标题)
- **4c 端到端测试（+8 测）**：
  - 8 integration widget tests (app_launch/theme_persistence/fake_camera_connection/download_flow/wifi_disconnect/theme_5x/notification/background_runner)
  - helpers/test_app.dart (buildTestApp + initTestEnv)
  - 清理后 0 warnings
- 同时：`shared_components.dart` 拆成 `widgets/` 11 文件

**真机验证遗留**：iOS 端 Phase 4 视觉对齐需要 iPhone（界面触感）+ Mac（编译验证），Android 端已在 emulator 验证空相册场景。

### Phase 5 — 多品牌扩展 (可选，预留 1-2 周) — ⏳ **未开始**

- 当前 `cameraTransportMode` 只有 `experimentalNikon`；设计成可扩展（CameraTransport abstract class 已留扩展点）
- Sony / Canon / Fujifilm 各加一个 transport 实现，UI 与协议编排层无需改动
- 此阶段**仅占位**，实施前需先确认：
  1. 有 Mac + 三品牌中至少一台真机
  2. 有对应品牌的 PTP/IP opcode / 私有协议文档
  3. 决策先做哪个品牌（推荐 Sony：Sony Remote API 公开，相对好入手）

详细规划见 [`Phase5实施计划.md`](Phase5实施计划.md)（待 D1~D10 拍板后启动）。

---

## 9. 风险与未决项（2026-07-27 增量更新）

| 风险 | 影响 | 缓解 / 状态 |
|---|---|---|
| Android 13+ scoped storage 下，相机下载的 RAW (.NEF) 写入相册可能失败 | 下载到 app sandbox OK，但用户相册看不到 | ⚠️ Phase 3 评估结论：`gal` 包不支持 RAW；已写 `MediaStore` 原生 channel（`PhotoLibraryPlugin.kt`），可写 RAW 到 `Pictures/Viewfinder/`。**待真机端到端验证** |
| Foreground service 在 Android 14+ 需要特定 type，type 选错被系统杀 | 后台下载中断 | ✅ Phase 3 选 `dataSync` + 通知里明示用途，APK 构建通过 |
| PTP/IP 是相机厂商扩展协议，Nikon 特定 opcode 在不同机身上表现不一 | 某些相机连不上 / 列表为空 | ⏳ Phase 1 + 3 未做真机验证；目前用 `FakePtpipSocket` + `FakeCameraTransport` 单测覆盖代码路径。**待真机** |
| Flutter engine 包大小 (~7MB) | 对国内渠道敏感 | ⏳ Phase 5 评估：启用 `--split-per-abi` 出多个 APK |
| Riverpod 3.x 还在演进 | API 可能变 | ✅ 锁 `flutter_riverpod: ^2.5.0`，Phase 4 没动 |
| Dart `freezed` 代码生成慢 | 大型项目编译延迟 | ✅ 接受；规模不构成问题 |
| iOS Live Activity 降级为通知，部分用户会觉得「变低端了」 | 体验降级 | ⚠️ README 已说明；Phase 5 评估是否加回（需 Mac） |
| 中文路径导致 aapt `Illegal byte sequence` | Android 构建失败 | ✅ 2026-07-27 路径迁 `D:\桌面\Nikon_connect\` → `D:\Nikon_connect\` 解决 |
| GitHub push 网络不稳 | 推送失败 | ✅ 重试机制（已多次验证可重试成功） |
| iOS 真机构建 | 需 macOS + Xcode 16+ | ⏳ 阻塞，等用户拿到 Mac |
| Phase 4 视觉细节对齐 | 需 iPhone 实测手感 | ⏳ 阻塞，等用户拿到 iPhone |

---

Phase 2 详细任务切片见 [`Phase2实施计划.md`](Phase2实施计划.md)。

## 10. 验证策略

每阶段结束跑一组 check：

```bash
# 设置国内镜像（每个新 PowerShell session 都要设一次）
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"

# 静态检查（项目约定用 dart analyze，不用 flutter analyze，因为后者在中文路径下有 LSP bug）
dart analyze                                              # 0 warnings（剩 12 info：集成测试命名 + const 提示）

# 单元测试
flutter test                                              # 385/385 全绿
flutter test test/protocol                                # 协议层
flutter test test/features                                # UI + Notifier + 主题
flutter test test/services                                # 服务层
flutter test test/domain                                  # Domain 层

# 自由生成 freezed 代码（修改 @freezed 类后必须跑）
dart run build_runner build --delete-conflicting-outputs

# 构建验证
flutter build apk --debug                                 # Android（已验证 160MB）
flutter build ios --no-codesign --debug                   # iOS（需 macOS，未验证）
flutter run -d emulator-5554                              # Android emulator 调试
```

CI 未规划，可后续补 GitHub Actions；本地开发依赖以上命令。

---

## 11. 与原 iOS 文件的映射表

| 原 iOS 文件 | Flutter 端落点 |
|---|---|---|
| `App/NikonConnectApp.swift` | `lib/main.dart` + `lib/app.dart` |
| `App/AppShellViewModel.swift` | `lib/features/app_shell/app_shell_view_model.dart`（Phase 2 决策：合并到单一 `AppShellNotifier`） |
| `App/AppTheme.swift` | `lib/features/shared/app_theme.dart` |
| `App/CameraSessionCoordinator.swift` | `lib/services/wifi_watcher.dart` + Riverpod Provider 拓扑替代 |
| `App/RootTabView.swift` | `lib/app.dart` 的 `NavigationBar` |
| `App/StatusBadgeView.swift` | `lib/features/shared/status_badge.dart` |
| `Domain/*.swift` (15 个 = 14 普通 + 1 特殊) | `lib/domain/*.dart` (freezed) |
| `Features/ConnectionSetup/*` | `lib/features/connection_setup/*` |
| `Features/PhotoBrowser/*` | `lib/features/photo_browser/*` |
| `Features/Downloads/*` | `lib/features/downloads/*` + `lib/services/download_manager_notifier.dart` |
| `Features/Settings/*` | `lib/features/settings/*` |
| `Features/Shared/SharedComponents.swift` | `lib/features/shared/shared_components.dart` |
| `Infrastructure/AppLogger.swift` | `lib/services/logger.dart` (包装 `package:logging`) |
| `Infrastructure/Formatters.swift` | `lib/features/shared/formatters.dart` |
| `Services/AppPreferencesStore.swift` | `lib/services/preferences_store.dart` |
| `Services/AssetThumbnailService.swift` | `lib/services/asset_thumbnail_service.dart`（内存 cache + in-flight 去重，~50 行） |
| `Services/BackgroundDownloadExecutionService.swift` | `lib/services/background_download_runner.dart` |
| `Services/CameraTransport*.swift` | `lib/protocol/camera_transport.dart` + factory |
| `Services/DownloadLiveActivityController.swift` | ❌ 删除，改为 `lib/services/download_notification_service.dart`（跨端不实现 Live Activity） |
| `Services/DownloadStore.swift` | `lib/services/download_store.dart` |
| `Services/ExperimentalNikonTransport.swift` | `lib/protocol/experimental_nikon_transport.dart` |
| `Services/PhotoLibraryExportService.swift` | `lib/platform/photo_library_channel_*.dart` |
| `Services/PTPIPPrimitives.swift` | `lib/protocol/primitives/*.dart` |
| `Services/PTPIPSession+Lifecycle.swift` → `Services/PTPIPSession.swift` (单文件) | `lib/protocol/session/ptpip_session.dart`（单类合并三 extension） |
| `Services/PTPIPTCPConnection.swift` | `lib/protocol/transport/ptpip_connection.dart` |
| `DownloadActivityWidget/*` | ❌ 删除 (跨端不实现 Live Activity) |
| `Tests/*.swift` (7 个) | `test/**/*.dart` (重写为 Dart 单测，198 测全绿) |

### 11.1 补充映射 (嵌套类型 + 接口协议) — 2026-07-27 实代码审计校准

iOS 的 Swift 单文件常包含多个类型。**Phase 2/3 落地策略**：抽象边界用 `abstract class` 定义接口（让实现可替），concrete class 走 Riverpod override 注入实现。下方"✅ 已落地 (abstract class)"指实际有 `abstract class` 定义；"❌ 未落地"指没抽象类（concrete class 直用）。

| 原 iOS 内容 | 所在文件 | Flutter 端落点 | 抽象边界 |
|---|---|---|---|
| `PhotoAssetKind` enum (raw/jpeg/png/movie) | `Domain/PhotoAsset.swift` | `lib/domain/photo_asset.dart` 同文件 | — |
| `PhotoAssetThumbnailInfo` struct | `Domain/PhotoAsset.swift` | 同上 | `@freezed class PhotoAssetThumbnailInfo` |
| `PhotoAssetPage` struct (分页返回) | `Domain/PhotoAsset.swift` | 同上 | `@freezed class PhotoAssetPage` |
| `CameraCapability` enum (3 值) | `Domain/CameraSession.swift` | `lib/domain/camera_capability.dart` 独立文件 | — |
| `CameraTransportMode` enum (1 值, 预留 Sony/Canon/Fuji) | `Domain/CameraTransportMode.swift` | `lib/domain/camera_transport_mode.dart` 独立文件 + 4 getter | — |
| `CameraWorkflowState` enum (6 值) | `Domain/CameraWorkflowState.swift` | `lib/domain/camera_workflow_state.dart` 独立文件 + 顶级函数 getter | — |
| `DownloadJobStatus` enum (7 值) | `Domain/DownloadJob.swift` | `lib/domain/download_job.dart` 同文件 + `isTerminal`/`canResume`/`displayTitle` getter | — |
| `DownloadQueueStatus` enum (4 值) | `Domain/DownloadQueueState.swift` | 同文件 + `displayTitle` getter | — |
| `DownloadThroughputTransferMode` / `Scene` / `ChunkSample` / `Report` | `Domain/DownloadThroughputDiagnostics.swift` | `lib/domain/download_throughput_diagnostics.dart` 同文件 | — |
| `DownloadThroughputStats` (派生 getter) | iOS ViewModel 内联 | `lib/domain/download_throughput_stats.dart` **独立文件, 非 freezed**（不需 copyWith） | — |
| `DownloadTransferProgress` (5 字段, `bytesTransferred`/`totalBytes`/`resumedCount`/`currentOffset`/`chunkSize` + `fractionCompleted`) | `Services/CameraTransport.swift` | `lib/protocol/camera_transport.dart:12-28` 同文件 `@freezed class DownloadTransferProgress` | — |
| `DownloadAssetPrioritizer` enum (JPEG 优先排序) | `Features/Downloads/DownloadManagerViewModel.swift` | `lib/services/download_asset_prioritizer.dart` 单独抽出（按 enum 对位） | — |
| `CameraTransportFactory` (工厂类) | `Services/CameraTransportFactoryProtocol.swift` | `lib/protocol/camera_transport_factory.dart` concrete class；签名 `CameraTransport makeTransport()`（**无参数**，按需可改） | ⚠️ **当前不抽象**：仅 concreate class，无 abstract；Phase 5 启动时改 abstract + mode-aware |
| `CameraTransport` (品牌抽象协议) | `Services/CameraTransport.swift` | `lib/protocol/camera_transport.dart` | ✅ 已落地 abstract class（line 30）：`connect`/`fetchAssetsPage`/`downloadAsset`/`downloadThumbnail`/`downloadAssetToTemporaryFile`/`downloadTransferMode`/`consumeDiagnostics`/`disconnect` 8 个方法 |
| `PtpipSocket` (socket 抽象) | `Services/PTPIPTCPConnection.swift` | `lib/protocol/transport/ptpip_socket.dart` | ✅ 已落地 abstract class（line 6）：`connect`/`send`/`receivePacket`/`close`/`isConnected` |
| `AppPreferencesStoring` (接口) | `Services/AppPreferencesStoring.swift` | `lib/services/preferences_store.dart` 直接 `AppPreferencesStore` concrete | ❌ **未抽象**（仅 concrete class）；Phase 5 如需 fake-Preferences 注入可改 abstract |
| `DownloadStoring` (接口) | `Services/DownloadStoring.swift` | `lib/services/download_store.dart:15` `abstract class DownloadStoring` | ✅ **已落地**（line 15-36）：`downloadsDirectoryURL`/`listRecords`/`storeDownloadedFile`/`markExported`/`loadQueueState`/`saveQueueState`/`upsertDownloadJob`/`removeDownloadJobs`/`markInterruptedRunningJobs` 9 个方法 |
| `AssetThumbnailServing` (接口) | `Services/AssetThumbnailServing.swift` | `lib/services/asset_thumbnail_service.dart:12` `abstract class AssetThumbnailServing` | ✅ **已落地**（line 12-21）：`thumbnailData({asset, transport, session})` + `clear()` |
| `WifiWatcher` (接口) | `Services/WifiWatcher.swift` | `lib/services/wifi_watcher.dart:9` `abstract class WifiWatcher` | ✅ **已落地**（line 9-13）：`isCameraWifiConnected` getter + `connectionStream` + `dispose()`；`DefaultWifiWatcher` concrete，BSSID+SSID 双指标匹配 `Nikon` |
| `DownloadNotificationService` (接口) | `Services/DownloadNotificationService.swift` | `lib/services/download_notification_service.dart:3` `abstract class DownloadNotificationService` | ✅ **已落地**（line 3-21）：`show({notificationId, title, body, progress, channelId, categoryId, payload})` + `update({notificationId, title?, body?, progress?})` + `cancel({notificationId})` + `cancelAll()` |
| `BackgroundDownloadRunner` (接口) | `Services/BackgroundDownloadExecutionService.swift` | `lib/services/background_download_runner.dart:12` `abstract class BackgroundDownloadRunner` | ✅ **已落地**（line 12-16）：`begin({name, onExpiration?})` + `end()` + `Future<bool> isActive`；`AndroidBackgroundDownloadRunner` + `IosBackgroundDownloadRunner` 两个 concrete |
| `PhotoLibraryChannel` (接口 + iOS/Android/IO 三实现) | `Services/PhotoLibraryExportService.swift` | `lib/platform/photo_library_channel.dart` 同文件 `abstract class PhotoLibraryChannel` | ✅ **已落地**（line 6-16）：`requestPermission()` + `exportFile({filePath})` + 平台感知 factory + `mapAndroidResult`/`mapIosResult` 两个 static 映射 |
| `PhotoLibraryPermission` enum (granted/limited/denied/neverAskAgain) | iOS PHPhotoLibrary 原生 enum | `lib/platform/photo_library_channel.dart:4` 同文件 | — |
| `DownloadLiveActivityController` | `Services/DownloadLiveActivityController.swift` | ❌ 删除 → `lib/services/download_notification_service.dart`（跨端不实现 Live Activity） | ✅ 已替换 |
| `DownloadActivityAttributes` (特殊 - widget + app 共用结构) | `Domain/DownloadActivityAttributes.swift` | ⚠️ iOS 原文要在 WidgetKit + 主 app 双端共用 Live Activity；Flutter 端 Phase 3 **改为** `DownloadTransferProgress` (`protocol/camera_transport.dart:12-28`)，由 `CameraTransport.downloadAssetToTemporaryFile(onProgress)` 直接传给 `DownloadManagerNotifier._handleProgressUpdate()` 写到 `DownloadNotificationService`。**不单独建 model**（无 widget 后无需独立文件） | ✅ 已替换 |

**校准总结**：9 个 abstract class 全部落地（`CameraTransport` / `PtpipSocket` / `DownloadStoring` / `AssetThumbnailServing` / `WifiWatcher` / `DownloadNotificationService` / `BackgroundDownloadRunner` / `PhotoLibraryChannel` / `LogFileStore`）；3 个直接 concrete（`AppPreferencesStore` / `CameraTransportFactory` / `DownloadAssetPrioritizer` enum）；1 个 iOS 协议被替换（`DownloadLiveActivityController` → `DownloadNotificationService`，跨端不实现 Live Activity）。

---

## 12. 当前进度与下一步（2026-07-27）

### 12.1 已完成路径

详见 §8 表格 + [`Phase4实施计划.md`](Phase4实施计划.md) + [`项目状态.md §5`](项目状态.md)。

### 12.2 阻塞与待决策

| 阻塞 | 解决条件 | 备注 |
|---|---|---|
| iOS 真机构建 | Mac + Xcode 16+ | 当前 Windows 上 `ios/Runner/` 文件已手动创建但未编 |
| iPhone 真机端到端验证 (连接/下载/通知/动效) | iPhone 一台 + 配 Wi-Fi | 当前用 emulator 验证 |
| Phase 5 多品牌扩展 | Mac + 对应品牌相机 + 协议文档 | Sony / Canon / Fujifilm 任选 |
| App Store / Google Play 上架材料 | 上架目标定下来 | 应用描述/截图/隐私声明 |

### 12.3 用户决策项

1. **下一步动作**：第 1 个候选是 Phase 5a 启动 ([`Phase5实施计划.md`](Phase5实施计划.md)) — 拍板 D1~D10 后启动协议调研
2. **i18n 优先级**：当前硬编码中文，仅服务中文用户。如需英文等其他语言要单独做 Phase
3. **iOS Live Activity 回滚**：是否要加回 iOS 锁屏进度条（与 §9 表同行）