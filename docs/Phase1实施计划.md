# Phase 1 协议层 — 实施计划（Handoff 文档）

> **给执行 AI 的说明**：这份文档假设你已经读过 `D:\桌面\Nikon_connect\Viewfinder\docs\` 下的所有 MD 文件。**没读过就别开始**——会做错方向。
>
> 这份文档列出 Phase 1 的所有任务、文件、验收标准。**严格按顺序执行**，每个任务完成后用 `dart analyze` 验证再进入下一个。

---

## 0. 上下文必读（5 分钟读完）

### 0.1 项目背景（一句话）

`Viewfinder` 是 Flutter app，通过 Wi-Fi 连接 Nikon 相机（默认 `192.168.1.1:15740`），用 CIPA PTP/IP 协议批量下载照片。Phase 0 完成（24 个 Domain 类型已就位、dart analyze 干净），Phase 1 实现 PTP/IP 协议层。

### 0.2 必读文档清单

按顺序读：

1. `D:\桌面\Nikon_connect\Viewfinder\AGENTS.md` — AI 工作守则（必读）
2. `D:\桌面\Nikon_connect\Viewfinder\docs\产品需求.md` — 产品需求（看 §3 F1/F2/F3 验收标准）
3. `D:\桌面\Nikon_connect\Viewfinder\docs\架构.md` — 架构（**必看 §4 数据模型 + §5 协议层设计要点**）
4. `D:\桌面\Nikon_connect\Viewfinder\docs\Viewfinder方案.md` — 实施方案（**必看 §8 Phase 1 + §11 与 iOS 映射**）
5. `D:\桌面\Nikon_connect\Viewfinder\docs\项目状态.md` — 当前状态（Phase 1 起点 §5.2）

### 0.3 iOS 源码（Phase 1 参考）

主要翻译源，**严格按这些文件 1:1 翻译**：

- `D:\桌面\Nikon_connect\Services\PTPIPPrimitives.swift` (380 行) — 命令/响应编解码
- `D:\桌面\Nikon_connect\Services\PTPIPTCPConnection.swift` (167 行) — 长连接 + 心跳 + 重连
- `D:\桌面\Nikon_connect\Services\PTPIPSession.swift` (219 行) — 会话主入口
- `D:\桌面\Nikon_connect\Services\PTPIPSession+Lifecycle.swift` — OpenSession / CloseSession
- `D:\桌面\Nikon_connect\Services\PTPIPSession+AssetTraversal.swift` — GetObjectHandles / GetObjectInfo
- `D:\桌面\Nikon_connect\Services\PTPIPSession+Transfers.swift` — GetObject / GetThumb
- `D:\桌面\Nikon_connect\Services\ExperimentalNikonTransport.swift` (175 行) — Nikon opcode 包装
- `D:\桌面\Nikon_connect\Services\CameraTransport.swift` (68 行) — 品牌抽象接口
- `D:\桌面\Nikon_connect\Services\CameraTransportFactory.swift` (7 行) — 工厂
- `D:\桌面\Nikon_connect\Tests\PTPIPSessionAssetTraversalTests.swift` (259 行) — 测试模式参考

---

## 1. 环境验证（开始前必跑）

按顺序执行，每条都要看到 ✓ 才能开始 Phase 1：

### 1.1 Flutter + dart analyze

```bash
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
cd "D:\桌面\Nikon_connect\Viewfinder"
flutter doctor
```

预期：所有 ✓ 通过（除了 Windows 上的 Xcode/iOS 工具链——这是正常的）

### 1.2 域模型保持干净

```bash
cd "D:\桌面\Nikon_connect\Viewfinder"
dart analyze
```

预期输出最后一行：`No issues found!`

如果报错，**别继续**，先修。

### 1.3 Git 配置验证

```bash
git -C "D:\桌面\Nikon_connect\Viewfinder" log --oneline | Select-Object -First 5
git -C "D:\桌面\Nikon_connect\Viewfinder" status
```

预期：HEAD 在 `26a6ace` 或更新；无未提交改动。

### 1.4 当前 git remote

```
origin = https://github.com/AbandonS-ED/Viewfinder.git
```

**所有 commit 必须 push 到这个 remote。**

---

## 2. Phase 1 总体目标

按 `Viewfinder方案.md §8 Phase 1`：

1. `lib/protocol/primitives/` 全部编解码
2. `lib/protocol/transport/ptpip_connection.dart`（含 PtpipSocket 抽象类 + IoPtpipSocket/FakePtpipSocket）
3. `lib/protocol/session/` 三块（lifecycle/traversal/transfers）
4. `lib/protocol/camera_transport.dart`（品牌抽象接口）
5. `lib/protocol/experimental_nikon_transport.dart`（Nikon 实现）
6. `lib/protocol/ptpip_session.dart`（主入口）
7. 翻写 `Tests/PTPIPSessionAssetTraversalTests.swift` 为 Dart 版
8. **异常路径测试**：网络超时 / 部分数据包到达 / 大文件中断恢复
9. Phase 1 验收 commit + push

---

## 3. 任务清单（8 个原子任务，按顺序执行）

### 任务依赖图

执行前先看清依赖关系。**严格按编号顺序做**，因为每个任务的产出是下一个任务的输入。

| 任务 | 前置任务 | 产出 |
|---|---|---|
| 3.0 准备 | — | 5 个空目录 |
| 3.1 data_types | 3.0 | 4 个 enum + 1 个常量类 |
| 3.2 data_structures | 3.1 | 4 个 freezed data class |
| 3.3 packet_codec + error | 3.1, 3.2 | 编解码 + 错误 sealed class |
| 3.4 socket + connection | 3.3 | PtpipSocket 抽象 + IoPtpipSocket + PtpipConnection |
| 3.5 session | 3.4 | PtpipSession 主类（含 lifecycle/traversal/transfers） |
| 3.6 camera_transport | 3.5 | CameraTransport 抽象 + ExperimentalNikonTransport + Factory |
| 3.7 测试 | 3.1, 3.3, 3.4, 3.5 | 单元测试 + 异常路径测试 |
| 3.8 验收 | 3.7 | commit + push |

### 任务 3.0 — 准备：环境变量 + 目录创建

**耗时**：2 分钟

**步骤**：

1. 跑 `setx PUB_HOSTED_URL https://pub.flutter-io.cn`（写入用户级环境变量，**每次新 PowerShell 都要再 set 一次**才能生效）
2. 跑 `setx FLUTTER_STORAGE_BASE_URL https://storage.flutter-io.cn`
3. 创建空目录：
   ```bash
   New-Item -ItemType Directory -Path "D:\桌面\Nikon_connect\Viewfinder\lib\protocol\primitives" -Force
   New-Item -ItemType Directory -Path "D:\桌面\Nikon_connect\Viewfinder\lib\protocol\transport" -Force
   New-Item -ItemType Directory -Path "D:\桌面\Nikon_connect\Viewfinder\lib\protocol\session" -Force
   New-Item -ItemType Directory -Path "D:\桌面\Nikon_connect\Viewfinder\test\protocol" -Force
   New-Item -ItemType Directory -Path "D:\桌面\Nikon_connect\Viewfinder\test\helpers" -Force
   ```
