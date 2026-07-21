# AGENTS.md — AI 工作守则

> 给所有给 Viewfinder 项目帮忙的 AI 看的规矩。一句话：**听人话，按规矩办，做小做精**。
>
> 架构与需求背景见 [`docs/arc.md`](./docs/arc.md) 和 [`docs/prd.md`](./docs/prd.md)。当前状态见 [`docs/project.md`](./docs/project.md)。Phase 拆解见 [`docs/Viewfinder方案.md`](./docs/Viewfinder方案.md)。

---

## 1. 项目一句话

**Viewfinder (取景器)**：Flutter 跨端 app，通过 Wi-Fi 热点连接 Nikon 相机，浏览并批量下载照片到手机。

---

## 2. AI 权限（最重要）

### ✅ 可以做

- 写用户**明确点名**要写的文件
- 写新文件、删空文件、改动现有代码（前提是用户允许）
- 跑 `flutter analyze` / `flutter test` / `dart format` 这类**只读检查**或**自动格式化**
- 建议重构，但**先问再动**

### ❌ 不能做

- **顺手重构**：用户没让改的文件，一个字不动
- **改 UI 风格**：用户没说要换风格，复用现有设计
- **改无关逻辑**：比如让 A 功能能跑，别顺手把 B 功能的代码也改了
- **改 pubspec 依赖**：除非用户明确同意；依赖改动需先说明替代方案
- **commit / push**：永远由用户决定何时 commit、写什么 message、是否 push
- **删除已有文件**：永远不要，除非用户明确说"删 X"
- **编造 API**：不知道的 PTP/IP opcode / Flutter API / Dart 方法，**必须查文档**，不能脑补

### ❓ 拿不准时

- **停下来问**。不要说"我猜是这样"。
- 用户给的指令有歧义 → 用 `question` 工具确认，**不要自己拍板**

---

## 3. 单次任务粒度

**一次只做一个小切片**。完整切片示例：

- ✅ "实现 `domain/camera_connection_config.dart` 的 freezed 版本"
- ✅ "把 `Services/PTPIPPrimitives.swift` 的 `encodeCommand` 翻成 Dart"
- ❌ "实现整个 Phase 1"（太大，失控）
- ❌ "写一个完整的下载功能"（模糊，拆不开）

每个切片完成后：

1. 用户验收（编译 / 跑测试 / 看 diff）
2. 用户决定是否 commit
3. 才进下一个切片

---

## 4. 命名规范

### 4.1 Dart

| 类型 | 命名 | 示例 |
|---|---|---|
| 类 | `PascalCase` | `CameraConnectionConfig`, `PtpipSession` |
| 抽象类 / 接口 | `PascalCase`，无 `I` 前缀 | `CameraTransport`（不是 `ICameraTransport`） |
| 文件 | `snake_case.dart` | `camera_connection_config.dart` |
| 私有变量 / 方法 | `_camelCase` 前导下划线 | `_socket`, `_parseResponse` |
| 公开变量 / 方法 | `camelCase` | `host`, `connect()` |
| 常量 | `lowerCamelCase` | `defaultHost`（不是 `DEFAULT_HOST`） |
| 枚举值 | `lowerCamelCase` | `experimentalNikon`（不是 `EXPERIMENTAL_NIKON`） |
| Riverpod Provider | 描述性 `xxxProvider` 后缀 | `connectionProvider`, `galleryProvider` |

### 4.2 目录

- 全小写，`snake_case`
- 复数目录：`features/`, `services/`, `protocol/`
- 单数目录：`domain/`（不放单文件，只放模型集合，所以单数也行；项目内部统一即可）

### 4.3 中文 vs 英文

| 项 | 语言 |
|---|---|
| 代码标识符 | **英文** (Dart 强制) |
| 注释 | **中文** (用户看不懂英文) |
| commit message | **中文** (项目约定) |
| 文档 (prd/arc/project/方案) | **中文** |
| 用户面字符串 | **中文** (i18n 后预留) |

---

## 5. 文件大小限制

| 类型 | 行数上限 | 超出时怎么办 |
|---|---|---|
| View (Page) | ≤ 300 | 拆 widget，提到 `widgets/` 子目录 |
| ViewModel / Notifier | ≤ 250 | 拆职责；用 mixin 拆分状态 |
| Service | ≤ 400 | 拆接口；IO 与业务分离 |
| 单文件 freezed model | 不限 | 但**一个文件一个 model** |
| 单测文件 | ≤ 500 | 按被测函数拆分 |

---

## 6. 测试规则

### 6.1 何时写测试

- **协议层 (`lib/protocol/`)** 必须有单测，覆盖率 ≥ 80%
- **Domain 层 (`lib/domain/`)** 关键 model 写 round-trip JSON 测试
- **Service 层** 至少 1 个 happy path + 1 个 error path
- **UI 层 (`lib/features/`)** Phase 4 之前不强求

