import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/camera_session.dart';
import 'package:viewfinder/domain/download_job.dart';
import 'package:viewfinder/domain/download_queue_state.dart';
import 'package:viewfinder/domain/download_record.dart';
import 'package:viewfinder/domain/photo_asset.dart';
import 'package:viewfinder/features/connection_setup/connection_view_model.dart';
import 'package:viewfinder/features/downloads/download_manager_view_model.dart';
import 'package:viewfinder/platform/photo_library_channel.dart';
import 'package:viewfinder/services/background_download_runner.dart';
import 'package:viewfinder/services/download_notification_service.dart';
import 'package:viewfinder/services/download_store.dart';
import '../../helpers/fake_camera_transport.dart';

class _StubBackgroundRunner2 implements BackgroundDownloadRunner {
  @override
  Future<bool> get isActive async => false;
  @override
  Future<void> begin({required String name, void Function()? onExpiration}) async {}
  @override
  Future<void> end() async {}
}

class _StubNotificationService2 implements DownloadNotificationService {
  @override
  Future<void> cancel({required int notificationId}) async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> show({
    required int notificationId,
    required String title,
    required String body,
    int progress = -1,
    String? channelId,
    String? categoryId,
    String? payload,
  }) async {}
  @override
  Future<void> update({
    required int notificationId,
    String? title,
    String? body,
    int? progress,
  }) async {}
}

class _StubPhotoLibraryChannel2 implements PhotoLibraryChannel {
  @override
  Future<void> exportFile({required String filePath}) async {}
  @override
  Future<PhotoLibraryPermission> requestPermission() async =>
      PhotoLibraryPermission.granted;
}

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
    return DownloadRecord(
      id: asset.id,
      sourceAssetIdentifier: asset.remoteIdentifier,
      fileName: asset.fileName,
      savedURL: sourcePath,
      byteSize: asset.byteSize,
      completedAt: DateTime.now(),
    );
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