4. 不需要 commit，commit 包含下面创建的文件就行

**验收**：5 个目录都已创建。

---

### 任务 3.1 — primitives/ptpip_data_types.dart（枚举 + 常量）

**耗时**：45 分钟

**翻译源**：
- `D:\桌面\Nikon_connect\Services\PTPIPPrimitives.swift` 第 3-74 行

**要包含的类型**：

| 类型 | 来源 | 说明 |
|---|---|---|
| `PTPIPPacketType` (enum, 15 值) | Swift 3-18 行 | iOS 枚举值固定：initCommandRequest, initCommandAck, initEventRequest, initEventAck, initFail, operationRequest, operationResponse, event, startData, data, cancel, endData, probeRequest, probeResponse |
| `PTPIPDataPhaseInfo` (enum, 3 值) | Swift 20-24 行 | noDataOrDataIn, dataOut, unknown |
| `PTPOperationCode` (enum, 12 值) | Swift 26-39 行 | getDeviceInfo, openSession, closeSession, getStorageIDs, getStorageInfo, getNumObjects, getObjectHandles, getObjectInfo, getObject, getThumb, getPartialObject, getObjectsMetaData |
| `PTPResponseCode` (enum, 35 值) | Swift 41-74 行 | **所有 35 个值都要**，从 ok 到 specificationOfDestinationUnsupported |
| `PTPIPBinary` (class) | Swift 147-150 行 | 只含两个 static 常量：`protocolVersion = 0x0001_0000`（UInt32）、`defaultFriendlyName = "NikonConnectIOS"`（String） |

**写法**：

- 用 Dart `enum`（Dart 3.0+ 支持 raw value）
- 例：
  ```dart
  enum PTPOperationCode {
    getDeviceInfo(0x1001),
    openSession(0x1002),
    // ...
    ;
    const PTPOperationCode(this.rawValue);
    final int rawValue;
  }
  ```

**禁止**：
- ❌ 跳过任何 enum 值（哪怕觉得"用不上"）— 35 个 PTPResponseCode 一个不能少
- ❌ 改 enum 值名（即使觉得拼写不对）
- ❌ 加 `@freezed` 注解（这是 enum 不是 data class）

**验收**：
- 4 个类型全部存在
- `PTPIPPacketType` 15 个值
- `PTPOperationCode` 12 个值
- `PTPResponseCode` 35 个值
- `PTPIPDataPhaseInfo` 3 个值
- `PTPIPBinary` 2 个常量
- `dart analyze` 干净

---

### 任务 3.2 — primitives/ptpip_data_structures.dart（4 个 data class）

**耗时**：30 分钟

**翻译源**：
- `D:\桌面\Nikon_connect\Services\PTPIPPrimitives.swift` 第 76-145 行

**要包含的 4 个 freezed data class**：

| 类 | 字段（严格） |
|---|---|
| `PTPIPDeviceInfo` | `String? model`, `String? manufacturer`, `Set<int> operationsSupported` |
| `PTPIPObjectInfo` | `int handle` (UInt32), `int storageID` (UInt32), `int objectFormat` (UInt16), `int compressedSize` (UInt32), `PhotoAssetThumbnailInfo? thumbnailInfo`, `String fileName`, `DateTime? captureDate`, `DateTime? modificationDate` |
| `PTPIPRawPacket` | `PTPIPPacketType type`, `Uint8List payload` |
| `PTPIPResponse` | `int code` (UInt16), `int transactionID` (UInt32), `List<int> parameters` |

**写 freezed 的标准格式**（参考 `lib/domain/camera_session.dart` 已有的写法）：

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'ptpip_data_types.dart';
import '../../domain/photo_asset.dart';

part 'ptpip_data_structures.freezed.dart';

@freezed
class PTPIPDeviceInfo with _$PTPIPDeviceInfo {
  const factory PTPIPDeviceInfo({
    String? model,
    String? manufacturer,
    @Default(<int>{}) Set<int> operationsSupported,
  }) = _PTPIPDeviceInfo;

  /// 检查是否支持某个 opcode
  bool supportsOperation(PTPOperationCode op) =>
    operationsSupported.contains(op.rawValue);
}
```

**注意事项**：
- `PhotoAssetThumbnailInfo` 在 `lib/domain/photo_asset.dart` 里已定义，**直接 import 复用**，不要重新定义
- `PTPIPRawPacket.payload` 用 `Uint8List`（不是 `List<int>`）— 字节流
- 所有 UInt16/32 在 Dart 里用普通 `int`（Dart int 是 64-bit，足够）
- `bool supportsOperation` 是**额外加的**便利方法（iOS 里也有，见 PTPIPPrimitives.swift 第 81-83 行）

**验收**：
- 4 个类全部存在
- 字段数严格匹配
- `dart analyze` 干净
- `dart run build_runner build --delete-conflicting-outputs` 能生成 `.freezed.dart`

---

### 任务 3.3 — primitives/ptpip_packet_codec.dart + ptpip_error.dart（编解码 + 错误）

**耗时**：90 分钟（**这是 Phase 1 最重要的纯 Dart 模块**）

**翻译源**：
- `D:\桌面\Nikon_connect\Services\PTPIPPrimitives.swift` 第 147-379 行

**拆分建议**：
- `ptpip_error.dart` — `PTPIPError` enum（含 message getter）
- `ptpip_packet_codec.dart` — `PTPIPBinary` class 的所有 encode/decode 静态方法

#### 子任务 3.3a — ptpip_error.dart

翻译 Swift 108-145 行。`PTPIPError` 是 enum with associated values：

| case | Swift 形式 | Dart 形式 |
|---|---|---|
| invalidPacketLength | (无) | sealed class 子类 |
| unsupportedPacketType | (UInt32) | 含 int |
| unexpectedPacket | (expected: [PTPIPPacketType], actual: PTPIPPacketType) | 含 list + 单个 |
| connectionClosed | (无) | sealed class 子类 |
| invalidProtocolVersion | (UInt32) | 含 int |
| invalidTransaction | (expected: UInt32, actual: UInt32) | 含 2 个 int |
| unexpectedResponse | (code: UInt16) | 含 int |
| malformedPayload | (String) | 含 String |
| sessionUnavailable | (无) | sealed class 子类 |
| timeout | (String) | 含 String |

**Dart 推荐用 sealed class**（参考 `lib/domain/camera_app_error.dart` 的写法）：

```dart
sealed class PTPIPError {
  const PTPIPError();
  String get message;

  const factory PTPIPError.invalidPacketLength() = _InvalidPacketLength;
  const factory PTPIPError.unsupportedPacketType(int value) = _UnsupportedPacketType;
  // ... 9 个 case
}
```

每个 case 自己的 `message` getter，中文翻译参考 iOS 的 `errorDescription`（PTPIPPrimitives.swift 第 120-144 行）。

#### 子任务 3.3b — ptpip_packet_codec.dart

翻译 Swift 152-268 行（PTPDataReader class）和 270-379 行（PTPIPBinary static methods）。

**结构**：

```dart
import 'dart:typed_data';
import 'ptpip_data_types.dart';
import 'ptpip_data_structures.dart';
import 'ptpip_error.dart';

