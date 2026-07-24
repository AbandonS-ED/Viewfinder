import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/download_job.dart';
import 'package:viewfinder/domain/download_queue_state.dart';
import 'package:viewfinder/domain/download_record.dart';
import 'package:viewfinder/domain/photo_asset.dart';
import 'package:viewfinder/features/connection_setup/connection_view_model.dart';
import 'package:viewfinder/features/downloads/download_manager_view_model.dart';
import 'package:viewfinder/services/download_store.dart';

class _FakeDownloadStore implements DownloadStoring {
  DownloadQueueState _lastSaved = const DownloadQueueState();

  @override
  Future<Directory> downloadsDirectoryURL() async => Directory.systemTemp;

  @override
  Future<List<DownloadRecord>> listRecords() async => [];

  @override
  Future<DownloadRecord> storeDownloadedFile({
    required String sourcePath,
    required PhotoAsset asset,
  }) async {
    throw UnimplementedError('stub');
  }

  @override
  Future<DownloadRecord> markExported(String recordID) async {
    throw UnimplementedError('stub');
  }

  @override
  Future<DownloadQueueState> loadQueueState() async => _lastSaved;

  @override
  Future<DownloadQueueState> saveQueueState(DownloadQueueState state) async {
    _lastSaved = state;
    return state;
  }

  @override
  Future<DownloadQueueState> upsertDownloadJob({
    required DownloadJob job,
    required DownloadQueueStatus queueStatus,
    required String? activeJobID,
  }) async {
    throw UnimplementedError('stub');
  }

  @override
  Future<DownloadQueueState> removeDownloadJobs({
    required List<String> ids,
    required DownloadQueueStatus queueStatus,
    required String? activeJobID,
  }) async {
    throw UnimplementedError('stub');
  }

  @override
  Future<DownloadQueueState> markInterruptedRunningJobs({String? reason}) async {
    final jobs = _lastSaved.jobs.map((j) {
      if (j.status == DownloadJobStatus.running) {
        return j.copyWith(status: DownloadJobStatus.interrupted, errorMessage: reason);
      }
      return j;
    }).toList();
    _lastSaved = _lastSaved.copyWith(jobs: jobs);
    return _lastSaved;
  }
}

PhotoAsset _asset({
  String id = '1',
  String remoteId = '100',
  String name = 'DSC_0100.NEF',
  PhotoAssetKind kind = PhotoAssetKind.raw,
  int size = 10 * 1024 * 1024,
}) {
  return PhotoAsset(
    id: id,
    remoteIdentifier: remoteId,
    fileName: name,
    kind: kind,
    byteSize: size,
    captureDate: DateTime(2024, 1, 1),
  );
}

ProviderContainer _container({DownloadStoring? store}) {
  return ProviderContainer(
    overrides: [
      if (store != null) downloadStoreProvider.overrideWithValue(store),
      cameraSessionProvider.overrideWith((ref) => null),
    ],
  );
}

