# Phase 5 实施计划 — 多品牌相机扩展

> **周期**：暂未启动（前置：拍板 §0 决策矩阵中的 D1~D10 + Mac + 真机）
> **拆分原因**：原 Phase 5 含糊地写成"多品牌扩展"。拆开做（Sony → Canon → Fujifilm），各自独立，每个品牌有自己的失败回滚点。
> **本次目标**：在现有 `CameraTransport` 抽象层上扩展可工作的多品牌 transport 实现。本文件是**完整实施计划**，**不写代码**直至 §0 决策点全部拍板。

---

## 0. 决策矩阵（启动前必须填完）

| # | 决策点 | 选项 | 推荐 | 状态 |
|---|---|---|---|---|
| **D1** | 第一阶段先做哪个品牌？ | A. Sony / B. Canon / C. Fujifilm / D. 暂不开始 | **A. Sony**（Sony Remote API 文档相对好入手，PTP 子集最接近标准） | ❓ 待定 |
| **D2** | 目标相机型号范围？ | A. 单旗舰机型 + 简化协议 / B. 主流 3-5 款 / C. 全 PTP 标准子集 | **B**（5 款内可承载 90% 用户 + 单测可控） | ❓ 待定 |
| **D3** | 真机测试硬件？ | A. 有对应相机可借 / B. 需要采购 / C. 仅协议层 fake | **A 或 B**（fake 仅够协议层覆盖，UI/通知/权限必须真机） | ❓ 待定 |
| **D4** | 抽象粒度？ | A. 维持 `CameraTransport` abstract，新加 `SonyCameraTransport extends` / B. 抽 `PtpipTransportBase` + 私有 opcode handler 注入 | **A 起步，B 在 5e 重构**（避免一开始就过度设计） | ❓ 待定 |
| **D5** | `CameraTransportMode` 扩展？ | A. 新加 enum 3 值 / B. 注册表 `Map<String, Factory>` | **A**（注册表是 5 阶段后才能评估的复杂度） | ❓ 待定 |
| **D6** | 品牌选择 UI 位置？ | A. Settings 页加 section / B. 连接页首次启动引导 / C. 失败后引导 | **A**（与 "外观" 平行，最小侵入） | ❓ 待定 |
| **D7** | 协议失败处理？ | A. 重试 + 提示用户换相机 / B. 报告具体 opcode 失败让用户上报 | **B**（品牌支持早期阶段需要 telemetry，运营友好） | ❓ 待定 |
| **D8** | UI 文案 / 图标？ | A. 通用 "Wi-Fi 连接相机" / B. 品牌化（Sony 紫、Canon 红、Fuji 绿） | **A 起步**（品牌化等 UI 设计阶段做） | ❓ 待定 |
| **D9** | 品牌测试是否需要真机？ | A. 必须真机 / B. gphoto2 输出作基准的 fake server / C. 用户社区贡献 | **B**（开源 fake 可让 PR 来自社区） | ❓ 待定 |
| **D10** | 协议覆盖率目标？ | A. 仅列表 + 下载 / B. + 删除 / C. + 实时取景 | **A**（live view 复杂度极高，留 v1.1） | ❓ 待定 |

**为什么先列决策项**：每个决策都对应一个具体任务分支，先决策能减少实施中途来回修改。

---

## 1. 五期拆分

| Phase | 内容 | 估时 | 依赖 | 何时做 |
|---|---|---|---|---|
| **5a** | **Sony transport**（D1=A 时）/ Canon（D1=B）/ Fujifilm（D1=C） | 15-20 天 (3-4 周) | D1~D10 + Mac + 真机 | 决策拍板后启动 |
| **5b** | Canon transport | 15-20 天 | 5a 完 | 5a 真机验证通过 |
| **5c** | Fujifilm transport | 15-20 天 | 5b 完 | 5b 真机验证通过 |
| **5d** | 品牌选择 UI（CameraBrandPickerRow）+ 持久化 + factory dispatch | 5 天 | 5a 完成 (任一品牌) | 与 5a 并行（5a 提供 mode 入口即可启动 5d） |
| **5e** | 抽 `PtpipStandardTransport` 基类（当 ≥ 2 品牌完成时） | 8 天 | 5b 完 | 5b/5c 推进过程中进行；不做会让 5c 推进变慢 |

**预估总时长**：Sony 15d + Canon 15d + Fuji 15d + 5e 8d + 5d 5d（并行）= **~40 天**（8 周），1 人顺序推进；如 2 人并行可缩 50%。