/// 字节流读取器 (对齐 Swift PTPDataReader)
class PTPDataReader {
  PTPDataReader(this._data);
  final Uint8List _data;
  int _offset = 0;

  int get remainingCount => _data.length - _offset;

  int readUInt8() { ... }
  int readUInt16LE() { ... }  // 小端
  int readUInt32LE() { ... }
  int readUInt64LE() { ... }
  Uint8List readBytes(int count) { ... }
  List<int> readPTPArrayUInt16() { ... }
  List<int> readPTPArrayUInt32() { ... }
  String readPTPString() { ... }  // UTF-16LE
  String readUTF16NullTerminatedString() { ... }
}

/// PTP/IP 报文编解码 (对齐 Swift PTPIPBinary)
class PTPIPBinary {
  PTPIPBinary._();

  static const int protocolVersion = 0x00010000;
  static const String defaultFriendlyName = 'NikonConnectIOS';

  /// 编码任意 packet 为字节流
  static Uint8List encodePacket({
    required PTPIPPacketType type,
    required Uint8List payload,
  }) { ... }

  /// 编码 InitCommandRequest
  static Uint8List encodeInitCommandRequest({
    required Uint8List guid,
    required String friendlyName,
  }) { ... }

  /// 编码 InitEventRequest
  static Uint8List encodeInitEventRequest(int connectionNumber) { ... }

  /// 编码 ProbeRequest / ProbeResponse
  static Uint8List encodeProbeRequest() => encodePacket(type: PTPIPPacketType.probeRequest, payload: Uint8List(0));
  static Uint8List encodeProbeResponse() => encodePacket(type: PTPIPPacketType.probeResponse, payload: Uint8List(0));

  /// 编码 OperationRequest
  static Uint8List encodeOperationRequest({
    required PTPOperationCode operation,
    required int transactionID,
    List<int> parameters = const [],
    required PTPIPDataPhaseInfo dataPhase,
  }) { ... }

  /// 解析响应包
  static PTPIPResponse parseResponsePacket(PTPIPRawPacket packet) { ... }

  /// 解析 StartData 包头
  static ({int transactionID, int totalLength}) parseStartDataPayload(Uint8List payload) { ... }

  /// 解析 Data 包体
  static ({int transactionID, Uint8List bytes}) parseDataPayload(Uint8List payload) { ... }
}
```

**关键点**：
- **全部用小端序** (little-endian) — 见 PTPIPPrimitives.swift 第 178 行 `littleEndian`
- `ByteData.setUint32(0, value, Endian.little)` 写；`ByteData.getUint32(offset, Endian.little)` 读
- 不要混大端
- UTF-16 字符串解码对齐 iOS 的 `decodeUTF16NullTerminated`
- 测试方法：写一个 round-trip 测试，对每个 encoder/decoder 都验证

**验收**：
- `PTPDataReader` 类能正确读取小端字节
- `PTPIPBinary` 所有 encode/decode 静态方法实现
- `dart analyze` 干净

---

### 任务 3.4 — transport/ptpip_socket.dart + ptpip_connection.dart（socket 抽象 + 实现）

**耗时**：2 小时

**翻译源**：
- `D:\桌面\Nikon_connect\Services\PTPIPTCPConnection.swift` (167 行)

**架构**（来自 `docs/架构.md §5.3`）：

```
PtpipSocket (abstract class)        ← 接口
   ↑
IoPtpipSocket implements PtpipSocket   ← 真实实现 (dart:io.Socket)
FakePtpipSocket implements PtpipSocket ← 测试实现 (内存 buffer)
```

#### 子任务 3.4a — ptpip_socket.dart

**接口设计**：

```dart
import 'dart:async';
import 'dart:typed_data';

/// PTP/IP socket 抽象接口 (对齐架构.md §5.3)
abstract class PtpipSocket {
  /// 连接到 host:port
  Future<void> connect({Duration timeout = const Duration(seconds: 10)});

  /// 发送字节
  Future<void> send(Uint8List bytes);

  /// 接收一个完整 PTP/IP packet (含 8 字节 header + payload)
  /// 失败时抛 PTPIPError
  Future<Uint8List> receivePacket({Duration timeout = const Duration(seconds: 10)});

  /// 关闭连接
  Future<void> close();

  /// 是否已连接
  bool get isConnected;
}
```

#### 子任务 3.4b — ptpip_socket_io.dart（IoPtpipSocket 真实实现）

```dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'ptpip_socket.dart';
import '../primitives/ptpip_error.dart';

/// PTP/IP socket 真实实现 (对齐 Swift PTPIPTCPConnection.receivePacket)
class IoPtpipSocket implements PtpipSocket {
  IoPtpipSocket({required this.host, required this.port});

  final String host;
  final int port;
  Socket? _socket;

  /// 累积未消费的字节 (TCP 是字节流，包边界不对齐)
  final List<int> _buffer = [];

  bool get isConnected => _socket != null;

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 10)}) async {
    _socket = await Socket.connect(host, port, timeout: timeout);
  }

  @override
  Future<void> send(Uint8List bytes) async {
    final s = _socket;
    if (s == null) throw StateError('not connected');
    s.add(bytes);
    await s.flush();
  }

  @override
  Future<Uint8List> receivePacket({Duration timeout = const Duration(seconds: 10)}) async {
    final s = _socket;
    if (s == null) throw StateError('not connected');

    // 1. 读 8 字节 header
    final header = await _readExact(8, timeout);
    // header[0..4] = length (UInt32 LE), header[4..8] = type (UInt32 LE)
    final length = ByteData.sublistView(header).getUint32(0, Endian.little);
    if (length < 8) throw PTPIPError.invalidPacketLength();

    // 2. 读 (length - 8) 字节 payload
    final payloadLen = length - 8;
    final payload = payloadLen > 0
        ? await _readExact(payloadLen, timeout)
        : Uint8List(0);

    // 3. 拼接成完整 packet 返回
    final result = Uint8List(length);
    result.setAll(0, header);
    result.setAll(8, payload);
    return result;
  }

  /// 读取正好 count 字节 (跨 TCP 包边界)
  /// 算法：用累积 buffer + Stream 监听，buffer 够就返回，不够就等
  Future<Uint8List> _readExact(int count, Duration timeout) async {
    if (count == 0) return Uint8List(0);
    final s = _socket;
    if (s == null) throw StateError('not connected');

    // 累积 buffer 已够，直接返回
    if (_buffer.length >= count) {
      final take = Uint8List.fromList(_buffer.sublist(0, count));
      _buffer.removeRange(0, count);
      return take;
    }

    // 否则订阅 socket stream，等数据填满
    final completer = Completer<Uint8List>();
    StreamSubscription<Uint8List>? subscription;

    void checkBuffer() {
      if (completer.isCompleted) return;
      if (_buffer.length >= count) {
        final take = Uint8List.fromList(_buffer.sublist(0, count));
        _buffer.removeRange(0, count);
        completer.complete(take);
      }
    }

    subscription = s.listen(
      (chunk) {
        _buffer.addAll(chunk);
        checkBuffer();
      },
      onError: (Object e) {
        if (!completer.isCompleted) {
          completer.completeError(PTPIPError.connectionClosed);
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(PTPIPError.connectionClosed);
        }
      },
      cancelOnError: true,
    );

    try {
      return await completer.future.timeout(
        timeout,
        onTimeout: () {
          if (!completer.isCompleted) {
            completer.completeError(
              PTPIPError.timeout('read $count bytes within ${timeout.inSeconds}s'),
            );
          }
          throw PTPIPError.timeout('read $count bytes within ${timeout.inSeconds}s');
        },
      );
    } finally {
      await subscription?.cancel();
    }
  }

  @override
  Future<void> close() async {
    await _socket?.close();
    _socket = null;
    _buffer.clear();
  }
}
```

**关键实现细节**：
- **累积 buffer**：TCP 是字节流，一个 PTP 包可能跨多个 TCP 包到达（或者多个 PTP 包塞在一个 TCP 包里）。`_buffer` 缓存未消费的字节，下次 `receivePacket` 先用 buffer 再去 stream 读
- **Stream 监听模式**：`Socket.listen()` 注册回调，chunk 到达时检查 buffer 是否够；够就 complete Completer，不够就继续等
- **超时机制**：用 `Future.timeout()` 给整个读过程加 deadline，超时抛 `PTPIPError.timeout`
- **断连处理**：socket 关闭 (`onDone`) 或出错 (`onError`) 都立即 complete error 为 `PTPIPError.connectionClosed`
- **避免资源泄漏**：`try/finally` 确保 `subscription.cancel()` 一定执行

**需要 PTPIPError 类型**——从任务 3.3a 导入。

#### 子任务 3.4c — ptpip_connection.dart（高层连接管理）

**对齐 Swift PTPIPTCPConnection**（`actor` + `withTimeout`）：

```dart
import 'dart:async';
import 'dart:typed_data';

