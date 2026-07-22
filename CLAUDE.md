# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目与工作区

- 这是一个 Flutter 跨端 app **Viewfinder (取景器)**，通过相机自带 Wi-Fi 热点和 CIPA PTP/IP 协议浏览、下载尼康相机中的照片。首版只实现 Nikon；Sony/Canon/Fujifilm 留作 Phase 5 占位。
- 配套参考资料：源 iOS Swift 项目 `D:\桌面\Nikon_connect\` (上级目录)，只作协议参考，不复用代码。
- 仓库路径含中文（`D:\桌面\Nikon_connect\Viewfinder`），Shell 命令必须加引号。
- 文档宪法：`README.md`（导航）+ `AGENTS.md`（AI 工作守则）+ `docs/产品需求.md` + `docs/架构.md` + `docs/项目状态.md` + `docs/Viewfinder方案.md` + `docs/Phase1实施计划.md`。进入任何 Phase 前先把对应文档读一遍。
- 项目成员：GitHub `AbandonS-ED/Viewfinder`，main 分支，远程 `https://github.com/AbandonS-ED/Viewfinder.git`。所有 commit 推到这；**commit / push 由人决定，AI 不要自动化**。
- `.gitignore` 是 Flutter 标准模板。`.dart_tool/`、`build/`、`.idea/`、`viewfinder.iml` 都在忽略列表内。

## 常用命令

工作目录：`D:\桌面\Nikon_connect\Viewfinder`，依赖国内镜像。每次新开 PowerShell 先 set 镜像（已 `setx` 持久化，但新会话仍要临时 `set` 一次）：

```powershell
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
```

```bash
# 健康检查（Windows 上 Xcode/iOS 工具链缺是正常的）
flutter doctor -v

# 静态分析（项目约定用 dart analyze，不用 flutter analyze，因为后者在中文路径下有 LSP bug）
dart analyze

# 跑全部测试
flutter test

# 跑单个文件
flutter test test/protocol/session_test.dart

# 跑单个测试用例（按 group/test 描述过滤）
flutter test test/protocol/session_test.dart --plain-name "openSession returns device info"

# 重新生成 freezed 代码（修改 @freezed 类后必须跑）
dart run build_runner build --delete-conflicting-outputs

# Android 真机构建（当前只配了 Android，iOS 在 macOS 上另开）
flutter build apk --debug
```

**iOS 限制**：当前仓库是 `flutter create --platforms=android`，没有 `ios/`。iOS 构建必须在 macOS + Xcode 16+ 重新 `flutter create . --platforms=ios` 后再做（Phase 2 真机验证才需要）。现在不要跑 `flutter build ios`。

**不要用** `flutter analyze` —— `项目状态.md` §5.1 已记录它在中文路径下有 LSP 通信 bug，统一用 `dart analyze`。

## 当前阶段与下一步

| Phase | 内容 | 状态 |
|---|---|---|
| 0 | 工程骨架 + 14 个 Domain freezed model | ✅ 已完成 |
| 1 | PTP/IP 协议层 + Dart 单测 | 🚧 进行中（primitives/socket/connection/session/Nikon transport 已落地，单测覆盖率仍不足） |
| 2 | 真机连 Nikon 端到端验证 | ⏳ 未开始 |
| 3 | 下载 + 进度通知 | ⏳ 未开始 |
| 4 | UI 抛光 + 触觉 + 动效 | ⏳ 未开始 |
| 5 | 多品牌扩展（占位） | ⏳ 未开始 |

Phase 1 详细切片见 `docs/Phase1实施计划.md` §3（8 个原子任务，按 3.0→3.8 顺序执行）。

## 整体架构

5 层从上到下，**严格单向依赖**（下层不依赖上层）：

```
UI (Features + App)              ← Riverpod Notifier + Flutter Widgets
↓
Services                         ← 偏好 / 持久化 / 通知 / 后台 / Wi-Fi
↓
Platform Channels (platform/)    ← MethodChannel 接口 + 各端实现
↓
Protocol                         ← PTP/IP 编解码 + 会话
↓
Domain                           ← freezed data class，无 IO / 无 Flutter
```

