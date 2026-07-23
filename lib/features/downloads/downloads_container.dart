import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'download_manager_view_model.dart';
import 'downloads_page.dart';

class DownloadsContainer extends ConsumerWidget {
  const DownloadsContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(downloadManagerProvider);
    return DownloadsPage(state: state);
  }
}