import 'ptpip_socket.dart';
import 'ptpip_socket_io.dart';
import 'primitives/ptpip_error.dart';

/// 高层 PTP/IP TCP 连接管理 (对齐 Swift PTPIPTCPConnection)
class PtpipConnection {
  PtpipConnection({required this.host, required this.port, PtpipSocket? socket})
    : _socket = socket ?? IoPtpipSocket(host: host, port: port);

  final String host;
  final int port;
  final PtpipSocket _socket;

  Future<void> open({Duration timeout = const Duration(seconds: 10)}) =>
    _socket.connect(timeout: timeout);

  Future<void> close() => _socket.close();

  Future<void> send(Uint8List packet) => _socket.send(packet);

  Future<Uint8List> receivePacket({Duration timeout = const Duration(seconds: 10)}) =>
    _socket.receivePacket(timeout: timeout);

  bool get isConnected => _socket.isConnected;
}
```

**关键设计决策**：
- iOS 用 Swift `actor` 保证串行访问 socket
- Dart 没有 actor；用 `Stream` + `Completer` 或简单的 async/await 串行即可
- 这里的 PtpipConnection 是 thin wrapper，主要逻辑在 PtpipSocket 实现里

**验收**：
- `IoPtpipSocket` 能 connect / send / receivePacket / close
- `PtpipConnection` 包装 IoPtpipSocket
- `dart analyze` 干净

---

### 任务 3.5 — session/ptpip_session.dart（主类，合一所有方法）

**耗时**：3 小时

**翻译源**（3 个 iOS Swift extension 合并成一个 Dart 类）：
- `D:\桌面\Nikon_connect\Services\PTPIPSession+Lifecycle.swift` — OpenSession / CloseSession
- `D:\桌面\Nikon_connect\Services\PTPIPSession+AssetTraversal.swift` — GetObjectHandles / GetObjectInfo
- `D:\桌面\Nikon_connect\Services\PTPIPSession+Transfers.swift` — GetObject / GetThumb / GetPartialObject

**设计决策**：iOS 的 Swift extension 模式（`extension PTPIPSession { ... }`）在 Dart 里没等价物。**不要拆成 3 个 class**——opcode / transactionID / PtpipConnection 实例状态在 3 个 class 间共享会引入循环依赖。**直接合并成 1 个 `PtpipSession` 主类**，按职能分组方法。

**文件**：`lib/protocol/session/ptpip_session.dart`（单一文件）

**完整模板**：

```dart
import 'dart:async';
import 'dart:typed_data';

import '../primitives/ptpip_data_types.dart';
import '../primitives/ptpip_data_structures.dart';
import '../transport/ptpip_connection.dart';

/// PTP/IP 会话主类 (合并 iOS 三个 Swift extension 的方法)
class PtpipSession {
  PtpipSession({required this.host, required this.port});

  final String host;
  final int port;
  late final PtpipConnection _connection;
  int _nextTransactionID = 1;

  // ============ Lifecycle (对齐 PTPIPSession+Lifecycle.swift) ============

  /// TCP 连接 + InitCommandRequest + InitEventRequest + OpenSession
  /// 返回相机返回的设备信息
  Future<PTPIPDeviceInfo> openSession() async {
    _connection = PtpipConnection(host: host, port: port);
    await _connection.open();

    // 1. 发送 InitCommandRequest
    final guid = Uint8List(16);  // Phase 0 占位；Phase 1+ 改成真 GUID
    await _sendCommand(
      type: PTPIPPacketType.initCommandRequest,
      payload: PTPIPBinary.encodeInitCommandRequest(
        guid: guid,
        friendlyName: PTPIPBinary.defaultFriendlyName,
      ),
    );
    // 2. 接收 InitCommandAck
    await _receiveCommand(
      expectedType: PTPIPPacketType.initCommandAck,
    );

    // 3. 发送 InitEventRequest
    final connectionNumber = 1;
    await _sendCommand(
      type: PTPIPPacketType.initEventRequest,
      payload: PTPIPBinary.encodeInitEventRequest(connectionNumber),
    );
    // 4. 接收 InitEventAck
    await _receiveCommand(
      expectedType: PTPIPPacketType.initEventAck,
    );

    // 5. 发送 OpenSession
    final deviceInfo = await _sendOperationRequest(
      operation: PTPOperationCode.openSession,
      parameters: [1],  // session ID
    );

    // deviceInfo 是 PTPIPGetDeviceInfo 的响应
    return deviceInfo;
  }

  /// CloseSession + 断开 TCP
  Future<void> closeSession() async {
    try {
      await _sendOperationRequest(
        operation: PTPOperationCode.closeSession,
        parameters: [1],  // session ID
      );
    } finally {
      await _connection.close();
    }
  }

  // ============ Asset Traversal (对齐 PTPIPSession+AssetTraversal.swift) ============

  /// GetStorageIDs + GetObjectHandles
  Future<List<int>> getObjectHandles({int storageID = 1}) async {
    // 1. GetStorageIDs
    final storageIds = await _sendOperationRequest(
      operation: PTPOperationCode.getStorageIDs,
      parameters: [],
    );
    // 解析 storageIds (UInt32 数组)，用第一个 (或传入的 storageID)

    // 2. GetObjectHandles
    final handles = await _sendOperationRequest(
      operation: PTPOperationCode.getObjectHandles,
      parameters: [storageID, 0xFFFFFFFF, 0],  // storageID, format=all, handle=0
    );
    return handles;  // List<int> (UInt32 数组)
  }

