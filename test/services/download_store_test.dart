import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/camera_app_error.dart';
import 'package:viewfinder/domain/download_job.dart';
import 'package:viewfinder/domain/download_queue_state.dart';
import 'package:viewfinder/domain/photo_asset.dart';
import 'package:viewfinder/services/download_store.dart';

PhotoAsset _asset({String name = 'DSC_0001.NEF', int size = 1024, String id = '1'}) {
  return PhotoAsset(
    id: id,
    remoteIdentifier: id,
    fileName: name,
    kind: PhotoAssetKind.jpeg,
    byteSize: size,
    captureDate: DateTime(2026, 7, 24, 12),
  );
}

DownloadJob _job({
  required String id,
  DownloadJobStatus status = DownloadJobStatus.queued,
}) {
  return DownloadJob(
    id: id,
    remoteIdentifier: id,
    fileName: 'DSC_$id.NEF',
    kind: PhotoAssetKind.jpeg,
    byteSize: 1024,
    captureDate: DateTime(2026, 7, 24, 12),
    autoExportToPhotoLibrary: false,
    status: status,
    bytesTransferred: 0,
    totalBytes: 1024,
    currentOffset: 0,
    resumedCount: 0,
    createdAt: DateTime(2026, 7, 24, 12),
    startedAt: null,
    completedAt: null,
    updatedAt: DateTime(2026, 7, 24, 12),
  );
}

File _makeTempFile(Directory dir, String name, List<int> bytes) {
  final f = File('${dir.path}/$name');
  f.writeAsBytesSync(bytes);
  return f;
}