**为什么把 Sony 单独列**：Sony Remote API 公开程度最高 + PTP 子集最标准化，可作为后续 Canon/Fuji 推进的"基线"。Canon/Fuji 私有 opcode 多，建议在 Sony 基础上做"对齐反推"。

---

## 2. Phase 5a — Sony transport（暂定首选品牌，可被 D1 切换）

### 2.1 目标

1. `lib/protocol/experimental_sony_transport.dart` 实现，能用 Sony 真机（A7 III / A7 IV 等旗舰）通过 PTP/IP 连接、列列表、下载 JPEG + RAW + MP4
2. `CameraTransportMode.sonyExperimental` enum 加 + factory route
3. `_classifyObjectFormat` 加 Sony-specific 格式码（ARW / SonyRaw / HEIF 等）
4. `FakeSonyPtpipSocket` + 8+ 单测覆盖 happy path + 3 错误路径
5. emulator 真机端到端跑通连接 + 列表 + 下载
6. Sony 私有 opcode 错误码映射到 `CameraAppError.sonySpecific(...)`
7. 文档同步（架构.md §6.1 / 产品需求.md §F5 / 项目状态.md §2 + §10）

### 2.2 不在本期范围（明确不做）

- ❌ Canon / Fujifilm（5b/5c）
- ❌ 品牌选择 UI（5d）- 5d 与 5a 并行（5a 提供 `mode = sonyExperimental` 入口）
- ❌ 通用 PTP 基类（5e）
- ❌ 实时取景（live view，复杂度极高；D10=A 已排除）
- ❌ 云同步（Sony Cloud / Imaging Edge Web）
- ❌ Sony Eye-AF 等品牌专属高级功能
- ❌ 视频流解码（仅下载 .mp4 文件，不预览）

### 2.3 核心设计决策（先审）

| 决策点 | 选择 | 理由 |
|---|---|---|
| 协议选 PTP/IP 还是 Sony Remote API (HTTP/JSON) | **PTP/IP 优先** | iOS 端已用 PTP/IP；架构一致；HTTP 仅在 PTP/IP 不够时 fallback |
| 私有 opcode 还是标准 PTP 子集 | **标准 PTP 子集 + Sony 私有 opcode 适配层** | 标准子集跨品牌可复用（5e 重构底子）；私有 opcode 单独 `_sonyOpCode()` 适配 |
| `_classifyObjectFormat` 位置 | 在 `ExperimentalSonyTransport`（不抽基类，5e 再做） | 5a 不抽基类 = 改造成本最低；Sony 适配独立 |
| Session 单例 vs per-call | **per-call**（跟 Nikon 一致） | Riverpod 持有 factory，每次 connect/disconnect 各一 session |
| 错误码映射 | `PTPResponseCode` → `CameraAppError`（映射到 sealed factory） | 业务层只看 sealed，私有码不漏出 |
| 测试 fixture | `FakeSonyPtpipSocket` 复用现有 `FakePtpipSocket` 框架 + `scriptedSonyResponses` 注入 | 与 Phase 1 fake socket 一致 |
| single-line constructor vs DI | 走 Riverpod override（同 Nikon） | 工厂 `CameraTransportFactory.makeTransport(config)` 按 mode 返回 |
| 真机端到端测试 | emulator 上 `flutter run --dart-define=BRAND=sony --dart-define=HOST=...` 接真机 | emulator ≠ 真机，UI/触觉必须真机 |

### 2.4 协议调研（前置，必做）

| 来源 | 内容 | 用法 |
|---|---|---|
| `libptp2` (`http://libptp.sourceforge.net/`) | 标准 PTP/IP opcode | 基础子集 |
| `libgphoto2` 项目 (`https://github.com/gphoto/libgphoto2`) | Sony backend (`camlibs/ptp2/`) | Sony 私有 opcode 实现参考 |
| Sony Developer World（注册） | Sony Camera Remote API（HTTP）文档 | 仅在 PTP/IP 不够时用 |
| CIPA 标准文档 | PTP/IP v1.1 spec | 协议根 |
| Sony A7 III / A7 IV 实机测试 | 验证私有 opcode 在不同固件表现 | 5a.5 端到端 |

