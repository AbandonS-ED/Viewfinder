import 'package:freezed_annotation/freezed_annotation.dart';

import 'download_job.dart';
import 'photo_asset.dart';

part 'download_throughput_diagnostics.freezed.dart';

/// 吞吐诊断 (调试用，对齐 iOS DownloadThroughputDiagnostics 整套)
@freezed
class DownloadThroughputDiagnostics with _$DownloadThroughputDiagnostics {
  const factory DownloadThroughputDiagnostics({
    required DownloadThroughputTransferMode transferMode,
    @Default(<int>[]) List<int> samples,
    @Default(0) int averageBps,
    @Default(0) int peakBps,
  }) = _DownloadThroughputDiagnostics;
}

/// 传输模式 (对齐 iOS 顺序)
enum DownloadThroughputTransferMode {
  getObject,         // 完整 GetObject
  getPartialObject,  // 分段 GetPartialObject (自适应)
  unknown;           // 未知
}

/// 下载场景 (对齐 iOS)
enum DownloadThroughputScene {
  foreground,    // 前台
  inactive,      // 切换中
  background;    // 后台
}

/// 单个下载块采样
@freezed
class DownloadThroughputChunkSample with _$DownloadThroughputChunkSample {
  const factory DownloadThroughputChunkSample({
    required DateTime startedAt,
    required DateTime finishedAt,
    required int bytesTransferred,
    required int deltaBytes,
    required int totalBytes,
    required int chunkSize,
    required DownloadThroughputScene scene,
  }) = _DownloadThroughputChunkSample;

  const DownloadThroughputChunkSample._();

  double get durationSeconds {
    final diff = finishedAt.difference(startedAt).inMilliseconds / 1000.0;
    return diff < 0 ? 0 : diff;
  }

  double get bytesPerSecond {
    if (durationSeconds <= 0) return 0;
    return deltaBytes / durationSeconds;
  }
}

/// 一次下载的完整吞吐报告
@freezed
class DownloadThroughputReport with _$DownloadThroughputReport {
  const factory DownloadThroughputReport({
    @Default('') String id,
    required String fileName,
    required PhotoAssetKind fileKind,
    @Default(0) int byteSize,
    @Default(0) int itemNumber,
    @Default(0) int totalItemCount,
    required DownloadThroughputTransferMode transferMode,
    required DownloadThroughputScene initialScene,
    required DownloadThroughputScene currentScene,
    required DateTime startedAt,
    required DateTime finishedAt,
    @Default(0) int lastBytesTransferred,
    @Default(<DownloadThroughputChunkSample>[]) List<DownloadThroughputChunkSample> chunkSamples,
    @Default(0) int liveActivityUpdateCount,
    @Default(0) int queuePersistenceCount,
    @Default(0) int backgroundExpirationCount,
    required DownloadJobStatus terminalStatus,
  }) = _DownloadThroughputReport;

  const DownloadThroughputReport._();

  double get durationSeconds {
    final diff = finishedAt.difference(startedAt).inMilliseconds / 1000.0;
    return diff < 0 ? 0 : diff;
  }

  double get averageBytesPerSecond {
    if (durationSeconds <= 0) return 0;
    return lastBytesTransferred / durationSeconds;
  }

  String get averageSpeedText {
    if (!averageBytesPerSecond.isFinite || averageBytesPerSecond <= 0) {
      return '0 MB/s';
    }
    final mb = averageBytesPerSecond / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB/s';
  }

  String get displaySummary =>
    '$fileName · $transferMode · $currentScene · $averageSpeedText';
}

/// 吞吐录制器 (纯 Dart 类，对齐 iOS DownloadThroughputDiagnosticsRecorder)
class DownloadThroughputDiagnosticsRecorder {
  DownloadThroughputDiagnosticsRecorder();

  _ActiveRecording? _active;

