# Phase 3 实施计划 v2 — 真机端到端 + 完整下载链路

> 本文档是 Phase 3 工作说明书。每个任务完成后用 `dart analyze` + `flutter test` 验证再进下一个。
>
> **v2 修复内容**：v1 文档经审查发现 25 个严重错误 + 30+ 中度遗漏（详见 §0），v2 已全部整合：协议层修复、接口签名修正、平台代码任务补全、权限清单完整、任务顺序重排、测试清单扩到 80+。

---

## 0. 背景

### 0.1 Phase 2 现状

Phase 0 + Phase 1 + Phase 2 已完成，commit `68ee999` 已 push 到 GitHub：
- **代码**：7 Provider + 5 Notifier + 4 页面 + 3 service + 11 widget，102 单测全绿
- **协议层**：Phase 1 PTP/IP 单连接架构 + 47 测全绿
- **下载**：仅占位（`DownloadManagerNotifier` 只有 `enqueue` + `cancelJob`）
- **缩略图**：Gallery 用 mock 占位，没接 `transport.downloadThumbnail()`

### 0.2 v1 审查发现的关键问题（25 个严重）

按重要性排序：

| # | 问题 | 来源对比 |
|---|---|---|
| 1 | `ExperimentalNikonTransport.downloadAssetToTemporaryFile` 接受 `onProgress` 参数但**不传** | Viewfinder 当前代码 vs iOS 原版 |
| 2 | `PtpipSession.getObject` 一次性全文件下载，**无 onProgress 支持** | Viewfinder vs iOS 原版 |
| 3 | `DownloadManagerNotifier` 缺 `downloadSelected(assets)` 多 asset 接口 | iOS `downloadAssets` |
| 4 | `DownloadQueueState.activeJob` getter 的 `orElse: () => jobs.first` 空 jobs 时抛 RangeError | Viewfinder 代码 |
| 5 | 任务依赖顺序错：3.13 (ConnectionVM cameraSessionProvider) 在 3.11 (GalleryPage) 之后 | v1 任务表 |
| 6 | 任务归属错：3.10 写"DownloadsContainer 接下载选中回调"，应是 GalleryContainer | v1 §13 目录结构 vs §14.1 |
| 7 | `BackgroundRunner.begin` 应返回 `Future<void>` 不是 `void`（iOS `beginBackgroundTask` 异步） | v1 §6.1 |
| 8 | `BackgroundRunner` `iOS MethodChannel` 命名错（`app.channel.background` → 应为 `viewfinder/background_download`） | v1 §6.3 |
| 9 | `BackgroundRunner` 注释错（Dart 没 `BackgroundIsolate`） | v1 §6.3 |
| 10 | `AssetThumbnailService.clear()` 应 `Future<void>` 且清 inFlight map | v1 §3.2 |
| 11 | `DownloadStore.downloadsDirectoryURL` 应返回 `Directory` 不是 `String` | v1 §4.1 |
| 12 | `DownloadStore` 缺 `upsertDownloadJob / removeDownloadJobs` 接口 | iOS 原版 |
| 13 | `DownloadStore` 缺 `markInterruptedRunningJobs` 在 `loadPersistedQueue` 自动调用 | iOS 原版 |
| 14 | `DownloadStore` 缺并发安全（iOS `actor`，Dart 用 `Lock` 或 `Mutex`） | iOS 原版 |
| 15 | `PhotoLibraryChannel.exportFile` 删 `mimeType` 参数（iOS 自动从扩展名判断） | v1 §8.1 |
| 16 | `PhotoLibraryChannel.requestPermission` 返回 `bool` 不够细（应区分 granted/limited/denied/never_ask） | v1 §8.1 |
| 17 | `PhotoLibraryChannel` 没列 iOS Swift + Android Kotlin 平台代码任务 | v1 §14 漏 |
| 18 | `NotificationService.show` 缺 `payload` deepLink 路由处理 | v1 §7.1 |
| 19 | `NotificationService` 没列 iOS 静态文字 vs Android 进度条区分（iOS 无 progress bar） | v1 §1 总体目标误导 |
| 20 | `LogFileStore` 没明确 rotation 算法 + level 来源 | v1 §10.2 |
| 21 | `pubspec` 列 `image ^4.x` 依赖但 §16.5 说不用 image 包 | v1 自相矛盾 |
| 22 | iOS Info.plist 漏 `NSAppTransportSecurity` / `NSLocationWhenInUseUsageDescription` 等 | v1 §11.2 |
| 23 | Android Manifest 漏 `READ_MEDIA_IMAGES / READ_MEDIA_VIDEO / POST_NOTIFICATIONS / WRITE_EXTERNAL_STORAGE / ACCESS_FINE_LOCATION` | v1 §16 缺 |
| 24 | v1 `§3.1` 简化的"磁盘 cache 在 Phase 3"与 `Phase2实施计划.md §7.1` "磁盘 cache 在 Phase 4" 矛盾 | 文档冲突 |
| 25 | v1 测试列表只 33 个，写"60+"但没列具体 27 个测 | v1 §14.2 |

### 0.3 v1 → v2 变更摘要

| 类别 | 变更数 |
|---|---|
| 接口签名修正 | 4 处 |
| 任务重排 | 3 处 |
| 任务增补 | 4 个（平台代码任务 + 协议层修 bug 任务） |
| 测试清单扩 | 33 → 80+ |
| 文档冲突解决 | 2 处 |
| 文档同步清单 | 7 个 .md |

---

## 1. 总体目标

### 1.1 核心交付

| 交付 | 说明 | 验证方式 |
|---|---|---|
| **Android 真机端到端** | 连 Nikon 相机 → 浏览 12+ 真实缩略图 → 选 → 下载 → 通知进度 → 入相册 | 真机 |
| **协议层进度回调** | 修 `PtpipSession.getObject` + `ExperimentalNikonTransport` onProgress 链 | 单元测 + 真机 |
| **缩略图服务** | 相机自带缩略图 → 内存 + 磁盘 cache → GridView 真实显示 | 真机 + 单元测 |
| **完整下载链路** | GetObject → temp file → DownloadStore → PhotoLibrary 入相册 | 真机 |
| **后台执行 + 通知** | Android Foreground Service + flutter_local_notifications 进度条；iOS 短期后台 + 静态通知 | 真机 |
| **Wi-Fi 断线** | 监听实际 Wi-Fi（SSID/BSSID）→ 自动 pause 队列 | 真机 |
| **日志文件** | 单文件 append + rotation + Settings 页导出按钮 | 真机 + 单元测 |
| **iOS 平台** | `flutter create . --platforms=ios` + Info.plist + AppDelegate | 代码到位，真机验证需 Mac |
| **测试** | 80+ 新测试（Phase 2 102 + Phase 3 80+ = 182+） | `flutter test` |
| **文档** | `项目状态.md` Phase 3 状态 + 决策同步 6 个 .md | grep |

### 1.2 明确**不**做的事

- ❌ iOS 真机验证（需 Mac + Apple Developer 账号）
- ❌ iOS Live Activity（跨端降级，Phase 4 可选）
- ❌ PTP/IP chunk 下载优化（iOS 自适应 chunk 1-8MB；Phase 3 单次全文件，Phase 4 优化）
- ❌ 客户端 RAW 缩略图降采样（用 `image` 包解码 .NEF）
- ❌ Dark Mode
- ❌ UI 抛光 + Haptics + 动画

---

## 2. 协议层补全（Phase 3 必修，必须先于 DownloadManager）

> **为什么 Phase 3 必须修协议层**：Phase 1 `downloadAssetToTemporaryFile` 接受 `onProgress` 但**不传**；`PtpipSession.getObject` 一次性返回 `Uint8List`，无 per-chunk 回调。Phase 3 进度条 / 实时状态完全失效。**先修这两个 bug 再写队列运行循环。**

### 2.1 PtpipSession.getObject 加 onProgress 支持

**当前代码** `lib/protocol/session/ptpip_session.dart`：
```dart
Future<Uint8List> getObject(Uint32 handle) async { ... }  // ❌ 无 progress
```

**目标**：加 per-chunk 进度回调 + 流式写入（避免 50MB 一次性 allocate Uint8List）。

**方案 A（Phase 3 简化）**：保持单次全文件读，但加 `onProgress` 在 read 完成后回调一次。
- 不修 PTP/IP 内部
- Transport 层加 progress 模拟
- 进度条"只跳一次"，不连续

**方案 B（推荐）**：加 `getObjectToTempFile(handle, filePath, onProgress)` 流式 API。
- `PtpipSession` 增加新方法
- 每次 read chunk 后调 `onProgress(bytesTransferred, totalBytes)`
- 真进度条

**Phase 3 决定：方案 B（推荐）**。

```dart
// lib/protocol/session/ptpip_session.dart 新增
Future<String> getObjectToTempFile({
  required Uint32 handle,
  required String suggestedFileName,
  required int? expectedByteSize,
  required void Function(int bytesTransferred, int totalBytes)? onProgress,
}) async {
  // 1. openData（getObject）
  // 2. 循环 readData，每次 write 到 temp file
  // 3. 每次 write 后调 onProgress(bytesWritten, expectedTotal)
  // 4. closeData / getObjectStatus
  // 5. 返回 temp file path
}
```

测试：mock socket 验证 onProgress 调用次数和累计 bytes。

### 2.2 ExperimentalNikonTransport 修 onProgress 传递 bug

**当前代码** `lib/protocol/experimental_nikon_transport.dart` L126：
```dart
Future<String> downloadAssetToTemporaryFile(
  PhotoAsset asset,
  CameraSession session, {
  void Function(DownloadTransferProgress)? onProgress,  // 接受但不用 ❌
}) async {
  final bytes = await downloadAsset(asset, session);  // 不传 onProgress
  ...
}
```

**修复**：调 `getObjectToTempFile`（§2.1 新方法）替代 `downloadAsset`。

```dart
// lib/protocol/experimental_nikon_transport.dart L126 修复
Future<String> downloadAssetToTemporaryFile(
  PhotoAsset asset,
  CameraSession session, {
  void Function(DownloadTransferProgress)? onProgress,
}) async {
  final s = _session;
  if (s == null) throw const CameraAppError.notConnected();
  final handle = int.tryParse(asset.remoteIdentifier);
  if (handle == null) {
    throw CameraAppError.unsupportedOperation('bad handle: ${asset.remoteIdentifier}');
  }
  // 调新流式方法，onProgress 真传
  return await s.getObjectToTempFile(
    handle: handle,
    suggestedFileName: asset.fileName,
    expectedByteSize: asset.byteSize,
    onProgress: onProgress == null ? null : (int transferred, int total) {
      onProgress(DownloadTransferProgress(
        bytesTransferred: transferred,
        totalBytes: total,
        resumedCount: 0,
        currentOffset: transferred,
        chunkSize: total - transferred,
      ));
    },
  );
}
```

