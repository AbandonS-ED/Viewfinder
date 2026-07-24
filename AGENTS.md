# AGENTS.md — AI 工作守则

> 给所有给 Viewfinder 项目帮忙的 AI 看的规矩。一句话：**听人话，按规矩办，做小做精**。
>
> 架构与需求背景见 [`docs/架构.md`](./docs/架构.md) 和 [`docs/产品需求.md`](./docs/产品需求.md)。当前状态见 [`docs/项目状态.md`](./docs/项目状态.md)。Phase 拆解见 [`docs/Viewfinder方案.md`](./docs/Viewfinder方案.md)。

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

- 做什么：[`docs/产品需求.md`](./docs/产品需求.md)
- 怎么搭：[`docs/架构.md`](./docs/架构.md)
- 现在在哪：[`docs/项目状态.md`](./docs/项目状态.md)
- 实施细节：[`docs/Viewfinder方案.md`](./docs/Viewfinder方案.md)
- Phase 2 任务：[`docs/Phase2实施计划.md`](./docs/Phase2实施计划.md)
- 参考样板：`reference/`（Phase 1 后开始填充）

---

## 12. 变更记录

| 日期 | 变更 |
|---|---|
| 2026-07-21 | 初版，配套 docs/ 三件套 |
| 2026-07-23 | Phase 1 完成：PTP/IP 协议层 + 47 单测全绿 |
| 2026-07-23 | Phase 2 完成：UI 骨架 + 102 单测全绿。详见 `docs/项目状态.md §5.3` |
| 2026-07-24 | Phase 3 完成：完整下载链路 + Android 前台服务 + 进度通知 + 144 单测全绿 + APK 构建成功。关键决策：onProgress 回调链绕过 Riverpod；Provider 替代 iOS Coordinator；缩略图纯内存 cache（磁盘 cache 因 Android 性能不适合）。详见 `docs/项目状态.md §5.4` |
| 2026-07-24 | Phase 3 修复合入：activeJob getter 修 RangeError (Phase 3 §17.9 漏修); main.dart 注册 WidgetsBindingObserver 转发生命周期到 handleScenePhaseChange; Gallery 接真实相机 (build() 通过 ref.listen cameraSessionProvider + onSessionChanged 回调); DownloadStore 直接单测 13 个; onProgress 链单测 5 个; Domain 层单测 17 个 (含 activeJob fix 回归测); `dart analyze` 0 issues。详见下方 12.3 节 |
| 2026-07-25 | Phase 3 修正 v2（对照计划 §3-§10 / §15 全审）：(1) handleScenePhaseChange 加 break 修 switch fall-through (回前台 → 后台 runner 重 arm 的 CRITICAL BUG); (2) wifiWatcherProvider 反应式化 (新增 cameraWifiConnectedProvider 让 §9.4 / §16 验收 4 行 "Wi-Fi 断线 → 队列自动暂停" 真工作); (3) GalleryContainer 改读 connectionProvider.autoExportToPhotoLibrary + prioritizeJPEGDownloads (用户偏好不再被覆盖); (4) refreshDownloads 真实现 (调 listRecords 剔磁盘无 record 的 completed job); (5) appendTransportDiagnostics 真实现 + _runQueue step 9 调用 (consumeDiagnostics → appendLog); (6) 53 个新测 (JPEG-sort / loadPersistedQueue running→interrupted / refreshDownloads sync records / cameraWifiConnectedProvider 反应式 / PhotoLibraryChannel mapIosResult+mapAndroidResult 全 5 值 ×2 / DownloadStore 13 + onProgress 流式 3 + 等等); (7) notification service 加 _payloads Map 修 update() payload 丢失; (8) LogFileStore.exportFile 改 timestamp 命名 (多次导出不覆盖); `dart analyze` 0 issues, `flutter test` 197/197 green |
| 2026-07-25 | Phase 3 修正 v3（v2 修复后审计): **根因** v2 让 GalleryContainer 读 `connectionProvider`, 但 `ConnectionNotifier.build()` v1/v2 用的是 stable `preferencesStoreProvider`, Settings 改 toggle 后 `connectionProvider` 不更新, v2 修复**没有真正让 toggle 生效**. **修复** `ConnectionNotifier.build()` 改 `ref.watch(preferencesProvider)` (NotifierProvider); GalleryContainer 现在**真**跟用户偏好同步. **新增 1 回归测** (cameraSessionProvider 反应式 → connectionProvider) 锁住此行为. `flutter test` 198/198 green |
| 2026-07-25 | Phase 3 修正 v3（v2 修复后审计): **根因** v2 让 GalleryContainer 读 `connectionProvider`, 但 `ConnectionNotifier.build()` v1/v2 用的是 stable `preferencesStoreProvider`, Settings 改 toggle 后 `connectionProvider` 不更新, v2 修复**没有真正让 toggle 生效**. **修复** `ConnectionNotifier.build()` 改 `ref.watch(preferencesProvider)` (NotifierProvider); GalleryContainer 现在**真**跟用户偏好同步. **新增 1 回归测** (cameraSessionProvider 反应式 → connectionProvider) 锁住此行为. `flutter test` 198/198 green |

