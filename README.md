# Viewfinder (取景器)

> 一个 Flutter 跨端相机照片传输 app —— 通过 Wi-Fi 热点连接相机 (首期 Nikon)，浏览照片列表并批量下载到手机。

## 项目说明

- **项目名**：Viewfinder / 取景器
- **目标平台**：iOS 16.0+ / Android API 24+
- **协议**：CIPA PTP/IP (TCP)，默认端点 `192.168.1.1:15740`
- **技术栈**：Dart 3 + Flutter stable + Riverpod 2.x + freezed 2.x + `dart:io` Socket + `google_fonts`
- **状态**：Phase 0-4 全部完成；385 个单测全绿；`dart analyze` 0 warnings（剩 12 个 info 提示：8 个 integration test 文件命名 + 4 个 const 构造提示，非阻塞）

## 当前能力 (Phase 4 完成)

- **连接**：默认 192.168.1.1:15740；可在设置页编辑 host/port，重启后保留
- **相册**：连接相机后展示真实缩略图（`AssetThumbnailService` 内存 cache + in-flight 去重）；离线态显示"暂无照片"空 state；支持多选 + 全选 + 清除选择；标准/紧凑网格切换（3↔5 列）；长按全屏预览（双击缩放 + 拖动平移）
- **下载**：完整队列管理（enqueue / cancel / retry / pause / resume / clearFinished）；`DownloadManagerNotifier` 13 方法；队列切换 runQueue 循环；`downloadSelected` 批量入队 + JPEG 优先排序；`ActiveDownloadProgress` 实时进度（文件名 / 项号 / bytes / 速率）；吞吐诊断 section
- **进度通知**：Android 进度条通知（`DownloadNotificationService.show/update/cancelAll`）；通知栏实时更新
- **后台下载**：Android `flutter_background_service` Foreground Service；iOS `UIBackgroundTask` MethodChannel 占位（需 Mac 验证）
- **相册导出**：Android `MediaStore` API（`PhotoLibraryPlugin.kt`）；iOS `PHPhotoLibrary.addOnly`（`PhotoLibraryPlugin.swift`，需 Mac 验证）；Dart IO stub（测试/桌面用）
- **日志**：1MB rotation + 3 文件备份（`LogFileStore`）；设置页"导出日志"按钮（share_plus 分享面板）
- **Wi-Fi 断线感知**：BSSID + SSID 双指标监听（`WifiWatcher`）；断线自动触发队列暂停
- **设置**：连接配置 + 下载行为（自动入相册 / JPEG 优先）+ 导出日志 + 版本信息
- **主题**：5 套主题切换（amber/forest/slate/terr/onyx），B10 视觉对齐 muban.html（27 处色值修正 + Noto Sans SC 中文正文 + Instrument Serif 衬线标题）
- **动效**：Haptics 触觉反馈 + LensGlow 脉冲 + Shimmer 闪烁 + PageView 280ms 滑动切换 + HeroTitle 品牌轮播（waitingForWifi 3s 切换）+ GlobalActivityCapsule 顶部进度胶囊 + ZoomablePhotoPreview 双击缩放

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
| 4 | UI 抛光 + 触觉 + 动效 + 5 主题 + B10 视觉对齐 | ✅ 已完成 (13/13) |
| 5 | 多品牌扩展 (Sony / Canon / Fujifilm) | ⏳ 未开始 (占位) |

## 来源

本项目是对原 iOS Swift 项目 `NikonConnectIOS` 的完全重写。原 Swift 代码不直接复用，但 PTP/IP 协议实现 (`Services/PTPIP*.swift`) 作为协议参考保留阅读价值。

## 本地开发

```powershell
# 设置国内镜像（每个新 PowerShell session 都要设）
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"

# 安装依赖
flutter pub get

# 静态检查 + 单测
dart analyze                       # 0 warnings (剩 12 info：集成测试命名 + const 提示)
flutter test                       # 385/385 全绿
flutter test test/protocol         # 协议层
flutter test test/features         # UI + Notifier + 主题
flutter test test/services         # 服务层
flutter test test/domain           # Domain 层

# 调试
flutter run -d emulator-5554       # Android 模拟器
flutter run                        # Android 真机需要 USB 调试开启
```

## 测试统计 (2026-07-27 Phase 4 完成)

| 类别 | 测试数 | 覆盖 |
|---|---|---|
| `test/protocol/` | 51 | PTP/IP 编解码 / 传输 / 会话 / Transport 实现 + onProgress 流式 |
| `test/features/` | 111 | 6 个 Notifier + 5 主题 palette (115) + viewfinder_theme (5) + formatters + Gallery + 队列持久化 + HeroTitle 轮播 + ZoomablePhotoPreview + GlobalActivityCapsule + StatusBarWidget + widgets (13) |
| `test/services/` | 53 | PreferencesStore / DownloadAssetPrioritizer / AssetThumbnailService / WifiWatcher / LogFileStore / NotificationService / BackgroundRunner / DownloadStore |
| `test/domain/` | 26 | DownloadQueueState + DownloadThroughputStats + 派生 getter + status 转换 |
| `test/platform/` | 15 | PhotoLibraryChannel 3 端实现 + mapIosResult/mapAndroidResult |
| `test/integration/` | 8 | Phase 4c 端到端 widget test 骨架 |
| `test/widget_test.dart` | 1 | App 启动 smoke |
| `test/smoke_test.dart` | 8 | 4 页面 happy/error widget smoke |
| **总计** | **385** | **全绿** |

### Phase 4 增量 (385 - 198 = +187)

- Phase 4a: +139 (129 palette + 5 viewfinder_theme + 4 themeNotifier + 1 prefs)
- Phase 4b: +31 (13 widgets + 9 throughput/gridDensity + 8 integration + 1 gridDensity)
- Phase 4b B2: +5 (ZoomablePhotoPreview 手势/缩放)
- Phase 4b B4: +6 (HeroTitle 轮播)
- Phase 4b Gallery: +1 (onSessionChanged regression)
- Phase 4b B10: -14 (palette 重写减少硬编码断言) +1 (textTheme 字体断言)