`downloadAsset`（一次性返回 Uint8List）保留，仅用于 Phase 2 简单场景；Phase 3 队列循环用 `downloadAssetToTemporaryFile`。

### 2.3 测试

`test/protocol/experimental_nikon_transport_test.dart` 加 2 测：
- `downloadAssetToTemporaryFile 真传 onProgress 给底层 getObjectToTempFile`
- `downloadAssetToTemporaryFile handle 解析失败抛 unsupportedOperation`

`test/protocol/session_test.dart` 加 3 测：
- `getObjectToTempFile 累计 bytes 正确`
- `getObjectToTempFile chunk 中断正确 closeData`
- `getObjectToTempFile 失败时清理 temp file`

---

## 3. AssetThumbnailService (`lib/services/asset_thumbnail_service.dart`)

### 3.1 设计决策

iOS 原版 715 行（2 derivative × 内存/磁盘 cache × in-flight × unavailable）。**Phase 3 简化为 ~180 行**：

| 简化项 | iOS 原版 | Phase 3 简化 |
|---|---|---|
| Derivative 数 | 2（thumbnail + preview） | **1**（仅 thumbnail） |
| RAW 资产缩略图 | 客户端 CGImage 缩略图（fallback） | **相机自带**（无 fallback；fail 返回 null） |
| Cache 层 | 内存 + 磁盘 + task 去重 + unavailable | 内存 + 磁盘 + task 去重 |
| 失败处理 | `unavailableIdentifiers: Set<String>` | 返回 null（不缓存负结果） |
| AssetThumbnailService 实现并发安全 | actor | 普通 class + `Lock`（`sync` 包） |

### 3.2 接口

```dart
abstract class AssetThumbnailServing {
  Future<void> clear();
  Future<Uint8List?> thumbnailData({
    required PhotoAsset asset,
    required CameraTransport transport,
    required CameraSession session,
  });
}

class AssetThumbnailService implements AssetThumbnailServing {
  AssetThumbnailService({
    required String cacheDirectory,
    Lock? lock,
  });
  // 内存 cache: Map<String, Uint8List>
  // 磁盘 cache: {cacheDirectory}/thumbnails/{key}.jpg
  // in-flight: Map<String, Future<Uint8List?>>  (lock-protected)
}
```

**关键修正**（对比 v1）：
- `clear()` 返回 `Future<void>`（v1 写 `void`）
- 加 `lock` 参数（测试可注入 fake lock）

### 3.3 缓存策略

- **Key**：`SHA256(remoteIdentifier|fileName|byteSize|kind|thumbnailInfo.byteSize|pixelWidth|pixelHeight)` —— **in-flight 和 cache 都用同一 key**（v1 in-flight 用 remoteIdentifier 错）
- **内存 cache**：进程级 `Map<String, Uint8List>`，无 LRU（Phase 4 加）
- **磁盘 cache**：`{cacheDirectory}/thumbnails/{key}.jpg`
- **In-flight 去重**：同一 asset 并发请求只下载一次

### 3.4 流程

```
thumbnailData(asset, transport, session):
  lock:
    if cache[cacheKey] exists: return cache[cacheKey]   // 内存 cache hit
    if inFlight[cacheKey] exists: return await inFlight[cacheKey]  // task 去重

  if磁盘 cache 存在: load → cache[cacheKey] = data → return

  inFlight[cacheKey] = _downloadAndCache(...)
  try: data = await inFlight[cacheKey]
  finally: inFlight.remove(cacheKey)

  if data != null: cache[cacheKey] = data; 写磁盘
  return data

clear():
  lock:
    cache.clear()
    inFlight.clear()  // 不取消 in-flight tasks，只清 map（让已完成 task 写入 cache 时跳过；新 task 重新调 transport）
```

### 3.5 RAW 资产策略

iOS 原版 RAW fallback：调 `downloadAssetToTemporaryFile` → CGImage 缩略图 → cache。Phase 3 简化：相机自带缩略图失败时直接返回 null（GridView 显示 ShimmerView 占位）。Phase 4 客户端降采样再补。

### 3.6 测试（5 测）

1. 内存 cache hit：第二次调不调 transport
2. 磁盘 cache hit：load + 写内存
3. in-flight 去重：并发同 asset 调一次 transport
4. transport 返回 null：cache 不存负结果
5. `clear()`：清 inFlight map + 内存 cache；不删磁盘

---

## 4. DownloadStore (`lib/services/download_store.dart`)

### 4.1 接口（修正版）

```dart
abstract class DownloadStoring {
  // 文件路径
  Future<Directory> downloadsDirectoryURL();  // ✅ Directory 不是 String

  // Record CRUD
  Future<List<DownloadRecord>> listRecords();
  Future<DownloadRecord> storeDownloadedFile({
    required String sourcePath,         // ✅ 命名统一（v1 用了 sourcePath，iOS 用 sourceURL）
    required PhotoAsset asset,
  });
  Future<DownloadRecord> markExported(String recordID);  // ✅ ID 类型与 Viewfinder DownloadRecord.id 对齐 String

  // Queue 状态
  Future<DownloadQueueState> loadQueueState();
  Future<DownloadQueueState> saveQueueState(DownloadQueueState state);
  Future<DownloadQueueState> upsertDownloadJob({
    required DownloadJob job,
    required DownloadQueueStatus queueStatus,
    required String? activeJobID,
  });  // 🆕 v1 漏
  Future<DownloadQueueState> removeDownloadJobs({
    required List<String> ids,
    required DownloadQueueStatus queueStatus,
    required String? activeJobID,
  });  // 🆕 v1 漏

  // 恢复
  Future<DownloadQueueState> markInterruptedRunningJobs({String? reason});
}

class DownloadStore implements DownloadStoring {
  DownloadStore({required Directory rootDirectory, Lock? lock});
  // 持久化路径：
  //   {rootDirectory}/Downloads/downloads-manifest.json   (List<DownloadRecord>)
  //   {rootDirectory}/Downloads/download-jobs.json       (DownloadQueueState)
}
```

### 4.2 并发安全

iOS 原版 `actor DownloadStore`（所有方法 `async throws` 自动串行访问 manifest 文件）。

Dart 端实现：用 `package:sync` 的 `Lock` 串行化所有 IO 操作。

```dart
class DownloadStore implements DownloadStoring {
  final Lock _lock = Lock();
  
  @override
  Future<List<DownloadRecord>> listRecords() async {
    return await _lock.synchronized(() async {
      final raw = await _readFile(_manifestPath);
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .map((j) => DownloadRecord.fromJson(j))
          .toList();
    });
  }
  // 其他方法同模式
}
```

### 4.3 uniqueDestinationURL（修 v1）

v1 §4.2 用了 `p.extension` 但没 `import 'package:path/path.dart'`。Phase 3 用 `dart:io.File` 自带的 basename/extension 操作避免依赖。

```dart
String _uniqueDestinationPath(String dir, String fileName) {
  var candidate = '$dir${Platform.pathSeparator}$fileName';
  if (!File(candidate).existsSync()) return candidate;
  final dotIdx = fileName.lastIndexOf('.');
  final base = dotIdx > 0 ? fileName.substring(0, dotIdx) : fileName;
  final ext = dotIdx > 0 ? fileName.substring(dotIdx) : '';
  var index = 2;
  while (true) {
    candidate = '$dir${Platform.pathSeparator}$base-$index$ext';
    if (!File(candidate).existsSync()) return candidate;
    index += 1;
  }
}
```

### 4.4 loadPersistedQueue 自动 interrupted

```dart
// DownloadManagerNotifier.loadPersistedQueue
Future<void> loadPersistedQueue() async {
  final state = await ref.read(downloadStoreProvider).loadQueueState();
  // 关键：iOS 原版不检查，直接用 markInterruptedRunningJobs 保证重启后状态正确
  final interrupted = await ref.read(downloadStoreProvider)
      .markInterruptedRunningJobs(reason: 'App 重启，自动标记为可恢复');
  state = interrupted;
  ref.read(downloadManagerProvider.notifier).applyState(state);
}
```

iOS 原版 `markInterruptedRunningJobs` 行为：
- 所有 `status == .running` → `status == .interrupted`
- 其他状态保持
- `activeJobID = nil`
- `status` 变 `.interrupted`（如果有 interrupted job）

### 4.5 测试（5 测）

1. `listRecords` 空 → `[]`
2. `saveQueueState` + `loadQueueState` round-trip
3. `storeDownloadedFile` unique -2/-3 后缀
4. `markExported` `record.exportedToPhotoLibrary = true`
5. `markInterruptedRunningJobs` running → interrupted，queued 保持

补 **2 测**（v1 漏）：
6. JSON 损坏恢复（loadQueueState 失败 → 返回 empty state）
7. Schema 兼容（缺字段走 default）

---

## 5. DownloadManagerNotifier 完整实现 (`lib/features/downloads/`)

### 5.1 方法表（修正版）

| 方法 | 签名 | v1 状态 | v2 状态 |
|---|---|---|---|
| `enqueue(asset)` | `void enqueue(PhotoAsset)` | ✅ Phase 2 | ✅ 保留 |
| **`downloadSelected(assets)`** | `Future<bool> downloadSelected(List<PhotoAsset> assets, {required bool autoExport, required bool prioritizeJPEG})` | ❌ v1 漏 | 🆕 Phase 3 |
| `cancelJob(id)` | `void cancelJob(String id)` | ✅ | ✅ |
| `cancelAll()` | `void cancelAllDownloads()` | ⏳ | 🆕 |
| `retryJob(id)` | `Future<void> retryJob(String id)` | ⏳ | 🆕 |
| `clearFinished()` | `void clearFinishedJobs()` | ⏳ | 🆕 |
| `pauseQueue()` | `void pauseQueue()` | ⏳ | 🆕 |
| `resumeInterruptedQueue()` | `Future<void> resumeInterruptedDownloads()` | ⏳ | 🆕 |
| `loadPersistedQueue()` | `Future<void> loadPersistedQueue()` | ⏳ | 🆕 |
| `refreshDownloads()` | `Future<void> refreshDownloads()` | ⏳ | 🆕 |
| `handleScenePhase(phase)` | `void handleScenePhaseChange(AppLifecycleState phase)` | ⏳ | 🆕 |
| `interruptActiveDownload(reason)` | `void interruptActiveDownload(String reason)` | ❌ 漏 | 🆕 |
| `consumeTransportDiagnostics(transport)` | `Future<void> appendTransportDiagnostics(CameraTransport)` | ❌ 漏 | 🆕 |
| `_runQueue()` | `Future<void> _runQueue()` | ⏳ | 🆕 |
| `DownloadJob.fromAsset` | factory | ✅ Phase 2 | ✅ |

