# PTP 协议标准性发现 — 原 iOS Nikon Transport 实现路径研究

> **作者**：AI 助手（基于实代码审计）
> **日期**：2026-07-27
> **目的**：留路标给「未来的自己/AI」，避免 Phase 5 重启时重做调研
> **重要度**：🔴 **关键发现** —— 可大幅缩短 Phase 5 多品牌实施工作量

---

## 0. 一句话结论

**原 iOS 项目 `NikonConnectIOS` 的 Nikon transport 完全跑标准 CIPA PTP/IP v1.1 协议，没有用任何 Nikon 私有 opcode**。

唯一适配 Nikon 的代码是 `ExperimentalNikonTransport.swift` 里的 `_classifyObjectFormat` —— 把 PTP 标准定义的 `objectFormatCode`（`0x3000` RAW / `0x3801` JPEG EXIF / `0x3808` JFIF / `0x300D` MOV / `0xB200` HEIF 等）映射成 iOS 的 `PhotoAssetKind`。

**推论**：Sony / Canon / Fujifilm 现代相机大概率也实现同一套 CIPA PTP/IP v1.1 标准，差异**只在格式码翻译**，不在协议本身。

---

## 1. 原 iOS 项目文件清单（PTP 相关）

| 文件 | 行数 | 角色 |
|---|---|---|
| `Services/PTPIPPrimitives.swift` | 380 | 包类型 / 数据相位 / opcode / response code / 4 个 freezed struct |
| `Services/PTPIPTCPConnection.swift` | 167 | 单 TCP socket 包装（send / receive / 心跳 / 重连）|
| `Services/PTPIPSession.swift` | 219 | 会话主类（持有 2 个 TCP 连接 + initiatorGUID）|
| `Services/PTPIPSession+Lifecycle.swift` | 513 | Init / OpenSession / CloseSession / GetDeviceInfo |
| `Services/PTPIPSession+AssetTraversal.swift` | 685 | GetObjectHandles / GetObjectInfo / 格式码翻译 |
| `Services/PTPIPSession+Transfers.swift` | 410 | GetObject / GetThumb / GetPartialObject / 流式下载 |
| `Services/CameraTransport.swift` | 68 | 品牌抽象接口（abstract protocol）|
| `Services/ExperimentalNikonTransport.swift` | 175 | **Nikon 唯一实现**：错误映射 + 格式码翻译 + DownloadTransferProgress 进度回调 |
| `Services/CameraTransportFactory.swift` | 7 | 工厂函数（hardcoded 返回 `ExperimentalNikonTransport`）|
| **合计** | **~2624 行** | 整个协议栈 |

---

## 2. 用到的 opcode 全部清单（无任何 Nikon 私有）

来自 `PTPIPPrimitives.swift` 的 `PTPOperationCode` enum：

| opcode | 名称 | 用途 | 是不是 Nikon 私有 |
|---|---|---|---|
| `0x1001` | `getDeviceInfo` | 拿 cameraName / model / 操作支持 | ❌ 标准 |
| `0x1002` | `openSession` | 打开会话 | ❌ 标准 |
| `0x1003` | `closeSession` | 关闭会话 | ❌ 标准 |
| `0x1004` | `getStorageIDs` | 列存储 ID | ❌ 标准 |
| `0x1005` | `getStorageInfo` | 拿存储详情 | ❌ 标准 |
| `0x1006` | `getNumObjects` | 对象总数 | ❌ 标准 |
| `0x1007` | `getObjectHandles` | 列对象句柄 | ❌ 标准 |
| `0x1008` | `getObjectInfo` | 拿对象元信息（含格式码）| ❌ 标准 |
| `0x1009` | `getObject` | 下载完整文件 | ❌ 标准 |
| `0x100A` | `getThumb` | 拿缩略图（无则抛 `noThumbnailPresent`）| ❌ 标准 |
| `0x101B` | `getPartialObject` | 分块下载 | ❌ 标准 |
| `0x9434` | `getObjectsMetaData` | 批量拿元数据（**⚠️ 这是 Nikon 私有扩展**）| ⚠️ **Nikon 私有** |

**结论**：13 个 opcode 里 12 个是 CIPA PTP v1.1 标准，**只有 `0x9434` 一个是 Nikon 私有**（`getObjectsMetaData`，且代码里**实际没调用**，只是 enum 写全了）。

---

## 3. 用到的 objectFormatCode 全部清单（标准 PTP 定义）

来自 `PTPIPSession+AssetTraversal.swift`：

| 格式码 | 含义 | 复用情况 |
|---|---|---|
| `0x3000` | RAW（标准定义）| 通用 RAW 通用 |
| `0x3001` | 关联对象 / TIFF-EP / DNG 之类 | |
| `0x300A` | AVI 视频 | |
| `0x300B` | MPEG 视频 | |
| `0x300D` | MOV 视频（QuickTime） | |
| `0x3801` | JPEG EXIF | |
| `0x3802` | TIFF-EP | |
| `0x3808` | JFIF（基础 JPEG） | |
| `0x380B` | PNG | |
| `0x380D` | | |
| `0x3810` | | |
| `0x3811` | | |
| `0xB200` | HEIF | |
| `0xB97E` | 厂商 MPEG（**兼容兜底**）| 兜底 |
| **`0xFFFF_FFFF`** | allStorageIdentifier / allAssociationHandle | 枚举全部时用 |

**全部都是 CIPA PTP 标准定义的格式码**，没有 Nikon 私有格式码。