**调研产物**：`docs/Phase5a协议调研.md`（独立文档，类似 `B10_visual_audit.md`），包含：
- Sony 设备 GetDeviceInfo 返回值示例
- GetObjectHandles / GetObjectInfo 私有变体
- _classifyObjectFormat 的 Sony 格式码表
- 已知 incompatible 固件版本清单

### 2.5 关键任务

| # | 任务 | 文件 | 估时 |
|---|---|---|---|
| 5a.0 | Sony 协议调研 + opcode 表 | `docs/Phase5a协议调研.md` | 3 天 |
| 5a.1 | `experimental_sony_transport.dart` 主类 | `lib/protocol/experimental_sony_transport.dart` | 4 天 |
| 5a.2 | `CameraTransportMode.sonyExperimental` 加 | `lib/domain/camera_transport_mode.dart` | 0.5 天 |
| 5a.3 | factory route 按 mode dispatch | `lib/protocol/camera_transport_factory.dart` | 0.5 天 |
| 5a.4 | `_classifyObjectFormat` Sony 私有格式码 | 同 5a.1 | 1 天 |
| 5a.5 | `FakeSonyPtpipSocket` + 8+ 单测 | `test/protocol/experimental_sony_transport_test.dart` + `test/helpers/fake_sony_ptpip_socket.dart` | 3 天 |
| 5a.6 | emulator 真机端到端 | 外部真机 | 2 天 |
| 5a.7 | Sony 私有错误码 → `CameraAppError.sonySpecific(...)` | `lib/domain/camera_app_error.dart` + sealed factory | 1 天 |
| 5a.8 | `lib/protocol/experimental_sony_transport.dart` 文档注释 + Architecture section sync | `lib/architecture.md` §6.1 | 0.5 天 |
| 5a.9 | README 标 Phase 5a 状态 + 更新 Viewfinder方案.md §8 进度表 | 多文件 | 0.5 天 |
| **5a 总计** | | | **~16 天** |

### 2.6 `CameraTransportMode` 扩展（D5=A）

> 当前 `CameraTransportMode` 只有 `experimentalNikon`，且 4 个 getter (`title`/`detail`/`defaultHost`/`defaultPort`) 写死 Nikon 值。**每加品牌需扩展 switch 4 个 getter**（不要直接写死）。

```dart
// lib/domain/camera_transport_mode.dart (扩展)
enum CameraTransportMode {
  experimentalNikon,    // 现有
  experimentalSony,     // ✅ 5a 新增
  experimentalCanon,    // 5b 新增
  experimentalFuji;     // 5c 新增

  String get title {
    switch (this) {
      case CameraTransportMode.experimentalNikon: return 'Nikon Wi-Fi';
      case CameraTransportMode.experimentalSony:  return 'Sony Wi-Fi';
      case CameraTransportMode.experimentalCanon: return 'Canon Wi-Fi';
      case CameraTransportMode.experimentalFuji:  return 'Fujifilm Wi-Fi';
    }
  }

  String get detail {
    switch (this) {
      case CameraTransportMode.experimentalNikon: return '使用尼康相机 Wi-Fi 地址 192.168.1.1:15740 建立连接。';
      case CameraTransportMode.experimentalSony:  return '使用 Sony 相机 Wi-Fi 地址 192.168.1.1:15740 建立连接。';
      // ...
    }
  }

  String? get defaultHost => '192.168.1.1';
  int get defaultPort => 15740;
}
```

### 2.7 factory dispatch（D5=A，**签名变更**）

> **注**：当前 factory 签名是 `CameraTransport makeTransport()`（无参数）。要做 mode-aware dispatch 必须 **改 factory 签名**为接受 `CameraConnectionConfig`，与之同时需修改 `connection_view_model.dart:78` 的 `factory.makeTransport()` 调用点和测试 fake。

```dart
// lib/protocol/camera_transport_factory.dart (扩展)
abstract class CameraTransportFactory {
  CameraTransport makeTransport(CameraConnectionConfig config);
}

class DefaultCameraTransportFactory implements CameraTransportFactory {
  @override
  CameraTransport makeTransport(CameraConnectionConfig config) {
    switch (config.transportMode) {
      case CameraTransportMode.experimentalNikon:
        return ExperimentalNikonTransport();
      case CameraTransportMode.experimentalSony:
        return ExperimentalSonyTransport();
      // 5b/5c 加这里
    }
  }
}
```

