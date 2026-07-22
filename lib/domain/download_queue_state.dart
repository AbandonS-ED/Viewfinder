import 'package:freezed_annotation/freezed_annotation.dart';
import 'download_job.dart';

part 'download_queue_state.freezed.dart';

/// 下载队列全局状态
@freezed
class DownloadQueueState with _$DownloadQueueState {
  const factory DownloadQueueState({
    @Default(<DownloadJob>[]) List<DownloadJob> jobs,
    String? activeJobID,
    @Default(DownloadQueueStatus.idle) DownloadQueueStatus status,
  }) = _DownloadQueueState;
}

/// 队列状态机
enum DownloadQueueStatus {
  idle,           // 空闲
  running,        // 下载中
  paused,         // 已暂停
  interrupted;    // 已中断

  String get displayTitle {
    switch (this) {
      case DownloadQueueStatus.idle: return '空闲';
      case DownloadQueueStatus.running: return '下载中';
      case DownloadQueueStatus.paused: return '已暂停';
      case DownloadQueueStatus.interrupted: return '已中断';
    }
  }
}