### 12.1 Phase 3 关键决策 (新增)

| 决策 | 备选 | 原因 |
|---|---|---|
| `onProgress` 回调链绕过 Riverpod | 通过 Riverpod 广播进度 | 避免每秒多次 `state = ...` 触发 UI rebuild；直接从 transport → notifier → notification |
| Provider 替代 `CameraSessionCoordinator` | 保留 iOS Coordinator 模式 | Riverpod Provider 拓扑 + `WifiWatcher` 天然替代 coordinator 职责 |
| `NotificationService.update()` 直接接管数字形变 | 用 AnimatedBuilder | 通知栏进度条需要 plain int 百分比，动画应由系统通知处理 |
| 缩略图纯内存 cache | 内存 + 磁盘 cache | Android 文件系统小文件读写性能不适合高频 thumbnail 场景 |

### 12.2 Phase 3 新增代码规范

| 文件 | 规范 |
|---|---|
| `lib/services/download_notification_service.dart` | `show`/`update`/`cancel`/`cancelAll` 四个公开方法；通过 `notificationServiceProvider` 被 Riverpod 持有；main isolate 调用 |
| `lib/services/background_download_runner.dart` | `begin`/`end`/`isActive` 三个公开方法；Android 端用 `flutter_background_service`，iOS 端用 `MethodChannel('viewfinder/background_download')`；`onExpiration` 回调 iOS 端从 channel handler 转发，Android 端暂存待 Phase 4 接 |
| `lib/platform/photo_library_channel.dart` | `requestPermission()` → `Future<PhotoLibraryPermission>`；`exportFile({required String filePath})` → `Future<void>`；各端实现自行处理权限/错误 |
| `lib/services/asset_thumbnail_service.dart` | 公开方法 `getThumbnail(PhotoAsset asset)` → `Future<Uint8List?>`；内部 `Map` cache + `Map` inFlight 去重 |
| `lib/services/download_store.dart` | `save`/`load`/`clear` 三方法；JSON round-trip；`encodeIfNotPresent` 兼容 |
| `lib/services/wifi_watcher.dart` | `start`/`stop`/`onWifiDisconnected` Stream；新增 `cameraWifiConnectedProvider` (NotifierProvider<bool>) 反应式订阅 `connectionStream`；`isCameraWifiConnected` 是同步 getter，`isActive` 在 BackgroundRunner 里改为 `Future<bool>` (测试用 await) |
| `lib/services/log_file_store.dart` | `append`/`readAll`/`exportFile` + 1MB rotation；`exportFile()` 用 `viewfinder-{ms}.log` 命名避免覆盖 |
| `lib/services/download_notification_service.dart` | `show`/`update`/`cancel`/`cancelAll` 四个公开方法；内部 `_payloads: Map<int, String>` 让 `update()` 保留首次 payload 供 deepLink |
| `lib/features/photo_browser/gallery_view_model.dart` | `build()` 初始返 mock 12 张 (无 session 时 fallback); `onSessionChanged(prev, next)` 由外部 (app.dart) ref.listen 触发切换到真实数据；`refresh()` 调 `transport.fetchAssetsPage`；`loadMore()` 同上但 `resetTraversal: false` |
| `lib/features/photo_browser/gallery_container.dart` | 从 `connectionProvider.autoExportToPhotoLibrary / prioritizeJPEGDownloads` 读用户偏好传入 `downloadSelected()`（不再硬编码） |
| `lib/features/downloads/download_manager_view_model.dart` | 13 个公开方法全真实现（含 `refreshDownloads` listRecords 对账、`appendTransportDiagnostics` _runQueue step 9、`loadPersistedQueue` markInterruptedRunningJobs） |
| `lib/app.dart` | `WidgetsBindingObserver` 注册到 downloadManagerProvider.notifier（注意 §5.5 的 `switch` 三个 `break` 不可省，否则 resumed fall-through 重 arm 后台 runner）；ref.listen `connectionProvider.select(activeSession)` 触发 gallery.onSessionChanged + 断线自动 pauseQueue；ref.listen **`cameraWifiConnectedProvider`** 断线自动 pauseQueue |

### 12.3 Phase 3 偏离 Phase3实施计划.md 的决策 (审计 2026-07-24 ~ 2026-07-25)