void main() {
  late Directory tempRoot;
  late DownloadStore store;

  setUp(() {
    tempRoot = Directory.systemTemp.createTempSync('download_store_test_');
    store = DownloadStore(rootDirectory: tempRoot);
  });

  tearDown(() {
    if (tempRoot.existsSync()) {
      tempRoot.deleteSync(recursive: true);
    }
  });

  group('DownloadStore listRecords', () {
    test('空目录 → 空 list', () async {
      expect(await store.listRecords(), isEmpty);
    });
  });

  group('DownloadStore saveQueueState + loadQueueState', () {
    test('round-trip 保留 jobs 和 status', () async {
      final jobs = [_job(id: 'a'), _job(id: 'b', status: DownloadJobStatus.running)];
      final state = DownloadQueueState(
        jobs: jobs,
        status: DownloadQueueStatus.running,
        activeJobID: 'b',
      );
      await store.saveQueueState(state);

      final loaded = await store.loadQueueState();
      expect(loaded.jobs.length, 2);
      expect(loaded.jobs[0].id, 'a');
      expect(loaded.jobs[1].status, DownloadJobStatus.running);
      expect(loaded.status, DownloadQueueStatus.running);
      expect(loaded.activeJobID, 'b');
    });
  });

  group('DownloadStore storeDownloadedFile', () {
    test('移动 source 到 Downloads/ 并加 manifest 记录', () async {
      final src = _makeTempFile(tempRoot, 'src.NEF', List.filled(512, 0));
      final asset = _asset(name: 'DSC_9999.NEF', size: 512);

      final record = await store.storeDownloadedFile(
        sourcePath: src.path,
        asset: asset,
      );

      expect(File(record.savedURL).existsSync(), isTrue);
      expect(File(record.savedURL).path, contains('DSC_9999.NEF'));
      expect(record.byteSize, 512);
      expect(record.exportedToPhotoLibrary, isFalse);

      final records = await store.listRecords();
      expect(records.length, 1);
      expect(records.first.fileName, 'DSC_9999.NEF');
    });

    test('重复文件名自动加 -2 / -3 后缀', () async {
      final src1 = _makeTempFile(tempRoot, 's1.NEF', [1]);
      final src2 = _makeTempFile(tempRoot, 's2.NEF', [2]);
      final src3 = _makeTempFile(tempRoot, 's3.NEF', [3]);
      final asset = _asset(name: 'DUP.NEF', size: 1);

      final r1 = await store.storeDownloadedFile(sourcePath: src1.path, asset: asset);
      final r2 = await store.storeDownloadedFile(sourcePath: src2.path, asset: asset);
      final r3 = await store.storeDownloadedFile(sourcePath: src3.path, asset: asset);

      expect(r1.fileName, 'DUP.NEF');
      expect(r2.fileName, 'DUP-2.NEF');
      expect(r3.fileName, 'DUP-3.NEF');
    });

    test('source 不存在抛 fileSystemFailure', () async {
      final asset = _asset(name: 'X.NEF');
      expect(
        () => store.storeDownloadedFile(sourcePath: '/nonexistent/path/X.NEF', asset: asset),
        throwsA(isA<CameraAppError>()),
      );
    });
  });

  group('DownloadStore markExported', () {
    test('记录 exportedToPhotoLibrary = true', () async {
      final src = _makeTempFile(tempRoot, 's.NEF', [1]);
      final asset = _asset(name: 'A.NEF', size: 1);
      final record = await store.storeDownloadedFile(sourcePath: src.path, asset: asset);

      final updated = await store.markExported(record.id);
      expect(updated.exportedToPhotoLibrary, isTrue);
      expect(updated.id, record.id);
    });

    test('ID 不存在抛 fileSystemFailure', () async {
      expect(
        () => store.markExported('nope'),
        throwsA(isA<CameraAppError>()),
      );
    });
  });

  group('DownloadStore markInterruptedRunningJobs', () {
    test('running → interrupted, queued 保持, 清 activeJobID', () async {
      final state = DownloadQueueState(
        jobs: [
          _job(id: 'a', status: DownloadJobStatus.queued),
          _job(id: 'b', status: DownloadJobStatus.running),
          _job(id: 'c', status: DownloadJobStatus.completed),
        ],
        activeJobID: 'b',
        status: DownloadQueueStatus.running,
      );
      await store.saveQueueState(state);

      final result = await store.markInterruptedRunningJobs(reason: 'App 重启');
      expect(result.jobs[0].status, DownloadJobStatus.queued);
      expect(result.jobs[1].status, DownloadJobStatus.interrupted);
      expect(result.jobs[2].status, DownloadJobStatus.completed);
      expect(result.jobs[1].errorMessage, 'App 重启');
      expect(result.activeJobID, isNull);
      expect(result.status, DownloadQueueStatus.interrupted);
    });
  });

  group('DownloadStore 损坏恢复', () {
    test('queue 文件 JSON 损坏 → loadQueueState 返回空 state, 文件被备份', () async {
      final dir = Directory('${tempRoot.path}/Downloads')..createSync();
      File('${dir.path}/download-jobs.json').writeAsStringSync('not valid json {{{');
      final loaded = await store.loadQueueState();
      expect(loaded.jobs, isEmpty);
      expect(loaded.status, DownloadQueueStatus.idle);
    });

    test('queue 文件缺字段走 default (Schema 兼容)', () async {
      final dir = Directory('${tempRoot.path}/Downloads')..createSync();
      File('${dir.path}/download-jobs.json')
          .writeAsStringSync('{"activeJobID": "x"}');
      final loaded = await store.loadQueueState();
      expect(loaded.jobs, isEmpty);
      expect(loaded.activeJobID, 'x');
      expect(loaded.status, DownloadQueueStatus.idle);
    });
  });

  group('DownloadStore upsert / remove', () {
    test('upsertDownloadJob 新增 + 替换', () async {
      final j1 = _job(id: 'a');
      final r1 = await store.upsertDownloadJob(
        job: j1,
        queueStatus: DownloadQueueStatus.running,
        activeJobID: 'a',
      );
      expect(r1.jobs.length, 1);

      final j1Updated = j1.copyWith(status: DownloadJobStatus.completed);
      final r2 = await store.upsertDownloadJob(
        job: j1Updated,
        queueStatus: DownloadQueueStatus.idle,
        activeJobID: null,
      );
      expect(r2.jobs.length, 1);
      expect(r2.jobs[0].status, DownloadJobStatus.completed);
    });

    test('removeDownloadJobs 按 id 列表删除 + 删 active 时清空', () async {
      await store.saveQueueState(DownloadQueueState(
        jobs: [_job(id: 'a'), _job(id: 'b'), _job(id: 'c')],
        activeJobID: 'b',
      ));
      final r = await store.removeDownloadJobs(
        ids: ['a', 'b'],
        queueStatus: DownloadQueueStatus.running,
        activeJobID: null,
      );
      expect(r.jobs.map((j) => j.id).toList(), ['c']);
      expect(r.activeJobID, isNull);
      expect(r.status, DownloadQueueStatus.running);
    });

    test('removeDownloadJobs 不删 active 时保留 activeJobID', () async {
      await store.saveQueueState(DownloadQueueState(
        jobs: [_job(id: 'a'), _job(id: 'b', status: DownloadJobStatus.running)],
        activeJobID: 'b',
      ));
      final r = await store.removeDownloadJobs(
        ids: ['a'],
        queueStatus: DownloadQueueStatus.running,
        activeJobID: 'b',
      );
      expect(r.jobs.map((j) => j.id).toList(), ['b']);
      expect(r.activeJobID, 'b');
    });
  });
}
