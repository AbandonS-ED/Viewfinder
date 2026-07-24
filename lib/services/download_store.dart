import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sync/sync.dart';

import '../domain/camera_app_error.dart';
import '../domain/download_job.dart';
import '../domain/download_queue_state.dart';
import '../domain/download_record.dart';
import '../domain/photo_asset.dart';

/// Phase 3 §4.1. JSON 持久化下载记录 + 队列状态。
abstract class DownloadStoring {
  Future<Directory> downloadsDirectoryURL();
  Future<List<DownloadRecord>> listRecords();
  Future<DownloadRecord> storeDownloadedFile({
    required String sourcePath,
    required PhotoAsset asset,
  });
  Future<DownloadRecord> markExported(String recordID);
  Future<DownloadQueueState> loadQueueState();
  Future<DownloadQueueState> saveQueueState(DownloadQueueState state);
  Future<DownloadQueueState> upsertDownloadJob({
    required DownloadJob job,
    required DownloadQueueStatus queueStatus,
    required String? activeJobID,
  });
  Future<DownloadQueueState> removeDownloadJobs({
    required List<String> ids,
    required DownloadQueueStatus queueStatus,
    required String? activeJobID,
  });
  Future<DownloadQueueState> markInterruptedRunningJobs({String? reason});
}

class DownloadStore implements DownloadStoring {
  DownloadStore({required this.rootDirectory, Mutex? mutex})
      : _mutex = mutex ?? Mutex();

  /// 应用根目录。暴露给测试断言路径布局。
  final Directory rootDirectory;
  final Mutex _mutex;
  static const _manifestFileName = 'downloads-manifest.json';
  static const _queueFileName = 'download-jobs.json';
  static const _downloadsSubdirName = 'Downloads';

  /// 串行化临界区。Phase 3 简化：每方法一个 acquire/release。
  Future<T> _withLock<T>(Future<T> Function() body) async {
    await _mutex.acquire();
    try {
      return await body();
    } finally {
      _mutex.release();
    }
  }