**调用点改动**（5d 同步改）：
- `lib/features/connection_setup/connection_view_model.dart:78` `final transport = factory.makeTransport();` → `final transport = factory.makeTransport(config);`
- `test/helpers/fake_camera_transport.dart:77` `FakeCameraTransportFactory.makeTransport()` → 接收 `CameraConnectionConfig config`（暂时不用可忽略参数）

### 2.8 测试覆盖目标

| 类别 | 测数 | 说明 |
|---|---|---|
| Sony PTP opcode encode/decode | 5+ | 标准 PTP 子集 |
| Sony GetDeviceInfo 解析 | 1+ | 含私有字段 |
| Sony GetObjectHandles | 1+ | 标准子集 |
| Sony GetObjectInfo 私有扩展 | 1+ | ARW 格式识别 |
| Sony 错误响应映射 | 3+ | PTPResponseCode → CameraAppError |
| FakeSocket + scriptedSonyResponses round-trip | 1+ | 端到端 happy path |
| **5a 总计** | **≥ 12** | |

### 2.9 验收标准

1. `dart analyze` 0 warnings（与现状一致）
2. `flutter test` ≥ 397/397 绿（385 + ≥ 12 新测）
3. emulator 真机跑通：Sony A7 III / A7 IV 任一连接 + 列列表 + 下载 1 张 JPEG + 下载 1 张 ARW
4. `flutter build apk --debug` 仍通过
5. 文档同步（项目状态 / 架构 / README / Viewfinder方案）

---

## 3. Phase 5b — Canon transport（暂定第二品牌）

### 3.1 目标

1. `lib/protocol/experimental_canon_transport.dart` 实现，能用 Canon EOS R 系列真机连接、列列表、下载 CR3 + JPEG + MP4
2. `CameraTransportMode.experimentalCanon` enum 加
3. Canon-specific 私有 opcode 适配（`GetCanonObjectInfo` 等）
4. `_classifyObjectFormat` Canon 格式码（CR3 / Canon RAW II / JPEG / MP4）
5. ≥ 10 单测 + emulator 真机端到端验证
6. 文档同步

### 3.2 不在本期范围

- ❌ Fujifilm（5c）
- ❌ Canon CCAPI（云端 API，复杂度高）
- ❌ Canon EOS 7D Mark II 等老机型（不维护 PTP 子集）
- ❌ 实时取景（live view）

### 3.3 关键差异（vs Sony）

| 项 | Sony | Canon |
|---|---|---|
| 协议文档 | 公开 SDK + gphoto2 参考 | 仅 gphoto2 反编译 + EDSDK 已停更 |
| GetObjectInfo 私有变体 | Sony-specific opcode | Canon-specific opcode（多版本不一致） |
| 格式码 | ARW (0xB002) / SonyRaw | CR3 (0xB108) / Canon RAW II |
| 错误码 | Sony-specific Response | Canon-specific Response |
| 难度 | ⭐⭐ | ⭐⭐⭐ |

### 3.4 关键任务

| # | 任务 | 文件 | 估时 |
|---|---|---|---|
| 5b.0 | Canon 协议调研（gphoto2 canon backend） | `docs/Phase5b协议调研.md` | 3 天 |
| 5b.1 | `experimental_canon_transport.dart` 主类 | 同 | 4 天 |
| 5b.2 | `CameraTransportMode.experimentalCanon` | `lib/domain/camera_transport_mode.dart` | 0.5 天 |
| 5b.3 | factory 加 Canon 分支 | `lib/protocol/camera_transport_factory.dart` | 0.5 天 |
| 5b.4 | `_classifyObjectFormat` Canon 格式码 | 同 5b.1 | 1 天 |
| 5b.5 | `FakeCanonPtpipSocket` + 10+ 单测 | `test/protocol/experimental_canon_transport_test.dart` + `test/helpers/fake_canon_ptpip_socket.dart` | 3 天 |
| 5b.6 | emulator 真机端到端 | 外部真机 | 2 天 |
| 5b.7 | Canon 错误码映射 | `lib/domain/camera_app_error.dart` | 1 天 |
| 5b.8 | 文档同步 | 多文件 | 1 天 |
| **5b 总计** | | | **~16 天** |

### 3.5 验收标准

1. `dart analyze` 0 warnings
2. `flutter test` ≥ 410/410 绿（Phase 5a 后基线 + 5b 新测）
3. emulator 真机跑通 Canon EOS R5 / R6 任一连接 + 列列表 + 下载 1 张 CR3 + 下载 1 张 JPEG
4. 文档同步