ProviderContainer _container({
  DownloadStoring? store,
  CameraSession? session,
}) {
  return ProviderContainer(
    overrides: [
      if (store != null) downloadStoreProvider.overrideWithValue(store),
      cameraSessionProvider.overrideWith((ref) => session),
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

    test('downloadSelected() 混合 RAW+JPEG, JPEG 优先排序 (DownloadAssetPrioritizer.jpegFirst.sort)',
        () async {
      final container = _container(store: _FakeDownloadStore());
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      await notifier.downloadSelected(
        [
          _asset(id: 'raw-1', name: 'DSC_0100.NEF', kind: PhotoAssetKind.raw),
          _asset(id: 'jpg-1', name: 'DSC_0101.JPG', kind: PhotoAssetKind.jpeg),
          _asset(id: 'raw-2', name: 'DSC_0102.NEF', kind: PhotoAssetKind.raw),
        ],
        autoExport: false,
        prioritizeJPEG: true,
      );

      final jobs = container.read(downloadManagerProvider).jobs;
      expect(jobs.length, 3);
      // JPEG 应该排第一
      expect(jobs[0].fileName, 'DSC_0101.JPG',
          reason: 'JPEG-first sort: jobs[0] 必须是 jpg-1');
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

    test('loadPersistedQueue() 自动把 running job 标 interrupted (markInterruptedRunningJobs 行为)',
        () async {
      final store = _FakeDownloadStore();
      // 预先写入 1 running + 1 queued + activeJobID 指向 running
      // 用 fileName 区分 (DownloadJob.id 默认 '')
      final persisted = DownloadQueueState(
        jobs: [
          DownloadJob.fromAsset(_asset(id: 'r1', remoteId: 'r1', name: 'running_asset.NEF'))
              .copyWith(status: DownloadJobStatus.running),
          DownloadJob.fromAsset(_asset(id: 'q1', remoteId: 'q1', name: 'queued_asset.NEF'))
              .copyWith(status: DownloadJobStatus.queued),
        ],
        activeJobID: 'some-id',
        status: DownloadQueueStatus.running,
      );
      await store.saveQueueState(persisted);

      final container = _container(store: store);
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      await notifier.loadPersistedQueue();

      final state = container.read(downloadManagerProvider);
      expect(state.jobs.length, 2);
      // 用 fileName 而不是 id (id 默认 '')
      final runningJob = state.jobs.firstWhere((j) => j.fileName == 'running_asset.NEF');
      final queuedJob = state.jobs.firstWhere((j) => j.fileName == 'queued_asset.NEF');
      expect(runningJob.status, DownloadJobStatus.interrupted,
          reason: 'running → interrupted (regression of §4.4)');
      expect(queuedJob.status, DownloadJobStatus.queued,
          reason: 'queued 保持不变');
      expect(state.activeJobID, isNull,
          reason: 'activeJobID 被清');
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

    test('downloadSelected() 批量入队 + session=null 时 status 变 interrupted', () async {
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
      expect(state.status, DownloadQueueStatus.interrupted,
          reason: 'session=null → queue 应立即 paused/interrupted');
    });

    test('downloadSelected() 有 session 时 status 立即变 running (用 _FakeDownloadStore + stub providers)',
        () async {
      // 关键: 不需要 transport 真下载, 只验证 _startQueueIfPossible 把 status 设为 running.
      // _runQueue 在 background 跑, 失败也无所谓 (我们只看 status 立刻翻成 running).
      // 但 backgroundRunnerProvider 没 override 会抛, 所以都 override.
      final container = ProviderContainer(overrides: [
        downloadStoreProvider.overrideWithValue(_FakeDownloadStore()),
        cameraSessionProvider.overrideWith((ref) => CameraSession(
              id: 'fake-session',
              connectedHost: '192.168.1.1',
              port: 15740,
              connectedAt: DateTime(2024, 1, 1),
            )),
        backgroundRunnerProvider.overrideWithValue(_StubBackgroundRunner2()),
        notificationServiceProvider.overrideWithValue(_StubNotificationService2()),
        photoLibraryChannelProvider.overrideWithValue(_StubPhotoLibraryChannel2()),
        cameraTransportProvider.overrideWith((ref) => FakeCameraTransport()),
        // appShellProvider 默认 OK (无 override), 但需要 appendLog 不会崩
      ]);
      addTearDown(() => container.dispose);

      final notifier = container.read(downloadManagerProvider.notifier);
      // 不 await, 因为 _runQueue 会异步跑 (FakeCameraTransport.downloadAssetToTemporaryFile 返回 '')
      unawaited(notifier.downloadSelected(
        [_asset(id: 'a'), _asset(id: 'b')],
        autoExport: false,
        prioritizeJPEG: false,
      ));

      // 给 event loop 让 _startQueueIfPossible 跑完, status 转 running
      await Future<void>.delayed(Duration.zero);

      final state = container.read(downloadManagerProvider);
      expect(state.jobs.length, 2);
      expect(state.status, DownloadQueueStatus.running,
          reason: '有 session + runnable jobs → status 应为 running');
    });

    test('refreshDownloads() 移除 completed 但磁盘无对应 record 的 job', () async {
      final store = _FakeDownloadStore();
      // 不走 loadPersistedQueue, 直接往 state 里塞
      final container = _container(store: store);
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      // 手工往 state 里加 1 completed + 1 queued (用 fileName 区分)
      notifier.enqueue(_asset(id: 'd1', remoteId: 'd1', name: 'completed_asset.NEF'));
      notifier.enqueue(_asset(id: 'q1', remoteId: 'q1', name: 'queued_asset.NEF'));
      // 把第 1 个标 completed (用 fileName 找)
      final jobs = container.read(downloadManagerProvider).jobs;
      final completedJob = jobs.firstWhere((j) => j.fileName == 'completed_asset.NEF');
      container.read(downloadManagerProvider.notifier).state =
          container.read(downloadManagerProvider).copyWith(
        jobs: container.read(downloadManagerProvider).jobs.map((j) {
          if (j.fileName != completedJob.fileName) return j;
          return j.copyWith(status: DownloadJobStatus.completed);
        }).toList(),
      );
      expect(container.read(downloadManagerProvider).jobs.length, 2);

      // listRecords 返回空 (Fake 默认), completed_asset 无 record, queued_asset 也无 record
      // refresh 应剔除 completed (id 不在 diskIDs), queued (非 completed) 保留
      await notifier.refreshDownloads();

      final state = container.read(downloadManagerProvider);
      expect(state.jobs.length, 1, reason: 'completed 但磁盘无 record 的 job 应被剔');
      expect(state.jobs.first.fileName, 'queued_asset.NEF',
          reason: 'queued (非 completed) 应保留');
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
