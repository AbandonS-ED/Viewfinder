# Nikon 真机联调 Checklist

> **目的**：Phase 4c 那 8 个 integration widget test 当前只是代码骨架（`test/integration/fake_nikon_server.dart` 抛 `UnimplementedError`），没在真机上跑过。这份 checklist 是**手动真机联调清单** —— 你按顺序跑，每跑一项打勾或记录问题，跑完我们就有具体的 bug 报告可以修。
>
> **适用机型**：任何支持 PTP/IP 的 Nikon（D5xxx 之后内置 Wi-Fi 的机型 + Z 系列全部）。D3400 等早期机型无 Wi-Fi，见 §0.1。
>
> **不适用**：本清单**不适用**于蓝牙/SnapBrideg 路径（那条路见 [`Bluetooth支持规划.md`](Bluetooth支持规划.md)）。

---

## 0. 准备阶段（10 分钟）

### 0.1 确认相机支持 Wi-Fi + PTP/IP

**操作**：
1. 打开相机 → 菜单 → 找「无线/Wireless/通信」相关项
2. 看相机支持哪种 Wi-Fi 模式：
   - **Infrastructure（基站模式）**：相机连入外部 Wi-Fi 路由器 → ❌ 当前 Viewfinder 不支持（仅支持相机自建热点）
   - **Access Point / Hotspot（热点模式）**：相机自建 Wi-Fi 热点，手机连入 → ✅ Viewfinder 设计目标
3. 打开 Wi-Fi 开关
4. 记下屏幕上显示的：
   - **SSID**（如 `Nikon_Z5_ABC123`）
   - **密码**（如 `nikonz5pass` 或简单数字）
   - **IP 地址**（默认 `192.168.1.1`，但有的机型是 `192.168.0.1`）
   - **Port**（PTP/IP 默认 15740，但部分机型可能不同）

**如相机无 Wi-Fi**：
- 2017 年以前的机型（D3xxx/D5xxx/D7xxx 部分）通常**没有内置 Wi-Fi** → 需配 WU-1a 适配器（已停产）
- 当前 Viewfinder 协议走标准 PTP/IP，WU-1a 用 Nikon 私有协议（不支持）
- 这种情况**用 D3400/D3300/D5500 之前机型无法联调**

### 0.2 准备 Android 手机

**操作**：
1. **关闭手机移动数据**（避免连接相机后还能上网）
2. 打开 **Wi-Fi**
3. 找到相机 SSID 并连接
4. 输入密码连接成功
5. **验证手机获取 IP**：
   - Android 设置 → Wi-Fi → 长按已连接的相机 SSID → 看 IP（应在 `192.168.1.x` 或 `192.168.0.x` 段）
6. **ping 相机**：
   - 用手机端调试工具（如 Termux），或电脑端用 `adb shell ping <相机IP>`
   - 应能 ping 通

### 0.3 安装 Viewfinder APK

**操作**：
1. 在 Windows 终端执行：
   ```powershell
   cd "D:\Nikon_connect\Viewfinder"
   $env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
   $env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
   & "D:\huanjing\Flutter\bin\flutter.bat" build apk --debug
   ```
2. 生成的 APK 在 `build/app/outputs/flutter-apk/app-debug.apk`
3. 传到手机（USB / 网盘 / `adb install` 都行）：
   ```powershell
   adb install -r build\app\outputs\flutter-apk\app-debug.apk
   ```
4. 启动 Viewfinder

---

## 1. 连接验证（Phase 4c 的 T3）

**对应代码**：`test/integration/03_fake_camera_connection_test.dart`

### ✅ 验证项

