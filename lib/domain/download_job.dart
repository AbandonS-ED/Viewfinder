import 'package:freezed_annotation/freezed_annotation.dart';
import 'photo_asset.dart';

part 'download_job.freezed.dart';

/// 单个下载任务
@freezed
class DownloadJob with _$DownloadJob {
  const factory DownloadJob({
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
    DateTime? startedAt,
    DateTime? completedAt,
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