### 5.2 队列运行循环（修正版）

```dart
Future<void> _runQueue() async {
  try {
    while (!isCancelled) {
      final job = _nextRunnableJob();
      if (job == null) break;

      // 1. 校验 session + transport
      final session = ref.read(cameraSessionProvider);
      final transport = ref.read(cameraTransportProvider);
      if (session == null || transport == null) {
        _updateJob(job.id, (j) {
          j.status = DownloadJobStatus.interrupted;
          j.errorMessage = '请重新连接 Nikon 相机后继续下载。';
        });
        state = state.copyWith(status: DownloadQueueStatus.interrupted, activeJobID: null);
        await _persist();
        break;
      }

      // 2. 后台执行 + 通知
      await ref.read(notificationServiceProvider).show(
        notificationId: job.id.hashCode,
        title: '下载中',
        body: job.fileName,
        progress: 0,
        channelId: 'download_progress',
        payload: 'downloads',
      );
      ref.read(backgroundRunnerProvider).begin(
        name: 'Nikon Download',
        onExpiration: () => interruptActiveDownload('iOS 已暂停后台传输'),
      );

      // 3. 启动 throughput recorder（Phase 3 占位：调用但不展示数据，Phase 4 UI）
      // 4. 更新 job 为 running
      _updateJob(job.id, (j) => j..status = DownloadJobStatus.running..startedAt = DateTime.now());
      state = state.copyWith(activeJobID: job.id, status: DownloadQueueStatus.running);

      try {
        // 5. 真传 onProgress 下载
        final tempPath = await transport.downloadAssetToTemporaryFile(
          asset, session,
          onProgress: (progress) {
            _updateJob(job.id, (j) => j
              ..bytesTransferred = progress.bytesTransferred
              ..totalBytes = progress.totalBytes
              ..currentOffset = progress.currentOffset);
            state = state.copyWith(
              activeDownloadProgress: ActiveDownloadProgress(
                fileName: job.fileName,
                currentItemNumber: _indexOf(job.id) + 1,
                totalItemCount: state.jobs.length,
                bytesTransferred: progress.bytesTransferred,
                totalBytes: progress.totalBytes,
                resumedCount: progress.resumedCount,
                currentOffset: progress.currentOffset,
                chunkSize: progress.chunkSize,
              ),
            );
            ref.read(notificationServiceProvider).update(
              notificationId: job.id.hashCode,
              progress: ((progress.bytesTransferred / progress.totalBytes) * 100).round(),
            );
          },
        );

        // 6. 持久化（临时文件 → DownloadStore）
        final record = await ref.read(downloadStoreProvider).storeDownloadedFile(
          sourcePath: tempPath,
          asset: asset,
        );

        // 7. 入相册（如果 autoExport）
        if (job.autoExportToPhotoLibrary) {
          try {
            await ref.read(photoLibraryChannelProvider).exportFile(filePath: record.savedURL);
            await ref.read(downloadStoreProvider).markExported(record.id);
          } catch (e) {
            ref.read(appShellProvider.notifier).appendLog('导出到相册失败: ${e.toString()}');
          }
        }

        // 8. 完成
        _updateJob(job.id, (j) => j..status = DownloadJobStatus.completed..completedAt = DateTime.now());
        state = state.copyWith(activeJobID: null, activeDownloadProgress: null);

        // 9. transport diagnostics
        await _consumeTransportDiagnostics(transport);

        // 10. 清理后台 + 通知
        ref.read(backgroundRunnerProvider).end();
        await ref.read(notificationServiceProvider).cancel(notificationId: job.id.hashCode);

        await _persist();
      } on CameraAppError catch (e) {
        // 11. 错误映射
        final status = _interruptibleStatus(e);
        _updateJob(job.id, (j) => j
          ..status = status
          ..errorMessage = e.message
          ..completedAt = status.isTerminal ? DateTime.now() : null);
        state = state.copyWith(
          activeJobID: null,
          status: status == DownloadJobStatus.interrupted 
              ? DownloadQueueStatus.interrupted 
              : DownloadQueueStatus.paused,
        );
        ref.read(backgroundRunnerProvider).end();
        ref.read(appShellProvider.notifier).appendLog('${job.fileName} 下载失败: ${e.message}');
        await _persist();
        return; // 错误时退出循环（避免 spam）
      }
    }
  } finally {
    // 队列结束：清后台执行
    ref.read(backgroundRunnerProvider).end();
  }
}
```

### 5.3 错误映射（完整 8 cases）

```dart
DownloadJobStatus _interruptibleStatus(Object error) {
  if (error is! CameraAppError) return DownloadJobStatus.failed;
  switch (error) {
    case CameraAppError.notConnected:
    case CameraAppError.networkProbeFailed():
      return DownloadJobStatus.interrupted;
    case CameraAppError.fileSystemFailure():
    case CameraAppError.unsupportedOperation():
    case CameraAppError.photoLibraryAccessDenied():
    case CameraAppError.photoLibraryExportFailed():
    case CameraAppError.missingHost():
    case CameraAppError.invalidPort():
      return DownloadJobStatus.failed;
  }
}
```

⚠️ v1 简化版 `if + return failed` 丢失 iOS 原版的 `notConnected → interrupted` 语义。

### 5.4 状态转换规则（iOS 原版 `normalizeQueueStatusAfterManualUpdate`）

```dart
void _normalizeQueueStatus({DownloadQueueStatus preferred = DownloadQueueStatus.paused}) {
  DownloadQueueStatus next;
  if (state.jobs.any((j) => j.status == DownloadJobStatus.running)) {
    next = DownloadQueueStatus.running;
  } else if (state.jobs.any((j) => j.status.canResume)) {
    next = preferred;
  } else {
    next = DownloadQueueStatus.idle;
    state = state.copyWith(activeJobID: null);
  }
  state = state.copyWith(status: next);
}
```

### 5.5 AppLifecycleState 处理

```dart
void handleScenePhaseChange(AppLifecycleState phase) {
  switch (phase) {
    case AppLifecycleState.resumed:
      // 回到前台，结束后台执行
      ref.read(backgroundRunnerProvider).end();
      break;
    case AppLifecycleState.paused:
    case AppLifecycleState.detached:
      // 进入后台，启动后台执行（iOS 给 30 秒-3 分钟延期）
      if (state.status == DownloadQueueStatus.running) {
        ref.read(backgroundRunnerProvider).begin(
          name: 'Nikon Download',
          onExpiration: () => interruptActiveDownload('App 进入后台后系统暂停了下载。'),
        );
      }
      break;
    case AppLifecycleState.inactive:
      break;
  }
}
```

`WidgetsBindingObserver` 在 `main.dart` 注册：
```dart
class _DownloadLifecycleObserver extends ConsumerStatefulWidget ... 
// 或独立 class
WidgetsBinding.instance.addObserver(downloadManagerProvider.notifier);
```

### 5.6 downloadSelected（v1 漏的关键方法）

```dart
Future<bool> downloadSelected(
  List<PhotoAsset> assets, {
  required bool autoExport,
  required bool prioritizeJPEG,
}) async {
  if (assets.isEmpty) return true;
  
  // JPEG 优先排序
  final ordered = prioritizeJPEG
      ? DownloadAssetPrioritizer.jpegFirst.sort(assets)
      : assets;
  
  // 全部入队
  for (final asset in ordered) {
    final job = DownloadJob.fromAsset(asset, autoExportToPhotoLibrary: autoExport);
    state = state.copyWith(jobs: [...state.jobs, job]);
  }
  
  // 启动队列
  await _persist();
  await _startQueueIfPossible();
  return true;
}

Future<void> _startQueueIfPossible() async {
  if (_queueRunnerFuture != null) return;
  if (!state.jobs.any((j) => j.status.canResume)) {
    state = state.copyWith(status: DownloadQueueStatus.idle, activeJobID: null);
    return;
  }
  if (ref.read(cameraSessionProvider) == null) {
    state = state.copyWith(status: DownloadQueueStatus.interrupted);
    return;
  }
  state = state.copyWith(status: DownloadQueueStatus.running);
  _queueRunnerFuture = _runQueue().then((_) => _queueRunnerFuture = null);
  await _queueRunnerFuture;
}
```

`GalleryContainer` Phase 3 调用：
```dart
class GalleryContainer extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(galleryProvider);
    final downloadManager = ref.read(downloadManagerProvider.notifier);
    final prefs = ref.read(preferencesProvider);
    
    return asyncState.when(
      data: (state) => GalleryPage(
        ...,
        onDownloadSelected: () => downloadManager.downloadSelected(
          state.selectedAssets,
          autoExport: prefs.autoExportToPhotoLibrary,
          prioritizeJPEG: prefs.prioritizeJPEGDownloads,
        ),
      ),
      ...
    );
  }
}
```

### 5.7 测试（13 测）

1. `build()` 初始 state（empty + idle）
2. `enqueue(asset)` 按 JPEG 优先排序
3. `downloadSelected(assets)` 多 asset 入队 + 启动队列
4. `cancelJob(id)` → cancelled
5. `cancelAll()` → 所有非 terminal → cancelled
6. `retryJob(id)` → 重置进度 + queued
7. `clearFinished()` → 移除 terminal
8. `pauseQueue()` → paused
9. `resumeInterruptedQueue()` → running
10. `loadPersistedQueue()` → interrupted 自动标记
11. `refreshDownloads()` → 同步磁盘 records
12. `interruptActiveDownload(reason)` → 中止当前 job
13. `_normalizeQueueStatus()` 状态转换规则

---

## 6. BackgroundRunner (`lib/services/background_download_runner.dart`)

