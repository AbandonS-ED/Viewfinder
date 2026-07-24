import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/download_job.dart';
import '../../domain/download_queue_state.dart';
import '../../domain/photo_asset.dart';
import '../shared/app_theme.dart';
import '../shared/shared_components.dart';
import '../shared/formatters.dart' as fmt;

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({
    super.key,
    required this.state,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.onCancelAll,
    this.onClearFinished,
    this.onRetry,
  });

  final DownloadQueueState state;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final void Function(String)? onCancel;
  final VoidCallback? onCancelAll;
  final VoidCallback? onClearFinished;
  final void Function(String)? onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        _overviewSection(context),
        const SizedBox(height: 24),
        _activeSection(context),
        const SizedBox(height: 24),
        _queueSection(context),
        const SizedBox(height: 24),
        _recordsSection(context),
      ],
    );
  }

  Widget _overviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: SectionHeader('概览')),
            if (state.status == DownloadQueueStatus.paused && onResume != null)
              TextButton.icon(
                onPressed: onResume,
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('恢复'),
              ),
            if (state.status == DownloadQueueStatus.running && onPause != null)
              TextButton.icon(
                onPressed: onPause,
                icon: const Icon(Icons.pause, size: 18),
                label: const Text('暂停'),
              ),
            if (state.hasPendingWork && onCancelAll != null)
              TextButton.icon(
                onPressed: onCancelAll,
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('取消全部'),
              ),
            if (state.completedJobs.isNotEmpty && onClearFinished != null)
              TextButton.icon(
                onPressed: onClearFinished,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('清理'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: '队列',
                value: '${state.totalItemCount - state.completedItemCount}',
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
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: '状态',
                value: state.status.displayTitle,
                icon: Icons.info_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _activeSection(BuildContext context) {
    final progress = state.activeDownloadProgress;
    if (progress == null) {
      if (state.status == DownloadQueueStatus.running) {
        return _sectionPlaceholder('准备中…', Icons.hourglass_bottom);
      }
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('当前下载'),
        const SizedBox(height: 12),
        DownloadProgressDetails(progress: progress),
      ],
    );
  }

  Widget _queueSection(BuildContext context) {
    final pending = state.pendingJobs;
    if (pending.isEmpty) {
      return _sectionPlaceholder('下载队列', Icons.queue_outlined);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('下载队列'),
        const SizedBox(height: 12),
        ...pending.map((job) => _jobCard(context, job)),
      ],
    );
  }

  Widget _jobCard(BuildContext context, DownloadJob job) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  job.kind == PhotoAssetKind.jpeg || job.kind == PhotoAssetKind.png
                      ? Icons.image_outlined
                      : job.kind == PhotoAssetKind.raw
                          ? Icons.camera_alt_outlined
                          : Icons.movie_outlined,
                  size: 20,
                  color: AppThemeColors.t2,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.fileName,
                    style: const TextStyle(color: AppThemeColors.t1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  fmt.fileSize(job.byteSize),
                  style: GoogleFonts.dmMono(fontSize: 12, color: AppThemeColors.t2),
                ),
                const Spacer(),
                _jobStatusChip(job.status),
                if (job.status.canResume && onRetry != null) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 28,
                    child: OutlinedButton.icon(
                      onPressed: () => onRetry?.call(job.id),
                      icon: const Icon(Icons.refresh, size: 14),
                      label: const Text('重试', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                    ),
                  ),
                ],
                if (job.status == DownloadJobStatus.queued && onCancel != null) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 28,
                    child: IconButton(
                      onPressed: () => onCancel?.call(job.id),
                      icon: const Icon(Icons.close, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _jobStatusChip(DownloadJobStatus status) {
    final color = switch (status) {
      DownloadJobStatus.queued => AppThemeColors.t2,
      DownloadJobStatus.running => AppThemeColors.aS,
      DownloadJobStatus.paused => AppThemeColors.warn,
      DownloadJobStatus.interrupted => AppThemeColors.er,
      DownloadJobStatus.cancelled => AppThemeColors.tm,
      DownloadJobStatus.completed => AppThemeColors.ok,
      DownloadJobStatus.failed => AppThemeColors.er,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayTitle,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }

  Widget _recordsSection(BuildContext context) {
    final completed = state.completedJobs;
    if (completed.isEmpty) {
      return _sectionPlaceholder('已下载记录', Icons.history_outlined);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('已下载'),
        const SizedBox(height: 12),
        ...completed.map((job) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CustomCard(
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 18, color: AppThemeColors.ok),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.fileName,
                    style: const TextStyle(color: AppThemeColors.t1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  fmt.fileSize(job.byteSize),
                  style: GoogleFonts.dmMono(fontSize: 12, color: AppThemeColors.t2),
                ),
              ],
            ),
          ),
        )),
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
            '暂无数据',
            style: TextStyle(fontSize: 11, color: AppThemeColors.tm),
          ),
        ],
      ),
    );
  }
}
