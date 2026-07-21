# project.md — 项目状态

> Viewfinder (取景器) 的当前状态快照。**架构 / 验收标准** 见 [`prd.md`](prd.md) 和 [`arc.md`](arc.md)。

---

## 1. 一句话进度

**当前位于 Phase 0 之前 —— 已完成规划 / 文档 / 仓库初始化；尚未跑 `flutter create`，没有 Dart 代码。**

---

## 2. 进度看板

| Phase | 内容 | 状态 | 完成度 |
|---|---|---|---|
| **—** | 文档宪法 (prd/arc/project + Viewfinder方案) | ✅ 已完成 | 100% |
| **—** | 仓库初始化 (git + GitHub) | ✅ 已完成 | 100% |
| 0 | 工程骨架 (`flutter create` + pubspec + Domain freezed) | ⏳ 未开始 | 0% |
| 1 | PTP/IP 协议层 + Dart 单测 | ⏳ 未开始 | 0% |
| 2 | 端到端真机连 Nikon (浏览) | ⏳ 未开始 | 0% |
| 3 | 下载 + 进度通知 | ⏳ 未开始 | 0% |
| 4 | UI 抛光 + 触觉 + 动效 | ⏳ 未开始 | 0% |
| 5 | 多品牌扩展 (Sony / Canon / Fujifilm) | ⏳ 未开始 (占位) | 0% |

图例：✅ 完成 / 🚧 进行中 / ⏳ 未开始 / ❌ 阻塞 / 🚫 取消

---

## 3. 已完成清单 (截至 2026-07-21)

### 3.1 仓库

- [x] 本地 Git 初始化 (main 分支)
- [x] 远端创建：`https://github.com/AbandonS-ED/Viewfinder`
- [x] 首次推送：3 个 commit (含 GitHub 自动 init commit)
- [x] `.gitignore` (Flutter 标准模板)
- [x] Git 用户配置：`AbandonS-ED` + 隐私邮箱 `AbandonS-ED@users.noreply.github.com`

### 3.2 文档宪法

- [x] `README.md` — 项目说明 + 链接到方案
- [x] `Viewfinder方案.md` — 12 节完整实施方案 (原 `FLUTTER_REWRITE_PLAN.md` 重命名)
- [x] `prd.md` — 5 个核心功能 + 验收标准 + 非功能需求 + 边界
- [x] `arc.md` — 技术栈 + 分层 + 数据模型 + 与 iOS 映射
- [x] `project.md` — 本文档

### 3.3 决策记录

- [x] 命名：Viewfinder / 取景器
- [x] 路径：`D:\桌面\Nikon_connect\Viewfinder\`
- [x] 技术栈：Flutter + Riverpod + freezed + `dart:io` Socket
- [x] iOS 最低 16.0 / Android 最低 API 24
- [x] 不实现 Live Activity（Android 无对应）
- [x] 首版只支持 Nikon（其他品牌 Phase 5）

---

## 4. 当前阻塞

无。当前没有阻塞 Phase 0 起步的事项。

⚠️ **网络提醒**（与开发无关）：
- 当前默认网络是相机 Wi-Fi 热点 (`192.168.1.1`)
- 推到 GitHub OK（已验证），但 `flutter pub get` 拉依赖可能慢 / 不稳
- **建议开发时切回家里 Wi-Fi 或手机热点**

---

## 5. 下一步 (按优先级)

| 序号 | 任务 | 前置条件 | 估时 |
|---|---|---|---|
| 1 | 跑 `flutter create viewfinder --org com.yaoyihan --platforms=ios,android` | 本机已装 Flutter SDK | 5 分钟 |
| 2 | 写 `pubspec.yaml` 依赖 (riverpod / freezed / connectivity_plus / 等) | 步骤 1 | 15 分钟 |
| 3 | 写 `analysis_options.yaml` (启用 `flutter_lints`) | 步骤 1 | 5 分钟 |
| 4 | `lib/domain/` 17 个 freezed 文件 (机械翻译原 Swift) | 步骤 2 | 2-3 小时 |
| 5 | 跑 `dart run build_runner build` 生成 freezed 代码 | 步骤 4 | 1 分钟 |
| 6 | 跑 `flutter analyze` 确认零警告 | 步骤 5 | 1 分钟 |
| 7 | Phase 0 验收 commit + push | 步骤 6 | 5 分钟 |

**Phase 0 验收**：`flutter analyze` 零警告；17 个 Domain 文件全部生成；`pubspec.lock` 已提交。

---

## 6. 风险与应对

| 风险 | 触发条件 | 应对 |
|---|---|---|
| Flutter SDK 未装 | 步骤 1 失败 | 装 Flutter stable (`flutter doctor`) |
| 网络拉依赖不稳 | `pub get` 超时 | 用国内镜像 / 切回普通 Wi-Fi |
| freezed 模板错误 | 步骤 5 报错 | 对照 `Viewfinder方案.md` §4 检查文件名 |
| Phase 1 协议层偏离参考 | 跑不通真机 | 严格对照原 `Services/PTPIP*.swift`，**禁止脑补 opcode** |
| Android scoped storage 限制 RAW 入相册 | Phase 3 | 评估 `gal` 包；不支持则降级到 "写入 app 专属目录 + 提示用户" |

---

## 7. 文档同步规则 (必须遵守)

| 何时更新 | 更新哪个文档 |
|---|---|
| 砍 / 加 / 改一个功能 | `prd.md` §3 + §6 |
| 改技术栈 / 加依赖 / 改模块边界 | `arc.md` §1 / §3 / §5 |
| 完成一个 Phase / 出现新阻塞 / 关键决策 | `project.md` §2 / §4 / §8 |
| 详细计划微调 | `Viewfinder方案.md` 对应小节 |
| **任何更新前必须先读相关文档当前内容**，避免覆盖他人改动 |

---

## 8. 决策日志 (Decision Log)

| 日期 | 决策 | 备选 | 选择原因 |
|---|---|---|---|
| 2026-07-21 | 走 Flutter 不走 KMP | KMP / 纯 Native Kotlin | 用户希望双端同步出包；iOS 体验可降级 (有原 iOS 项目作参考) |
| 2026-07-21 | 用 Riverpod 2.x | Bloc / Provider | 用户在前一轮已点名 Riverpod |
| 2026-07-21 | 用 freezed 写 Domain | 手写 data class | 替代 `==`/`hashCode`/`copyWith`/`fromJson` 样板 |
| 2026-07-21 | 首版只支持 Nikon | 多品牌并行 | Phase 5 留扩展点；首版避免范围蔓延 |
| 2026-07-21 | 不实现 Live Activity | 写 platform channel 模拟 | Android 无对应；通知 + foreground service 是务实降级 |
| 2026-07-21 | 隐私邮箱 (noreply) | 真实邮箱 (qq.com) | 防止 commit 历史泄露真实邮箱 |

---

## 9. 链接

- 仓库：https://github.com/AbandonS-ED/Viewfinder
- 源 iOS 项目 (参考用)：`D:\桌面\Nikon_connect\` (上级目录)
- 实施详细方案：[`Viewfinder方案.md`](Viewfinder方案.md)
- PRD：[`prd.md`](prd.md)
- 架构：[`arc.md`](arc.md)

---

## 10. 变更记录

| 日期 | 变更 |
|---|---|
| 2026-07-21 | 初版创建 |