### 6.1 接口（修正版）

```dart
abstract class BackgroundDownloadRunner {
  Future<void> begin({
    required String name,
    void Function()? onExpiration,
  });  // ✅ 返回 Future<void> 不是 void（iOS beginBackgroundTask 异步）
  Future<void> end();
  bool get isActive;
}

class AndroidBackgroundDownloadRunner implements BackgroundDownloadRunner {
  // 用 flutter_background_service
  // FlutterForegroundService.configure(
  //   androidNotificationOptions: AndroidNotificationOptions(
  //     channelId: 'download_foreground',
  //     channelName: 'Viewfinder 下载',
  //     channelDescription: '保持下载任务在后台运行',
  //     channelImportance: NotificationImportance.LOW,
  //     priority: NotificationPriority.LOW,
  //     onlyAlertOnce: true,
  //   ),
  //   iosNotificationOptions: ...,  // iOS 也提供（fallback）
  //   foregroundServiceTypes: [AndroidForegroundType.DataSync],  // Android 14+ 必填
  // );
}

class IosBackgroundDownloadRunner implements BackgroundDownloadRunner {
  // MethodChannel('viewfinder/background_download')
  // AppDelegate.swift 处理 beginBackgroundTask
  int _taskId = -1;
  
  @override
  Future<void> begin({required String name, void Function()? onExpiration}) async {
    if (_taskId != -1) return;
    _taskId = await _channel.invokeMethod<int>('begin', {'name': name});
    if (onExpiration != null) {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onExpiration') {
          onExpiration();
        }
        return null;
      });
    }
  }
  
  @override
  Future<void> end() async {
    if (_taskId == -1) return;
    await _channel.invokeMethod('end', {'taskId': _taskId});
    _taskId = -1;
  }
  
  @override
  bool get isActive => _taskId != -1;
}
```

### 6.2 iOS Swift 平台代码（Phase 3 新任务）

`ios/Runner/AppDelegate.swift` 添加：
```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // 注册 BackgroundDownload MethodChannel
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "viewfinder/background_download",
      binaryMessenger: controller.binaryMessenger
    )
    BackgroundDownloadHandler.register(channel: channel)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// BackgroundDownloadHandler.swift
class BackgroundDownloadHandler {
  static var currentTaskId: UIBackgroundTaskIdentifier = .invalid
  
  static func register(channel: FlutterMethodChannel) {
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "begin":
        guard let args = call.arguments as? [String: Any],
              let name = args["name"] as? String else {
          result(FlutterError(code: "BAD_ARGS", message: nil, details: nil))
          return
        }
        currentTaskId = UIApplication.shared.beginBackgroundTask(withName: name) {
          // expiration
          channel.invokeMethod("onExpiration", arguments: nil)
        }
        result(currentTaskId.rawValue)
      case "end":
        guard currentTaskId != .invalid else { result(nil); return }
        UIApplication.shared.endBackgroundTask(currentTaskId)
        currentTaskId = .invalid
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
```

### 6.3 Android 平台配置（Phase 3 新任务）

`android/app/src/main/AndroidManifest.xml` 加 Foreground Service 权限 + service 声明（详见 §12.1）。

`android/app/src/main/kotlin/.../MainActivity.kt` 注册 PhotoLibraryChannel MethodChannel。

### 6.4 测试（3 测）

1. `begin` 调一次成功；重复 `begin` 跳过
2. `end` 后 `isActive = false`
3. Android `begin` 时调 `FlutterForegroundService.start(...)`

---

## 7. NotificationService (`lib/services/download_notification_service.dart`)

### 7.1 接口（修正版）

```dart
abstract class DownloadNotificationService {
  Future<void> show({
    required int notificationId,
    required String title,
    required String body,
    int progress = -1,  // -1 = indeterminate; 0-100
    String? channelId,    // ✅ Android 需要
    String? categoryId,   // ✅ iOS 需要
    String? payload,      // ✅ deepLink payload
  });
  Future<void> update({
    required int notificationId,
    String? title,
    String? body,
    int? progress,
  });
  Future<void> cancel({required int notificationId});
  Future<void> cancelAll();  // 🆕 清理完成项时批量清
}
```

### 7.2 Android 实现

```dart
class AndroidDownloadNotificationService implements DownloadNotificationService {
  // flutter_local_notifications + ProgressIndicator
  // notification channel: 'download_progress' (IMPORTANCE_LOW)
  // notification ID = job.id.hashCode & 0x7FFFFFFF（确保 positive int32）
  // 点击通知 → onDidReceiveNotificationResponse → deepLink payload
}
```

**AndroidManifest 加 receiver**：
```xml
<receiver android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
```

### 7.3 iOS 实现

```dart
class IosDownloadNotificationService implements DownloadNotificationService {
  // flutter_local_notifications + DarwinNotificationDetails
  // 不支持 progress bar（iOS Notification API 限制）
  // 显示 "DSC_001.NEF 5.2MB / 12MB"（从 progress 算百分比）
  // categoryIdentifier: 'download_progress'（iOS 14+ 通知分类）
}
```

### 7.4 deepLink 路由

`main.dart` 监听 notification tap：
```dart
flutterLocalNotificationsPlugin.initialize(
  initializationSettings,
  onDidReceiveNotificationResponse: (response) {
    final payload = response.payload;  // 'downloads'
    if (payload == 'downloads') {
      // 切到下载 tab
      _appShellRef.read(appShellProvider.notifier).switchToTab(2);
    }
  },
);
```

### 7.5 测试（4 测）

1. `show(progress: 50)` 创建进度通知
2. `update(progress: 80)` 进度更新
3. `cancel` 通知消失
4. `cancelAll` 批量清

---

## 8. PhotoLibraryChannel (`lib/platform/`)

### 8.1 接口（修正版）

```dart
abstract class PhotoLibraryChannel {
  /// 返回详细权限状态（v1 的 bool 不够）
  Future<PhotoLibraryPermission> requestPermission();
  Future<void> exportFile({required String filePath});  // ✅ 删 mimeType
}

enum PhotoLibraryPermission {
  granted,           // iOS .authorized / Android granted
  limited,           // iOS .limited（部分权限）
  denied,            // 拒绝
  neverAskAgain,     // 永久拒绝（用户点过"不再询问"）
}
```

### 8.2 iOS 实现（`.addOnly` 权限）

```dart
class IosPhotoLibraryChannel implements PhotoLibraryChannel {
  static const _channel = MethodChannel('viewfinder/photo_library');
  
  @override
  Future<PhotoLibraryPermission> requestPermission() async {
    // iOS 14+ PHPhotoLibrary.requestAuthorization(for: .addOnly)
    final result = await _channel.invokeMethod<String>('requestPermission');
    return switch (result) {
      'authorized' => PhotoLibraryPermission.granted,
      'limited' => PhotoLibraryPermission.limited,
      'denied' => PhotoLibraryPermission.denied,
      'restricted' => PhotoLibraryPermission.denied,
      _ => PhotoLibraryPermission.denied,
    };
  }
  
  @override
  Future<void> exportFile({required String filePath}) async {
    await _channel.invokeMethod('exportFile', {'filePath': filePath});
  }
}
```

`ios/Runner/PhotoLibraryPlugin.swift`：
```swift
import Flutter
import Photos

class PhotoLibraryPlugin {
  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "viewfinder/photo_library",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "requestPermission":
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
          let str = switch status {
            case .authorized: "authorized"
            case .limited: "limited"
            case .denied: "denied"
            case .restricted: "restricted"
            case .notDetermined: "denied"
            @unknown default: "denied"
          }
          result(str)
        }
      case "exportFile":
        guard let args = call.arguments as? [String: Any],
              let filePath = args["filePath"] as? String else {
          result(FlutterError(code: "BAD_ARGS", message: nil, details: nil))
          return
        }
        // PHPhotoLibrary.shared().performChanges + PHAssetCreationRequest
        // ...
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
```

### 8.3 Android 实现

```dart
class AndroidPhotoLibraryChannel implements PhotoLibraryChannel {
  static const _channel = MethodChannel('viewfinder/photo_library');
  
  @override
  Future<PhotoLibraryPermission> requestPermission() async {
    final result = await _channel.invokeMethod<String>('requestPermission');
    return switch (result) {
      'granted' => PhotoLibraryPermission.granted,
      'limited' => PhotoLibraryPermission.limited,
      'denied' => PhotoLibraryPermission.denied,
      'never_ask_again' => PhotoLibraryPermission.neverAskAgain,
      _ => PhotoLibraryPermission.denied,
    };
  }
  
  @override
  Future<void> exportFile({required String filePath}) async {
    await _channel.invokeMethod('exportFile', {'filePath': filePath});
  }
}
```

`android/app/src/main/kotlin/.../PhotoLibraryPlugin.kt`：
```kotlin
class PhotoLibraryPlugin(private val activity: MainActivity) : MethodChannel.MethodCallHandler {
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "requestPermission" -> {
        // ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE), ...)
        // 实际用 permission_handler
      }
      "exportFile" -> {
        val filePath = call.argument<String>("filePath")!!
        val file = File(filePath)
        // MediaStore.Images.Media.insertImage(contentResolver, file.absolutePath, ...)
        // Android 10+ 用 MediaStore.Images.Media.EXTERNAL_CONTENT_URI + IS_PENDING
        // RAW → MediaStore.Files + DIRECTORY_PICTURES
        result.success(null)
      }
    }
  }
}
```

### 8.4 导出策略表（修正版）

| 格式 | JPEG/PNG | RAW (.NEF) | MOV |
|---|---|---|---|
| Android | MediaStore.Images (`Pictures/Viewfinder/`) | MediaStore.Files (`Pictures/Viewfinder/`) | MediaStore.Video |
| iOS | PHAsset (photo, .addOnly) | ❌ Phase 3 不入库 | PHAsset (video, .addOnly) |
| 测试 | 写到 `{cacheDir}/exported/` | 写到 `{cacheDir}/exported/` | 写到 `{cacheDir}/exported/` |

### 8.5 测试（5 测）

1. `requestPermission` 授予 → granted
2. `requestPermission` 部分授权 → limited
3. `exportFile(JPEG)` → 成功
4. `exportFile(RAW)` → 成功
5. `exportFile` 异常路径（磁盘满 / 权限拒绝）→ throws

---

## 9. WifiWatcher (`lib/services/wifi_watcher.dart`)

### 9.1 接口

