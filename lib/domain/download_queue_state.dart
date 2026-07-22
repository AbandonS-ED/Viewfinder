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

  const DownloadQueueState._();

  /// 当前正在运行的 job
  DownloadJob? get activeJob {
    final id = activeJobID;
    if (id == null) return null;
    return jobs.firstWhere(
      (j) => j.id == id,
      orElse: () => jobs.first,
    );
  }

  /// 未完成的 jobs (queued/running/paused/interrupted)
  List<DownloadJob> get pendingJobs =>
    jobs.where((j) => !j.status.isTerminal).toList(growable: false);

  /// 已完成的 jobs
  List<DownloadJob> get completedJobs =>
    jobs.where((j) => j.status == DownloadJobStatus.completed).toList(growable: false);

  /// 是否有未完成的工作
  bool get hasPendingWork => jobs.any((j) => !j.status.isTerminal);

  /// 已完成数量
  int get completedItemCount =>
    jobs.where((j) => j.status == DownloadJobStatus.completed).length;

  /// 总数
  int get totalItemCount => jobs.length;
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