| 偏离项 | 计划要求 | 实际实现 | 原因 / 状态 |
|---|---|---|---|
| Gallery 默认 fallback 仍用 mock | §1.1 §16 #4 "12+ 张真实缩略图（从相机拉的，不是 mock）" | `build()` 返 12 张 mock，外部 `onSessionChanged(null→session)` 触发 `refresh()` 切真实 | mock 保留用于 (a) 测试环境 (b) 未连接相机的 demo；连接后立刻切真实数据。**Phase 4 评估是否需要去掉 mock fallback** |
| `AssetThumbnailService` 磁盘 cache | §3.6 列了 5 个测含 "磁盘 cache hit" | 纯内存 cache (Line 11 注释明确); 测试 8 个全部内存路径 | Android 文件系统小文件随机读性能不适合；iOS 端有 NSURLCache 兜底。**Phase 4 评估 iOS 端磁盘 cache 价值** |
| 持久化 JSON 文件数 | §4.1 "3 JSON 文件" | 2 JSON 文件 (`downloads-manifest.json` + `download-jobs.json`) | 取消独立的 throughput 文件 (Phase 3 简化为 memory only, 计划 §18 推到 Phase 4) |
| `WRITE_EXTERNAL_STORAGE` maxSdkVersion | §12.1 写 "32" | 实际 "29" | 28+ scoped storage 引入，WRITE_EXTERNAL_STORAGE 仅 Android 9 及以下需要 |
| 测试总数 | §15.2 "Phase 2 102 + Phase 3 80 = 182" | **198** (Phase 2 102 + Phase 3 **96**) | v1: 144 → v2: 197 (+53) → v3: 198 (+1)。v2 加 DownloadStore 13 + JPEG-sort 1 + downloadSelected-session 1 + loadPersistedQueue-running→interrupted 1 + refreshDownloads 1 + cameraWifiConnectedProvider 反应式 1 + PhotoLibraryChannel mapIosResult 5 + mapAndroidResult 5 + onProgress 流式 3 + Domain 17 + 等等 = 53；v3 加 connectionProvider 反应式回归测 1 |
| `BackgroundRunner.onExpiration` Android 端 | §6.1 要求 | Android 端 `onExpiration` 暂存未调 (iOS 端已 wire) | flutter_background_service 暂不支持 onExpiration 回调；**Phase 4 评估替代方案 (WorkManager getInstance().getWorkInfoByIdLiveData)** |
| `BackgroundRunner.isActive` 类型 | §6.1 `bool get isActive` | `Future<bool> get isActive` | iOS 真实现需要 await `_taskId != -1`（channel 异步）；测试也 `await runner.isActive`。计划原文属伪代码偏差 |
| `DownloadStore` 并发原语 | §4.2 写 "Lock" | `Mutex` (`package:sync` 实际导出 `Mutex`，无 Lock) | import 名笔误，功能等价（acquire/release 串行化） |
| `DownloadStore` 路径连接 | §4.3 写 `Platform.pathSeparator` | `p.join()` (`package:path`) | 跨平台 POSIX 风格，路径包已在依赖里 |
| `_interruptibleStatus` 实现 | §5.3 8-case switch | `error.isInterruptibleDownloadStatus ? interrupted : failed` (boolean) | 8 个 `CameraAppError` 子类各自定义此 getter，行为完全等价 |
| `downloadSelected()` `prioritizeJPEG: false` 路径 | §5.6 写 "raw assets" | `DownloadAssetPrioritizer.cameraOrder.sort()` (defensive copy) | 防御性 list copy，功能等价 |
| **`handleScenePhaseChange` switch break** | §5.5 隐含每个 case 独立 | 2026-07-25 v2 修复加上 3 个 `break`（**v1 漏修的 critical bug**） | 不修则 resumed fall-through 到 paused，重新 arm 后台 runner；LinkState 测试可加 |
| **`wifiWatcherProvider` 反应式化** | §9.4 `ref.listen(wifiWatcherProvider, ...)` | 2026-07-25 v2 加 `cameraWifiConnectedProvider: NotifierProvider<bool>` 转发 `connectionStream` | 不修则 `ref.listen` 永不触发，"Wi-Fi 断线 → 队列自动暂停"失效 |
| **`GalleryContainer.downloadSelected` prefs** | §5.6 / §13.4 从 prefs 读 | 2026-07-25 v2 改读 `connectionProvider.autoExportToPhotoLibrary + prioritizeJPEGDownloads` | 不修则用户开关形同虚设（设置页 autoExportToPhotoLibrary toggle 永远不生效） |
| **`ConnectionNotifier.build()` 反应式** (v3 根因) | §5.6 隐含 `connectionProvider` 必须跟 `preferencesProvider` | 2026-07-25 v3 改 `ref.watch(preferencesProvider)` (NotifierProvider) 替代 v1/v2 的 stable `preferencesStoreProvider` | **v2 fix 不到位**：v2 让 GalleryContainer 读 `connectionProvider` 但 `connectionProvider` 自己不更新。Settings 改 toggle 后必须重启 app 才生效，违反 §16 验收"设置页 → 立即生效"。v3 fix 让 `connectionProvider` 跟 `preferencesProvider` 反应式同步 |
| **`refreshDownloads` / `appendTransportDiagnostics` 实现** | §5.1 + §5.2 step 11/9 | 2026-07-25 v2 全部填实（listRecords 对账 + consumeDiagnostics → appendLog） | v1 是空 stub，§5.7 test 11 无法补 |
| `NotificationService.update()` 持久化 payload | §7.4 deepLink 隐含 | v1 漏，`update()` 写 `payload: null`；v2 加 `_payloads` Map 修复 | 不修则下载中点通知不路由 downloads 页 |