```dart
abstract class WifiWatcher {
  /// true = 已连接相机热点；false = 断开或连其他 Wi-Fi
  bool get isCameraWifiConnected;
  Stream<bool> get connectionStream;  // 变化时推送
  Future<void> dispose();
}
```

### 9.2 实现（BSSID 优先 + SSID fallback）

```dart
class DefaultWifiWatcher implements WifiWatcher {
  DefaultWifiWatcher({NetworkInfo? networkInfo, Connectivity? connectivity}) {
    _networkInfo = networkInfo ?? NetworkInfo();
    _connectivity = connectivity ?? Connectivity();
    _subscription = _connectivity.onConnectivityChanged.listen((_) => _refresh());
    _refresh();
  }
  
  bool _isCameraWifi = false;
  
  Future<void> _refresh() async {
    final wifiName = await _networkInfo.getWifiName();
    final wifiBSSID = await _networkInfo.getWifiBSSID();
    _isCameraWifi = _matchesNikonPattern(wifiName) || _matchesNikonPattern(wifiBSSID);
    _controller.add(_isCameraWifi);
  }
  
  bool _matchesNikonPattern(String? s) {
    if (s == null) return false;
    return s.contains('Nikon') || s.contains('nikon');
  }
  
  @override
  bool get isCameraWifiConnected => _isCameraWifi;
  
  @override
  Stream<bool> get connectionStream => _controller.stream;
}
```

⚠️ v1 只用 SSID 前缀（Nikon_），BSSID 更稳定。Phase 3 用 BSSID + SSID 兼容。

### 9.3 权限

- Android: `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION`（`network_info_plus` 读 SSID 需要）+ `ACCESS_WIFI_STATE`
- iOS: `NSLocationWhenInUseUsageDescription`（`network_info_plus` 在 iOS 13+ 需要）

### 9.4 集成

`DownloadManagerNotifier.handleScenePhaseChange` + 监听 `wifiWatcher.connectionStream`：
```dart
// main.dart 初始化
WidgetsBinding.instance.addObserver(downloadManagerProvider.notifier);
ref.listen(wifiWatcherProvider, (prev, next) {
  if (!next && downloadManager.state.status == DownloadQueueStatus.running) {
    downloadManager.pauseQueue();
    ref.read(appShellProvider.notifier).appendLog('Wi-Fi 已断开相机热点，下载队列自动暂停。');
  }
});
```

### 9.5 测试（3 测）

1. 推送 connectivity change
2. SSID 含 "Nikon" → `isCameraWifiConnected = true`
3. SSID 是其他 Wi-Fi → `isCameraWifiConnected = false`

---

## 10. LogFileStore (`lib/services/log_file_store.dart`)

### 10.1 接口

```dart
abstract class LogFileStore {
  Future<void> append({required String message, required LogLevel level});
  Future<String> readAll();
  Future<File> exportFile();  // 复制到 downloadDir 给 share_plus 分享
}

enum LogLevel { info, warning, severe }
```

### 10.2 rotation 算法（明确）

```dart
class FileLogStore implements LogFileStore {
  static const _maxSizeBytes = 1024 * 1024;  // 1MB
  static const _maxRotatedFiles = 3;          // 保留 3 个旧文件
  
  @override
  Future<void> append({required String message, required LogLevel level}) async {
    await _lock.synchronized(() async {
      final timestamp = DateTime.now().toIso8601String().substring(11, 19);  // HH:mm:ss
      final line = '$timestamp [${level.name.toUpperCase()}] $message\n';
      final file = File(_currentPath);
      if (!await file.exists()) await file.create(recursive: true);
      
      // rotation check
      if (await file.length() + line.length > _maxSizeBytes) {
        await _rotate();
      }
      
      await file.writeAsString(line, mode: FileMode.append, flush: true);  // ✅ flush 防止丢日志
    });
  }
  
  Future<void> _rotate() async {
    // viewfinder.log.3 删除（最老）
    final oldestBackup = File('$_basePath/viewfinder.log.$_maxRotatedFiles');
    if (await oldestBackup.exists()) await oldestBackup.delete();
    // viewfinder.log.2 → viewfinder.log.3
    for (var i = _maxRotatedFiles - 1; i >= 1; i--) {
      final src = File('$_basePath/viewfinder.log.$i');
      final dst = File('$_basePath/viewfinder.log.${i + 1}');
      if (await src.exists()) await src.rename(dst.path);
    }
    // viewfinder.log → viewfinder.log.1
    await File(_currentPath).rename('$_basePath/viewfinder.log.1');
  }
  
  @override
  Future<File> exportFile() async {
    final src = File(_currentPath);
    final dstDir = Directory(await _downloadDir());
    final dst = File('${dstDir.path}/viewfinder-${DateTime.now().millisecondsSinceEpoch}.log');
    await src.copy(dst.path);
    return dst;
  }
}
```

### 10.3 AppLogger 集成

`setupLogging()` 在 `main.dart`：
```dart
void setupLogging() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final level = switch (record.level.name) {
      'INFO' => LogLevel.info,
      'WARNING' => LogLevel.warning,
      _ => LogLevel.severe,
    };
    ref.read(logFileStoreProvider).append(
      message: '${record.loggerName}: ${record.message}',
      level: level,
    );
    print('[${record.level.name}] ${record.loggerName}: ${record.message}');  // stdout
  });
}
```

### 10.4 测试（5 测）

1. `append` → 文件增长
2. `readAll` → 完整内容
3. 1MB rotation → 旧文件 `viewfinder.log.1/2/3`
4. 4 次 rotation → 最老的 `.3` 被删
5. `exportFile` → 复制到 downloadDir

---

## 11. iOS 平台创建

### 11.1 步骤

```bash
flutter create . --platforms=ios --org com.yaoyihan.viewfinder
```

创建 `ios/Runner/AppDelegate.swift` + `ios/Runner/Info.plist` + `ios/Runner.xcodeproj/`。

### 11.2 完整 Info.plist（修正版）

```xml
<dict>
  <!-- 已有 -->
  <key>CFBundleName</key><string>Viewfinder</string>
  <key>CFBundleDisplayName</key><string>Viewfinder</string>
  
  <!-- Phase 3 新增：网络 -->
  <key>NSLocalNetworkUsageDescription</key>
  <string>需要本地网络权限以连接 Nikon 相机的 Wi-Fi 热点。</string>
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
  </dict>
  
  <!-- Phase 3 新增：相册 -->
  <key>NSPhotoLibraryAddUsageDescription</key>
  <string>需要相册写入权限以保存下载的照片。</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>需要相册读取权限以查看已下载的照片。</string>
  
  <!-- Phase 3 新增：位置（Wi-Fi SSID 检测） -->
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>需要位置权限以检测是否连接 Nikon 相机的 Wi-Fi 热点。</string>
  
  <!-- Phase 3 新增：后台 -->
  <key>UIBackgroundModes</key>
  <array>
    <string>fetch</string>
  </array>
</dict>
```

⚠️ v1 漏 `NSAppTransportSecurity / NSLocationWhenInUseUsageDescription`。

### 11.3 iOS 限制

- **真机验证需 Mac**（Windows 上无法编 iOS）
- **Apple Developer 账号**：发布到 App Store 才需要；本地跑 Debug 不需要
- **Provisioning Profile**：Xcode 自动管理
- **Phase 3 iOS 部分 = "代码到位 + 真机未验证"**

---

## 12. Android 平台补全

### 12.1 AndroidManifest 完整权限清单（修正版）

`android/app/src/main/AndroidManifest.xml`：
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <!-- 已有 -->
  <uses-permission android:name="android.permission.INTERNET"/>
  
  <!-- Phase 3 新增 -->
  <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>      <!-- Wi-Fi SSID -->
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
  <uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE"/>
  
  <!-- 通知 (Android 13+) -->
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
  
  <!-- 相册写入 (Android < 13) -->
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                   android:maxSdkVersion="32"/>
  
  <!-- 媒体读取 (Android 13+) -->
  <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
  <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
  
  <!-- Foreground Service (Phase 3 后台下载) -->
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC"/>
  
  <application ...>
    <activity android:name=".MainActivity" ...>
      <!-- flutter_local_notifications receivers -->
      <receiver android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver"/>
      <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
    </activity>
    
    <!-- flutter_background_service -->
    <service android:name="id.flutter.flutter_background_service.BackgroundService"
             android:foregroundServiceType="dataSync"/>
  </application>
</manifest>
```

⚠️ v1 §16 缺几乎全部上述权限。

### 12.2 Phase 3 Android 平台代码（v1 漏）

`android/app/src/main/kotlin/com/yaoyihan/viewfinder/MainActivity.kt` 加 PhotoLibraryPlugin 注册：
```kotlin
class MainActivity: FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    PhotoLibraryPlugin.registerWith(flutterEngine.dartExecutor.binaryMessenger)
    BackgroundDownloadPlugin.registerWith(flutterEngine.dartExecutor.binaryMessenger)
  }
}
```

---

## 13. 缩略图集成到 Gallery

### 13.1 GalleryNotifier 扩展

```dart
class GalleryNotifier extends AsyncNotifier<GalleryState> {
  Future<Uint8List?> thumbnailFor(PhotoAsset asset) async {
    final session = ref.read(cameraSessionProvider);
    final transport = ref.read(cameraTransportProvider);
    if (session == null || transport == null) return null;
    return ref.read(thumbnailServiceProvider).thumbnailData(
      asset: asset, transport: transport, session: session,
    );
  }
}
```

### 13.2 gallery_page.dart

```dart
Widget _thumbnail(BuildContext context, PhotoAsset asset) {
  return FutureBuilder<Uint8List?>(
    future: ref.read(galleryProvider.notifier).thumbnailFor(asset),
    builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const ShimmerView();  // Phase 2 占位
      }
      if (snap.hasData && snap.data != null) {
        return Image.memory(snap.data!, fit: BoxFit.cover);
      }
      return _thumbnailPlaceholder(asset);  // Icon + filename fallback
    },
  );
}
```

### 13.3 CameraSessionCoordinator → Riverpod Provider

⚠️ v1 §12.3 写"用 Provider 替代"但没说如何同时存 activeTransport。需要 2 个 Provider：

```dart
final cameraSessionProvider = StateProvider<CameraSession?>((ref) => null);
final cameraTransportProvider = StateProvider<CameraTransport?>((ref) => null);