---

## 4. Phase 5c — Fujifilm transport（暂定第三品牌）

### 4.1 目标

1. `lib/protocol/experimental_fuji_transport.dart` 实现，能用 Fujifilm X-T 系列真机连接、列列表、下载 RAF (Fuji RAW) + JPEG + MOV
2. `CameraTransportMode.experimentalFuji` enum 加
3. Fuji-specific 私有 opcode
4. `_classifyObjectFormat` Fuji 格式码（RAF / MOV）
5. ≥ 8 单测 + emulator 真机端到端
6. 文档同步

### 4.2 关键差异（vs Canon）

| 项 | Canon | Fujifilm |
|---|---|---|
| 协议文档 | gphoto2 反编译较多 | 文档稀缺，最封闭 |
| GetObjectInfo 私有变体 | Canon-specific | Fuji-specific（opcode 表分散） |
| 格式码 | CR3 / Canon RAW II | RAF (0xB103) / Fuji RAW |
| 难度 | ⭐⭐⭐ | ⭐⭐⭐⭐ |

### 4.3 关键任务

| # | 任务 | 文件 | 估时 |
|---|---|---|---|
| 5c.0 | Fujifilm 协议调研（gphoto2 fuji backend + 第三方 reverse engineering 文档） | `docs/Phase5c协议调研.md` | 4 天 |
| 5c.1 | `experimental_fuji_transport.dart` | 同 | 5 天 |
| 5c.2 | `CameraTransportMode.experimentalFuji` | `lib/domain/camera_transport_mode.dart` | 0.5 天 |
| 5c.3 | factory 加 Fuji 分支 | `lib/protocol/camera_transport_factory.dart` | 0.5 天 |
| 5c.4 | `_classifyObjectFormat` Fuji 格式码 | 同 5c.1 | 1 天 |
| 5c.5 | `FakeFujiPtpipSocket` + 8+ 单测 | `test/protocol/experimental_fuji_transport_test.dart` + `test/helpers/fake_fuji_ptpip_socket.dart` | 3 天 |
| 5c.6 | emulator 真机端到端 | 外部真机 | 2 天 |
| 5c.7 | Fuji 错误码映射 | `lib/domain/camera_app_error.dart` | 1 天 |
| 5c.8 | 文档同步 | 多文件 | 1 天 |
| **5c 总计** | | | **~18 天** |

### 4.4 验收标准

1. `dart analyze` 0 warnings
2. `flutter test` ≥ 420/420 绿（5b 后基线 + 5c 新测）
3. emulator 真机跑通 Fujifilm X-T5 / X-H2 任一连接 + 列列表 + 下载 1 张 RAF + 下载 1 张 JPEG
4. 文档同步

---

## 5. Phase 5d — Camera Brand Picker UI（与 5a 并行启动）

### 5.1 目标

1. Settings 页加 "相机品牌" section，紧邻 "外观" section 下方
2. 复用 `ThemePickerRow` 模式，`CameraBrandPickerRow` 显示 4 个圆点 + 选中态
3. `CameraConnectionConfig.cameraTransportMode` 字段持久化（新增字段，老用户 default 'experimentalNikon'）
4. `CameraTransportFactory.makeTransport()` 改成 mode-based dispatch（5a.3 同步）
5. `ConnectionNotifier.build()` 启动时按 `cameraTransportMode` 创建对应 transport
6. ≥ 4 单测 + UI smoke test

### 5.2 不在本期范围

- ❌ Canon / Fujifilm 选项启用（D1~D3 拍板前，5d 只显示 Nikon + Sony 占位）
- ❌ 品牌化 UI 文案（D8=A，已排除）

### 5.3 核心设计决策

| 决策点 | 选择 | 理由 |
|---|---|---|
| UI 位置 | Settings 页 "相机连接" 上方单独 section | 与 "相机 IP / 端口" 平行，逻辑连续 |
| 选择器样式 | 复刻 `ThemePickerRow`（圆点 + id） | 视觉一致 |
| 默认值 | 老用户 `experimentalNikon`，新用户也 `experimentalNikon` | 不破坏现状 |
| `cameraTransportMode` 字段已存在于 `CameraConnectionConfig` | 不需新增；`@Default(CameraTransportMode.experimentalNikon)` schema 兼容 | 字段 L26 已存在 |
| factory dispatch 路径 | 改 `CameraTransportFactory` 为 `abstract` + `DefaultCameraTransportFactory` 实现（mode-aware dispatch） | 与 §2.7 一致 |
| Transport 实例创建时机 | 维持现状：`connect()` 时才创建，`disconnect()` 时丢弃 | 单 session 不持有 transport，避免跨 session 状态污染 |

