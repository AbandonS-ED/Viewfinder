# Bluetooth 支持规划（SnapBridge BLE）

> **目的**：评估"蓝牙支持"作为未来 Phase 的工作量、风险、可行性。
> **当前状态**：❌ 不做（用户"以后需要"，未拍板）。
> **触发条件**：用户拿到有 SnapBridge 的 Nikon（D5600/Z 系列等）真机后再启动调研。

---

## 0. 一句话

**蓝牙 ≠ PTP/IP**。蓝牙通道（Nikon SnapBridge）只传输**缩略图 + GPS 元数据 + 拍摄控制**，**不能下载 RAW**。Viewfinder 的核心价值是"批量下载 RAW/JPEG"，蓝牙不能替代 Wi-Fi，只能作为**辅助通道**（自动接收相机回传的缩略图做离线预览）。

---

## 1. 蓝牙通道的真实能力

### 1.1 Nikon SnapBridge 的设计目的

Nikon SnapBridge 是 Nikon 2017 年后引入的低功耗连接方案，**目的是替代旧版 WMU (Wireless Mobile Utility) 的部分场景**。它的能力边界：

| 操作 | SnapBridge BLE | Wi-Fi PTP/IP（现状）|
|---|---|---|
| 缩略图同步（2MP JPEG）| ✅ 自动推送 | ✅ 主动拉取 |
| GPS 元数据写入照片 | ✅ 自动 | ❌ |
| 远程拍摄控制 | ✅（低延迟）| ❌ |
| RAW 文件传输 | ❌ | ✅ |
| 全尺寸 JPEG 传输 | ❌（仅 2MP 缩略图）| ✅ |
| 批量下载 | ❌ | ✅ |
| 大文件传输 | ❌（速度太慢）| ✅ |
| 浏览所有照片 | ❌（仅拍摄后推送的新照片）| ✅ |

### 1.2 速度对比

| 通道 | 理论速度 | 实际速度 | 适用 |
|---|---|---|---|
| **Wi-Fi 802.11ac** | 100+ MB/s | 20-40 MB/s | RAW 批量下载 |
| **Wi-Fi 802.11n** | 50 MB/s | 10-20 MB/s | JPEG 批量下载 |
| **Bluetooth 5.0 LE** | 2 MB/s | 几十~200 KB/s | 缩略图、遥控、GPS |
| **Bluetooth 4.x LE** | 1 MB/s | 几十 KB/s | 缩略图、GPS |

蓝牙的几十 KB/s **连 1 张 2MB JPEG 都传不完**，更别说 RAW。

### 1.3 关键结论

**蓝牙不是 Wi-Fi 的替代品，是它的补充**。两个通道的角色：

```
Wi-Fi PTP/IP     →  "下载" 通道（用户主动发起，传输大文件）
Bluetooth BLE    →  "同步" 通道（相机自动推送，传输缩略图+GPS+遥控）
```

Viewfinder 当前**只有 Wi-Fi**。要加蓝牙 = 加一条**辅助同步通道**，**不替代**下载。

---

## 2. 协议调研（前置，必做）

> 这部分**当前不做**，等真机到位再启动。

### 2.1 调研目标

1. **Nikon SnapBridge BLE 协议逆向**：Nikon 不公开 BLE 协议 spec，必须通过抓包逆向
2. **哪些 Nikon 机型支持**：D5600 / D7500 / Z6 / Z7 / Z50 等（D3400 ❌ 无蓝牙）
3. **配对流程**：首次需在相机菜单配对，BLE GATT service UUID 是什么
4. **缩略图推送协议**：相机主动 notify 的 payload 格式
5. **GPS / EXIF 注入**：Nikon 私有协议

### 2.2 调研产物（目标文档）

如果启动 Phase，写 `docs/SnapBridge协议调研.md`，包含：
- BLE GATT service / characteristic UUID 清单
- 配对 / 认证流程
- 缩略图推送 payload 格式（SNBR / NSP 协议族）
- GPS / EXIF 注入协议
- 已知 incompatible 固件版本

### 2.3 调研来源

| 来源 | 内容 | 备注 |
|---|---|---|
| Wireshark BLE 抓包 | 实际通讯数据 | 需要支持 BLE 的 Android 手机 + nRF Connect |
| Nikon SnapBridge APK 反编译 | Java 层逻辑 | Android APK 在 Play Store 可下载 |
| `gattacker` / `gatttool` | 模拟 BLE 设备 | Linux 工具，Windows 不直接支持 |
| `bleshark` / `bleak` | BLE 协议分析 | Python 工具 |
| 现有第三方 Nikon SnapBridge 开源实现 | 寻找社区已有的逆向成果 | GitHub / GitLab 搜索 |
| 公开论文 / 技术博客 | 偶尔有人逆向过 | Google Scholar |

---

## 3. 工作量估算

按"加一条辅助 BLE 同步通道"目标估算（**不含协议逆向时间**）：