| # | 检查点 | 期望 | 实际 | 通过? |
|---|---|---|---|---|
| 1.1 | 打开 Viewfinder 默认进入「连接」页 | 显示「Viewfinder / 取景器 / 为 Nikon 而生」3 brand 轮播（每 3s 切换）| | ☐ |
| 1.2 | 检查「相机连接」section host/port 显示 | host=`192.168.1.1`（或你的相机实际 IP），port=`15740` | | ☐ |
| 1.3 | 修改 host（如果相机 IP 不同）→ 点「连接」| workflow state 切到 `connecting`，UI 显示加载动画 | | ☐ |
| 1.4 | 等待 1-3 秒 | workflow state 切到 `connected`，显示相机型号（如「Nikon Z5」）| | ☐ |
| 1.5 | 检查底部状态栏 | 显示「已连接」绿色状态 | | ☐ |
| 1.6 | 切到「相册」tab | 应显示相机中的真实照片缩略图（不是「暂无照片」）| | ☐ |

### 🐛 常见 Bug 记录位

| 现象 | 错误日志（adb logcat）| 截图 |
|---|---|---|
| 1.A 连接卡在 `connecting` 不动 | | |
| 1.B 连接超时后报「网络不通」| | |
| 1.C 连接成功但相机型号为空 | | |
| 1.D Gallery 显示「暂无照片」但相机有照片 | | |

**Bug 报告模板**（每发现一个问题就填一个）：
```markdown
### Bug N.1
- **现象**：[1.A / 1.B / 1.C / 1.D]
- **相机型号**：______
- **固件版本**：______（相机菜单 → 设定信息）
- **手机型号 + Android 版本**：______
- **完整错误日志**：（adb logcat | grep viewfinder 或 CameraAppError）
- **重现步骤**：______
- **预期 vs 实际**：______
```

---

## 2. 浏览验证（Phase 4c 的 T4 部分场景）

**对应代码**：`test/integration/04_download_flow_test.dart`

### ✅ 验证项

| # | 检查点 | 期望 | 实际 | 通过? |
|---|---|---|---|---|
| 2.1 | GalleryPage 默认显示 3 列网格 | 每行 3 张缩略图 | | ☐ |
| 2.2 | 切到 5 列（设置 → 网格密度）| 每行 5 张缩略图 | | ☐ |
| 2.3 | 滚动到列表底部 | 缩略图滚动流畅，无明显卡顿 | | ☐ |
| 2.4 | 长按一张照片 | 弹出全屏预览 + 选中模式开启 | | ☐ |
| 2.5 | 双击预览中照片 | 缩放 1x ↔ 2.5x 切换 | | ☐ |
| 2.6 | 单击 1x 状态预览 | 关闭预览 | | ☐ |
| 2.7 | 长按一张选中后，点其他几张 | 多选模式生效，底部出现选择条 | | ☐ |
| 2.8 | 点「全选」| 全部选中 | | ☐ |
| 2.9 | 点「清除选择」| 全部取消 | | ☐ |

### 🐛 常见 Bug 记录位

| 现象 | 错误日志 | 截图 |
|---|---|---|
| 2.A 缩略图加载很慢 / 一直显示骨架 | | |
| 2.B 列表只显示一半照片 | | |
| 2.C 长按不响应 | | |
| 2.D 双击缩放不切换 | | |
| 2.E GridDensity 切换不生效 | | |

---

## 3. 下载验证（Phase 4c 的 T4 核心）

**对应代码**：`test/integration/04_download_flow_test.dart`

### ✅ 验证项（先单文件）

| # | 检查点 | 期望 | 实际 | 通过? |
|---|---|---|---|---|
| 3.1 | 选 1 张 JPEG → 「下载选中」| 切到「下载」tab，队列显示 1 个 job 状态 running | | ☐ |
| 3.2 | 实时进度 | 进度条从 0% → 100%，文件名/项号/bytes/速率实时更新 | | ☐ |
| 3.3 | Android 通知中心 | 显示进度通知（带百分比）| | ☐ |
| 3.4 | 下载完成 | 状态变 `completed`，通知消失 | | ☐ |
| 3.5 | 检查手机相册 | 新照片出现在「Pictures/Viewfinder/」目录 + 系统相册 | | ☐ |
| 3.6 | EXIF 信息保留 | 在系统相册中点开 → 拍摄时间 / 相机型号 / 镜头正确 | | ☐ |

