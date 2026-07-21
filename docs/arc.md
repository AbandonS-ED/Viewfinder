# arc.md — 架构文档

> Viewfinder (取景器) 的架构层信息。**做什么 / 验收标准**见 [`prd.md`](prd.md)；**实施细节 / Phase 拆分 / 源文件映射**见 [`Viewfinder方案.md`](Viewfinder方案.md)。

---

## 1. 技术栈决策

完整对比与理由见 `Viewfinder方案.md` §2。此处只锁死结论：

| 层 | 选型 | 备注 |
|---|---|---|
| 语言 | Dart 3.x | Flutter 默认 |
| Framework | Flutter stable | 用户选 Flutter (vs KMP) |
| 状态管理 | **Riverpod 2.x** (`flutter_riverpod`) | 编译期安全、对 async 友好 |
| 数据类 | **freezed + json_serializable** | 替代手写样板 |
| 网络 | **`dart:io` Socket** (裸 TCP) | PTP/IP 是二进制协议，无 HTTP |
| 本地 KV | `shared_preferences` | 替代 iOS `UserDefaults` |
| 相册 | `gal` 包 + 自写 platform channel | Android 13+ scoped storage 必须处理 |
| 通知 | `flutter_local_notifications` + `flutter_background_service` | 跨端进度提示 |
| Wi-Fi 监听 | `connectivity_plus` + `network_info_plus` | 断线检测 |
| Lint | `flutter_lints` (官方) | 强制 |

### 1.1 选 Flutter 而非 KMP 的决策依据

| 维度 | Flutter | KMP |
|---|---|---|
| 双端 UI 一份代码 | ✅ | ❌ |
| 上手 / 工具链 | ✅ | ❌ (Gradle + Xcode 桥接坑多) |
| iOS Live Activity 体验 | ⚠️ 降级 | ✅ 保留原生 |
| 后台下载稳健性 | ⚠️ 包封装 | ✅ 原生 API |
| 包大小 | ⚠️ +5-10MB | ✅ +2MB |

**结论**：用户希望"双端同步出包"权重高 + **iOS 体验可降级**（已有原 iOS 项目作为参考），选 Flutter。

---

## 2. 分层架构

```
┌─────────────────────────────────────────┐
│  UI 层 (Features + App)                  │  ← Flutter Widgets + Riverpod
├─────────────────────────────────────────┤
│  服务层 (Services)                       │  ← 偏好 / 持久化 / 通知 / 后台 / Wi-Fi
├─────────────────────────────────────────┤
│  平台桥接层 (Platform Channels)           │  ← 相册 / 前台服务 / 原生方法
├─────────────────────────────────────────┤
│  协议层 (Protocol)                       │  ← PTP/IP 编解码 + 会话
├─────────────────────────────────────────┤
│  Domain 层 (Domain)                      │  ← freezed data classes, 无 IO
└─────────────────────────────────────────┘
```

**依赖方向**：上层可依赖下层，**下层绝不依赖上层**。Domain 层无任何外部依赖 (除 `dart:core` + `freezed_annotation`)。

**`platform/` 与 `services/` 边界**：`platform/` 只放 MethodChannel 接口定义 + 各端实现（薄壳，原生胶水层）；`services/` 调用 `platform/` 处理业务逻辑（厚壳，业务规则）。两者是**调用关系**，不是平级关系。例：`services/photo_library_export_service.dart` 调用 `platform/photo_library_channel_android.dart` 实现相册写入。

---

## 3. 目录结构

完整树见 `Viewfinder方案.md` §4。要点：

```
lib/
├── main.dart, app.dart
├── domain/         ← 14 个 freezed model + 1 个特殊 (DownloadActivityAttributes)
├── protocol/       ← PTP/IP 实现
│   ├── primitives/      ← 命令/响应编解码
│   ├── transport/       ← socket 长连接
│   ├── session/         ← 会话 (lifecycle / traversal / transfers)
│   └── camera_transport.dart  ← 品牌抽象
│   └── experimental_nikon_transport.dart  ← Nikon 实现
├── services/       ← 应用级服务
├── features/       ← UI 业务模块 (connection / browser / downloads / settings / shared)
└── platform/       ← MethodChannel 接口与各端实现
```

---

## 4. 数据模型 (Domain 层)

14 个 freezed model，对应原 iOS `Domain/` 目录下 14 个普通 `.swift` 文件。`DownloadActivityAttributes`（原 iOS widget + app 共用）在本项目中**折叠到 `services/download_progress_notifier.dart` 内部，作为私有 state class**，不再独立成 model。

| Class | 角色 | 关键字段 |
|---|---|---|
| `CameraConnectionConfig` | 连接配置 | host, port, transportMode, autoExportToPhotoLibrary, prioritizeJPEGDownloads |
| `CameraTransportMode` | 传输模式枚举 | (目前仅 `experimentalNikon`) |
| `CameraSession` | 相机会话状态 | host, port, isOpen, deviceInfo |
| `CameraWorkflowState` | UI 工作流状态 | (idle / connecting / browsing / downloading / error) |
| `PhotoAsset` | 照片资产 | remoteIdentifier, fileName, kind (raw/jpeg/movie), byteSize, captureDate, thumbnail |
| `PhotoAssetMerge` | RAW+JPEG 配对 | primary, paired |
| `DownloadJob` | 下载任务 | id, assets, status, progressBytes |
| `DownloadQueueState` | 队列状态 | pending, inProgress, completed, failed |
| `DownloadRecord` | 已下载记录 | id, asset, completedAt, localPath |
| `ActiveDownloadProgress` | 实时进度 | current, total, bytesPerSecond |
| `DownloadThroughputDiagnostics` | 吞吐诊断 | samples, averageBps, peakBps |
| `LogEntry` | 日志条目 | timestamp, level, message |
| `AlertContext` | 错误提示上下文 | title, message, severity |
| `CameraAppError` | 错误枚举 | (networkFailure / protocolError / storageFull / 等) |