void main() {
  group('DownloadManagerNotifier', () {
    test('build() 初始 state：jobs = [], status = idle', () async {
      final container = _container();
      addTearDown(() => container.dispose());

      final state = container.read(downloadManagerProvider);
      expect(state.jobs, isEmpty);
      expect(state.status, DownloadQueueStatus.idle);
      expect(state.activeJobID, isNull);
    });

    test('enqueue(asset) 增加一个 job', () async {
      final container = _container();
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      notifier.enqueue(_asset());

      final state = container.read(downloadManagerProvider);
      expect(state.jobs.length, 1);
      expect(state.jobs.first.status, DownloadJobStatus.queued);
    });

    test('cancelJob(id) → cancelled', () async {
      final container = _container();
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      notifier.enqueue(_asset(id: 'a'));
      final jobId = container.read(downloadManagerProvider).jobs.first.id;

      notifier.cancelJob(jobId);

      expect(container.read(downloadManagerProvider).jobs.first.status,
          DownloadJobStatus.cancelled);
    });

    test('cancelAll() 清空所有非 terminal', () async {
      final container = _container();
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      notifier.enqueue(_asset(id: 'a'));
      notifier.enqueue(_asset(id: 'b'));

      notifier.cancelAll();

      final state = container.read(downloadManagerProvider);
      expect(state.jobs.every((j) => j.status == DownloadJobStatus.cancelled), isTrue);
    });

    test('retryJob(id) 重置进度为 queued', () async {
      final container = _container(store: _FakeDownloadStore());
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      notifier.enqueue(_asset(id: 'a'));
      final jobId = container.read(downloadManagerProvider).jobs.first.id;
      notifier.cancelJob(jobId);

      await notifier.retryJob(jobId);

      final state = container.read(downloadManagerProvider);
      expect(state.jobs.first.status, DownloadJobStatus.queued);
      expect(state.jobs.first.bytesTransferred, 0);
    });

    test('clearFinished() 移除所有 terminal jobs', () async {
      final container = _container();
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      notifier.enqueue(_asset(id: 'a'));
      final jobId = container.read(downloadManagerProvider).jobs.first.id;
      notifier.cancelJob(jobId);
      notifier.enqueue(_asset(id: 'b'));

      notifier.clearFinished();

      expect(container.read(downloadManagerProvider).jobs.length, 1);
      expect(container.read(downloadManagerProvider).jobs.first.status,
          DownloadJobStatus.queued);
    });

    test('pauseQueue() 将 queued → paused', () async {
      final container = _container();
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      notifier.enqueue(_asset(id: 'a'));
      notifier.enqueue(_asset(id: 'b'));

      notifier.pauseQueue();

      final state = container.read(downloadManagerProvider);
      expect(state.jobs.every((j) => j.status == DownloadJobStatus.paused), isTrue);
      expect(state.status, DownloadQueueStatus.paused);
    });

    test('resumeInterruptedDownloads() 将 interrupted → queued', () async {
      final container = _container(store: _FakeDownloadStore());
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      notifier.enqueue(_asset(id: 'a'));
      notifier.enqueue(_asset(id: 'b'));
      notifier.pauseQueue();

      await notifier.resumeInterruptedDownloads();

      final state = container.read(downloadManagerProvider);
      expect(state.jobs.every((j) => j.status == DownloadJobStatus.queued), isTrue);
    });

    test('loadPersistedQueue() 从 store 恢复', () async {
      final store = _FakeDownloadStore();
      // 预先写入一个 interrupted job
      final persisted = DownloadQueueState(
        jobs: [
          DownloadJob.fromAsset(_asset(id: 'p', remoteId: 'p1'))
              .copyWith(status: DownloadJobStatus.interrupted),
        ],
        status: DownloadQueueStatus.interrupted,
      );
      await store.saveQueueState(persisted);

      final container = _container(store: store);
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      await notifier.loadPersistedQueue();

      final state = container.read(downloadManagerProvider);
      expect(state.jobs.length, 1);
      // markInterruptedRunningJobs 把 running 标 interrupted；这里的 job 已是 interrupted
      // 所以 canResume = true
      expect(state.status, DownloadQueueStatus.interrupted);
    });

    test('interruptActiveDownload() 中止当前 job', () async {
      final container = _container();
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      notifier.enqueue(_asset(id: 'a'));
      final jobId = container.read(downloadManagerProvider).jobs.first.id;
      // 手工设为 running
      container.read(downloadManagerProvider.notifier).state =
          container.read(downloadManagerProvider).copyWith(
        jobs: container.read(downloadManagerProvider).jobs.map((j) {
          if (j.id != jobId) return j;
          return j.copyWith(status: DownloadJobStatus.running);
        }).toList(),
        activeJobID: jobId,
      );

      notifier.interruptActiveDownload('测试中断');

      final state = container.read(downloadManagerProvider);
      expect(state.activeJobID, isNull);
      expect(state.status, DownloadQueueStatus.interrupted);
    });

    test('downloadSelected() 批量入队', () async {
      final container = _container(store: _FakeDownloadStore());
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      await notifier.downloadSelected(
        [_asset(id: 'a'), _asset(id: 'b')],
        autoExport: false,
        prioritizeJPEG: false,
      );

      final state = container.read(downloadManagerProvider);
      expect(state.jobs.length, 2);
    });

    test('_normalizeQueueStatus() 转换规则', () async {
      final container = _container();
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      notifier.enqueue(_asset(id: 'a'));
      notifier.enqueue(_asset(id: 'b'));

      // idle → running 经过 cancel 后
      notifier.cancelAll();
      expect(container.read(downloadManagerProvider).status, DownloadQueueStatus.idle);
    });

    test('队列持久化 round-trip：save → 新 store → load 恢复', () async {
      final store = _FakeDownloadStore();
      final container1 = _container(store: store);
      addTearDown(() => container1.dispose());
      final notifier = container1.read(downloadManagerProvider.notifier);

      await notifier.downloadSelected(
        [_asset(id: 'persist-a', name: 'pic_a.nef', kind: PhotoAssetKind.raw)],
        autoExport: false,
        prioritizeJPEG: false,
      );
      await notifier.downloadSelected(
        [_asset(id: 'persist-b', name: 'pic_b.jpg', kind: PhotoAssetKind.jpeg)],
        autoExport: false,
        prioritizeJPEG: false,
      );

      final state1 = container1.read(downloadManagerProvider);
      expect(state1.jobs.length, 2);

      // 模拟重启：新 container 从同一 store 加载
      final container2 = ProviderContainer(overrides: [
        downloadStoreProvider.overrideWithValue(store),
        cameraSessionProvider.overrideWithValue(null),
      ]);
      addTearDown(() => container2.dispose());

      final notifier2 = container2.read(downloadManagerProvider.notifier);
      await notifier2.loadPersistedQueue();

      final state2 = container2.read(downloadManagerProvider);
      expect(state2.jobs.length, 2);
      expect(state2.jobs[0].fileName, 'pic_a.nef');
      expect(state2.jobs[1].fileName, 'pic_b.jpg');
    });
  });
}