### 5.4 关键任务

| # | 任务 | 文件 | 估时 |
|---|---|---|---|
| 5d.0 | D6 决策（选择 UI 位置）确认 | — | — |
| 5d.1 | `CameraBrandPickerRow` widget | `lib/features/settings/widgets/camera_brand_picker_row.dart` | 1 天 |
| 5d.2 | `CameraConnectionConfig.cameraTransportMode` 字段已存在（`@Default experimentalNikon`），无需新增 | `lib/domain/camera_connection_config.dart` | 0 天 |
| 5d.3 | `PreferencesNotifier.setTransportMode(id)` 持久化（**`settings_view_model.dart:39` 已实现**） | `lib/features/settings/settings_view_model.dart` | 0 天 |
| 5d.4 | `CameraTransportFactory` 改成 abstract + `DefaultCameraTransportFactory` 实现（mode-aware dispatch） | `lib/protocol/camera_transport_factory.dart` | 1 天 |
| 5d.5 | `ConnectionNotifier.connect()` 已按 `state.transportMode` 调 `factory.makeTransport()`（**`connection_view_model.dart:78` 已实现**），**仅需更新调用签名加 config 参数** | `lib/features/connection_setup/connection_view_model.dart` | 0.5 天 |
| 5d.6 | 单测 + UI smoke | `test/features/settings/camera_brand_picker_test.dart` + smoke | 1 天 |
| 5d.7 | 文档同步 | 多文件 | 0.5 天 |
| **5d 总计** | | | **~4 天** |

### 5.5 验收标准

1. `dart analyze` 0 warnings
2. `flutter test` 通过现有基线 + 新增测
3. Settings 页可见 "相机品牌" section，Nikon 圆点选中
4. emulator 上手动改 Sony + 重启 app → 真机切 Sony 后能连

---

## 6. Phase 5e — 通用 PTP 基类（5b/5c 推进过程中做）

### 6.1 目标

当 5a/5b/5c 完成 ≥ 2 品牌后，把共通的 list/GetObjectInfo/GetObject 提取到 `PtpipStandardTransport` 基类，各品牌 transport 继承基类 + 仅覆写私有 opcode handler。

### 6.2 不在本期范围

- ❌ 跨品牌 cross-vendor 互操作（不同品牌本来不能互相连接）

### 6.3 核心设计决策

| 决策点 | 选择 | 理由 |
|---|---|---|
| 抽公共基类 | `PtpipStandardTransport extends CameraTransport implements PtpipSessionUser` | 把 `listAssets` / `getObjectInfo` / `getObject` 标准子集移到基类 |
| 私有 opcode handler | abstract method `_sendPrivateOpCode(...)` 留给品牌覆写 | 仅扩展点 |
| `_classifyObjectFormat` 整合 | 基类提供表 + 品牌覆写扩展点 | 跨品牌通用 |

### 6.4 关键任务

| # | 任务 | 估时 |
|---|---|---|
| 5e.0 | 分析 5a/5b/5c 三个 transport 公共代码 | 1 天 |
| 5e.1 | 抽 `PtpipStandardTransport` 基类 | 3 天 |
| 5e.2 | `ExperimentalNikonTransport` refactor 用基类 | 1 天 |
| 5e.3 | `ExperimentalSonyTransport` refactor 用基类 | 1 天 |
| 5e.4 | `ExperimentalCanonTransport` refactor 用基类 | 1 天 |
| 5e.5 | 验证测试兼容 (`flutter test` 全绿) | 1 天 |
| **5e 总计** | | **~8 天** |

### 6.5 验收标准

1. `dart analyze` 0 warnings
2. `flutter test` 全绿（基线不变，因重构不增测）
3. 4 个 transport 类行数总和减少 ≥ 30%

---

## 7. 总结

### 7.1 累计测试预估

| 阶段 | 测数 |
|---|---|
| Phase 4 已完成 | 385 |
| Phase 5a (Sony) | +12 |
| Phase 5b (Canon) | +13 |
| Phase 5c (Fujifilm) | +12 |
| Phase 5d (Brand Picker UI) | +5 |
| Phase 5e (Common base refactor) | +0 (不增测，回归覆盖) |
| **总计（Phase 5 完成时）** | **~427** |