iOS 端 `_classifyObjectFormat` 把这些格式码翻译成 iOS `PhotoAssetKind`（raw / jpeg / png / movie 4 个枚举值）。

---

## 4. 双 TCP 连接架构（标准 PTP/IP 特性）

`PTPIPSession` 持有 **2 条独立 TCP 长连接**：

```
┌──────────────────────────────────────────────┐
│             PTPIPSession                      │
│  ┌─────────────────┐  ┌─────────────────┐   │
│  │ commandConnection│  │ eventConnection  │   │
│  │  (PTPIPTCPConn) │  │  (PTPIPTCPConn) │   │
│  │  → 192.168.1.1  │  │  → 192.168.1.1  │   │
│  │     :15740      │  │     :15740      │   │
│  └─────────────────┘  └─────────────────┘   │
│           ↓                       ↓          │
│    InitCommandRequest        InitEventRequest│
│         (0x1)                      (0x3)     │
│                                              │
│  • command 通道发 OperationRequest           │
│  • event 通道每 30s 发 ProbeRequest 保活      │
│  • data phase 在 command 通道上回流           │
└──────────────────────────────────────────────┘
```

这是 CIPA PTP/IP v1.1 spec 的标准要求（双通道互不干扰）。

---

## 5. Sony / Canon / Fujifilm 的 Phase 5 工作量修正

### 原计划估算（错误）

`docs/Phase5实施计划.md` 估算 **12 周**（3-4 周/品牌 × 3 品牌 + 8 周 5e 重构），基于假设"每个品牌需要反向工程私有协议"。

### 修正后估算（基于本发现）

| 任务 | 原估算 | 修正估算 | 差距原因 |
|---|---|---|---|
| 5a.0 协议调研 | 3 天 | **0.5-1 天** | 复用标准 PTP/IP，只需查厂商的格式码（Sony ARW、Canon CR3、Fuji RAF 在 PTP 标准的格式码）|
| 5a.1 主类 | 4 天 | **1-2 天** | 继承 PtpipSession + 覆写 _classifyObjectFormat |
| 5a.5 单测 | 3 天 | **1-2 天** | 复用 FakePtpipSocket 加新模板 |
| **5a 单品牌总计** | **16 天** | **~5-7 天** | **节省 ~60%** |
| **5a/5b/5c 三品牌** | **50 天** | **~15-21 天** | |
| 5d BrandPickerUI | 5 天 | 5 天 | 不变 |
| 5e 抽基类 | 8 天 | 8 天 | 不变 |
| **总计** | **12 周** | **~5-6 周** | **节省 50%** |

### 注意：仍有硬阻塞

节省的是**协议调研和实现时间**，但仍有 3 个不能省的硬阻塞：
1. ⚠️ **真机**：每个品牌至少 1 台真机（A7 III / EOS R6 / X-T5 任一）
2. ⚠️ **Mac**：iOS 编译仍需 macOS（Android emulator 部分可绕过）
3. ⚠️ **D1-D10 决策**：仍需用户拍板

---

## 6. Phase 5 重启时的验证清单

启动时用这个 checklist 快速核对（不需要重做调研）：

- [ ] 目标品牌的官方文档搜「PTP object format code + 型号」找格式码表
- [ ] 真机连电脑，跑一次 `0x1001 getDeviceInfo`，确认 device info 返回 `operationsSupported` 包含上面 13 个 opcode
- [ ] 跑 `0x1007 getObjectHandles` 列对象，`0x1008 getObjectInfo` 拿格式码，匹配厂商格式码表
- [ ] 跑 `0x1009 getObject` 下载一张 RAW + 一张 JPEG 验证

如果以上都通过，**直接复用现有 `lib/protocol/primitives/` `transport/` `session/` 整套实现**，只新增一份 `lib/protocol/experimental_xxx_transport.dart` ~200 行 + `CameraTransportMode` enum 加 1 值。

---

## 7. 与 Flutter 现状的对应

iOS Swift 项目的 PTP/IP 实现已经按 Phase 1 完整翻成 Dart，结构一致：

| iOS 文件 | Flutter 对位 | 状态 |
|---|---|---|
| `PTPIPPrimitives.swift` | `lib/protocol/primitives/*.dart` (4 文件) | ✅ |
| `PTPIPTCPConnection.swift` | `lib/protocol/transport/ptpip_socket_io.dart` | ✅ |
| `PTPIPSession.swift` + 3 extensions | `lib/protocol/session/ptpip_session.dart`（合并单类）| ✅ |
| `ExperimentalNikonTransport.swift` | `lib/protocol/experimental_nikon_transport.dart` | ✅ |
| `CameraTransport.swift` | `lib/protocol/camera_transport.dart`（abstract class）| ✅ |
| `CameraTransportFactory.swift` | `lib/protocol/camera_transport_factory.dart` (6 行) | ✅ |

**Phase 5 新增品牌只需**：在 `lib/protocol/` 加 `experimental_xxx_transport.dart` + 扩 `CameraTransportMode` enum + 改 factory dispatch（D5=A 路线）。

---

## 8. 参考文献

- CIPA DC-005-2005 「Picture Transfer Protocol over TCP/IP」（iOS 项目有 `defaultFriendlyName = "NikonConnectIOS"` 等纯标准实现痕迹）
- libgphoto2 项目的 Sony backend：`https://github.com/gphoto/libgphoto2/tree/master/camlibs/ptp2`
- 现有 PTP 设备格式码公开汇总：`https://www.exif.org/`