  Directory _downloadsDir() {
    final dir = Directory(p.join(rootDirectory.path, _downloadsSubdirName));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  File _manifestFile() => File(p.join(_downloadsDir().path, _manifestFileName));
  File _queueFile() => File(p.join(_downloadsDir().path, _queueFileName));

  // ============ Public API ============

  @override
  Future<Directory> downloadsDirectoryURL() async => _downloadsDir();

  @override
  Future<List<DownloadRecord>> listRecords() => _withLock(_readManifest);

  @override
  Future<DownloadRecord> storeDownloadedFile({
    required String sourcePath,
    required PhotoAsset asset,
  }) {
    return _withLock(() async {
      final src = File(sourcePath);
      if (!src.existsSync()) {
        throw const CameraAppError.fileSystemFailure('下载的临时文件不存在。');
      }

      final dest = _uniqueDestinationPath(asset.fileName);
      try {
        await src.rename(dest);
      } on FileSystemException catch (e) {
        throw CameraAppError.fileSystemFailure('无法移动下载文件：${e.message}');
      }

      final size = await _safeFileSize(dest);
      final record = DownloadRecord(
        sourceAssetIdentifier: asset.remoteIdentifier,
        fileName: p.basename(dest),
        savedURL: dest,
        byteSize: size,
        completedAt: DateTime.now(),
        exportedToPhotoLibrary: false,
      );

      final manifest = await _readManifest();
      manifest.add(record);
      await _writeManifest(manifest);
      return record;
    });
  }

  @override
  Future<DownloadRecord> markExported(String recordID) {
    return _withLock(() async {
      final manifest = await _readManifest();
      final index = manifest.indexWhere((r) => r.id == recordID);
      if (index < 0) {
        throw CameraAppError.fileSystemFailure('找不到下载记录：$recordID');
      }
      final updated = manifest[index].copyWith(exportedToPhotoLibrary: true);
      manifest[index] = updated;
      await _writeManifest(manifest);
      return updated;
    });
  }

  @override
  Future<DownloadQueueState> loadQueueState() => _withLock(_readQueueOrEmpty);

  @override
  Future<DownloadQueueState> saveQueueState(DownloadQueueState state) {
    return _withLock(() async {
      await _writeQueue(state);
      return state;
    });
  }

  @override
  Future<DownloadQueueState> upsertDownloadJob({
    required DownloadJob job,
    required DownloadQueueStatus queueStatus,
    required String? activeJobID,
  }) {
    return _withLock(() async {
      final state = await _readQueueOrEmpty();
      final jobs = List<DownloadJob>.from(state.jobs);
      final idx = jobs.indexWhere((j) => j.id == job.id);
      if (idx >= 0) {
        jobs[idx] = job;
      } else {
        jobs.add(job);
      }
      final next = state.copyWith(
        jobs: jobs,
        activeJobID: activeJobID,
        status: queueStatus,
      );
      await _writeQueue(next);
      return next;
    });
  }

  @override
  Future<DownloadQueueState> removeDownloadJobs({
    required List<String> ids,
    required DownloadQueueStatus queueStatus,
    required String? activeJobID,
  }) {
    return _withLock(() async {
      final state = await _readQueueOrEmpty();
      final jobs = state.jobs.where((j) => !ids.contains(j.id)).toList();
      final nextActive = state.activeJobID == null || ids.contains(state.activeJobID)
          ? null
          : state.activeJobID;
      final hasPending = jobs.any((j) => !j.status.isTerminal);
      final next = state.copyWith(
        jobs: jobs,
        activeJobID: hasPending ? nextActive : null,
        status: hasPending ? queueStatus : DownloadQueueStatus.idle,
      );
      await _writeQueue(next);
      return next;
    });
  }

  @override
  Future<DownloadQueueState> markInterruptedRunningJobs({String? reason}) {
    return _withLock(() async {
      final state = await _readQueueOrEmpty();
      final now = DateTime.now();
      var anyInterrupted = false;
      final jobs = state.jobs.map((job) {
        if (job.status != DownloadJobStatus.running) return job;
        anyInterrupted = true;
        return job.copyWith(
          status: DownloadJobStatus.interrupted,
          updatedAt: now,
          errorMessage: reason,
        );
      }).toList();
      final hasPending = jobs.any((j) => !j.status.isTerminal);
      final next = state.copyWith(
        jobs: jobs,
        activeJobID: null,
        status: anyInterrupted
            ? DownloadQueueStatus.interrupted
            : (hasPending ? state.status : DownloadQueueStatus.idle),
      );
      await _writeQueue(next);
      return next;
    });
  }

  // ============ Internal IO ============

  Future<List<DownloadRecord>> _readManifest() async {
    final file = _manifestFile();
    if (!file.existsSync()) return <DownloadRecord>[];
    try {
      final raw = await file.readAsString();
      if (raw.isEmpty) return <DownloadRecord>[];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => _decodeRecord(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // 损坏 manifest：备份后返回空（不抛，避免启动崩溃）
      await _backupCorrupted(file);
      return <DownloadRecord>[];
    }
  }

  Future<void> _writeManifest(List<DownloadRecord> records) async {
    final file = _manifestFile();
    final dir = file.parent;
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final encoded = jsonEncode(records.map(_encodeRecord).toList());
    await file.writeAsString(encoded, flush: true);
  }

  Future<DownloadQueueState> _readQueueOrEmpty() async {
    final file = _queueFile();
    if (!file.existsSync()) return const DownloadQueueState();
    try {
      final raw = await file.readAsString();
      if (raw.isEmpty) return const DownloadQueueState();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return _decodeQueueState(json);
    } catch (_) {
      await _backupCorrupted(file);
      return const DownloadQueueState();
    }
  }

  Future<void> _writeQueue(DownloadQueueState state) async {
    final file = _queueFile();
    final dir = file.parent;
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final encoded = jsonEncode(_encodeQueueState(state));
    await file.writeAsString(encoded, flush: true);
  }

  Future<void> _backupCorrupted(File file) async {
    try {
      final backup = File('${file.path}.corrupt.${DateTime.now().millisecondsSinceEpoch}');
      await file.rename(backup.path);
    } catch (_) {
      // 备份失败也吞（避免启动崩溃）
    }
  }

  String _uniqueDestinationPath(String fileName) {
    final dir = _downloadsDir().path;
    var candidate = p.join(dir, fileName);
    if (!File(candidate).existsSync()) return candidate;
    final dotIdx = fileName.lastIndexOf('.');
    final base = dotIdx > 0 ? fileName.substring(0, dotIdx) : fileName;
    final ext = dotIdx > 0 ? fileName.substring(dotIdx) : '';
    var index = 2;
    while (true) {
      candidate = p.join(dir, '$base-$index$ext');
      if (!File(candidate).existsSync()) return candidate;
      index += 1;
    }
  }

  Future<int> _safeFileSize(String path) async {
    try {
      final file = File(path);
      final size = await file.length();
      return size < 0 ? 0 : size;
    } catch (_) {
      return 0;
    }
  }

  // ============ JSON codecs ============

  Map<String, dynamic> _encodeRecord(DownloadRecord r) => {
        'id': r.id,
        'sourceAssetIdentifier': r.sourceAssetIdentifier,
        'fileName': r.fileName,
        'savedURL': r.savedURL,
        'byteSize': r.byteSize,
        'completedAt': r.completedAt.toIso8601String(),
        'exportedToPhotoLibrary': r.exportedToPhotoLibrary,
      };

  DownloadRecord _decodeRecord(Map<String, dynamic> j) {
    return DownloadRecord(
      id: (j['id'] as String?) ?? '',
      sourceAssetIdentifier: j['sourceAssetIdentifier'] as String? ?? '',
      fileName: j['fileName'] as String? ?? '',
      savedURL: j['savedURL'] as String? ?? '',
      byteSize: (j['byteSize'] as num?)?.toInt() ?? 0,
      completedAt: DateTime.tryParse(j['completedAt'] as String? ?? '') ?? DateTime.now(),
      exportedToPhotoLibrary: j['exportedToPhotoLibrary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _encodeQueueState(DownloadQueueState s) => {
        'jobs': s.jobs.map(_encodeJob).toList(),
        'activeJobID': s.activeJobID,
        'status': s.status.name,
      };

  DownloadQueueState _decodeQueueState(Map<String, dynamic> j) {
    final jobsJson = j['jobs'] as List<dynamic>? ?? const [];
    return DownloadQueueState(
      jobs: jobsJson
          .map((e) => _decodeJob(e as Map<String, dynamic>))
          .toList(),
      activeJobID: j['activeJobID'] as String?,
      status: _decodeQueueStatus(j['status'] as String? ?? 'idle'),
    );
  }

  Map<String, dynamic> _encodeJob(DownloadJob j) => {
        'id': j.id,
        'remoteIdentifier': j.remoteIdentifier,
        'fileName': j.fileName,
        'kind': j.kind.name,
        'byteSize': j.byteSize,
        'captureDate': j.captureDate.toIso8601String(),
        'autoExportToPhotoLibrary': j.autoExportToPhotoLibrary,
        'status': j.status.name,
        'bytesTransferred': j.bytesTransferred,
        'totalBytes': j.totalBytes,
        'currentOffset': j.currentOffset,
        'resumedCount': j.resumedCount,
        'createdAt': j.createdAt.toIso8601String(),
        'startedAt': j.startedAt?.toIso8601String(),
        'completedAt': j.completedAt?.toIso8601String(),
        'updatedAt': j.updatedAt.toIso8601String(),
        'errorMessage': j.errorMessage,
      };

  DownloadJob _decodeJob(Map<String, dynamic> j) {
    return DownloadJob(
      id: (j['id'] as String?) ?? '',
      remoteIdentifier: j['remoteIdentifier'] as String? ?? '',
      fileName: j['fileName'] as String? ?? '',
      kind: _decodeKind(j['kind'] as String? ?? 'raw'),
      byteSize: (j['byteSize'] as num?)?.toInt() ?? 0,
      captureDate: DateTime.tryParse(j['captureDate'] as String? ?? '') ?? DateTime.now(),
      autoExportToPhotoLibrary: j['autoExportToPhotoLibrary'] as bool? ?? false,
      status: _decodeJobStatus(j['status'] as String? ?? 'queued'),
      bytesTransferred: (j['bytesTransferred'] as num?)?.toInt() ?? 0,
      totalBytes: (j['totalBytes'] as num?)?.toInt() ?? 0,
      currentOffset: (j['currentOffset'] as num?)?.toInt() ?? 0,
      resumedCount: (j['resumedCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
      startedAt: _tryParseDateTime(j['startedAt'] as String?),
      completedAt: _tryParseDateTime(j['completedAt'] as String?),
      updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '') ?? DateTime.now(),
      errorMessage: j['errorMessage'] as String?,
    );
  }

  DateTime? _tryParseDateTime(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  DownloadJobStatus _decodeJobStatus(String s) {
    for (final v in DownloadJobStatus.values) {
      if (v.name == s) return v;
    }
    return DownloadJobStatus.queued;
  }

  DownloadQueueStatus _decodeQueueStatus(String s) {
    for (final v in DownloadQueueStatus.values) {
      if (v.name == s) return v;
    }
    return DownloadQueueStatus.idle;
  }

  PhotoAssetKind _decodeKind(String s) {
    for (final v in PhotoAssetKind.values) {
      if (v.name == s) return v;
    }
    return PhotoAssetKind.raw;
  }
}
