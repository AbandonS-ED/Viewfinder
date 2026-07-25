import 'package:flutter/material.dart';

import '../../domain/download_queue_state.dart';
import '../shared/shared_components.dart';

class ThroughputDiagnosticsSection extends StatelessWidget {
  const ThroughputDiagnosticsSection({super.key, required this.state});

  final DownloadQueueState state;

  @override
  Widget build(BuildContext context) {
    final stats = state.throughputStats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('吞吐诊断'),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            children: [
              GridRowItem(
                label: '已完成项目',
                value: '${stats.completedItems}',
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 8),
              GridRowItem(
                label: '总传输字节',
                value: stats.totalBytesLabel,
                icon: Icons.cloud_done_outlined,
              ),
              const SizedBox(height: 8),
              GridRowItem(
                label: '平均每项',
                value: stats.avgBytesPerItemLabel,
                icon: Icons.straighten,
              ),
            ],
          ),
        ),
      ],
    );
  }
}