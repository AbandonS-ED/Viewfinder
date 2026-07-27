# Phase 5 规划 — 多品牌相机扩展

> **目标**：在 Viewfinder 现有架构上新增 Sony / Canon / Fujifilm 三个品牌的相机传输支持，复用所有 UI / 协议编排 / Service 层。
>
> **本文是规划文档，**不写代码**。Phase 5 启动前必须先回答完本文所有 **❓决策项**。

---

## 0. 当前状态

| 项 | 现状 |
|---|---|
| 品牌支持 | 仅 Nikon (`CameraTransportMode.experimentalNikon`) |
| 抽象层 | `CameraTransport` (`lib/protocol/camera_transport.dart`) abstract class 已设计为可扩展 |
| 工厂 | `CameraTransportFactory.makeTransport()` 当前**硬编码**返回 `ExperimentalNikonTransport` |
| 测试 fake | `FakeCameraTransport` 可模拟任意品牌 handle 解析，便于写真机端到端测试 |
| UI 入口 | Settings 页 `cameraTransportMode` 字段有持久化默认值，但 UI 未做品牌选择器 |
| Domain | `CameraTransportMode` enum 仅有 1 个值，需要扩 4 值 |
| 真实测试 | 仅 Nikon 单测（fake socket 层）+ emulator 上 Gallery/下载路径验证。真 Nikon 相机测试**未做**（无 Nikon 相机） |

---

## 1. Phase 5 拆分候选

按工作量 + 用户群覆盖度排：

| 拆分 | 内容 | 估时 (单人) | 推荐度 |
|---|---|---|---|
| **5a** | Sony (Sony Remote API + 部分 PTP) | 2-3 周 | ⭐⭐⭐ |
| **5b** | Canon (Canon PTP 扩展 + EOS Capture) | 2-3 周 | ⭐⭐ |
| **5c** | Fujifilm (Fujifilm 私有 PTP + X Webcam) | 2-3 周 | ⭐ |
| **5d** | 品牌选择 UI + 持久化 + 文档 | 1 周 | ⭐⭐⭐（与 5a 并行） |
| **5e** | 通用 PTP 抽象（如果可以提取） | 1-2 周 | ⭐（先看下能不能做） |

---

## 2. 品牌协议调研

### 2.1 Sony

- **官方**：Sony Camera Remote API（基于 HTTP/JSON）— SDK 在 Sony Developer World（需注册）
- **实际**：现代 Sony 相机（A7 III 起）支持 PTP/IP 协议子集，但私有 opcode 较多（`GetSonyObjectInfo` 等）
- **资源**：
  - gphoto2 源码的 `ptp.c` + `ptp2.c`（开源 Sony 私有 opcode 实现参考）
  - libgphoto2 文档 + reverse-engineered 协议表
- **难度**：⭐⭐（协议文档散落，但有开源参考）

### 2.2 Canon

- **官方**：Canon EDSDK（C 库，已停产）+ CCAPI（云端 API，复杂）
- **实际**：Canon EOS 相机走 PTP/IP 但私有 opcode 多（`GetCANONObjectInfo` 等）
- **资源**：
  - gphoto2 源码的 Canon backend
  - libptp2 / libusb 文档
- **难度**：⭐⭐⭐（协议反编译多，EDSDK 已停更）

### 2.3 Fujifilm

- **官方**：Fujifilm X Webcam SDK（仅 Mac/PC，PTP/IP 私有）
- **实际**：Fujifilm X 系列相机走 PTP/IP 但 opcode 完全不同
- **资源**：
  - gphoto2 Fujifilm backend
  - 第三方 reverse engineering 文档
- **难度**：⭐⭐⭐（私有协议最封闭）

---

## 3. 启动前必须解决 ❓决策项

### 3.1 资源 / 硬件

| # | 决策点 | 选项 |
|---|---|---|
| **D1** | 第一阶段先做哪个品牌？ | A. Sony / B. Canon / C. Fujifilm / D. 暂不开始 |
| **D2** | 目标相机型号范围？ | A. 单旗舰机型 + 简化协议 / B. 主流 3-5 款 / C. 全 PTP 标准子集 |
| **D3** | 真机测试硬件？ | A. 有对应相机可借 / B. 需要采购 / C. 仅协议层 fake + 等用户后续验 |

### 3.2 架构选择

