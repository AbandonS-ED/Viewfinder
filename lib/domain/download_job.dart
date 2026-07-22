import 'package:freezed_annotation/freezed_annotation.dart';

import 'photo_asset.dart';

part 'download_job.freezed.dart';

/// 单个下载任务
@freezed
class DownloadJob with _$DownloadJob {
  const factory DownloadJob({
    /// 唯一标识 (Phase 0 用空字符串占位)
    @Default('') String id,

    /// 相机对象 handle
    required String remoteIdentifier,

    required String fileName,

    required PhotoAssetKind kind,

    @Default(0) int byteSize,

    required DateTime captureDate,

    @Default(false) bool autoExportToPhotoLibrary,

    @Default(DownloadJobStatus.queued) DownloadJobStatus status,

    @Default(0) int bytesTransferred,

    @Default(0) int totalBytes,

    /// 当前已下载偏移 (用于续传)
    @Default(0) int currentOffset,

    /// 续传次数
    @Default(0) int resumedCount,

    required DateTime createdAt,

    DateTime? startedAt,

    DateTime? completedAt,

    required DateTime updatedAt,

    String? errorMessage,
  }) = _DownloadJob;

  const DownloadJob._();

  bool get isTerminal =>
    status == DownloadJobStatus.completed ||
    status == DownloadJobStatus.cancelled ||
    status == DownloadJobStatus.failed;

  bool get canResume =>
    status == DownloadJobStatus.queued ||
    status == DownloadJobStatus.paused ||
    status == DownloadJobStatus.interrupted;

  /// 下载进度 0.0-1.0
  double get fractionCompleted {
    if (totalBytes <= 0) return 0;
    final progress = bytesTransferred / totalBytes;
    return progress.clamp(0.0, 1.0);
  }

  /// 百分比文本
  String get percentageText => '${(fractionCompleted * 100).round()}%';

  /// 把 PhotoAsset 提升为 DownloadJob
  factory DownloadJob.fromAsset(
    PhotoAsset asset, {
    bool autoExportToPhotoLibrary = false,
    DateTime? createdAt,
  }) {
    final now = DateTime.now();
    return DownloadJob(
      remoteIdentifier: asset.remoteIdentifier,
      fileName: asset.fileName,
      kind: asset.kind,
      byteSize: asset.byteSize,
      captureDate: asset.captureDate,
      autoExportToPhotoLibrary: autoExportToPhotoLibrary,
      totalBytes: asset.byteSize < 0 ? 0 : asset.byteSize,
      createdAt: createdAt ?? now,
      updatedAt: createdAt ?? now,
    );
  }
}

/// 下载任务状态机
enum DownloadJobStatus {
  queued,        // 等待中
  running,       // 下载中
  paused,        // 已暂停
  interrupted,   // 已中断 (断线等)
  cancelled,     // 已取消
  completed,     // 已完成
  failed;        // 失败

  bool get isTerminal =>
    this == DownloadJobStatus.completed ||
    this == DownloadJobStatus.cancelled ||
    this == DownloadJobStatus.failed;

  bool get canResume =>
    this == DownloadJobStatus.queued ||
    this == DownloadJobStatus.paused ||
    this == DownloadJobStatus.interrupted;

  String get displayTitle {
    switch (this) {
      case DownloadJobStatus.queued: return '等待中';
      case DownloadJobStatus.running: return '下载中';
      case DownloadJobStatus.paused: return '已暂停';
      case DownloadJobStatus.interrupted: return '已中断';
      case DownloadJobStatus.cancelled: return '已取消';
      case DownloadJobStatus.completed: return '已完成';
      case DownloadJobStatus.failed: return '失败';
    }
  }
}