### ✅ 验证项（再批量）

| # | 检查点 | 期望 | 实际 | 通过? |
|---|---|---|---|---|
| 3.7 | 选 10+ 张混合 JPEG + RAW | JPEG 优先排序，RAW 后排 | | ☐ |
| 3.8 | 「下载选中」| 队列添加 10+ job，逐个下载 | | ☐ |
| 3.9 | 队列页面「暂停」| 状态变 `paused`，当前 job 停在中间 | | ☐ |
| 3.10 | 「继续」| 从暂停点继续，不重头开始 | | ☐ |
| 3.11 | 「取消单个」| 该 job 变 `cancelled`，其他继续 | | ☐ |
| 3.12 | 「取消全部」| 所有非 completed job 变 `cancelled` | | ☐ |
| 3.13 | 「重试」失败 job | 该 job 重新进入队列 | | ☐ |
| 3.14 | 「清除已完成」| completed job 从列表移除 | | ☐ |

### ✅ 验证项（吞吐诊断）

| # | 检查点 | 期望 | 实际 | 通过? |
|---|---|---|---|---|
| 3.15 | 下载页面底部「吞吐诊断」section | 显示 completed item 数 / total bytes / avg bytes per item | | ☐ |
| 3.16 | 完成一项后数据更新 | 数字实时刷新 | | ☐ |

### 🐛 常见 Bug 记录位

| 现象 | 错误日志 | 截图 |
|---|---|---|
| 3.A 下载卡 0% 不动 | | |
| 3.B 进度跳变（无平滑）| | |
| 3.C RAW 下载后系统相册不显示 | | |
| 3.D 暂停后继续不工作 | | |
| 3.E 重试后重复下载 | | |
| 3.F 通知不显示进度条 | | |
| 3.G EXIF 丢失 | | |

---

## 4. Wi-Fi 断线验证（Phase 4c 的 T5）

**对应代码**：`test/integration/05_wifi_disconnect_test.dart`

### ✅ 验证项

| # | 检查点 | 期望 | 实际 | 通过? |
|---|---|---|---|---|
| 4.1 | 正在下载时关掉手机 Wi-Fi（关热点/关相机）| 队列自动暂停，进度通知消失 | | ☐ |
| 4.2 | 重新连回相机 Wi-Fi | 队列自动恢复下载（不是从 0 开始，是断点续传）| | ☐ |
| 4.3 | 切到「连接」页 | workflow state 应能恢复到 `connected` | | ☐ |
| 4.4 | 反复断/连 3 次 | 每次都正确响应，无泄漏 timer / 内存 | | ☐ |

### 🐛 常见 Bug 记录位

| 现象 | 错误日志 | 截图 |
|---|---|---|
| 4.A 断线后下载不暂停继续空转 | | |
| 4.B 重连后队列不恢复 | | |
| 4.C 重连后从 0 重头下载 | | |
| 4.D 反复断/连后 timer 泄漏（logcat 警告）| | |

---

## 5. 通知 + 后台验证（Phase 4c 的 T7 + T8）

**对应代码**：`test/integration/07_notification_test.dart` + `08_background_runner_test.dart`

### ✅ 验证项

| # | 检查点 | 期望 | 实际 | 通过? |
|---|---|---|---|---|
| 5.1 | 下载中切到后台 | 通知栏持续显示进度 | | ☐ |
| 5.2 | 锁屏 | 锁屏界面有进度通知 | | ☐ |
| 5.3 | 锁屏点击通知 | 唤醒 app 并跳到下载页 | | ☐ |
| 5.4 | 后台期间下载完成 | 通知变「下载完成」系统通知 | | ☐ |

### 🐛 常见 Bug 记录位

| 现象 | 错误日志 | 截图 |
|---|---|---|
| 5.A 后台后下载被系统杀死 | | |
| 5.B 锁屏通知不显示 | | |
| 5.C 点击通知不能唤回 app | | |
| 5.D 完成通知不出现 | | |