// ConnectionNotifier.connect() 成功后：
ref.read(cameraSessionProvider.notifier).state = session;
ref.read(cameraTransportProvider.notifier).state = transport;

// ConnectionNotifier.disconnect()：
ref.read(cameraSessionProvider.notifier).state = null;
ref.read(cameraTransportProvider.notifier).state = null;
```

### 13.4 GalleryContainer 加 onDownloadSelected

```dart
class GalleryContainer extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(galleryProvider);
    final prefs = ref.watch(preferencesProvider);
    
    return asyncState.when(
      data: (state) => GalleryPage(
        state: state,
        onRefresh: () => ref.read(galleryProvider.notifier).refresh(),
        onLoadMore: () => ref.read(galleryProvider.notifier).loadMore(),
        onToggleSelection: (id) => ref.read(galleryProvider.notifier).toggleSelection(id),
        onSelectAll: () => ref.read(galleryProvider.notifier).selectAllAssets(),
        onClearSelection: () => ref.read(galleryProvider.notifier).clearSelection(),
        onDownloadSelected: () {
          if (state.selectedAssets.isEmpty) return;
          ref.read(downloadManagerProvider.notifier).downloadSelected(
            state.selectedAssets,
            autoExport: prefs.autoExportToPhotoLibrary,
            prioritizeJPEG: prefs.prioritizeJPEGDownloads,
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('$err')),
    );
  }
}
```

### 13.5 Settings 页 "导出日志" 按钮

`features/settings/settings_page.dart` 加：
```dart
Widget _supportSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionHeader('支持与版本'),
      const SizedBox(height: 12),
      CustomCard(
        child: Column(
          children: [
            GridRowItem(label: '版本', value: 'Viewfinder v0.3.0', icon: Icons.info_outline),
            const SizedBox(height: 12),
            SecondaryActionButton(
              title: '导出日志',
              icon: Icons.upload_file,
              onPressed: () async {
                final file = await ref.read(logFileStoreProvider).exportFile();
                await Share.shareXFiles([XFile(file.path)], text: 'Viewfinder 日志');
              },
            ),
          ],
        ),
      ),
      // iOS 原版有 DisclosureGroup 显示 activityLog；Phase 3 也可加（optional）
    ],
  );
}
```

---

## 14. 目录结构（Phase 3 落地后）

```
lib/
├── main.dart                          ← Phase 3: 注入 7 个新 service Provider + setupLogging 接 LogFileStore
├── app.dart
│
├── domain/                            (Phase 0 + Phase 3 修 activeJob getter bug)
│
├── protocol/                          ← Phase 3 修 (⚠️ v1 标"无改"错)
│   ├── primitives/                    (Phase 1)
│   ├── transport/                     (Phase 1, Phase 3 修 ExperimentalNikonTransport.downloadAssetToTemporaryFile 真传 onProgress)
│   ├── session/
│   │   └── ptpip_session.dart          ← Phase 3 加 getObjectToTempFile(handle, filePath, onProgress)
│   ├── camera_transport.dart
│   ├── experimental_nikon_transport.dart ← Phase 3 修 onProgress 传递 bug
│   └── camera_transport_factory.dart
│
├── services/                          ← Phase 3 大幅扩展 (8 个新文件)
│   ├── preferences_store.dart              ✅
│   ├── logger.dart                          ✅
│   ├── download_asset_prioritizer.dart      ✅
│   ├── asset_thumbnail_service.dart         🆕 Phase 3 (~180 行)
│   ├── download_store.dart                  🆕 Phase 3 (~150 行, Lock + 3 文件持久化)
│   ├── download_notification_service.dart   🆕 Phase 3 (抽象 + Android/iOS 实现)
│   ├── background_download_runner.dart      🆕 Phase 3 (抽象 + FlutterForegroundService + iOS MethodChannel)
│   ├── wifi_watcher.dart                    🆕 Phase 3 (~80 行, connectivity_plus + network_info_plus)
│   ├── log_file_store.dart                  🆕 Phase 3 (~100 行, 1MB rotation + flush)
│
├── platform/                          ← Phase 3 新建
│   ├── photo_library_channel.dart           🆕 interface + PhotoLibraryPermission enum
│   ├── photo_library_channel_io.dart        🆕 test stub (写到 temp dir)
│   ├── photo_library_channel_android.dart   🆕 MethodChannel 调用
│   └── photo_library_channel_ios.dart       🆕 MethodChannel 调用
│
└── features/
    ├── app_shell/                            ✅ Phase 2 + Phase 3 (appendLog 委托 LogFileStore)
    ├── connection_setup/                    ✅ Phase 2 + Phase 3 (connect 成功后 set cameraSessionProvider, disconnect 清空)
    ├── photo_browser/                       ✅ Phase 2 + Phase 3 (GalleryPage 真实缩略图 + GalleryContainer.onDownloadSelected)
    ├── downloads/                            ← Phase 3 完整
    │   ├── downloads_container.dart         (Phase 3: ref.watch(downloadManagerProvider) 转发 7 回调)
    │   ├── downloads_page.dart               Phase 3 完整 (overview + queue + active + records 4 section；throughput 占位)
    │   └── download_manager_view_model.dart  Phase 3 完整 (~250 行，13 方法)
    ├── settings/                            ✅ Phase 2 + Phase 3 (SettingsPage 加 "导出日志" 按钮)
    └── shared/                              ✅ Phase 2

ios/  (Phase 3 新建)
├── Runner/
│   ├── AppDelegate.swift                   🆕 + BackgroundDownloadHandler 注册
│   ├── PhotoLibraryPlugin.swift            🆕 Swift 实现 MethodChannel
│   └── Info.plist                          🆕 + 11.2 完整权限清单
└── Runner.xcodeproj/

android/  (Phase 3 补全)
└── app/src/main/
    ├── AndroidManifest.xml                 🆕 + 12.1 完整权限清单
    └── kotlin/.../viewfinder/
        ├── MainActivity.kt                  🆕 + PhotoLibraryPlugin/BackgroundDownloadPlugin 注册
        ├── PhotoLibraryPlugin.kt            🆕 Kotlin 实现 MethodChannel
        └── BackgroundDownloadPlugin.kt      🆕 FlutterForegroundService + onExpiration callback
```

---

## 15. 任务切片（22 个，按依赖顺序）

> **关键修正**（vs v1）：
> - 3.13 提到 3.11 之前（依赖关系正确）
> - 3.10 改 GalleryContainer 接 onDownloadSelected（不是 DownloadsContainer）
> - 加 4 个任务：协议层修 (3.A/3.B) + 平台代码 (3.16b/3.16c/3.16d)
> - 测试清单 80+（v1 只 33）

| # | 任务 | 估时 | 前置 | 产出 |
|---|---|---|---|---|
| 3.0 | pubspec 加 `path_provider ^2.x` + `connectivity_plus ^6.x` + `network_info_plus ^4.x` + `flutter_local_notifications ^17.x` + `flutter_background_service ^5.x` + `share_plus ^9.x` + `permission_handler ^11.x`（**不加** `image ^4.x`） | 30 min | — | 7 个新依赖（v1 是 8 个，删 image） |
| **3.A** | **修 `PtpipSession.getObjectToTempFile` 加流式 + onProgress 支持** | 4 h | 3.0 | 新方法 + 3 测 |
| **3.B** | **修 `ExperimentalNikonTransport.downloadAssetToTemporaryFile` 真传 onProgress 给 §3.A 新方法** | 1 h | 3.A | onProgress 链打通 |
| 3.1 | `services/download_store.dart`（Lock + 3 JSON 文件 + markInterrupted 行为） | 3 h | 3.0 | DownloadStore + 7 测 |
| 3.2 | `services/asset_thumbnail_service.dart`（Lock + 内存/磁盘 + in-flight + RAW fallback 简化） | 3 h | 3.0 | AssetThumbnailService + 5 测 |
| 3.3 | `services/wifi_watcher.dart`（BSSID + SSID 兼容） | 1.5 h | 3.0 | WifiWatcher + 3 测 |
| 3.4 | `services/log_file_store.dart`（1MB rotation + flush + 3 文件备份） | 2 h | 3.0 | LogFileStore + 5 测 |
| 3.5 | `services/download_notification_service.dart`（抽象 + Android/iOS 实现 + deepLink） | 3 h | 3.0 | NotificationService + 4 测 |
| 3.6 | `services/background_download_runner.dart`（抽象 + Android flutter_background_service + iOS MethodChannel） | 3 h | 3.0 | BackgroundRunner + 3 测 |
| 3.7 | `platform/photo_library_channel.dart` + IO/Android/iOS 实现 + 删 mimeType + 加 PhotoLibraryPermission enum | 2 h | 3.0 | PhotoLibraryChannel + 5 测 |
| 3.8 | `features/downloads/download_manager_view_model.dart` 完整（13 方法 + 队列循环 + Task.checkCancellation + consumeDiagnostics + downloadSelected） | 8 h | 3.1 + 3.5 + 3.6 + 3.B | DownloadManagerNotifier + 13 测 |
| 3.9 | `features/downloads/downloads_page.dart` 完整 UI（4 section：overview + queue + active + records；throughput 占位 "Phase 4 实现"） | 4 h | 3.8 | DownloadsPage + 0 测（widget） |
| 3.10 | `features/photo_browser/gallery_container.dart` 加 onDownloadSelected 回调 | 1 h | 3.8 + 3.13 | GalleryContainer 完整 |
| 3.11 | `features/photo_browser/gallery_page.dart` 真实缩略图（Image.memory + ShimmerView fallback） | 2 h | 3.2 + 3.13 | GalleryPage 完整 |
| 3.12 | `features/settings/settings_page.dart` 加 "导出日志" 按钮 + share_plus | 1 h | 3.4 | SettingsPage 完整 |
| **3.13** | **`features/connection_setup/connection_view_model.dart` 加 `cameraSessionProvider` / `cameraTransportProvider` 注入 + 清空** | 1 h | — | ✅ GalleryPage 依赖此 |
| 3.14 | `lib/main.dart` 注入 7 个新 service Provider + setupLogging 接 LogFileStore + WidgetsBindingObserver | 1 h | 3.1-3.13 | wireUp 完成 |
| 3.15 | `lib/features/downloads/downloads_container.dart` 接 7 回调（onRefresh/pause/resume/cancelJob/retryJob/clearFinishedJobs）+ iOS Live Activity 占位 | 1 h | 3.8 | DownloadsContainer 完整 |
| **3.16a** | **iOS 平台创建** `flutter create . --platforms=ios` + Info.plist 完整 + 权限 | 1.5 h | — | `ios/` 目录 |
| **3.16b** | **`ios/Runner/AppDelegate.swift` + `BackgroundDownloadHandler.swift`** | 1.5 h | 3.16a | iOS 后台支持 |
| **3.16c** | **`ios/Runner/PhotoLibraryPlugin.swift`** | 1.5 h | 3.16a | iOS 相册导出 |
| **3.16d** | **`android/.../MainActivity.kt` + `PhotoLibraryPlugin.kt` + `BackgroundDownloadPlugin.kt`** | 2 h | 3.7 + 3.6 | Android 平台代码 |
| **3.16e** | **Android Manifest 完整权限清单（§12.1）+ receiver 注册** | 30 min | 3.16d | Android 权限 |
| 3.17 | 集成测试：缩略图缓存命中 + 缩略图并发 + 日志文件 rotation + queue 恢复 | 4 h | 3.1-3.15 | 8 集成测 |
| 3.18 | Android 真机端到端验证（连 Nikon → 浏览 → 选 → 下载 → 入相册）+ 杀进程恢复 + Wi-Fi 断线 | 6 h | 3.16e + 3.17 | 真机验收 |
| 3.19 | 文档同步（更新架构.md §1/§6 + Viewfinder方案.md + Phase2计划.md §7.1 + 项目状态.md §3/§5/§8/§10 + README.md + AGENTS.md §12） | 1.5 h | 3.18 | 7 个 .md 同步 |
| 3.20 | `dart analyze` + `flutter test` + `flutter build apk --debug` 全部绿 + commit（按 §19 commit 规范 11 个 commit） | 1.5 h | 全部 | Phase 3 完成 |

**总估时**：~52 小时纯干活（不含真机调试反复）→ **约 2-3 周**（按 4-5h/天）

### 15.1 任务依赖图（修正版）

```
3.0 pubspec
   │
   ├─► 3.A PtpipSession.getObjectToTempFile
   │      │
   │      └─► 3.B ExperimentalNikonTransport 真传 onProgress
   │             │
   │             ├─► 3.8 DownloadManagerNotifier (用 onProgress)
   │             └─► 3.11 GalleryPage 缩略图 (调 transport)
   │
   ├─► 3.1 DownloadStore
   │      └─► 3.8 DownloadManagerNotifier
   │
   ├─► 3.2 AssetThumbnailService
   │      └─► 3.11 GalleryPage
   │
   ├─► 3.3 WifiWatcher
   │      └─► 3.14 main.dart wireUp
   │
   ├─► 3.4 LogFileStore
   │      ├─► 3.12 SettingsPage 导出日志
   │      └─► 3.14 main.dart wireUp
   │
   ├─► 3.5 NotificationService
   │      └─► 3.8 DownloadManagerNotifier
   │
   ├─► 3.6 BackgroundRunner
   │      └─► 3.8 DownloadManagerNotifier
   │
   ├─► 3.7 PhotoLibraryChannel
   │      └─► 3.8 DownloadManagerNotifier
   │
   ├─► 3.13 ConnectionVM cameraSessionProvider (前置 — ；但 3.10/3.11 依赖)
   │      ├─► 3.10 GalleryContainer.onDownloadSelected
   │      └─► 3.11 GalleryPage 真实缩略图
   │
   └─► 3.8 DownloadManagerNotifier (前置 3.1 + 3.5 + 3.6 + 3.B)
          ├─► 3.9 DownloadsPage UI
          ├─► 3.10 GalleryContainer (3.13 之后)
          ├─► 3.11 GalleryPage (3.13 之后)
          ├─► 3.14 main.dart wireUp
          └─► 3.15 DownloadsContainer