### 7.2 时间轴

| 时间 | Phase | 完成度 |
|---|---|---|
| 2026-07-21 ~ 23 | Phase 1（协议层） | ✅ 100% |
| 2026-07-23 | Phase 2（UI 骨架） | ✅ 100% |
| 2026-07-24 ~ 25 | Phase 3（下载链路） | ✅ 100% |
| 2026-07-25 ~ 27 | Phase 4（5 主题 + B10 视觉对齐） | ✅ 100% |
| TBD | **Phase 5a (Sony) 启动**（D1~D10 拍板后） | ⏳ |
| TBD | Phase 5b (Canon) | 5a 验收通过 |
| TBD | Phase 5c (Fujifilm) | 5b 验收通过 |
| TBD | Phase 5d (Brand Picker UI) | 与 5a 并行 |
| TBD | Phase 5e (Common base) | 5b/5c 推进过程中 |

### 7.3 累计耗时预估

按单人顺序推进：

- Phase 5a: 16 天
- Phase 5b: 16 天
- Phase 5c: 18 天
- Phase 5e: 8 天
- Phase 5d: 5.5 天（与 5a 并行，串行不增加总时长）

**总耗时 ≈ 16 + 16 + 18 + 8 = 58 天 ≈ 12 周**（2 人并行可缩 50%）

### 7.4 关键里程碑

| 里程碑 | 标准 |
|---|---|
| M1 | Phase 5a 真机端到端跑通（Sony 1 款机） |
| M2 | Phase 5b 真机端到端跑通（Canon 1 款机） |
| M3 | Phase 5d Brand Picker UI 在 Settings 页可用 |
| M4 | Phase 5c 真机端到端跑通（Fujifilm 1 款机） |
| M5 | Phase 5e 重构完成，4 品牌基类一致 |
| M6 | v1.0 准备（文档/截图/上架材料） |

---

## 8. 已知风险与未决项

### 8.1 协议层风险

| 风险 | 触发条件 | 缓解 |
|---|---|---|
| Sony 私有 opcode 在不同固件表现不同 | 部分 A7 系列不兼容 | 真机验收 ≥ 主流 2 款固件 |
| Canon EDSDK 已停更多年 | 反编译协议不稳定 | CCAPI 调研 + 评估仅支持 EOS R 系列（较新固件） |
| Fujifilm 协议最封闭 | 实现周期 + 兼容性最差 | 不强求 100% 覆盖，列已知不支持型号 |
| `CameraAppError` sealed 工厂持续扩张 | 跨品牌错误码差异大 | 5e 重构时考虑 `BrandExtension` 模式（按品牌扩展 sealed） |

### 8.2 UI/UX 风险

| 风险 | 触发条件 | 缓解 |
|---|---|---|
| 品牌选择 UI 用户混淆 | 不知道自己在用哪个品牌 | Settings 页显示当前 mode + "上次连接 [Sony A7 III]" 信息 |
| 多品牌切换导致连接失败 | 用户误选 Sony 但相机是 Canon | 连接 3 次失败后弹提示"检测相机品牌"（D7=A 路由） |
| 5d 与 5a 同步推进时 mode 字段加进 `CameraConnectionConfig` | 老用户 JSON 兼容问题 | `@Default` 字段 fallback（schema 兼容原则） |

### 8.3 测试风险

| 风险 | 触发条件 | 缓解 |
|---|---|---|
| 多品牌 fake socket 维护成本高 | 每个品牌要维护一份 | 抽 `FakePtpipSocketBase` 让 3 个 fake 共享 scriptedResponses 机制（5e 顺手做） |
| 真机测试需用户配合 | 3 个品牌都需真机拍照/下载实测 | 提供明确测试 checklist + 远程协作模式 |

### 8.4 业务决策风险

| 风险 | 触发条件 | 缓解 |
|---|---|---|
| D1 中途变更 | "做了一半想换品牌" | 5a 选 Sony 已是最稳；若切换只损失 5a 投资（3 天调研） |
| D10=C 用户强烈要求 live view | D10=A 已锁 | v1.1 加，但 v1.0 不做 |

---

## 9. 启动会议 checklist（与用户拍板的顺序）

按顺序逐项讨论：

