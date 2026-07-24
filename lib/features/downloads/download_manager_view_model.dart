import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/active_download_progress.dart';
import '../../domain/camera_app_error.dart';
import '../../domain/download_job.dart';
import '../../domain/download_queue_state.dart';
import '../../domain/photo_asset.dart';
import '../../protocol/camera_transport.dart';
import '../../services/asset_thumbnail_service.dart';
import '../../services/background_download_runner.dart';
import '../../services/download_asset_prioritizer.dart';
import '../../services/download_notification_service.dart';
import '../../services/download_store.dart';
import '../../platform/photo_library_channel.dart' as plc;
import '../app_shell/app_shell_view_model.dart';
import '../connection_setup/connection_view_model.dart';

final downloadManagerProvider =
    NotifierProvider<DownloadManagerNotifier, DownloadQueueState>(
  DownloadManagerNotifier.new,
);

final downloadStoreProvider = Provider<DownloadStoring>((ref) {
  throw UnimplementedError('downloadStoreProvider must be overridden in main.dart');
});

final notificationServiceProvider = Provider<DownloadNotificationService>((ref) {
  throw UnimplementedError('notificationServiceProvider must be overridden in main.dart');
});

final backgroundRunnerProvider = Provider<BackgroundDownloadRunner>((ref) {
  throw UnimplementedError('backgroundRunnerProvider must be overridden in main.dart');
});

final photoLibraryChannelProvider = Provider<plc.PhotoLibraryChannel>((ref) {
  throw UnimplementedError('photoLibraryChannelProvider must be overridden in main.dart');
});

final assetThumbnailServiceProvider = Provider<AssetThumbnailServing>((ref) {
  throw UnimplementedError('assetThumbnailServiceProvider must be overridden in main.dart');
});

class DownloadManagerNotifier extends Notifier<DownloadQueueState> {
  Future<void>? _queueRunnerFuture;
  bool _isCancelled = false;

  @override
  DownloadQueueState build() {
    return const DownloadQueueState();
  }

  // ──────────────────────── 队列操作 ────────────────────────

  void enqueue(PhotoAsset asset) {
    final job = DownloadJob.fromAsset(asset);
    state = state.copyWith(jobs: [...state.jobs, job]);
  }

  Future<bool> downloadSelected(
    List<PhotoAsset> assets, {
    required bool autoExport,
    required bool prioritizeJPEG,
  }) async {
    if (assets.isEmpty) {
      return true;
    }

    final ordered = prioritizeJPEG
        ? DownloadAssetPrioritizer.jpegFirst.sort(assets)
        : DownloadAssetPrioritizer.cameraOrder.sort(assets);

    for (final asset in ordered) {
      final job = DownloadJob.fromAsset(
        asset,
        autoExportToPhotoLibrary: autoExport,
      );
      state = state.copyWith(jobs: [...state.jobs, job]);
    }

    await _persist();
    await _startQueueIfPossible();
    return true;
  }

  void cancelJob(String id) {
    if (state.activeJobID == id) {
      _isCancelled = true;
    }
    state = state.copyWith(
      jobs: state.jobs.map((j) {
        if (j.id != id) return j;
        return j.copyWith(status: DownloadJobStatus.cancelled);
      }).toList(),
    );
    _normalizeQueueStatus();
  }

  void cancelAll() {
    _isCancelled = true;
    state = state.copyWith(
      jobs: state.jobs.map((j) {
        if (j.status.isTerminal) return j;
        return j.copyWith(status: DownloadJobStatus.cancelled);
      }).toList(),
      activeDownloadProgress: null,
    );
    _normalizeQueueStatus();
  }

  Future<void> retryJob(String id) async {
    state = state.copyWith(
      jobs: state.jobs.map((j) {
        if (j.id != id) return j;
        return j.copyWith(
          status: DownloadJobStatus.queued,
          bytesTransferred: 0,
          currentOffset: 0,
          errorMessage: null,
          startedAt: null,
          completedAt: null,
          updatedAt: DateTime.now(),
        );
      }).toList(),
    );
    await _persist();
    await _startQueueIfPossible();
  }

  void clearFinished() {
    state = state.copyWith(
      jobs: state.jobs.where((j) => !j.status.isTerminal).toList(growable: false),
      activeDownloadProgress: null,
    );
    _normalizeQueueStatus(preferred: DownloadQueueStatus.idle);
  }