  /// GetObjectInfo
  Future<PTPIPObjectInfo> getObjectInfo(int handle) async {
    final params = await _sendOperationRequest(
      operation: PTPOperationCode.getObjectInfo,
      parameters: [handle, 0],  // handle, storageID=0 (any)
    );
    return _parseObjectInfo(params);  // 从 parameters 数组解析
  }

  // ============ Transfers (对齐 PTPIPSession+Transfers.swift) ============

  /// GetObject (单次获取整张大文件)
  Future<Uint8List> getObject(int handle) async {
    // 1. GetObjectInfo 获取文件大小
    final info = await getObjectInfo(handle);
    final totalSize = info.compressedSize;

    // 2. GetObject (data phase = dataOut)
    await _sendOperationRequest(
      operation: PTPOperationCode.getObject,
      parameters: [handle, 0, totalSize],  // handle, storageID=0, maxSize
      dataPhase: PTPIPDataPhaseInfo.dataOut,
    );

    // 3. 接收 StartData
    final startData = await _receiveCommand(expectedType: PTPIPPacketType.startData);
    final startInfo = PTPIPBinary.parseStartDataPayload(startData.payload);
    final actualTotal = startInfo.totalLength;

    // 4. 接收 Data 包 (可能多个)
    final buffer = BytesBuilder(copy: false);
    while (buffer.length < actualTotal) {
      final dataPacket = await _receiveCommand(expectedType: PTPIPPacketType.data);
      final dataInfo = PTPIPBinary.parseDataPayload(dataPacket.payload);
      buffer.add(dataInfo.bytes);
    }

    // 5. 接收 EndData
    await _receiveCommand(expectedType: PTPIPPacketType.endData);

    return buffer.toBytes();
  }

  /// GetThumb
  Future<Uint8List?> getThumbnail(int handle) async {
    try {
      await _sendOperationRequest(
        operation: PTPOperationCode.getThumb,
        parameters: [handle, 0],
        dataPhase: PTPIPDataPhaseInfo.dataOut,
      );
      final startData = await _receiveCommand(expectedType: PTPIPPacketType.startData);
      final startInfo = PTPIPBinary.parseStartDataPayload(startData.payload);
      final totalLen = startInfo.totalLength;

      final buffer = BytesBuilder(copy: false);
      while (buffer.length < totalLen) {
        final dataPacket = await _receiveCommand(expectedType: PTPIPPacketType.data);
        final dataInfo = PTPIPBinary.parseDataPayload(dataPacket.payload);
        buffer.add(dataInfo.bytes);
      }
      await _receiveCommand(expectedType: PTPIPPacketType.endData);
      return buffer.toBytes();
    } on PTPIPError catch (e) {
      if (e is PTPIPError && e.message.contains('No thumbnail')) {
        return null;
      }
      rethrow;
    }
  }

  /// GetPartialObject (用于断点续传)
  Future<Uint8List> getPartialObject({
    required int handle,
    required int offset,
    required int maxByteCount,
  }) async {
    await _sendOperationRequest(
      operation: PTPOperationCode.getPartialObject,
      parameters: [handle, offset, maxByteCount],
      dataPhase: PTPIPDataPhaseInfo.dataOut,
    );
    final startData = await _receiveCommand(expectedType: PTPIPPacketType.startData);
    final startInfo = PTPIPBinary.parseStartDataPayload(startData.payload);

    final buffer = BytesBuilder(copy: false);
    while (buffer.length < startInfo.totalLength) {
      final dataPacket = await _receiveCommand(expectedType: PTPIPPacketType.data);
      final dataInfo = PTPIPBinary.parseDataPayload(dataPacket.payload);
      buffer.add(dataInfo.bytes);
    }
    await _receiveCommand(expectedType: PTPIPPacketType.endData);
    return buffer.toBytes();
  }

  // ============ 内部辅助方法 ============

  /// 发送 + 接收一个普通命令 (无 data phase)
  Future<Uint8List> _sendCommand({
    required PTPIPPacketType type,
    required Uint8List payload,
  }) async {
    final packet = PTPIPBinary.encodePacket(type: type, payload: payload);
    await _connection.send(packet);
    final response = await _connection.receivePacket();
    return response.sublist(8);  // 去掉 8 字节 header，返回 payload
  }

  /// 接收指定类型的包，校验类型
  Future<PTPIPRawPacket> _receiveCommand({
    required PTPIPPacketType expectedType,
  }) async {
    final raw = await _connection.receivePacket();
    // raw[4..8] 是 packet type (小端 UInt32)
    final type = ByteData.sublistView(raw).getUint32(4, Endian.little);
    if (type != expectedType.rawValue) {
      throw PTPIPError.unexpectedPacket(
        expected: [expectedType],
        actual: PTPIPPacketType.values.firstWhere(
          (t) => t.rawValue == type,
          orElse: () => throw PTPIPError.unsupportedPacketType(type),
        ),
      );
    }
    return PTPIPRawPacket(
      type: PTPIPPacketType.values.firstWhere((t) => t.rawValue == type),
      payload: raw.sublist(8),
    );
  }

  /// 发送 OperationRequest + 接收 OperationResponse + 校验 OK
  Future<List<int>> _sendOperationRequest({
    required PTPOperationCode operation,
    required List<int> parameters,
    PTPIPDataPhaseInfo dataPhase = PTPIPDataPhaseInfo.noDataOrDataIn,
  }) async {
    final txId = _nextTransactionID++;
    await _sendCommand(
      type: PTPIPPacketType.operationRequest,
      payload: PTPIPBinary.encodeOperationRequest(
        operation: operation,
        transactionID: txId,
        parameters: parameters,
        dataPhase: dataPhase,
      ),
    );

    final response = await _receiveCommand(expectedType: PTPIPPacketType.operationResponse);
    final parsed = PTPIPBinary.parseResponsePacket(response);

    if (parsed.code != PTPResponseCode.ok.rawValue) {
      throw PTPIPError.unexpectedResponse(parsed.code);
    }
    if (parsed.transactionID != txId) {
      throw PTPIPError.invalidTransaction(
        expected: txId,
        actual: parsed.transactionID,
      );
    }
    return parsed.parameters;
  }

  /// 从 OperationResponse parameters 解析 GetDeviceInfo
  PTPIPDeviceInfo _parseGetDeviceInfo(List<int> params) {
    // PTP GetDeviceInfo 响应是 dataset，按 PTP 规范解析
    // 具体格式参考 iOS PTPIPPrimitives.swift 和 PTP/IP 规范
    // Phase 1 占位实现：返回最小可用对象
    return const PTPIPDeviceInfo(
      model: null,
      manufacturer: null,
      operationsSupported: const {},
    );
  }

