# Viewfinder (取景器)

> 一个 Flutter 跨端相机照片传输 app —— 通过 Wi-Fi 热点连接相机 (首期 Nikon)，浏览照片列表并批量下载到手机。

## 项目说明

- **项目名**：Viewfinder / 取景器
- **目标平台**：iOS 16.0+ / Android API 24+
- **协议**：CIPA PTP/IP (TCP)，默认端点 `192.168.1.1:15740`
- **技术栈**：Dart 3 + Flutter stable + Riverpod + freezed + `dart:io` Socket

## 文档导航

| 文档 | 内容 |
|---|---|
| [`docs/产品需求.md`](./docs/产品需求.md) | 产品需求：痛点 / 用户 / 场景 / 核心功能验收标准 / 非功能需求 |
| [`docs/架构.md`](./docs/架构.md) | 架构：技术栈决策 / 分层 / 数据模型 / 协议设计 |
| [`docs/项目状态.md`](./docs/项目状态.md) | 项目状态：进度看板 / 下一步 / 决策日志 |
| [`docs/Viewfinder方案.md`](./docs/Viewfinder方案.md) | 实施方案：12 节详细 Phase 拆分 + 源文件映射表 |

## 进度

| Phase | 内容 | 状态 |
|---|---|---|---|
| — | 文档宪法 (产品需求 / 架构 / 项目状态) | ✅ 已完成 |
| — | 仓库初始化 (git + GitHub) | ✅ 已完成 |
| — | 环境配置 (Flutter SDK / Android Studio / 国内镜像) | ✅ 已完成 |
| 0 | 工程骨架 (`flutter create` + pubspec + Domain freezed) | ✅ 已完成 |
| 1 | PTP/IP 协议层 + Dart 单测 (47 测试全绿) | ✅ 已完成 |
| 2 | 端到端真机连 Nikon (浏览) | ⏳ 未开始 |
| 3 | 下载 + 进度通知 | ⏳ 未开始 |
| 4 | UI 抛光 + 触觉 + 动效 | ⏳ 未开始 |
| 5 | 多品牌扩展 (Sony / Canon / Fujifilm) | ⏳ 未开始 (占位) |

## 来源

本项目是对原 iOS Swift 项目 `NikonConnectIOS` 的完全重写。原 Swift 代码不直接复用，但 PTP/IP 协议实现 (`Services/PTPIP*.swift`) 作为协议参考保留阅读价值。