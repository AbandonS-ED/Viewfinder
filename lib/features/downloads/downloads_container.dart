import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'download_manager_view_model.dart';
import 'downloads_page.dart';

class DownloadsContainer extends ConsumerWidget {
  const DownloadsContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(downloadManagerProvider);
    final notifier = ref.read(downloadManagerProvider.notifier);
    return DownloadsPage(
      state: state,
      onPause: () => notifier.pauseQueue(),
      onResume: () => notifier.resumeInterruptedDownloads(),
      onCancel: (id) => notifier.cancelJob(id),
      onCancelAll: () => notifier.cancelAll(),
      onClearFinished: () => notifier.clearFinished(),
      onRetry: (id) => notifier.retryJob(id),
    );
  }
}