### Domain 层

- `lib/domain/` 下 15 个文件，10 个 `@freezed` data class + 5 个独立 enum / 工具类 + 1 个 `sealed class CameraAppError`（8 个 case）。详细字段表见 `docs/架构.md` §4。
- 关键不变量：
  - 所有 class `final` + immutable；JSON 反序列化用 `decodeIfPresent`，**新增字段必须有默认值**（schema 向后兼容）。
  - 不导入 Flutter / `dart:io`，仅依赖 `dart:core` + `freezed_annotation`。
  - `CameraAppError` 是 sealed class，调用方用 `switch` 模式匹配做穷举处理。
  - `PhotoAssetMerge.preservingCameraOrder(...)` 是**静态工具方法**（不是 data class），签名见 `lib/domain/photo_asset_merge.dart`。
- `DownloadActivityAttributes` 在 iOS 是 widget + app 共用结构，本项目**折叠到 `services/download_progress_notifier.dart`** 作为私有 state class，不单独建 model。

### Protocol 层（已落地，可读）

- `lib/protocol/primitives/`
  - `ptpip_data_types.dart`：`PTPIPPacketType` (15 值) / `PTPOperationCode` (12 值) / `PTPResponseCode` (35 值，一个不能少) / `PTPIPDataPhaseInfo` (3 值) / `PTPIPBinary` 常量类。
  - `ptpip_data_structures.dart`：4 个 freezed data class (`PTPIPRawPacket` / `PTPIPDeviceInfo` / `PTPIPObjectInfo` / `PTPIPDataPayloadInfo`)。
  - `ptpip_error.dart`：`sealed class PTPIPError` —— `unexpectedPacket` / `unexpectedResponse` / `invalidTransaction` / `timeout` / `socketClosed`。
  - `ptpip_packet_codec.dart`：所有 `PTPIPCodec.encode*` / `parse*` 函数，小端序，跟 iOS `PTPIPPrimitives.swift` 1:1 对位。`protocolVersion = 0x0001_0000`，`defaultFriendlyName = "NikonConnectIOS"`（保留原字符串，不要改）。
- `lib/protocol/transport/`
  - `ptpip_socket.dart`：**abstract class** `PtpipSocket`（接口边界，所有 socket 实现都走这里）。
  - `ptpip_socket_io.dart`：`IoPtpipSocket`，基于 `dart:io.Socket`，双端共用。
  - `ptpip_connection.dart`：`PtpipConnection` 持有 socket，提供 `open / send / receivePacket / close`。
- `lib/protocol/session/ptpip_session.dart`：**单类**包含 lifecycle / traversal / transfers 三段（不是 iOS 那种 extension 拆文件）。公开 API：
  - `Future<PTPIPDeviceInfo> openSession()` —— Init Command Request → Init Event Request → GetDeviceInfo → OpenSession。
  - `Future<void> closeSession()` —— CloseSession + 关两条 TCP。
  - `Future<List<int>> getObjectHandles({int storageID = 0xFFFFFFFF})`
  - `Future<PTPIPObjectInfo> getObjectInfo(int handle)`
  - `Future<Uint8List> getObject(int handle)` / `Future<Uint8List?> getThumbnail(int handle)`（无缩略图返回 null，不抛）。
  - 内部 `_collectDataStream` 处理 `startData → data* → endData → operationResponse` 的拼包与最终响应码校验。
- `lib/protocol/camera_transport.dart`：**abstract class** `CameraTransport`，是品牌抽象边界（iOS `CameraTransport` 协议的对位）。具体实现类：
  - `Future<CameraSession> connect({required CameraConnectionConfig config})`
  - `Future<PhotoAssetPage> fetchAssetsPage({required CameraSession session, required bool resetTraversal, required int limit})`
  - `Future<Uint8List> downloadAsset(...)` / `Future<Uint8List?> downloadThumbnail(...)`
  - `Future<String> downloadAssetToTemporaryFile(...)`（带 `DownloadTransferProgress` 进度回调）
  - `Future<DownloadThroughputTransferMode> downloadTransferMode(...)`
  - `Future<List<String>> consumeDiagnostics(...)`
  - `Future<void> disconnect(...)`