3.16a iOS 平台创建
   ├─► 3.16b iOS Swift BackgroundDownloadHandler
   └─► 3.16c iOS Swift PhotoLibraryPlugin

3.16d Android 平台代码 (前置 3.7 + 3.6)
3.16e Android Manifest 权限 (前置 3.16d)

3.17 集成测 (前置 3.1-3.15)
3.18 真机 (前置 3.16e + 3.17)
3.19 文档同步 (前置 3.18)
3.20 commit (前置 3.19)
```

### 15.2 测试用例清单（80+ 新测）

#### 协议层（5 测）
1. `getObjectToTempFile 累计 bytes 正确`
2. `getObjectToTempFile chunk 中断正确 closeData`
3. `getObjectToTempFile 失败时清理 temp file`
4. `downloadAssetToTemporaryFile 真传 onProgress`
5. `downloadAssetToTemporaryFile handle 解析失败抛 unsupportedOperation`

#### DownloadStore（7 测）
1. `listRecords` 空 → `[]`
2. `saveQueueState` + `loadQueueState` round-trip
3. `storeDownloadedFile` unique -2/-3 后缀
4. `markExported` `record.exportedToPhotoLibrary = true`
5. `markInterruptedRunningJobs` running → interrupted，queued 保持
6. JSON 损坏恢复（loadQueueState 失败 → empty state）
7. Schema 兼容（缺字段走 default）

#### AssetThumbnailService（5 测）
1. 内存 cache hit：第二次调不调 transport
2. 磁盘 cache hit：load + 写内存
3. in-flight 去重：并发同 asset 调一次 transport
4. transport 返回 null：cache 不存负结果
5. `clear()`：清 inFlight map + 内存 cache

#### WifiWatcher（3 测）
1. 推送 connectivity change
2. SSID 含 "Nikon" → `isCameraWifiConnected = true`
3. SSID 是其他 Wi-Fi → `isCameraWifiConnected = false`

#### LogFileStore（5 测）
1. `append` → 文件增长
2. `readAll` → 完整内容
3. 1MB rotation → 旧文件 `viewfinder.log.1/2/3`
4. 4 次 rotation → 最老的 `.3` 被删
5. `exportFile` → 复制到 downloadDir

#### NotificationService（4 测）
1. `show(progress: 50)` 创建进度通知
2. `update(progress: 80)` 进度更新
3. `cancel` 通知消失
4. `cancelAll` 批量清

#### BackgroundRunner（3 测）
1. `begin` 调一次成功；重复 `begin` 跳过
2. `end` 后 `isActive = false`
3. Android `begin` 时调 `FlutterForegroundService.start(...)`

#### PhotoLibraryChannel（5 测）
1. `requestPermission` 授予 → granted
2. `requestPermission` 部分授权 → limited
3. `exportFile(JPEG)` → 成功
4. `exportFile(RAW)` → 成功
5. `exportFile` 异常路径 → throws

#### DownloadManagerNotifier（13 测）
1. `build()` 初始 state（empty + idle）
2. `enqueue(asset)` 按 JPEG 优先排序
3. `downloadSelected(assets)` 多 asset 入队 + 启动队列
4. `cancelJob(id)` → cancelled
5. `cancelAll()` → 所有非 terminal → cancelled
6. `retryJob(id)` → 重置进度 + queued
7. `clearFinished()` → 移除 terminal
8. `pauseQueue()` → paused
9. `resumeInterruptedQueue()` → running
10. `loadPersistedQueue()` → interrupted 自动标记
11. `refreshDownloads()` → 同步磁盘 records
12. `interruptActiveDownload(reason)` → 中止当前 job
13. `_normalizeQueueStatus()` 状态转换规则

#### 集成测试（8 测，`integration_test/` 新目录）
1. 完整流程：mock transport → 选 3 张 → 下载 → 入相册 → NotificationService 调 3 次 update
2. 队列恢复：kill mid-download → restart → interrupted → resume → 完成
3. Wi-Fi 断线：连接 → pause → 连接 → resume
4. 并发缩略图：同 asset 并发 5 个请求 → 只 1 次 transport 调用
5. 并发缩略图：不同 asset 并发 12 个 → 12 次 transport 调用
6. 日志 rotation：写入 2MB → 触发 rotation → viewfinder.log.1/2/3 存在
7. PhotoLibraryChannel iOS addOnly 真机测：iOS 真机授权弹窗 + 拒绝处理（仅真机）
8. PhotoLibraryChannel Android 真机测：Android 13+ POST_NOTIFICATIONS 拒绝处理（仅真机）

#### Domain 层（v1 没列，Phase 3 顺手测）
1. `DownloadQueueState.activeJob` getter 空 jobs 不抛 RangeError
2. `DownloadJob.isTerminal` × 7 status
3. `DownloadJob.canResume` × 7 status
4. `DownloadJob.fromAsset` factory 边界（negative byteSize）
5. `DownloadQueueStatus.displayTitle` × 4 status
6. `DownloadQueueState` 6 getter
7. `DownloadJob` JSON round-trip
8. `DownloadQueueState` JSON round-trip
9. `DownloadRecord` JSON round-trip

#### 已有的（Phase 2 保留）
- `test/features/app_shell/app_shell_view_model_test.dart` 4 测
- `test/features/connection_setup/connection_view_model_test.dart` 5 测
- `test/features/photo_browser/gallery_view_model_test.dart` 5 测
- `test/features/downloads/download_manager_view_model_test.dart` 3 测
- `test/features/settings/settings_view_model_test.dart` 4 测
- `test/features/shared/app_theme_test.dart` 17 测
- `test/services/preferences_store_test.dart` 5 测
- `test/services/download_asset_prioritizer_test.dart` 5 测
- `test/smoke_test.dart` 8 测
- `test/widget_test.dart` 1 测
- `test/protocol/*` 47 测

**总计**：47 + 21 + 60 + 13 + 8 = **149 测试**

Phase 2 已有 102 → Phase 3 新增 80 → 总 182 测试。

---

## 16. 验收标准

```bash
cd "D:\桌面\Nikon_connect\Viewfinder"

dart analyze                                  # No issues found!
flutter test                                  # All 182 tests passed
flutter build apk --debug                     # BUILD SUCCESSFUL（Android）
```

1. ✅ `dart analyze` 零警告
2. ✅ `flutter test` 全绿（Phase 2 102 + Phase 3 80 = 182）
3. ✅ `flutter build apk --debug` Android 装到真机启动
4. ✅ Android 真机端到端：
   - 连 Nikon 相机 → 浏览 12+ 张真实缩略图（从相机拉的，不是 mock）
   - 选 3 张 → 点下载 → 通知显示 3 个进度条
   - 下载完成 → JPEG/PNG 入相册，RAW 存应用本地
   - 杀进程 → 重启 → 队列显示 3 张 interrupted → 按"继续"恢复
   - 断 Wi-Fi → 队列自动暂停 + log "Wi-Fi 已断开"
   - 重连 Wi-Fi → 按"继续"恢复
   - Settings 页 "导出日志" → 分享面板弹出
5. ✅ iOS 平台代码到位（`ios/Runner/AppDelegate.swift` + Info.plist + Swift 插件），但**真机验证需 Mac**，记为已知限制
6. ✅ 7 个 .md 文档同步（项目状态 / 架构 / Viewfinder方案 / Phase2计划 / 产品需求 / AGENTS / README）

---

## 17. 已知坑和应急方案

### 17.1 Android 13+ POST_NOTIFICATIONS 运行时权限

**症状**：Android 13+ 通知不弹，logcat 报 "Missing POST_NOTIFICATIONS permission"。

**解法**：用 `permission_handler` 包，AppShellNotifier 在 app 启动后请求 `Permission.notification.request()`。用户拒绝后只显示 in-app 通知，notification 静默。

### 17.2 iOS Photos 拒绝授权

**症状**：iOS 用户拒绝 `.addOnly` 权限，导出到相册失败。

**解法**：`PhotoLibraryChannel.requestPermission` 返回 `neverAskAgain` 时，AppShellNotifier 显示 alert "去系统设置开启照片权限"，附带 `app_settings: ^5.x` 跳设置。

### 17.3 Android 13+ ACCESS_FINE_LOCATION + Wi-Fi SSID

**症状**：`network_info_plus.getWifiBSSID()` 在 Android 13+ 返回 "02:00:00:00:00:00"（脱敏占位），除非 ACCESS_FINE_LOCATION 已授权。

**解法**：AppShellNotifier 启动后请求 `Permission.locationWhenInUse.request()`。拒绝则 SSID 退化为 `getWifiName()`（精度低但能用）。

### 17.4 flutter_background_service 在 isolate

**症状**：`FlutterForegroundService` 启动的后台 isolate 不能直接用 Riverpod Provider。

**解法**：**Phase 3 简化**——FlutterForegroundService 不启动独立 isolate，仅在 main isolate 调 `FlutterForegroundService.start()` 让 Android 保持 app 进程 5-10 分钟。所有下载业务仍在 main isolate 跑。

### 17.5 iOS 真机验证需 Mac + Apple Developer

**症状**：Windows 上 `flutter build ios` 必然失败。

**解法**：
- Phase 3 iOS 部分 = "代码到位 + 真机未验证"
- 找 Mac 借：找同事 / 借 MacBook / GitHub Actions macOS runner
- Phase 3 验收明确"iOS 代码到位"为 soft 验收

### 17.6 iOS Live Activity 跨端降级

**症状**：Phase 3 不实现 iOS Live Activity（跨端降级为 flutter_local_notifications），iOS 用户体验降级。

**解法**：README.md 明确说明；Phase 4 可选补 ActivityKit platform channel。

### 17.7 中文路径 Flutter 工具链

**症状**：跟 Phase 1/2 一样，`flutter analyze` 在中文路径下有 LSP bug。

**解法**：用 `dart analyze` 替代 `flutter analyze`。

### 17.8 phase 1 protocol layer onProgress bug

**症状**：Phase 1 `ExperimentalNikonTransport.downloadAssetToTemporaryFile` 接受 `onProgress` 但不传（v1 漏修）。

**解法**：§3.A 修 `PtpipSession.getObjectToTempFile` 加流式 + onProgress；§3.B 修 Transport 真传。

### 17.9 phase 2 DownloadQueueState.activeJob getter bug

**症状**：`activeJob` getter 的 `orElse: () => jobs.first` 在 jobs 为空时抛 RangeError。

**解法**：Phase 3 顺手修：
```dart
DownloadJob? get activeJob {
  final id = activeJobID;
  if (id == null || jobs.isEmpty) return null;
  for (final j in jobs) {
    if (j.id == id) return j;
  }
  return null;  // 不抛异常，返回 null
}
```

### 17.10 PTP/IP 协议不同 Nikon 机身高低差异

**症状**：Nikon 不同机型（Z5 / Z8 / D850）opcode 行为可能不同。

**解法**：Phase 3 真机测试覆盖多机型；不兼容机型 `transport.fetchAssetsPage` 容错返回空；`transport.consumeDiagnostics()` 收集错误日志写 LogFileStore。

### 17.11 并发 manifest 文件读写

**症状**：多个 `markExported / storeDownloadedFile` 并发调用导致 race condition（manifest 文件读-改-写不一致）。

**解法**：`DownloadStore` 用 `Lock` (`package:sync`) 串行化所有 IO（§4.2）。

---

## 18. 不在本 Phase 范围（推到 Phase 4 / 5）

- ❌ **Phase 4**：UI 抛光 + StatusBadge pulsing + LensGlow 呼吸 + Shimmer 闪烁 + Haptics 触觉
- ❌ **Phase 4**：PTP/IP chunk 下载优化（iOS 自适应 1-8MB chunk；Flutter Phase 3 单次全文件）
- ❌ **Phase 4**：客户端 RAW 缩略图降采样（用 `image` 包解码 .NEF）
- ❌ **Phase 4**：客户端 RAW 预览（超高分辨率 JPEG 转码）
- ❌ **Phase 4**：MV 缩略图（AVFoundation 替代 CGImage）
- ❌ **Phase 4**：Dark Mode
- ❌ **Phase 4**：Settings 页 "导出下载文件" + 选择性同步相册
- ❌ **Phase 4**：iOS Live Activity（可选，ActivityKit platform channel）
- ❌ **Phase 5**：多品牌（Sony / Canon / Fujifilm）

---

## 19. 提交规范（AGENTS.md §8.2）

```
<动词><对象>：<一句话说明>
```

按依赖顺序拆 11 个 commit（推荐）：

```
修协议层：PtpipSession.getObjectToTempFile 加流式 onProgress
修协议层：ExperimentalNikonTransport 真传 onProgress 给 getObjectToTempFile
实现 download_store：JSON 持久化 + Lock 并发安全 + markInterrupted
实现 asset_thumbnail_service：内存+磁盘 cache + Lock 并发安全
实现 wifi_watcher + log_file_store：断线检测 + 1MB rotation 日志
实现 download_notification_service + background_runner：进度通知 + 后台
实现 photo_library_channel：相册导出（Android + iOS + IO stub）
实现 DownloadManagerNotifier 完整 13 方法：downloadSelected + 队列循环 + cancel/retry/pause/resume + loadPersistedQueue
iOS 平台创建：Info.plist + AppDelegate.swift + PhotoLibraryPlugin.swift + BackgroundDownloadHandler.swift
Android 平台代码：MainActivity.kt + PhotoLibraryPlugin.kt + BackgroundDownloadPlugin.kt + Manifest 完整权限
新增 80 测试：protocol/onProgress + download_store + thumbnail + wifi + log + notification + runner + photo_library + download_manager + domain + 集成测
Phase 3 验收 + 文档同步：架构.md / 项目状态.md / Viewfinder方案.md / Phase2 §7.1 / AGENTS.md / README.md / 产品需求.md
```

---

## 20. Phase 3 vs Phase 4 边界（修正版）

| 维度 | Phase 3 | Phase 4 |
|---|---|---|
| 下载链路 | ✅ 完整 + onProgress | 优化（chunk size + 吞吐录制展示） |
| 后台执行 | ✅ Android Foreground Service + iOS beginBackgroundTask | 优化（不杀进程保证） |
| 进度通知 | ✅ Android 进度条 + iOS 静态文字 | iOS Live Activity（可选） |
| 缩略图 | ✅ 相机自带缩略图 + cache | 客户端降采样 + Dark Mode |
| Throughput 诊断 | ⚠️ Phase 3 仅 Recorder.start/finish 调用，**UI 不展示**（占位） | UI 展示（top 5 reports） |
| Wi-Fi 断线 | ✅ 自动 pause | 重连策略 + 手动 resume |
| 日志导出 | ✅ share_plus | 远程日志上报（可选） |
| UI 动画 | 占位 | StatusBadge pulsing + LensGlow 呼吸 + Shimmer 闪烁 |
| Haptics | 占位 | 实际接 UIImpactFeedbackGenerator |
| Dark Mode | 不做 | ✅ |
| iOS 真机验证 | ⏳ 待 Mac | ✅ |
| 多品牌 | 不做 | 不做（Phase 5） |

---

## 21. 文档同步清单

Phase 3 完成时要同步：

| 文档 | 同步内容 |
|---|---|
| `AGENTS.md §12` | 加 Phase 3 完成条目 + 新决策（onProgress 链 / Provider 替代 Coordinator） |
| `README.md` | Phase 3 ✅ 状态 + 当前能力 + 真机验证要求 |
| `docs/产品需求.md §F5/§4.4/§8` | 加 Phase 3 完成 + 运行时权限说明 |
| `docs/架构.md §1/§3/§6/§7/§10` | 加 8 个新 Provider + PhotoLibraryChannel + 平台代码 + 依赖清单 |
| `docs/Viewfinder方案.md §6/§11/§Phase3段` | 完整协议层 + iOS/Android 平台映射 + Phase 3 任务列表更新 |
| `docs/项目状态.md §1/§2/§3/§4/§5.4/§8/§10` | Phase 3 ✅ + 测试 182 + 决策 11 条 |
| `docs/Phase2实施计划.md §7.1` | **删"磁盘 cache 不实现"**（v1 §3.1 改决策） |
| `docs/Phase3实施计划.md` | **v1 → v2 替换**（本文档） |

---

## 22. 完成后

Phase 3 完成后，本工程就有了：
- ✅ 完整下载链路（连接 → 选 → 下载 → 入相册）+ 真机验证
- ✅ Android 端进度通知 + 后台执行 + Wi-Fi 断线感知
- ✅ 日志文件 + 导出分享
- ✅ iOS 平台代码（待 Mac 真机验证）
- ✅ 协议层修 onProgress bug（避免 50MB 内存爆 + 进度条失效）
- ✅ 182 测试全绿

Phase 4 在骨架上填肉：UI 抛光 + 触觉 + 动效 + iOS Live Activity（可选）。
Phase 5 多品牌扩展。

**这份文档 = Phase 3 的工作说明书（v2）。**