| # | 决策点 | 选项 |
|---|---|---|
| **D4** | 抽象粒度？ | A. 维持 `CameraTransport` abstract，新加 `SonyCameraTransport extends CameraTransport` / B. 抽 `PtpipTransportBase` + 私有 opcode handler 注入 |
| **D5** | `CameraTransportMode` 扩展？ | A. 新加 `sonyRemoteApi` / `canonExperimental` / `fujiExperimental` 三枚举 / B. 做成可注册表（`Map<String, Factory>`） |
| **D6** | 品牌选择 UI 位置？ | A. Settings 页加 "相机品牌" section（与 主题 平行）/ B. 连接页 (初次连接时让用户选) / C. 自动探测（连接失败 3 次后弹选择） |
| **D7** | 协议失败处理？ | A. 重试 + 提示用户换相机 / B. 报告具体 opcode 失败让用户上报 |
| **D8** | UI 文案 / 图标？ | A. 通用 "Wi-Fi 连接相机" / B. 品牌化 (Sony 紫、Canon 红、Fuji 绿) |

### 3.3 测试 / 质量门

| # | 决策点 | 选项 |
|---|---|---|
| **D9** | 品牌测试是否需要真机？ | A. 必须真机 / B. gphoto2 输出作基准的 fake server / C. 用户社区贡献 |
| **D10** | 协议覆盖率目标？ | A. 仅列表 + 下载 / B. + 删除 / C. + 实时取景（live view，复杂度极高） |

---

## 4. 推荐启动路径（基于决策项）

### 推荐路径：**Sony → 品牌选择 UI → Canon → Fujifilm**

理由：
1. **Sony Remote API 公开文档**比 Canon/Fuji 多，优先降风险
2. **Sony PTP 子集**最接近 PTP 标准，5a 推进时可顺手把通用 PTP 抽出（5e）
3. UI 层并行做（5d），降低后期集成工作量
4. Canon / Fujifilm 顺序按用户群大小排

### 启动前置条件（必须满足）

```
✅ Mac (iOS 集成测试)
✅ Sony A7 III / A7 IV / A7C 等真机一台
✅ Sony Camera Remote API 协议文档（已注册 SDK）
✅ 拍板 D1-D10 决策项
```

---

## 5. Phase 5a (Sony) 任务估算

> 仅在 D1=A 且 D2-D10 决策完成后开始估算。

| # | 任务 | 估时 | 依赖 |
|---|---|---|---|
| 5a.0 | Sony 协议调研 + opcode 表（GetDeviceInfo/GetObjectHandles 等私有变体） | 3 天 | D1=A, 真机 |
| 5a.1 | `lib/protocol/experimental_sony_transport.dart` 实现（Sony-specific opcode + format code） | 4 天 | 5a.0 |
| 5a.2 | `CameraTransportMode.sonyExperimental` 枚举加 + factory route | 0.5 天 | 5a.1 |
| 5a.3 | `_classifyObjectFormat` Sony-specific (ARW/SonyRaw vs JPEG vs MP4) | 1 天 | 5a.1 |
| 5a.4 | Sony 单测 (FakePtpipSocket + Sony-specific scripted responses) | 3 天 | 5a.1 |
| 5a.5 | emulator 真机调通连接 + 列表 + 下载 | 2 天 | 5a.1 + Mac + 真机 |
| 5a.6 | Sony 私有错误码映射 (`CameraAppError.sonySpecific(...)`) | 1 天 | 5a.5 |
| 5a.7 | 文档同步 (`Phase5a实施计划.md` + README + 架构.md §6.1) | 0.5 天 | 5a.5 |
| **5a 总计** | | **~15 天** | |

---

## 6. Phase 5d (品牌选择 UI) 任务估算

> 与 5a 并行，依赖 D6 决策。

| # | 任务 | 估时 | 依赖 |
|---|---|---|---|
| 5d.0 | D6 决策（选择 UI 位置） | — | 用户拍板 |
| 5d.1 | `app_theme_picker_row` 参考，扩展为 `CameraBrandPickerRow` | 1 天 | 5d.0 |
| 5d.2 | `CameraConnectionConfig.cameraTransportMode` 字段持久化 | 0.5 天 | — |
| 5d.3 | `CameraTransportFactory.makeTransport()` 改成 mode-based dispatch | 1 天 | 5d.2 + 5a.2 |
| 5d.4 | 连接页加品牌选择器（或首次启动引导） | 1 天 | 5d.1 |
| 5d.5 | 单测 + UI smoke | 1 天 | 5d.4 |
| **5d 总计** | | **~4.5 天** | |