  void pauseQueue() {
    _isCancelled = true;
    state = state.copyWith(
      jobs: state.jobs.map((j) {
        if (j.status == DownloadJobStatus.running ||
            j.status == DownloadJobStatus.queued) {
          return j.copyWith(status: DownloadJobStatus.paused, updatedAt: DateTime.now());
        }
        return j;
      }).toList(),
      status: DownloadQueueStatus.paused,
      activeDownloadProgress: null,
    );
  }

  Future<void> resumeInterruptedDownloads() async {
    if (state.status == DownloadQueueStatus.idle ||
        state.status == DownloadQueueStatus.running) {
      return;
    }

    state = state.copyWith(
      jobs: state.jobs.map((j) {
        if (!j.status.canResume) return j;
        return j.copyWith(status: DownloadJobStatus.queued, updatedAt: DateTime.now());
      }).toList(),
    );
    await _persist();
    await _startQueueIfPossible();
  }

  Future<void> loadPersistedQueue() async {
    final store = ref.read(downloadStoreProvider);
    final marked = await store.markInterruptedRunningJobs(
      reason: '应用启动时下载中断',
    );
    state = state.copyWith(
      jobs: marked.jobs,
      status: marked.jobs.any((j) => j.status.canResume)
          ? DownloadQueueStatus.interrupted
          : DownloadQueueStatus.idle,
    );
  }

  Future<void> refreshDownloads() async {}

  void handleScenePhaseChange(AppLifecycleState phase) {
    switch (phase) {
      case AppLifecycleState.resumed:
        unawaited(ref.read(backgroundRunnerProvider).end());
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (state.status == DownloadQueueStatus.running) {
          unawaited(ref.read(backgroundRunnerProvider).begin(
            name: 'Nikon Download',
            onExpiration: () => interruptActiveDownload('App 进入后台后系统暂停了下载。'),
          ));
        }
      case AppLifecycleState.inactive:
        break;
    }
  }

  void interruptActiveDownload(String reason) {
    final activeId = state.activeJobID;
    if (activeId == null) return;
    _isCancelled = true;
    state = state.copyWith(
      jobs: state.jobs.map((j) {
        if (j.id != activeId) return j;
        return j.copyWith(
          status: DownloadJobStatus.interrupted,
          errorMessage: reason,
          updatedAt: DateTime.now(),
        );
      }).toList(),
      activeJobID: null,
      status: DownloadQueueStatus.interrupted,
      activeDownloadProgress: null,
    );
  }

  Future<void> appendTransportDiagnostics(CameraTransport transport) async {}

  // ──────────────────────── 内部 ────────────────────────

  Future<void> _startQueueIfPossible() async {
    if (_queueRunnerFuture != null) return;
    if (!state.jobs.any((j) => j.status.canResume)) {
      state = state.copyWith(status: DownloadQueueStatus.idle, activeJobID: null);
      return;
    }
    if (ref.read(cameraSessionProvider) == null) {
      state = state.copyWith(status: DownloadQueueStatus.interrupted);
      ref.read(appShellProvider.notifier).appendLog('下载队列已暂停：相机未连接');
      return;
    }
    state = state.copyWith(status: DownloadQueueStatus.running);
    _queueRunnerFuture = _runQueue().then((_) => _queueRunnerFuture = null);
    await _queueRunnerFuture;
  }