1. **D1 先做哪个品牌**（推荐 Sony）
2. **D2 目标相机型号范围**（推荐 3-5 款）
3. **D3 真机硬件**（有/买/仅 fake）
4. **D4 抽象粒度**（推荐 A 起步）
5. **D5 enum 扩展方式**（推荐 A enum）
6. **D6 品牌选择 UI 位置**（推荐 Settings）
7. **D7 协议失败处理**（推荐 B 报告 opcode）
8. **D8 UI 文案**（推荐 A 通用）
9. **D9 测试方式**（推荐 B gphoto2 基准 fake）
10. **D10 协议覆盖率**（推荐 A 列表 + 下载）

拍板后 → 创建 `docs/Phase5a实施计划.md`（第一品牌细化，类似本文 §2 但更具体） → 才进代码。

---

## 10. 不在 Phase 5 范围（明确切边）

| 不做 | 原因 |
|---|---|
| 实时取景 (Live View) | 视频流协议 + 跨端编码，复杂度极高（D10=A） |
| 云同步 (Canon CCAPI / Sony Cloud) | 隐私考量 + 网络复杂 |
| 品牌专属高级功能 (Sony Eye-AF / Canon DPAF / Fuji Film Simulation) | 单测覆盖不了，需真机 + 业务量大 |
| 视频下载（首先满足 RAW/JPEG） | MOV/MP4 文件大，吞吐测试需要更多协议层实测 |
| 协议自己造通用 `TransportFactory` 注册表 | Phase 5 量级不需要，保持硬编码 dispatch |

---

## 11. 文档同步清单（Phase 5 完成后同步）

| 文档 | 改动 | 触发 |
|---|---|---|
| `AGENTS.md` §12 | 加 Phase 5a/5b/5c/5d/5e 变更记录 | 每段完成 |
| `CLAUDE.md` §当前阶段 | Phase 5 行标 ✅ 完成 | 每段完成 |
| `README.md` §当前能力 | 加 "Phase 5: Sony/Canon/Fujifilm 支持" | 5a 完成 |
| `docs/产品需求.md` §F1 + §5 | 默认相机品牌 + UI icon 描述（如果 D8=B） | 5d 完成 |
| `docs/架构.md` §6.1 + §7 + §8 | Provider 拓扑加 `mode-based dispatch`；iOS 映射加 Sony/Canon/Fuji transport；演进方向标 Phase 5 完成 | 各段完成 |
| `docs/项目状态.md` §1 + §2 + §10 | 进度看板标 ✅；决策日志加 D1~D10 决议；变更记录 | 各段完成 |
| `docs/Viewfinder方案.md` §8 + §12 | 阶段表更新；下一步改 "Phase 6: i18n / 上架" | 全部完成 |

---

## 12. 提交规范

遵循 `AGENTS.md §8`：

- 中文 commit message，动词在前（实现 / 修复 / 重构 / 添加 / 删除 / 更新），≤ 50 字
- 一个 phase / 一个 bug 修完 / 一个模块落地 → 才 commit
- 不要"顺手 commit 一堆"

Phase 5 实际 commit 风格示例：

```
实现 Phase 5a Sony transport：ExperimentalSonyTransport + factory mode dispatch
添加 Sony-specific opcode 适配 + _classifyObjectFormat 扩展（ARW/JPEG/MP4）
Phase 5a 单测 + FakeSonyPtpipSocket scriptedResponses round-trip
真机端到端：Sony A7 III 连接 + 列列表 + 下载 ARW
```

---

## 13. 完成后（Phase 5 → v1.0）

Phase 5 完成后，本工程就有了：

- ✅ 4 个 CameraTransport 实现（Nikon / Sony / Canon / Fujifilm）
- ✅ 19+ Provider + 7 Notifier（保持不变）
- ✅ 品牌选择 UI（5d）
- ✅ 通用 PTP 基类（5e）
- ✅ ~427 测试全绿，`dart analyze` 0 warnings
- ✅ 真机端到端验证（Nikon / Sony / Canon / Fujifilm 各 1 款机）

**Phase 6/v1.0 发布准备**：

- i18n 国际化（中英双语，flutter_localizations + intl）
- App Store / Google Play 上架材料
- 隐私声明 / 应用截图 / 演示视频
- README 重写与营销文案
- 可选：iOS Live Activity 回滚
- 可选：macOS Catalyst / Windows 客户端（评估 ROI）

---

**这份文档 = Phase 5 的工作说明书（草稿，等 D1~D10 拍板后定稿）**。
