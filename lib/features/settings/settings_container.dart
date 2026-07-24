import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/log_file_store.dart';
import 'settings_page.dart';
import 'settings_view_model.dart';

final logFileStoreProvider = Provider<LogFileStore>((ref) {
  throw UnimplementedError('override in main.dart');
});

class SettingsContainer extends ConsumerWidget {
  const SettingsContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);
    return SettingsPage(
      config: config,
      onSetHost: notifier.setHost,
      onSetPort: (raw) {
        final port = int.tryParse(raw.trim());
        if (port == null || port <= 0 || port > 65535) return;
        notifier.setPort(port);
      },
      onSetAutoExport: notifier.setAutoExportToPhotoLibrary,
      onSetPrioritizeJPEG: notifier.setPrioritizeJPEGDownloads,
      onExportLogs: () async {
        final store = ref.read(logFileStoreProvider);
        final file = await store.exportFile();
        await Share.shareXFiles([XFile(file.path)], text: 'Viewfinder 日志');
      },
    );
  }
}