- `lib/protocol/experimental_nikon_transport.dart`：**唯一实现**，持有 `PtpipSession`。`_classifyObjectFormat(int)` 把 PTP 格式码（`0x3000` RAW / `0x3001` MOV / `0x3801`/`0x3808` JPEG / `0x380B` PNG 等）翻译成 `PhotoAssetKind`。异常一律用 `CameraAppError` sealed class 抛出。
- `lib/protocol/camera_transport_factory.dart`：`CameraTransportFactory.makeTransport()` 当前**硬编码**返回 `ExperimentalNikonTransport()`。
- **测试 fake**：`test/helpers/fake_ptpip_socket.dart` 实现 `PtpipSocket` 用于协议单测（替代 iOS 的 `127.0.0.1` fake server）。

### Protocol 层不变量（必须保留）

1. **命令通道与事件通道** 双 TCP，命令 / 事件互不干扰。事件循环用 `Future.doWhile` + `probeRequest → probeResponse` 保活，30s 超时。
2. **事务 ID 单调递增**，`openSession()` 后强制 `_nextTransactionID = 1`；`_requestResponseOnly` 校验响应事务 ID 与请求一致。
3. **响应码校验**：每个 `_request*` 内部都检查 `code == PTPResponseCode.ok`，非 OK 直接抛 `PTPIPError.unexpectedResponse(code)`。
4. **缩略图缺图不抛**：`getThumbnail` 捕 `noThumbnailPresent` / `operationNotSupported` 返回 `null`。
5. **错误不向上混**：`ExperimentalNikonTransport._mapError` 把 `PTPIPError` 与未知异常统一翻成 `CameraAppError`，业务层只看到 sealed `CameraAppError`。
6. **fake socket 必须实现 `PtpipSocket` 完整接口**（`connect / send / receivePacket / close / isConnected`），协议单测才能不依赖真机。

### UI / Services / Platform（Phase 1 之后才建）

- 当前 `lib/features/`、`lib/services/`、`lib/platform/` 三个目录**还没有内容**。`lib/main.dart` 是 Phase 0 占位 `ViewfinderApp`，Phase 4 才换成正式 UI。
- 计划：
  - `lib/services/`：`preferences_store.dart` (shared_preferences) / `download_store.dart` / `asset_thumbnail_service.dart` / `photo_library_export_service.dart` / `download_progress_notifier.dart` (替代 Live Activity) / `background_download_runner.dart` / `wifi_watcher.dart`。
  - `lib/platform/`：`photo_library_channel*.dart` (interface + Android + iOS + IO stub)。
  - `lib/features/`：`connection_setup/` / `photo_browser/` / `downloads/` / `settings/` / `shared/`。

## Riverpod 状态管理

- 原 iOS ViewModel → Flutter Notifier：`ConnectionNotifier extends Notifier<ConnectionState>` / `GalleryNotifier extends AsyncNotifier<List<PhotoAsset>>` / `DownloadManagerNotifier extends Notifier<DownloadQueueState>` / AppShell 拆成多个 `Provider`。
- **协议层不持有 Riverpod**：`PtpipSession` 是 plain Dart 类，Notifier 注入并订阅。`PtpipSocket` 接口允许单测里注入 fake。
- `StreamProvider` 包 socket 数据事件，`family` modifier 处理多任务下载（按 downloadId 区分）。
- 详细见 `docs/架构.md` §6。

## 平台能力与权限矩阵