| 任务 | 工作量 | 估时 |
|---|---|---|
| **3.1 BLE 协议调研 + 文档** | 调研本身 | **5-10 天**（高风险：协议可能反人类）|
| **3.2 添加蓝牙权限** | `BLUETOOTH_SCAN` / `BLUETOOTH_CONNECT` / iOS `NSBluetoothAlwaysUsageDescription` | 0.5 天 |
| **3.3 配对流程 UI** | 首次启动引导用户去相机菜单触发配对 | 1-2 天 |
| **3.4 BLE transport 层** | `lib/protocol/snapbridge_transport.dart` + abstract | 5-8 天 |
| **3.5 BLE fake + 单测** | mock BLE 行为 + scripted payloads | 3-5 天 |
| **3.6 缩略图接收 → Gallery 缓存** | 收到缩略图自动存入 cache → Gallery 展示 | 2-3 天 |
| **3.7 GPS 注入** | 把蓝牙收到的 GPS 数据合并进 PhotoAsset | 1-2 天 |
| **3.8 iOS 端 BLE** | iOS BLE API 与 Android 不同，需另写 | 3-5 天 |
| **3.9 真机端到端** | 至少 1 台带蓝牙的 Nikon 真机 | 2-3 天 |
| **3.10 文档同步** | CLAUDE.md / README / AGENTS changelog | 0.5 天 |
| **总计** | | **~25-40 天**（约 5-8 周单顺序）|

**关键风险**：
1. **协议逆向失败**：SnapBridge 协议可能加密 / 签名 / 反调试，导致投入打水漂
2. **iOS 兼容**：iOS BLE 限制更严（Background mode / Core Bluetooth 行为差异）
3. **用户预期管理**：用户可能误以为蓝牙能下载 RAW，要提前明确说明

---

## 4. 启动 Phase 的 5 个前置条件（必须全满足）

按 AGENTS.md §2「❓ 拿不准时：停下来问，不要自己拍板」原则，**蓝牙 Phase 不能在没满足以下条件时启动**：

1. **真机**：至少 1 台支持 SnapBridge 的 Nikon（D5600/D7500/Z6/Z7/Z50/Z5/Z6II/Z7II/Z8/Z9/D850/D780 等）
2. **Mac**：iOS BLE 编译需要 macOS + Xcode 16+
3. **用户拍板 D1-D10 决策**：
   - D-BT-1: 蓝牙是作为"Wi-Fi 的补充"还是"完全替代 Wi-Fi"？**当前推荐：补充**
   - D-BT-2: 蓝牙支持哪些功能？缩略图同步？GPS？遥控？还是全部？**当前推荐：缩略图 + GPS**
   - D-BT-3: iOS 蓝牙开发环境什么时候到位？
4. **协议调研产出**：上面 §2.2 的 `SnapBridge协议调研.md` 完成
5. **风险预案**：如逆向失败，是否有 Plan B（如 Nikon 提供正式 SDK / 弃用蓝牙功能）？

---

## 5. Phase 拆分建议

如果启动，按工作量拆分：

| 子 Phase | 内容 | 估时 | 依赖 |
|---|---|---|---|
| **BT-a** | 协议调研 + 抓包 + 文档 | 5-10 天 | 真机 + 抓包工具 |
| **BT-b** | BLE 配对 + GATT 服务抽象 | 5-8 天 | BT-a 完成 |
| **BT-c** | 缩略图接收 + Gallery 集成 | 5-7 天 | BT-b 完成 |
| **BT-d** | GPS 注入 + EXIF 合并 | 2-3 天 | BT-c 完成 |
| **BT-e** | iOS 端 BLE 适配 | 3-5 天 | BT-d 完成 + Mac |
| **BT-f** | 真机端到端 + 文档同步 | 2-3 天 | BT-e 完成 |
| **总计** | | **~25-40 天** | |

**注**：与 Phase 5 (多品牌) 并行不可行 —— 都需 Mac + 真机，资源冲突。**建议先后顺序**：BT-x 排 Phase 5 之后。

---

## 6. 不在蓝牙 Phase 范围（明确切边）

| 不做 | 原因 |
|---|---|
| 用蓝牙下载 RAW | BLE 速度不够，技术上不可行 |
| 蓝牙远程快门控制 | 不是 Viewfinder 核心功能 |
| SnapBridge 完整逆向 | 工作量过大，ROI 低（用户主要做 Nikon，缩略图同步就够了）|
| 实时取景（Live View over BLE）| BLE 带宽不够；Wi-Fi 也不做（Phase 5 §10 已排除）|

---

## 7. 建议的决策路径

```
                ┌────────────────────────┐
                │  你想要 Bluetooth 支持？   │
                └───────────┬────────────┘
                            │
                  ┌─────────┴─────────┐
                  │                   │
            ┌─────▼─────┐      ┌──────▼──────┐
            │  没真机/没Mac │      │ 有真机+有Mac │
            └─────┬─────┘      └──────┬──────┘
                  │                   │
            暂不启动             启动 BT-a 协议调研
            Phase 6 (i18n/        (5-10 天)
            上架) 优先                 │
                                  BT-b/c/d/e/f 按序推进
```

**当下建议**：先做 Phase 6（i18n / 上架 / Nikon Wi-Fi 稳定性），蓝牙 Phase 排到用户明确表态"需要"且硬件到位后启动。

---

## 8. 关联文档

- [`Ptp协议标准性发现.md`](Ptp协议标准性发现.md) — 当前 Wi-Fi 路径的技术基础
- [`Nikon真机联调checklist.md`](Nikon真机联调checklist.md) — **当下**优先级最高的行动
- [`Phase5实施计划.md`](Phase5实施计划.md) — 多品牌 Phase 5（与蓝牙 Phase 是不同路径，互不冲突）

---

## 9. 变更记录

| 日期 | 变更 |
|---|---|
| 2026-07-27 | 初版：基于用户"以后需要蓝牙"发言 + 当前 Nikon PTP/IP 架构，列出调研路径、工作量、决策前置、Phase 拆分 |