  /// 从 OperationResponse parameters 解析 GetObjectInfo
  PTPIPObjectInfo _parseObjectInfo(List<int> params) {
    // PTP GetObjectInfo 响应是 ObjectInfo dataset
    // 具体解析逻辑参考 iOS PTPIPSession+AssetTraversal.swift
    return const PTPIPObjectInfo(
      handle: 0,
      storageID: 0,
      objectFormat: 0,
      compressedSize: 0,
      thumbnailInfo: null,
      fileName: '',
    );
  }
}
```

**关键点**：
- **不拆 3 个 class**——opcode/transactionID/connection 实例状态会跨边界，拆开会引入循环依赖
- `_sendOperationRequest` 是核心辅助方法，所有 PTP 操作都走它
- `_parseGetDeviceInfo` 和 `_parseObjectInfo` 是 PTP dataset 解析的占位实现——Phase 2 需要根据 PTP/IP 规范补完整
- GetObject/GetThumb/GetPartialObject 都遵循同样的模式：发 Request → 收 StartData → 循环收 Data → 收 EndData

**验收**：
- `PtpipSession` 类有所有方法（openSession / closeSession / getObjectHandles / getObjectInfo / getObject / getThumbnail / getPartialObject）
- 每个方法严格对齐 iOS 的 opcode + 参数
- `dart analyze` 干净

---

### 任务 3.6 — camera_transport.dart + experimental_nikon_transport.dart（品牌抽象 + Nikon 实现）

**耗时**：1.5 小时

**翻译源**：
- `D:\桌面\Nikon_connect\Services\CameraTransport.swift` (68 行) — abstract protocol + DownloadTransferProgress struct
- `D:\桌面\Nikon_connect\Services\ExperimentalNikonTransport.swift` (175 行) — Nikon 实现
- `D:\桌面\Nikon_connect\Services\CameraTransportFactory.swift` (7 行) — 工厂

#### 子任务 3.6a — protocol/camera_transport.dart

**包含**：
- `DownloadTransferProgress` freezed class（5 字段：bytesTransferred, totalBytes, resumedCount, currentOffset, chunkSize）
- `abstract class CameraTransport` 接口（与 iOS 协议 1:1）
- 5 个方法 + 1 个 getter + connect/disconnect

```dart
@freezed
class DownloadTransferProgress with _$DownloadTransferProgress {
  const factory DownloadTransferProgress({
    @Default(0) int bytesTransferred,
    @Default(0) int totalBytes,
    @Default(0) int resumedCount,
    @Default(0) int currentOffset,
    @Default(0) int chunkSize,
  }) = _DownloadTransferProgress;
  
  const DownloadTransferProgress._();
  
  double get fractionCompleted {
    if (totalBytes <= 0) return 0;
    return (bytesTransferred / totalBytes).clamp(0.0, 1.0);
  }
}

abstract class CameraTransport {
  Future<CameraSession> connect(using config: CameraConnectionConfig);
  Future<PhotoAssetPage> fetchAssetsPage({...});
  Future<Uint8List> downloadAsset(PhotoAsset asset, CameraSession session);
  Future<Uint8List?> downloadThumbnail(PhotoAsset asset, CameraSession session);
  Future<URL> downloadAssetToTemporaryFile(PhotoAsset asset, CameraSession session, ...);
  Future<DownloadThroughputTransferMode> downloadTransferMode(PhotoAsset asset, CameraSession session);
  Future<List<String>> consumeDiagnostics(CameraSession session);
  Future<void> disconnect(CameraSession session);
}
```

#### 子任务 3.6b — protocol/experimental_nikon_transport.dart

翻译 iOS `ExperimentalNikonTransport.swift` (175 行)。**这是协议层 ↔ Domain 层的桥梁**，必须给出完整 connect 流程，不能只写骨架。

**完整模板**：

```dart
import 'dart:async';

import '../domain/camera_connection_config.dart';
import '../domain/camera_session.dart';
import '../domain/photo_asset.dart';
import 'camera_transport.dart';
import 'session/ptpip_session.dart';
import 'download_throughput_transfer_mode.dart';  // 与 Domain 复用同名 enum

/// Nikon 相机传输实现 (对齐 Swift ExperimentalNikonTransport)
class ExperimentalNikonTransport implements CameraTransport {
  PtpipSession? _session;
  List<String> _pendingDiagnostics = [];

  @override
  Future<CameraSession> connect({required CameraConnectionConfig config}) async {
    // 1. 验证 config
    final host = config.normalizedHost;
    if (host.isEmpty) {
      throw const CameraAppErrorMissingHost();
    }
    if (config.port < 1 || config.port > 65535) {
      throw const CameraAppErrorInvalidPort();
    }

    // 2. 关闭已存在的 session (防重入)
    if (_session != null) {
      await _session!.closeSession();
      _session = null;
    }

    // 3. 创建新 PTP/IP 会话
    final session = PtpipSession(host: host, port: config.port);

    try {
      // 4. 打开 PTP/IP 会话 (TCP + InitCommand + InitEvent + OpenSession)
      //    返回的 PTPIPDeviceInfo 是 PTP/IP 层原始结果
      final deviceInfo = await session.openSession();
      _session = session;

      // 5. 构造 Domain CameraSession (Phase 1 占位映射，Phase 2 会更精细)
      //    cameraName 默认 'Nikon Camera'，无设备名信息时 fallback
      //    capabilities 根据 operationsSupported 推断
      final capabilities = <CameraCapability>{
        if (deviceInfo.operationsSupported.contains(PTPOperationCode.getObjectHandles.rawValue))
          CameraCapability.connectionProbe,
        if (deviceInfo.operationsSupported.contains(PTPOperationCode.getObjectInfo.rawValue))
          CameraCapability.listAssets,
        if (deviceInfo.operationsSupported.contains(PTPOperationCode.getObject.rawValue))
          CameraCapability.downloadAssets,
      };

      return CameraSession(
        id: DateTime.now().microsecondsSinceEpoch.toString(),  // Phase 0 占位
        cameraName: deviceInfo.model ?? 'Nikon Camera',
        connectedHost: host,
        port: config.port,
        connectedAt: DateTime.now(),
        capabilities: capabilities,
      );
    } catch (e) {
      // 6. 失败清理
      await session.closeSession();
      _session = null;
      // 包成 CameraAppError
      if (e is CameraAppError) rethrow;
      throw CameraAppError.networkProbeFailed(e.toString());
    }
  }