---

## 6. 设置 + 持久化验证（Phase 4c 的 T2）

**对应代码**：`test/integration/02_theme_persistence_test.dart`

### ✅ 验证项

| # | 检查点 | 期望 | 实际 | 通过? |
|---|---|---|---|---|
| 6.1 | 设置 → host 改 `192.168.0.1`，port 改 `15740`，返回 | 值已保存 | | ☐ |
| 6.2 | 设置 → 外观 → 切「onyx」主题 | 立即变黑底 | | ☐ |
| 6.3 | 设置 → JPEG 优先开关 | 切到 on / off | | ☐ |
| 6.4 | 设置 → 自动入相册开关 | 切到 on / off | | ☐ |
| 6.5 | **完全杀掉 app**（最近任务上滑删除），重新打开 | 所有设置保留 | | ☐ |
| 6.6 | 卸载重装 app | 设置恢复默认（合理） | | ☐ |

### 🐛 常见 Bug 记录位

| 现象 | 错误日志 | 截图 |
|---|---|---|
| 6.A 杀进程后设置丢失 | | |
| 6.B 主题切换不立即生效 | | |
| 6.C 开关状态错位（on/off 颠倒）| | |

---

## 7. 提交 Bug 报告（结束阶段）

跑完上面所有 checklist 后，把 Bug 报告整理到一个统一格式：

```markdown
# Nikon 真机联调报告 - YYYY-MM-DD

## 相机信息
- 型号：Nikon ______
- 固件版本：______
- 镜头（如适用）：______

## 手机信息
- 型号：______
- Android 版本：______
- Viewfinder APK 版本：______（git commit hash）

## Checklist 完成度
- [x] §0 准备：完成
- [x] §1 连接：完成
- [ ] §2 浏览：跳过（没时间）
- [x] §3 下载：部分完成（10 项中完成 8 项）
- ...

## 发现的 Bug
1. Bug 1.1 - 连接卡在 connecting - 详见下方
2. Bug 3.A - 下载卡 0%
3. ...

## 性能数据（可选）
- JPEG 10MB 下载耗时：______ 秒（理论 5 秒，实际 ______ 秒）
- RAW 30MB 下载耗时：______ 秒
- 缩略图列表加载耗时：______ 秒（200 张）

## 体验感受
- 连接稳定性：好 / 一般 / 差
- UI 流畅度：好 / 一般 / 差
- 整体可用性：好 / 一般 / 差
```

---

## 8. 下一步动作

按 bug 数量决定：

- **0 bug**：完美，提交 `验证：Nikon 真机联调通过 13/13` → 可推 Phase 6 (i18n / 上架)
- **1-3 bug**：典型 bug，提交每个 fix → 一周内可全清
- **4-10 bug**：Phase 4 没真机验证过的副作用，需要专门一轮 "Phase 5-Nikon 稳定性" 子计划
- **> 10 bug**：说明协议层有系统性 bug，需要回 Phase 1 协议层重审

---

## 附录 A：adb logcat 抓取命令

```powershell
# 启动实时日志，过滤 Viewfinder 标签
adb logcat -v time | Select-String "viewfinder|CameraAppError|PTPIP|FlutterEngine"

# 抓取最近 1000 行存文件（适合长场景复现）
adb logcat -d -v time > C:\temp\viewfinder_log.txt

# 过滤 Flutter print
adb logcat -d | Select-String "flutter"
```

## 附录 B：快速重置 app 数据（保留 APK）

```powershell
# 清除 SharedPreferences（重置所有设置回默认）
adb shell pm clear com.yaoyihan.viewfinder
```

## 附录 C：iOS 端真机联调

iOS 端需要 Mac + Xcode 16+，当前 Windows 环境无法做。
等拿到 Mac 后，按相同的 checklist 跑一遍即可（流程 100% 一致，只是工具换 Xcode）。