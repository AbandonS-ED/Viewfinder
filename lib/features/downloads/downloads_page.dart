import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/download_queue_state.dart';
import '../shared/app_theme.dart';
import '../shared/shared_components.dart';
import '../shared/formatters.dart' as fmt;

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({
    super.key,
    required this.state,
  });

  final DownloadQueueState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        _overviewSection(context),
        const SizedBox(height: 24),
        _queueSection(context),
        const SizedBox(height: 24),
        _activeSection(context),
        const SizedBox(height: 24),
        _throughputSection(context),
        const SizedBox(height: 24),
        _recordsSection(context),
      ],
    );
  }

  Widget _sectionPlaceholder(String title, IconData icon) {
    return CustomCard(
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppThemeColors.tm),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: AppThemeColors.tm)),
          const SizedBox(height: 4),
          const Text(
            'Phase 3 实现',
            style: TextStyle(fontSize: 11, color: AppThemeColors.tm),
          ),
        ],
      ),
    );
  }

  Widget _overviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('概览'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: '队列总数',
                value: '${state.totalItemCount}',
                icon: Icons.download_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: '已完成',
                value: '${state.completedItemCount}',
                icon: Icons.check_circle_outline,
                accent: AppThemeColors.ok,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _queueSection(BuildContext context) {
    if (state.pendingJobs.isEmpty) {
      return _sectionPlaceholder('下载队列', Icons.queue_outlined);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('下载队列'),
        const SizedBox(height: 12),
        ...state.pendingJobs.map(
          (job) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CustomCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      job.fileName,
                      style: const TextStyle(color: AppThemeColors.t1),
                    ),
                  ),
                  Text(
                    fmt.fileSize(job.byteSize),
                    style: GoogleFonts.dmMono(
                      fontSize: 13,
                      color: AppThemeColors.t2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _activeSection(BuildContext context) {
    return _sectionPlaceholder('当前下载', Icons.arrow_circle_down_outlined);
  }

  Widget _throughputSection(BuildContext context) {
    return _sectionPlaceholder('传输速率', Icons.speed_outlined);
  }

  Widget _recordsSection(BuildContext context) {
    return _sectionPlaceholder('已下载记录', Icons.history_outlined);
  }
}