  @override
  Future<PhotoAssetPage> fetchAssetsPage({
    required CameraSession session,
    required bool resetTraversal,
    required int limit,
  }) async {
    final s = _session;
    if (s == null) throw const CameraAppErrorNotConnected();

    try {
      // Phase 1 占位：直接 GetObjectHandles 全部，return 整个 page
      // Phase 2 会加分页逻辑
      final handles = await s.getObjectHandles(storageID: 1);

      final assets = <PhotoAsset>[];
      for (final handle in handles.take(limit)) {
        try {
          final info = await s.getObjectInfo(handle);
          // 从 PTPIPObjectInfo 构造 Domain PhotoAsset
          // Phase 1 占位映射：handle 转字符串，fileName 等后续字段填占位
          assets.add(PhotoAsset(
            id: handle.toString(),  // Phase 0 用 handle 字符串当 id
            remoteIdentifier: handle.toString(),
            fileName: info.fileName.isNotEmpty ? info.fileName : 'DSC_$handle',
            kind: _classifyObjectFormat(info.objectFormat),
            byteSize: info.compressedSize,
            captureDate: info.captureDate ?? DateTime.now(),
            thumbnailInfo: info.thumbnailInfo,
          ));
        } on PTPIPError {
          // 单张照片失败不致命，跳过
        }
      }

      return PhotoAssetPage(assets: assets, hasMore: handles.length > limit);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<Uint8List> downloadAsset(PhotoAsset asset, CameraSession session) async {
    final s = _session;
    if (s == null) throw const CameraAppErrorNotConnected();

    final handle = int.tryParse(asset.remoteIdentifier);
    if (handle == null) {
      throw CameraAppError.unsupportedOperation('bad handle: ${asset.remoteIdentifier}');
    }

    try {
      return await s.getObject(handle);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<Uint8List?> downloadThumbnail(PhotoAsset asset, CameraSession session) async {
    final s = _session;
    if (s == null) throw const CameraAppErrorNotConnected();

    final handle = int.tryParse(asset.remoteIdentifier);
    if (handle == null) return null;

    try {
      return await s.getThumbnail(handle);
    } on PTPIPError catch (e) {
      // 没缩略图不算错
      if (e is PTPIPErrorUnsupportedPacketType ||
          e is PTPIPErrorUnexpectedResponse) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<String> downloadAssetToTemporaryFile(
    PhotoAsset asset,
    CameraSession session,
  ) async {
    final bytes = await downloadAsset(asset, session);
    final tempDir = Directory.systemTemp.createTempSync();
    final file = File('${tempDir.path}/${asset.fileName}');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  @override
  Future<DownloadThroughputTransferMode> downloadTransferMode(
    PhotoAsset asset,
    CameraSession session,
  ) async {
    return DownloadThroughputTransferMode.unknown;
  }

  @override
  Future<List<String>> consumeDiagnostics() async {
    final messages = List<String>.from(_pendingDiagnostics);
    _pendingDiagnostics.clear();
    return messages;
  }

  @override
  Future<void> disconnect(CameraSession session) async {
    final s = _session;
    if (s != null) {
      await s.closeSession();
      _session = null;
    }
  }

  // ============ 辅助方法 ============

  /// PTP objectFormat → Domain PhotoAssetKind
  PhotoAssetKind _classifyObjectFormat(int format) {
    // PTP Object Format Codes (从 iOS PTPIPPrimitives.swift 注释或 PTP 规范查)
    // 0x3000 = RAW, 0x3801 = JPEG, 0x3001 = MOV, 等
    // Phase 1 占位：粗略分类
    if (format == 0x3001) return PhotoAssetKind.movie;
    if (format == 0x3801 || format == 0x3802) return PhotoAssetKind.jpeg;
    return PhotoAssetKind.raw;
  }

  CameraAppError _mapError(Object e) {
    if (e is CameraAppError) return e;
    if (e is PTPIPError) return CameraAppError.networkProbeFailed(e.message);
    return CameraAppError.networkProbeFailed(e.toString());
  }
}
```

**关键点**：
- **connect 流程**：validate config → close old session → create new → openSession → construct CameraSession（Domain 类型）
- **fetchAssetsPage**：Phase 1 占位全量拉，Phase 2 加分页
- **downloadAsset / downloadThumbnail**：用 `int.tryParse(asset.remoteIdentifier)` 把 Domain 的字符串 handle 还原成 PTP 的 int handle
- **`_classifyObjectFormat`**：PTP object format code → Domain PhotoAssetKind 的映射（参考 iOS PTPIPSession+AssetTraversal.swift）

**验收**：
- `ExperimentalNikonTransport` 实现 CameraTransport 所有方法
- `connect()` 能跑通端到端流程（虽然 `_parseGetDeviceInfo` 是占位）
- `dart analyze` 干净

#### 子任务 3.6c — protocol/camera_transport_factory.dart

```dart
import 'camera_transport.dart';
import 'experimental_nikon_transport.dart';

class CameraTransportFactory {
  CameraTransport makeTransport() => ExperimentalNikonTransport();
}
```

**验收**：
- `CameraTransport` 是 abstract class（不是 Dart `abstract` 关键字，是用 `abstract` 修饰 class）
- `ExperimentalNikonTransport` 实现所有方法
- `DownloadTransferProgress` 有 fractionCompleted getter
- `dart analyze` 干净

---

### 任务 3.7 — 单元测试（fake socket + 翻写真实测试）

**耗时**：2 小时

**翻译源**：
- `D:\桌面\Nikon_connect\Tests\PTPIPSessionAssetTraversalTests.swift` (259 行)
- AGENTS.md §6.1: Protocol 层覆盖率 ≥ 80%

#### 子任务 3.7a — test/helpers/fake_ptpip_socket.dart

```dart
import 'dart:async';
import 'dart:typed_data';

import 'package:viewfinder/lib/protocol/transport/ptpip_socket.dart';

/// 用于测试的内存 socket (不连真实相机)
class FakePtpipSocket implements PtpipSocket {
  FakePtpipSocket({this.scriptedResponses = const []});
  
  /// 预编排的响应序列 (调用 receivePacket 时按顺序返回)
  final List<Uint8List> scriptedResponses;
  int _responseIndex = 0;
  
  /// 记录所有 send() 调用过的字节
  final List<Uint8List> sentPackets = [];
  
  bool _connected = false;
  
  @override
  bool get isConnected => _connected;
  
  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 10)}) async {
    _connected = true;
  }
  
  @override
  Future<void> send(Uint8List bytes) async {
    sentPackets.add(bytes);
  }
  
  @override
  Future<Uint8List> receivePacket({Duration timeout = const Duration(seconds: 10)}) async {
    if (_responseIndex >= scriptedResponses.length) {
      throw Exception('no more scripted responses');
    }
    return scriptedResponses[_responseIndex++];
  }
  
  @override
  Future<void> close() async {
    _connected = false;
  }
}
```

#### 子任务 3.7b — test/protocol/primitives_test.dart

测试 PTPIPBinary 的所有 encode/decode 方法：

- `test('encodePacket returns 8-byte header + payload')`
- `test('decodePacketType rejects unknown values')`
- `test('parseResponsePacket handles valid responses')`
- `test('encodeOperationRequest packs parameters in little-endian')`
- `test('parseStartDataPayload returns transaction + length')`
- 等等

#### 子任务 3.7c — test/protocol/session_test.dart

翻译 iOS `PTPIPSessionAssetTraversalTests.swift`，用 FakePtpipSocket 模拟相机响应：

```dart
test('getObjectHandles returns parsed handle list', () async {
  // 编排 fake socket 响应 (InitCommandAck, InitEventAck, OperationResponse 等)
  // 调 session.getObjectHandles()
  // 验证返回值
});
```

#### 子任务 3.7d — 异常路径测试（必须覆盖）

参考 `docs/Viewfinder方案.md §8 Phase 1` 验收：

```dart
group('异常路径', () {
  test('网络超时 → connect throws PTPIPError.timeout');
  test('部分数据包到达 → receivePacket throws PTPIPError.malformedPayload');
  test('GetPartialObject 重试 → 续传字节正确');
});
```

**验收**：
- `dart test` 全绿
- 协议层覆盖率 ≥ 80%（跑 `dart test --coverage`）

---

### 任务 3.8 — Phase 1 验收 commit + push

**耗时**：10 分钟

**步骤**：

1. 跑 `dart analyze` 确保干净
2. 跑 `flutter test` 确保全绿
3. 更新 `docs/项目状态.md`：
   - §2 Phase 1 状态从 `⏳` 改 `✅`
   - §3 已完成清单加 Phase 1 条目
   - §5.2 Phase 2 起点展开
   - §8 决策日志加 Phase 1 决策
4. Commit message 模板：
   ```
   Phase 1 完成：PTP/IP 协议层落地（primitives/transport/session + camera_transport + experimental_nikon_transport），X 个单测覆盖率达 80%，异常路径测试通过
   ```
5. `git push origin main`
6. 验证 `gh api /repos/AbandonS-ED/Viewfinder/commits | Select-String "message"` 看到新 commit

---

## 4. commit 规范（来自 AGENTS.md §8）

格式：`<动词><对象>：<一句话说明>`

示例：
```
实现 protocol/primitives 全部编解码 (15 enum + 12 opcode + 35 response code)
实现 protocol/transport PtpipSocket 抽象 + IoPtpipSocket 真实实现
翻写 iOS PTPIPSessionAssetTraversalTests 为 Dart 版 (fake socket)
```

- 中文为主
- 动词：实现 / 修复 / 重构 / 添加 / 删除 / 更新
- 不超过 50 字
- **不要**用 "update" / "fix" / "misc" / "wip" 这种空 message

---

## 5. 已知坑和应急方案

### 5.1 pub.dev 解析失败

**症状**：
```
Got socket error trying to find package flutter_lints at https://pub.dev.
```

**解法**：每个新 PowerShell 都要设：
```powershell
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
```

### 5.2 freezed enum getter 报错

**症状**：
```
freezed on xxx: 7:10: Expected to find ','
```

**原因**：freezed 2.5.8 + Dart 3.12 不兼容 enum 内 getter

**解法**：把 getter 拆成顶级函数（参考 `lib/domain/camera_workflow_state.dart` 的做法）

### 5.3 dart analyze 在中文路径下崩溃

**症状**：`FormatException: Unexpected end of input`（LSP 通信错误）

**解法**：**用 `dart analyze` 替代 `flutter analyze`**，结果一样可靠

### 5.4 Git push 失败 "Recv failure: Connection was reset"

**原因**：当前网络限制（用户主机在 `D:\桌面\` 中文路径下，且可能处于受限网络）

**解法**：
1. 切换到家里 Wi-Fi
2. 检查 `C:\Windows\System32\drivers\etc\hosts` 是否有 `127.0.0.1 github.com` 之类的屏蔽（如果有，删掉那行）
3. 重试

### 5.5 build_runner 失败

**症状**：
```
[SEVERE] freezed on xxx: <some error>
```

**排查**：
1. 看错误指向哪个文件哪一行
2. 检查 freezed class 的 factory 参数（特别是 `@Default()` 的常量是否合规）
3. 检查跨文件 import 是否齐全

### 5.6 测试跑不动

**症状**：`flutter test` 卡死或报路径错误

**解法**：
1. 确认在项目根目录跑（不是 lib/ 或 test/）
2. 确认 `flutter_test` 在 dev_dependencies
3. 用 `dart test` 替代 `flutter test`（不需要模拟器）

---

## 6. 不要做的事

来自 AGENTS.md §2：

- ❌ 顺手重构用户没让改的文件
- ❌ 改 UI 风格（Phase 1 不涉及 UI，跳过即可）
- ❌ 改 pubspec 依赖（除非用户明确同意）
- ❌ commit / push 自动化（必须人确认）
- ❌ 编造 PTP/IP opcode（不知道的去 iOS Swift 文件查）
- ❌ 改 doc/ 之外的文件名（README.md / AGENTS.md 必须保留英文）

---

## 7. 完成标志

Phase 1 完成的判定：

```bash
cd "D:\桌面\Nikon_connect\Viewfinder"

# 1. 所有目标文件存在
Test-Path "lib\protocol\primitives\ptpip_data_types.dart"     # true
Test-Path "lib\protocol\primitives\ptpip_data_structures.dart" # true
Test-Path "lib\protocol\primitives\ptpip_packet_codec.dart"   # true
Test-Path "lib\protocol\primitives\ptpip_error.dart"          # true
Test-Path "lib\protocol\transport\ptpip_socket.dart"          # true
Test-Path "lib\protocol\transport\ptpip_socket_io.dart"      # true
Test-Path "lib\protocol\transport\ptpip_connection.dart"      # true
Test-Path "lib\protocol\session\ptpip_session.dart"           # true
Test-Path "lib\protocol\camera_transport.dart"                # true
Test-Path "lib\protocol\experimental_nikon_transport.dart"   # true
Test-Path "lib\protocol\camera_transport_factory.dart"        # true
Test-Path "test\helpers\fake_ptpip_socket.dart"               # true
Test-Path "test\protocol\primitives_test.dart"                # true
Test-Path "test\protocol\session_test.dart"                   # true

# 2. 编译/分析干净
dart analyze                # No issues found!

# 3. 单测全绿
flutter test                # All tests passed!

# 4. Git 同步
git log --oneline | Select-Object -First 1   # 显示 Phase 1 完成 commit
git status                                  # nothing to commit
```

全部 ✓ 即 Phase 1 完成。

---

## 8. 时间预算

| 任务 | 估时 |
|---|---|
| 3.0 准备 | 2 分钟 |
| 3.1 data_types | 45 分钟 |
| 3.2 data_structures | 30 分钟 |
| 3.3 packet_codec + error | 90 分钟 |
| 3.4 socket + connection | 2 小时 |
| 3.5 session | 3 小时 |
| 3.6 camera_transport | 1.5 小时 |
| 3.7 测试 | 2 小时 |
| 3.8 验收 | 10 分钟 |
| **总计** | **~11 小时** |

按规划文档说"5-7 天"，其实连续干的话 2 个工作日够。

---

## 9. 完成后

### 9.1 Phase 1 vs Phase 2 的边界

**Phase 1（本次）只做协议层，**返回原始 PTP/IP 类型**：

- `PtpipSession.getObjectHandles()` → `List<int>` (handles)
- `PtpipSession.getObjectInfo(handle)` → `PTPIPObjectInfo`
- `PtpipSession.getObject(handle)` → `Uint8List` (原始字节)
- `ExperimentalNikonTransport.fetchAssetsPage()` → `PhotoAssetPage` (Phase 1 的占位映射)

**Phase 2 需要补一个 adapter 层**，把 PTP 原始结果转成 Domain 类型（`PhotoAsset`、`DownloadJob` 等）：

- 建议位置：`lib/protocol/adapters/`（Phase 2 新建目录）
- 建议接口：`PhotoAssetAdapter.fromPtpip(PTPIPObjectInfo, int handle) → PhotoAsset`
- Phase 1 的 `ExperimentalNikonTransport.fetchAssetsPage()` 是占位实现，**Phase 2 重写**成调 adapter

### 9.2 下一步

读 `docs/项目状态.md §5.2 Phase 2 起点`——下一步是 Phase 2 真机端到端验证（在真 Nikon 相机上跑）。

---

**这份文档自己 = Phase 1 的工作说明书**。任何会 Dart + 看得懂 Swift 的人，照着这份 + `docs/` + iOS 源码 都能完成。