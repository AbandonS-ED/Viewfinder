import 'package:viewfinder/domain/active_download_progress.dart';
import 'package:viewfinder/domain/download_job.dart';
import 'package:viewfinder/domain/download_queue_state.dart';
import 'package:viewfinder/domain/photo_asset.dart';
import 'package:flutter_test/flutter_test.dart';

DownloadJob _makeJob({
  required String id,
  DownloadJobStatus status = DownloadJobStatus.queued,
  int byteSize = 1024,
  PhotoAssetKind kind = PhotoAssetKind.jpeg,
}) {
  return DownloadJob(
    id: id,
    remoteIdentifier: id,
    fileName: 'DSC_$id.NEF',
    kind: kind,
    byteSize: byteSize,
    captureDate: DateTime(2026, 7, 24, 12),
    autoExportToPhotoLibrary: false,
    status: status,
    bytesTransferred: 0,
    totalBytes: byteSize,
    currentOffset: 0,
    resumedCount: 0,
    createdAt: DateTime(2026, 7, 24, 12),
    startedAt: null,
    completedAt: null,
    updatedAt: DateTime(2026, 7, 24, 12),
  );
}

void main() {
  group('DownloadQueueState.activeJob getter', () {
    test('activeJobID == null 返回 null', () {
      const state = DownloadQueueState();
      expect(state.activeJob, isNull);
    });

    test('jobs 为空且 activeJobID 非 null 不抛 RangeError (Phase 3 §17.9 bug fix)', () {
      const state = DownloadQueueState(activeJobID: 'missing-id');
      expect(state.activeJob, isNull);
    });

    test('jobs 包含 activeJobID 对应 job 时返回该 job', () {
      final target = _makeJob(id: 'target', status: DownloadJobStatus.running);
      final other = _makeJob(id: 'other');
      final state = DownloadQueueState(
        jobs: [other, target, _makeJob(id: 'third')],
        activeJobID: 'target',
      );
      expect(state.activeJob?.id, 'target');
    });

    test('jobs 包含 activeJobID 但找不到时返回 null (不抛异常)', () {
      final state = DownloadQueueState(
        jobs: [_makeJob(id: 'a'), _makeJob(id: 'b')],
        activeJobID: 'gone',
      );
      expect(state.activeJob, isNull);
    });
  });

  group('DownloadQueueState 派生 getter', () {
    test('pendingJobs 仅包含非 terminal 状态', () {
      final state = DownloadQueueState(jobs: [
        _makeJob(id: 'a', status: DownloadJobStatus.queued),
        _makeJob(id: 'b', status: DownloadJobStatus.running),
        _makeJob(id: 'c', status: DownloadJobStatus.completed),
        _makeJob(id: 'd', status: DownloadJobStatus.failed),
        _makeJob(id: 'e', status: DownloadJobStatus.cancelled),
      ]);
      final ids = state.pendingJobs.map((j) => j.id).toList();
      expect(ids, ['a', 'b']);
    });

    test('completedJobs 仅包含 completed', () {
      final state = DownloadQueueState(jobs: [
        _makeJob(id: 'a', status: DownloadJobStatus.completed),
        _makeJob(id: 'b', status: DownloadJobStatus.completed),
        _makeJob(id: 'c', status: DownloadJobStatus.queued),
      ]);
      expect(state.completedJobs.length, 2);
    });

    test('hasPendingWork 在有非 terminal 时为 true', () {
      final state = DownloadQueueState(jobs: [
        _makeJob(id: 'a', status: DownloadJobStatus.completed),
        _makeJob(id: 'b', status: DownloadJobStatus.queued),
      ]);
      expect(state.hasPendingWork, isTrue);
    });

    test('completedItemCount / totalItemCount', () {
      final state = DownloadQueueState(jobs: [
        _makeJob(id: 'a', status: DownloadJobStatus.completed),
        _makeJob(id: 'b', status: DownloadJobStatus.queued),
        _makeJob(id: 'c', status: DownloadJobStatus.failed),
      ]);
      expect(state.completedItemCount, 1);
      expect(state.totalItemCount, 3);
    });
  });

  group('DownloadJobStatus 行为', () {
    test('7 个状态值 (queued/running/paused/interrupted/cancelled/completed/failed)', () {
      expect(DownloadJobStatus.values.length, 7);
    });

    test('terminal 状态: completed/failed/cancelled', () {
      expect(DownloadJobStatus.completed.isTerminal, isTrue);
      expect(DownloadJobStatus.failed.isTerminal, isTrue);
      expect(DownloadJobStatus.cancelled.isTerminal, isTrue);
      expect(DownloadJobStatus.queued.isTerminal, isFalse);
      expect(DownloadJobStatus.running.isTerminal, isFalse);
      expect(DownloadJobStatus.paused.isTerminal, isFalse);
      expect(DownloadJobStatus.interrupted.isTerminal, isFalse);
    });

    test('canResume: queued/paused/interrupted 可恢复; running 不可 (本轮已开始)', () {
      expect(DownloadJobStatus.queued.canResume, isTrue);
      expect(DownloadJobStatus.paused.canResume, isTrue);
      expect(DownloadJobStatus.interrupted.canResume, isTrue);
      expect(DownloadJobStatus.running.canResume, isFalse);
      expect(DownloadJobStatus.completed.canResume, isFalse);
      expect(DownloadJobStatus.failed.canResume, isFalse);
      expect(DownloadJobStatus.cancelled.canResume, isFalse);
    });

    test('displayTitle 7 个状态各自有 label', () {
      for (final s in DownloadJobStatus.values) {
        expect(s.displayTitle.isNotEmpty, isTrue);
      }
    });
  });

  group('DownloadQueueStatus', () {
    test('4 个值 (idle/running/paused/interrupted)', () {
      expect(DownloadQueueStatus.values.length, 4);
    });

    test('displayTitle 各自不同且非空', () {
      final titles = DownloadQueueStatus.values.map((s) => s.displayTitle).toList();
      expect(titles.toSet().length, 4);
      for (final t in titles) {
        expect(t.isNotEmpty, isTrue);
      }
    });
  });

  group('ActiveDownloadProgress', () {
    test('fractionCompleted 计算正确', () {
      const p = ActiveDownloadProgress(
        fileName: 'X.NEF',
        currentItemNumber: 1,
        totalItemCount: 3,
        bytesTransferred: 500,
        totalBytes: 1000,
        resumedCount: 0,
        currentOffset: 500,
        chunkSize: 500,
      );
      expect(p.fractionCompleted, 0.5);
    });

    test('percentageText 含 %', () {
      const p = ActiveDownloadProgress(
        fileName: 'X.NEF',
        currentItemNumber: 1,
        totalItemCount: 3,
        bytesTransferred: 250,
        totalBytes: 1000,
        resumedCount: 0,
        currentOffset: 250,
        chunkSize: 250,
      );
      expect(p.percentageText, '25%');
    });

    test('totalBytes = 0 时 fractionCompleted = 0 (避免除零)', () {
      const p = ActiveDownloadProgress(
        fileName: 'X.NEF',
        currentItemNumber: 1,
        totalItemCount: 3,
        bytesTransferred: 0,
        totalBytes: 0,
        resumedCount: 0,
        currentOffset: 0,
        chunkSize: 0,
      );
      expect(p.fractionCompleted, 0);
    });
  });
}
