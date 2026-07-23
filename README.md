# Viewfinder (取景器)

> 一个 Flutter 跨端相机照片传输 app —— 通过 Wi-Fi 热点连接相机 (首期 Nikon)，浏览照片列表并批量下载到手机。

## 项目说明

- **项目名**：Viewfinder / 取景器
- **目标平台**：iOS 16.0+ / Android API 24+
- **协议**：CIPA PTP/IP (TCP)，默认端点 `192.168.1.1:15740`
- **技术栈**：Dart 3 + Flutter stable + Riverpod 2.x + freezed 2.x + `dart:io` Socket + `google_fonts`
- **状态**：Phase 0 + Phase 1 + Phase 2 已完成；102 个单测全绿；`dart analyze` 零警告

## 当前能力 (Phase 2)

- **连接**：默认 192.168.1.1:15740；可在设置页编辑 host/port，重启后保留
- **相册**：mock 12 张照片缩略图（缩略图/网格/选择/3 段式状态）
- **下载**：占位 5 section（概览 / 队列 / 当前下载 / 传输速率 / 已下载记录）
- **设置**：连接配置 + 下载行为 + 版本信息
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
| 3 | 下载 + 进度通知 + 真机端到端验证 | ⏳ 下一步 |
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
flutter test                       # 102/102 全绿
flutter test test/features         # 37 features 测
flutter test test/protocol         # 47 协议测

# 调试
flutter run                        # Android 真机需要 USB 调试开启
```

## 测试统计 (2026-07-23)

| 类别 | 测试数 | 覆盖 |
|---|---|---|
| `test/protocol/` | 47 | PTP/IP 编解码 / 传输 / 会话 / Transport 实现 |
| `test/features/` | 37 | 5 个 Notifier + 主题 + formatters + widget smoke |
| `test/services/` | 10 | AppPreferencesStore (5) + DownloadAssetPrioritizer (5) |
| `test/widget_test.dart` | 1 | App 启动 smoke |
| `test/smoke_test.dart` | 8 | 4 页面 happy/error widget smoke |
| **总计** | **102** | **全绿** |