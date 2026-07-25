import 'package:flutter/material.dart';

import '../shared/shared_components.dart';

class SupportSection extends StatelessWidget {
  const SupportSection({
    super.key,
    required this.appVersion,
    this.onExportLogs,
  });

  final String appVersion;
  final Future<void> Function()? onExportLogs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('支持与版本'),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            children: [
              GridRowItem(
                label: '版本',
                value: 'Viewfinder $appVersion',
                icon: Icons.info_outline,
              ),
              if (onExportLogs != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await onExportLogs?.call();
                    },
                    icon: const Icon(Icons.file_download_outlined, size: 18),
                    label: const Text('导出日志'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}