  void start({
    required DownloadJob job,
    required int itemNumber,
    required int totalItemCount,
    required DownloadThroughputTransferMode transferMode,
    required DownloadThroughputScene scene,
    DateTime? at,
  }) {
    final now = at ?? DateTime.now();
    _active = _ActiveRecording(
      id: now.microsecondsSinceEpoch.toString(),
      fileName: job.fileName,
      fileKind: job.kind,
      byteSize: job.byteSize,
      itemNumber: itemNumber,
      totalItemCount: totalItemCount,
      transferMode: transferMode,
      initialScene: scene,
      currentScene: scene,
      startedAt: now,
      lastProgressAt: now,
    );
  }

  void recordSceneChange(DownloadThroughputScene scene, {DateTime? at}) {
    _active?.currentScene = scene;
  }

  void recordProgress({
    required int bytesTransferred,
    required int totalBytes,
    required int chunkSize,
    required DownloadThroughputScene scene,
    DateTime? at,
  }) {
    final rec = _active;
    if (rec == null) return;
    final now = at ?? DateTime.now();
    final transferred = bytesTransferred < 0 ? 0 : bytesTransferred;
    final delta = transferred - rec.lastBytesTransferred;
    if (delta > 0) {
      rec.chunkSamples.add(DownloadThroughputChunkSample(
        startedAt: rec.lastProgressAt,
        finishedAt: now,
        bytesTransferred: transferred,
        deltaBytes: delta,
        totalBytes: totalBytes < transferred ? transferred : totalBytes,
        chunkSize: chunkSize < 0 ? 0 : chunkSize,
        scene: scene,
      ));
    }
    rec.lastProgressAt = now;
    rec.lastBytesTransferred = transferred;
    rec.currentScene = scene;
  }

  void recordLiveActivityUpdate() {
    final rec = _active;
    if (rec == null) return;
    rec.liveActivityUpdateCount += 1;
  }

  void recordQueuePersistence() {
    final rec = _active;
    if (rec == null) return;
    rec.queuePersistenceCount += 1;
  }

  void recordBackgroundExpiration() {
    final rec = _active;
    if (rec == null) return;
    rec.backgroundExpirationCount += 1;
  }

  DownloadThroughputReport? finish({
    required DownloadJobStatus status,
    DateTime? at,
  }) {
    final rec = _active;
    if (rec == null) return null;
    final now = at ?? DateTime.now();
    _active = null;
    return DownloadThroughputReport(
      id: rec.id,
      fileName: rec.fileName,
      fileKind: rec.fileKind,
      byteSize: rec.byteSize,
      itemNumber: rec.itemNumber,
      totalItemCount: rec.totalItemCount,
      transferMode: rec.transferMode,
      initialScene: rec.initialScene,
      currentScene: rec.currentScene,
      startedAt: rec.startedAt,
      finishedAt: now,
      lastBytesTransferred: rec.lastBytesTransferred,
      chunkSamples: List.unmodifiable(rec.chunkSamples),
      liveActivityUpdateCount: rec.liveActivityUpdateCount,
      queuePersistenceCount: rec.queuePersistenceCount,
      backgroundExpirationCount: rec.backgroundExpirationCount,
      terminalStatus: status,
    );
  }
}

class _ActiveRecording {
  _ActiveRecording({
    required this.id,
    required this.fileName,
    required this.fileKind,
    required this.byteSize,
    required this.itemNumber,
    required this.totalItemCount,
    required this.transferMode,
    required this.initialScene,
    required this.currentScene,
    required this.startedAt,
    required this.lastProgressAt,
  });

  final String id;
  final String fileName;
  final PhotoAssetKind fileKind;
  final int byteSize;
  final int itemNumber;
  final int totalItemCount;
  final DownloadThroughputTransferMode transferMode;
  final DownloadThroughputScene initialScene;
  DownloadThroughputScene currentScene;
  final DateTime startedAt;
  DateTime lastProgressAt;
  int lastBytesTransferred = 0;
  final List<DownloadThroughputChunkSample> chunkSamples = [];
  int liveActivityUpdateCount = 0;
  int queuePersistenceCount = 0;
  int backgroundExpirationCount = 0;
}