  Future<void> _runQueue() async {
    _isCancelled = false;
    try {
      while (!_isCancelled) {
        final job = _nextRunnableJob();
        if (job == null) break;

        final session = ref.read(cameraSessionProvider);
        final transport = ref.read(cameraTransportProvider);
        if (session == null || transport == null) {
          state = state.copyWith(
            jobs: state.jobs.map((j) {
              if (j.id != job.id) return j;
              return j.copyWith(
                status: DownloadJobStatus.interrupted,
                errorMessage: '请重新连接 Nikon 相机后继续下载。',
              );
            }).toList(),
            status: DownloadQueueStatus.interrupted,
            activeJobID: null,
          );
          await _persist();
          break;
        }

        await ref.read(notificationServiceProvider).show(
          notificationId: job.id.hashCode,
          title: '下载中',
          body: job.fileName,
          progress: 0,
          channelId: 'download_progress',
          payload: 'downloads',
        );
        unawaited(ref.read(backgroundRunnerProvider).begin(
          name: 'Nikon Download',
          onExpiration: () => interruptActiveDownload('iOS 已暂停后台传输'),
        ));

        state = state.copyWith(
          jobs: state.jobs.map((j) {
            if (j.id != job.id) return j;
            return j.copyWith(
              status: DownloadJobStatus.running,
              startedAt: DateTime.now(),
            );
          }).toList(),
          activeJobID: job.id,
          status: DownloadQueueStatus.running,
        );

        try {
          final asset = _jobToAsset(job);
          final tempPath = await transport.downloadAssetToTemporaryFile(
            asset, session,
            onProgress: (progress) {
              state = state.copyWith(
                jobs: state.jobs.map((j) {
                  if (j.id != job.id) return j;
                  return j.copyWith(
                    bytesTransferred: progress.bytesTransferred,
                    totalBytes: progress.totalBytes,
                    currentOffset: progress.currentOffset,
                  );
                }).toList(),
                activeDownloadProgress: ActiveDownloadProgress(
                  fileName: job.fileName,
                  currentItemNumber: _indexOf(job.id) + 1,
                  totalItemCount: state.jobs.length,
                  bytesTransferred: progress.bytesTransferred,
                  totalBytes: progress.totalBytes,
                  resumedCount: progress.resumedCount,
                  currentOffset: progress.currentOffset,
                  chunkSize: progress.chunkSize,
                ),
              );
              ref.read(notificationServiceProvider).update(
                notificationId: job.id.hashCode,
                progress: progress.totalBytes > 0
                    ? ((progress.bytesTransferred / progress.totalBytes) * 100).round()
                    : 0,
              );
            },
          );

          final record = await ref.read(downloadStoreProvider).storeDownloadedFile(
            sourcePath: tempPath,
            asset: asset,
          );

          if (job.autoExportToPhotoLibrary) {
            try {
              await ref.read(photoLibraryChannelProvider).exportFile(
                filePath: record.savedURL,
              );
              await ref.read(downloadStoreProvider).markExported(record.id);
            } catch (e) {
              ref.read(appShellProvider.notifier).appendLog('导出到相册失败: $e');
            }
          }

          state = state.copyWith(
            jobs: state.jobs.map((j) {
              if (j.id != job.id) return j;
              return j.copyWith(
                status: DownloadJobStatus.completed,
                completedAt: DateTime.now(),
              );
            }).toList(),
            activeJobID: null,
            activeDownloadProgress: null,
          );

          unawaited(ref.read(backgroundRunnerProvider).end());
          await ref.read(notificationServiceProvider).cancel(
            notificationId: job.id.hashCode,
          );
          await _persist();
        } on CameraAppError catch (e) {
          final status = _interruptibleStatus(e);
          state = state.copyWith(
            jobs: state.jobs.map((j) {
              if (j.id != job.id) return j;
              return j.copyWith(
                status: status,
                errorMessage: e.message,
                completedAt: status.isTerminal ? DateTime.now() : null,
              );
            }).toList(),
            activeJobID: null,
            status: status == DownloadJobStatus.interrupted
                ? DownloadQueueStatus.interrupted
                : DownloadQueueStatus.paused,
            activeDownloadProgress: null,
          );
          unawaited(ref.read(backgroundRunnerProvider).end());
          ref.read(appShellProvider.notifier).appendLog('${job.fileName} 下载失败: ${e.message}');
          await _persist();
          break;
        }
      }
    } finally {
      unawaited(ref.read(backgroundRunnerProvider).end());
    }
  }

  DownloadJob? _nextRunnableJob() {
    for (final job in state.jobs) {
      if (job.status == DownloadJobStatus.queued) return job;
    }
    return null;
  }

  int _indexOf(String id) => state.jobs.indexWhere((j) => j.id == id);

  void _normalizeQueueStatus({DownloadQueueStatus preferred = DownloadQueueStatus.paused}) {
    DownloadQueueStatus next;
    if (state.jobs.any((j) => j.status == DownloadJobStatus.running)) {
      next = DownloadQueueStatus.running;
    } else if (state.jobs.any((j) => j.status.canResume)) {
      next = preferred;
    } else {
      next = DownloadQueueStatus.idle;
      state = state.copyWith(activeJobID: null);
    }
    state = state.copyWith(status: next);
  }

  DownloadJobStatus _interruptibleStatus(Object error) {
    if (error is! CameraAppError) return DownloadJobStatus.failed;
    return error.isInterruptibleDownloadStatus
        ? DownloadJobStatus.interrupted
        : DownloadJobStatus.failed;
  }

  PhotoAsset _jobToAsset(DownloadJob job) {
    return PhotoAsset(
      remoteIdentifier: job.remoteIdentifier,
      fileName: job.fileName,
      kind: job.kind,
      byteSize: job.byteSize,
      captureDate: job.captureDate,
    );
  }

  Future<void> _persist() async {
    try {
      await ref.read(downloadStoreProvider).saveQueueState(state);
    } catch (_) {}
  }
}