| 能力 | iOS | Android |
|---|---|---|
| 默认最低版本 | 16.0 | API 24 (Android 7.0) |
| 局域网 | `NSLocalNetworkUsageDescription` | `ACCESS_WIFI_STATE` + `ACCESS_NETWORK_STATE` |
| 相册写入 | `NSPhotoLibraryAddUsageDescription` | MediaStore (targetSdk 30+) |
| 后台下载 | Phase 3 待评估（裸 TCP 不支持 background session） | Foreground Service `dataSync` type + `flutter_background_service` |
| 通知 | `UNUserNotificationCenter`（静态文字，**不支持进度条**） | `flutter_local_notifications` 进度条 |
| Bonjour | 直连 IP 暂不需要 | `CHANGE_WIFI_MULTICAST_STATE` 同上 |

iOS Live Activity **不做**（Android 无对应，跨端统一降级）。原 iOS 锁屏进度条的用户体验在 iOS 端退化为打开 app 才能看到进度。

## 代码约束（必须遵守）

- **命名**：Dart 强制 `snake_case` 文件名；类 `PascalCase`，**无 `I` 前缀**（`CameraTransport` 不是 `ICameraTransport`）；常量 `lowerCamelCase`；enum 值 `lowerCamelCase`（`experimentalNikon`）。
- **注释中文**（用户看不懂英文）；标识符英文；commit message 中文；用户面字符串中文。
- **禁止顺手重构**：用户没让改的文件一个字不动；改 UI 风格要先问；改 pubspec 依赖要先说替代方案。
- **禁止编造 API**：不熟悉的 PTP/IP opcode / Flutter API 必须查文档，不能脑补。
- **commit 时机**：一个 Phase 通过验收 / 一个 bug 修完带回归测试 / 一个模块落地，**不要顺手 commit 一堆**。commit message 中文，动词在前（实现 / 修复 / 重构 / 添加 / 删除 / 更新），≤ 50 字。
- **`.gitignore` 不要改**：Flutter 标准模板已覆盖 `build/`、`.dart_tool/`、`.idea/`、IDE 文件等。
- `download_*` 相关诊断字段命名严格对齐 iOS；新增字段必须有 `decodeIfPresent` 默认值。
- `lib/protocol/primitives/ptpip_data_types.dart` 的 35 个 `PTPResponseCode` **一个不能少**，即使"看着用不上"也保留。

## 测试规则

- 测试目录 `test/` 镜像 `lib/`。协议层 `test/protocol/`，helpers `test/helpers/`。
- 协议层单测覆盖率目标 ≥ 80%。当前已有 `test/protocol/primitives_test.dart` 和 `test/protocol/session_test.dart` 两个文件，相对于 4 个 primitives + session + transport/socket + Nikon transport 的覆盖面还很薄，**Phase 1 后续要补**：
  - `transport/ptpip_socket_io_test.dart` —— 真实 localhost loopback
  - `experimental_nikon_transport_test.dart` —— 用 fake socket 跑完整 connect → listAssets → getThumbnail → getObject 路径
  - 异常场景：网络超时 / 部分数据包到达 / 大文件中断恢复（`GetPartialObject` 重试路径）/ Nikon 不同机身 opcode 差异
- 不要 mock 整个相机（用 fake socket server）；不要测私有方法（通过公开 API 测）；不要写脆弱的 snapshot test。
- `dart analyze` 干净 + `flutter test` 全绿，是 commit 前的最低门槛。

## 文档同步规则

改动时同步更新（**先读相关文档当前内容，避免覆盖他人改动**）：

| 改动 | 更新 |
|---|---|
| 加 / 砍 / 改功能 | `docs/产品需求.md` §3 + §6 |
| 改技术栈 / 依赖 / 模块边界 | `docs/架构.md` §1 / §3 / §5 |
| Phase 完成 / 新阻塞 / 关键决策 | `docs/项目状态.md` §2 / §4 / §8 |
| 计划微调 | `docs/Viewfinder方案.md` 对应节 |
| Phase 1 切片级进度 | `docs/Phase1实施计划.md` §3 |