**原则**：
- 所有 class `final` + immutable (`@immutable` 来自 freezed)
- 所有字段用 `decodeIfPresent` 做 schema 向后兼容 (新增字段必须有默认值)
- Domain 层不导入 Flutter / `dart:io`

---

## 5. 协议层设计要点

### 5.1 PTP/IP 概述

- **CIPA PTP/IP** 标准协议，TCP 端口 **15740**
- 命令 / 响应 / 数据流三种 packet
- 命令 packet：12 字节 header (length + type + code + transactionId + params)
- 数据流：`GetObject` 返回大数据块 (单张照片 10-50 MB)

### 5.2 模块边界

| 模块 | 职责 | 不做 |
|---|---|---|
| `primitives/` | 单 packet 编解码 | socket IO |
| `transport/` | 长连接 + 心跳 + 重连 | 业务逻辑 |
| `session/lifecycle` | OpenSession / CloseSession | 数据传输 |
| `session/asset_traversal` | GetObjectHandles / GetObjectInfo | 下载 |
| `session/transfers` | GetObject (单张大文件传输) | 列表浏览 |
| `camera_transport.dart` | 品牌抽象接口 | 具体实现 |
| `experimental_nikon_transport.dart` | Nikon opcode 包装 | 通用 PTP/IP |

### 5.3 异步模型

- `PtpipSocket` 是 abstract class，定义接口；IoPtpipSocket / FakePtpipSocket 是两种实现
  - **iOS**：`dart:io.Socket` 直接 BSD socket
  - **Android**：`dart:io.Socket` (同)
  - **测试**：fake 实现 (内存 buffer / loopback)
- `PtpipConnection` 持有 socket，处理异步收发 (Stream + Completer)
- `PtpipSession` 提供 `Future<List<PhotoAsset>> listAssets()` 等**协程风格 API**

**线程模型**：所有 PTP/IP 操作运行在 Dart isolate 的 main event loop；socket IO 用异步 listener，**不阻塞 UI**。

---

## 6. 状态管理 (Riverpod) 设计

### 6.1 Notifier 划分

| Notifier | 类型 | 来源 |
|---|---|---|
| `ConnectionNotifier` | `Notifier<ConnectionState>` | 原 `ConnectionViewModel` |
| `GalleryNotifier` | `AsyncNotifier<List<PhotoAsset>>` | 原 `GalleryViewModel` |
| `DownloadManagerNotifier` | `Notifier<DownloadQueueState>` | 原 `DownloadManagerViewModel` |
| App-level Providers | 多个独立 `Provider` | 原 `AppShellViewModel` 拆开 |

### 6.2 关键设计原则

- **协议层不持有 Riverpod**：`PtpipSession` 是 plain Dart 类；Notifier 注入并订阅
- **`StreamProvider`** 包装 socket 数据事件，UI 用 `ref.watch` 自动 rebuild
- **`family` modifier** 处理多任务下载队列 (按 `downloadId` 区分)
- **测试用 `ProviderContainer`** 注入 fake，不依赖 widget 测试

---

## 7. 与原 iOS 项目的映射表

完整映射见 `Viewfinder方案.md` §11。要点：

| 原 iOS 文件 | Flutter 落点 |
|---|---|
| `App/NikonConnectApp.swift` | `lib/main.dart` + `lib/app.dart` |
| `Domain/*.swift` (15 个 = 14 普通 + 1 特殊) | `lib/domain/*.dart` (freezed) |
| `Services/PTPIP*.swift` | `lib/protocol/**/*.dart` |
| `Services/ExperimentalNikonTransport.swift` | `lib/protocol/experimental_nikon_transport.dart` |
| `Services/CameraTransport*.swift` | `lib/protocol/camera_transport.dart` |
| `Services/AppPreferencesStore.swift` | `lib/services/preferences_store.dart` |
| `Services/DownloadStore.swift` | `lib/services/download_store.dart` |
| `Services/DownloadLiveActivityController.swift` | ❌ 删除 → `lib/services/download_progress_notifier.dart` |
| `Services/PhotoLibraryExportService.swift` | `lib/platform/photo_library_channel_*.dart` |
| `Features/**` | `lib/features/**` |
| `DownloadActivityWidget/*` | ❌ 删除 (跨端不实现) |
| `Tests/*.swift` (7 个) | `test/**/*.dart` (重写为 Dart 单测) |

---

## 8. 演进方向

| 阶段 | 架构变化 |
|---|---|
| Phase 0 | 落地目录 + freezed Domain |
| Phase 1 | 实现协议层 + Dart 单测 (架构核心不动) |
| Phase 2 | 真机端到端验证 (架构不增项) |
| Phase 3 | 加 DownloadManagerNotifier + 后台下载服务 |
| Phase 4 | UI 抛光 + 触觉 |
| Phase 5 | **多品牌扩展点**：新增 `SonyTransport` / `CanonTransport` / `FujifilmTransport`，UI 与协议层无需改动 (这是抽象的回报) |

---

## 9. 关联文档

- **做什么 / 验收标准** → [`prd.md`](prd.md)
- **当前进度 / 状态** → [`project.md`](project.md)
- **实施细节 / Phase 拆分** → [`Viewfinder方案.md`](Viewfinder方案.md)

---

## 10. 变更记录

| 日期 | 变更 | 原因 |
|---|---|---|
| 2026-07-21 | 初版 | 与 prd.md / project.md 同步立宪法 |