### 6.2 测试约定

- 单测目录：`test/`，**镜像** `lib/` 结构
- 集成测试：`integration_test/`
- 命名：用 Dart `package:test` / `package:flutter_test` 标准——`group('X', () { test('does Y', () {...}); });`
- 每个 PR / commit 前必须 `flutter test` 全绿

### 6.3 测试不准做的事

- ❌ mock 整个相机 —— 用 fake socket server
- ❌ 测试私有方法 —— 通过公开 API 测
- ❌ 写脆弱的快照测试 (snapshot test) —— UI 改动会全挂

---

## 7. 报错处理（5 步走）

遇到报错或异常，**严格按这个流程**：

```
1. 最小复现 ─ 写一个 5 行内能触发的最小代码 / 命令
2. 加日志 ─ 在可疑位置加 print / debugPrint，看实际值
3. 查文档 ─ 查官方 API、源码注释、GitHub issue
4. 写测试锁住 ─ 给 bug 写一个 failing test，重现 bug
5. 改代码 ─ 基于测试和日志改，不要"猜"
```

**两次无证据的猜测就停手**。告诉用户"我猜不到根因，需要你提供更多信息"。

---

## 8. Commit 规范

### 8.1 何时 commit

- ✅ 一个 Phase 的 tracer bullet 通过验收
- ✅ 一个 bug 修完（带回归测试）
- ✅ 一个文件 / 一个模块落地
- ❌ 不要"顺手 commit 一堆"
- ❌ 不要"写到一半 commit 一下"

### 8.2 message 格式

```
<动词><对象>：<一句话说明>
```

例：

```
实现 domain 层 14 个 freezed model
修复 PTP/IP 握手超时导致 session 假开
重构 download service 拆 IO 与业务
```

- 中文为主
- 动词：实现 / 修复 / 重构 / 添加 / 删除 / 更新
- 不超过 50 字

### 8.3 永远不要

- ❌ 写 "update" / "fix" / "misc" / "wip" 这种空 message
- ❌ 把 `git push` 写在自动化里 —— push 由人决定

---

## 9. `reference/` 目录约定

`reference/` 放**认可的标准实现样板**，所有 UI 业务代码从这里复制。

```
reference/
├── widgets/
│   ├── primary_button.dart       # 主按钮（黑色圆角胶囊 + 琥珀金强调）
│   ├── haptic_card.dart          # 带触觉的卡片
│   └── empty_state.dart          # 空状态占位
├── patterns/
│   ├── riverpod_notifier.dart    # Notifier 标准模板
│   ├── freezed_model.dart        # freezed class 模板
│   └── method_channel.dart       # 平台 channel 模板
└── README.md                     # 列出 reference 目录有什么 / 怎么用
```

### 9.1 reference 的"准入门槛"

放进 reference 的代码必须：
- ✅ 已经被业务代码用过 ≥ 1 次
- ✅ 单元测试覆盖
- ✅ 经过用户验收

**未达门槛的代码不进 reference**——避免样板库污染。

---

## 10. 与 9 步开发流程的对齐

按用户分享的 9 步流程，AI 在每一步的角色：

| 步骤 | AI 做什么 | AI 不做什么 |
|---|---|---|
| 1-2 需求/PRD | 提问、补全、提问式对话 | 不替用户拍板业务决策 |
| 3 视觉 | 出 2-3 个对比方案，让用户选 | 不擅自定调 |
| 4 边界 | 主动问"上线吗？/ 多人用吗？" | 不假设 |
| 5 技术栈 | 给对比表 + 推荐 + 理由 | 不替用户选 |
| 6 架构 | 草拟目录树 / 分层 / 数据模型 | 不直接落地代码 |
| 7 固化 | 帮写 prd/arc/project 三件套 | 不自己改业务方向 |
| 8 规范 | 写 AGENTS.md + reference/ | 不擅自添加规则 |
| 9 Git+质量 | 配 `.gitignore` / `analysis_options.yaml` / CI workflow | 不擅自 push / 不擅自改 git 历史 |

---

## 11. 关联文档

- 做什么：[`docs/prd.md`](./docs/prd.md)
- 怎么搭：[`docs/arc.md`](./docs/arc.md)
- 现在在哪：[`docs/project.md`](./docs/project.md)
- 实施细节：[`docs/Viewfinder方案.md`](./docs/Viewfinder方案.md)
- 参考样板：`reference/`（Phase 1 后开始填充）

---

## 12. 变更记录

| 日期 | 变更 |
|---|---|
| 2026-07-21 | 初版，配套 docs/ 三件套 |
