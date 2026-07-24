# Viewfinder (取景器)

> 一个 Flutter 跨端相机照片传输 app —— 通过 Wi-Fi 热点连接相机 (首期 Nikon)，浏览照片列表并批量下载到手机。

## 项目说明

- **项目名**：Viewfinder / 取景器
- **目标平台**：iOS 16.0+ / Android API 24+
- **协议**：CIPA PTP/IP (TCP)，默认端点 `192.168.1.1:15740`
- **技术栈**：Dart 3 + Flutter stable + Riverpod 2.x + freezed 2.x + `dart:io` Socket + `google_fonts`
- **状态**：Phase 0 + Phase 1 + Phase 2 + Phase 3 已完成；198 个单测全绿；`dart analyze` 零警告；`flutter build apk --debug` 成功

## 当前能力 (Phase 3)

- **连接**：默认 192.168.1.1:15740；可在设置页编辑 host/port，重启后保留
- **相册**：连接相机后展示真实缩略图（`AssetThumbnailService` 内存 cache + in-flight 去重）；离线态 fallback 图标；支持多选 + 全选 + 清除选择
- **下载**：完整队列管理（enqueue / cancel / retry / pause / resume / clearFinished）；`DownloadManagerNotifier` 13 方法；队列切换 runQueue 循环；`downloadSelected` 批量入队 + JPEG 优先排序；`ActiveDownloadProgress` 实时进度（文件名 / 项号 / bytes / 速率）
- **进度通知**：Android 进度条通知（`DownloadNotificationService.show/update/cancelAll`）；通知栏实时更新
- **后台下载**：Android `flutter_background_service` Foreground Service；iOS `UIBackgroundTask` MethodChannel 占位（需 Mac 验证）
- **相册导出**：Android `MediaStore` API（`PhotoLibraryPlugin.kt`）；iOS `PHPhotoLibrary.addOnly`（`PhotoLibraryPlugin.swift`，需 Mac 验证）；Dart IO stub（测试/桌面用）
- **日志**：1MB rotation + 3 文件备份（`LogFileStore`）；设置页"导出日志"按钮（share_plus 分享面板）
- **Wi-Fi 断线感知**：BSSID + SSID 双指标监听（`WifiWatcher`）；断线自动触发队列暂停
- **设置**：连接配置 + 下载行为（自动入相册 / JPEG 优先）+ 导出日志 + 版本信息
- **主题**：暖阳琥珀 (#F9F9F8 暖白 + #D4A24E 琥珀金)；衬线标题用 Instrument Serif，等宽标签用 DM Mono

## 文档导航

| 文档 | 内容 |
|---|---|
| [`docs/产品需求.md`](./docs/产品需求.md) | 产品需求：痛点 / 用户 / 场景 / 核心功能验收标准 / 非功能需求 |
| [`docs/架构.md`](./docs/架构.md) | 架构：技术栈决策 / 分层 / 数据模型 / 协议设计 / Provider 拓扑 |
| [`docs/项目状态.md`](./docs/项目状态.md) | 项目状态：进度看板 / 下一步 / 决策日志 |
| [`docs/Viewfinder方案.md`](./docs/Viewfinder方案.md) | 实施方案：12 节详细 Phase 拆分 + 源文件映射表 |
| [`docs/Phase2实施计划.md`](./docs/Phase2实施计划.md) | Phase 2 工作说明书（已完成） |

## 进度

| Phase | 内容 | 状态 |
|---|---|---|
| — | 文档宪法 (产品需求 / 架构 / 项目状态) | ✅ 已完成 |
| — | 仓库初始化 (git + GitHub) | ✅ 已完成 |
| — | 环境配置 (Flutter SDK / Android Studio / 国内镜像) | ✅ 已完成 |
| 0 | 工程骨架 (`flutter create` + pubspec + Domain freezed) | ✅ 已完成 |
| 1 | PTP/IP 协议层 + Dart 单测 (47 测试全绿) | ✅ 已完成 |
| 2 | UI 骨架阶段：Riverpod Provider + 4 个 Tab + Shared 包 + 102 测试全绿 | ✅ 已完成 |
| 3 | 下载 + 进度通知 + Android 端到端 + 集成测试 | ✅ 已完成 |
| 4 | UI 抛光 + 触觉 + 动效 | ⏳ 未开始 |
| 5 | 多品牌扩展 (Sony / Canon / Fujifilm) | ⏳ 未开始 (占位) |

## 来源

本项目是对原 iOS Swift 项目 `NikonConnectIOS` 的完全重写。原 Swift 代码不直接复用，但 PTP/IP 协议实现 (`Services/PTPIP*.swift`) 作为协议参考保留阅读价值。

## 本地开发

```bash
# 设置国内镜像（每个新 shell 都要设）
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"

# 静态检查 + 单测
dart analyze                       # 0 issues
flutter test                       # 198/198 全绿
flutter test test/features         # 54 features 测
flutter test test/protocol         # 51 协议测
flutter test test/services         # 52 服务测
flutter test test/domain           # 17 Domain 测

# 调试
flutter run                        # Android 真机需要 USB 调试开启
```

## 测试统计 (2026-07-25 v3)

| 类别 | 测试数 | 覆盖 |
|---|---|---|
| `test/protocol/` | 51 | PTP/IP 编解码 / 传输 / 会话 / Transport 实现 + onProgress 流式 |
| `test/features/` | 54 | 6 个 Notifier + 主题 + formatters + Gallery 真实相机 + 队列持久化 round-trip + v3 connectionProvider 反应式 |
| `test/services/` | 52 | PreferencesStore / DownloadAssetPrioritizer / AssetThumbnailService / WifiWatcher (含 cameraWifiConnectedProvider 反应式) / LogFileStore / NotificationService (含 payload 保留) / BackgroundRunner / DownloadStore (13 测) |
| `test/domain/` | 17 | DownloadQueueState activeJob getter + 派生 getter + status 转换 (含 §17.9 fix 回归测) |
| `test/platform/` | 15 | PhotoLibraryChannel 3 端实现 + mapIosResult/mapAndroidResult 完整覆盖 5 值 |
| `test/widget_test.dart` | 1 | App 启动 smoke |
| `test/smoke_test.dart` | 8 | 4 页面 happy/error widget smoke |
| **总计** | **198** (Phase 2 102 + Phase 3 96) | **全绿** |

### 2026-07-25 v2 修复 (+53 测)

对照 `docs/Phase3实施计划.md` 全审后落地：

- `handleScenePhaseChange` switch 加 3 个 `break` 修 fallback（critical：resumed 后 → 不会重新 arm 后台 runner）
- 新增 `cameraWifiConnectedProvider` (NotifierProvider<bool>) 反应式订阅 `connectionStream`（critical：§9.4 "Wi-Fi 断线 → 队列自动暂停" 现在真工作）
- GalleryContainer 改从 `connectionProvider` 读用户偏好（硬编码失效让设置页 autoExport 永远 false）
- `refreshDownloads` 真实现 `listRecords` 对账
- `appendTransportDiagnostics` 真实现 + `_runQueue` step 9 调用
- `NotificationService.update()` 加 `_payloads` Map 保留首次 payload（deepLink 路由不丢）
- `LogFileStore.exportFile()` 改 timestamp 命名（多次导出不覆盖）

### 2026-07-25 v3 修复 (+1 测)

v2 让 GalleryContainer 读 `connectionProvider`, 但 v1/v2 的 `connectionProvider` 自己不反应式跟 `preferencesProvider`, Settings 改 toggle 后仍要走旧值 → **v2 修复没有真正让设置 toggle 生效**。

- **`ConnectionNotifier.build()` 改 `ref.watch(preferencesProvider)` (NotifierProvider 而非 stable `preferencesStoreProvider`)** → `connectionProvider` 现在真正跟用户偏好同步, Settings 改 toggle 后 Gallery 下载参数立即更新
- 加 1 个回归测锁住此行为 (`v3 fix: connectionProvider 反应式跟随 preferencesProvider`)