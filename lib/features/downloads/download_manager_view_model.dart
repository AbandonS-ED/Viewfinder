import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/download_job.dart';
import '../../domain/download_queue_state.dart';
import '../../domain/photo_asset.dart';

final downloadManagerProvider =
    NotifierProvider<DownloadManagerNotifier, DownloadQueueState>(
  DownloadManagerNotifier.new,
);

class DownloadManagerNotifier extends Notifier<DownloadQueueState> {
  @override
  DownloadQueueState build() {
    return const DownloadQueueState();
  }

  void enqueue(PhotoAsset asset) {
    final job = DownloadJob.fromAsset(asset);
    state = state.copyWith(
      jobs: [...state.jobs, job],
    );
  }

  void cancelJob(String id) {
    final jobs = state.jobs.map((j) {
      if (j.id != id) return j;
      return j.copyWith(status: DownloadJobStatus.cancelled);
    }).toList();
    state = state.copyWith(jobs: jobs);
  }
}