---

## 7. Phase 5e (通用 PTP 抽象) 任务估算

> 5a/5b/5c 完成 ≥ 2 个后回头做，目的是把共通的 list/GetObjectInfo/GetObject 提取到 `PtpipStandardTransport` 基类。

| # | 任务 | 估时 |
|---|---|---|
| 5e.0 | 把 `PtpipSession` 的标准部分抽公共基类 | 3 天 |
| 5e.1 | `ExperimentalNikonTransport` / `SonyCameraTransport` refactor 用基类 | 2 天 |
| 5e.2 | `CanonCameraTransport` 用基类重写 | 2 天 |
| 5e.3 | 单测验证兼容 | 1 天 |
| **5e 总计** | | **~8 天**（5b/5c 推进会变快） |

---

## 8. 不在 Phase 5 范围（明确切边）

| 不做 | 原因 |
|---|---|
| 实时取景 (Live View) | 视频流协议 + 跨端编码，复杂度极高 |
| 云同步 (Canon CCAPI / Sony Cloud) | 隐私考量 + 网络复杂 |
| 品牌专属高级功能 (Sony Eye-AF / Canon DPAF / Fuji Film Simulation) | 单测覆盖不了，需真机 + 业务量大 |
| 视频下载（首先满足 RAW/JPEG） | MOV/MP4 文件大，吞吐测试需要更多协议层实测 |
| 协议自己造通用 `TransportFactory` 注册表 | Phase 5 量级不需要，保持硬编码 dispatch |

---

## 9. 风险

| 风险 | 影响 | 缓解 |
|---|---|---|
| Sony 私有 opcode 在不同固件版本表现不同 | 部分相机不兼容 | 真机验收覆盖 ≥ 主流 2 款 |
| Canon EDSDK 已停更多年 | 反编译协议不可持续 | CCAPI 调研 + 评估是否仅支持 EOS R 系列（较新固件） |
| Fujifilm 协议最封闭 | 实现周期长 | 不强求 100% 覆盖，列已知不支持的型号 |
| 多品牌测试 fixture 维护成本 | 单测变慢 | 每个品牌的 fake server 单独文件，分目录组织 |
| 用户反馈"为什么只支持 Nikon"压力 | 影响项目口碑 | README 明确 roadmap（Phase 5 推进计划） |

---

## 10. 不开始 Phase 5 的备选路径

如果 D1 选 D（暂不开始）：

| 备选方向 | 工作量 | 价值 |
|---|---|---|
| **iOS 真机构建**（需 Mac） | 1 周 | 验证 §3 iOS 端代码（PhotoLibraryPlugin.swift 等）实际编译 |
| **i18n 国际化**（中文 ↔ 英文） | 1-2 周 | 拓展海外用户基础 |
| **App Store / Google Play 上架材料** | 1 周 | 准备 v1.0 发布 |
| **iOS Live Activity（需 Mac）** | 1-2 周 | 提升 iOS 用户进度体验 |
| **真机端到端验证（Nikon 1 台）** | 1 周 | Phase 3 + 4 关键路径实测；当前仅 emulator 验证 |
| **README 重写 + 截图 + 演示视频** | 1 周 | 准备 v1.0 营销 |

---

## 11. 决策会议指引

启动 Phase 5 前，与用户过一遍：

1. **D1 先做哪个品牌**？（推荐 Sony）
2. **D2 目标相机型号范围**？（推荐主流 3-5 款）
3. **D3 真机硬件**？（有就最理想，没有则推 §10 备选）
4. **D6 品牌选择 UI 位置**？（推荐 Settings 页）
5. **D10 协议覆盖率**？（推荐 A: 列表 + 下载）

拍板 → 创建 `docs/Phase5a实施计划.md`（类似 Phase4 风格） → 才进代码。

---

## 12. 关联文档

- **当前项目状态**：[`项目状态.md`](项目状态.md)
- **整体规划**：[`Viewfinder方案.md`](Viewfinder方案.md) §8 / §12
- **Phase 4 详情**：[`Phase4实施计划.md`](Phase4实施计划.md)（参考其结构 + 节奏）
