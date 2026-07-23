import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/download_job.dart';
import 'package:viewfinder/domain/download_queue_state.dart';
import 'package:viewfinder/domain/photo_asset.dart';
import 'package:viewfinder/features/downloads/download_manager_view_model.dart';

void main() {
  group('DownloadManagerNotifier', () {
    test('build() 初始 state：jobs = [], status = idle', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final state = container.read(downloadManagerProvider);
      expect(state.jobs, isEmpty);
      expect(state.status, DownloadQueueStatus.idle);
      expect(state.activeJobID, isNull);
    });

    test('enqueue(asset)：state.jobs.length = 1', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      final asset = PhotoAsset(
        id: '1',
        remoteIdentifier: '100',
        fileName: 'DSC_0100.NEF',
        kind: PhotoAssetKind.raw,
        byteSize: 10 * 1024 * 1024,
        captureDate: DateTime.now(),
      );

      notifier.enqueue(asset);

      expect(container.read(downloadManagerProvider).jobs.length, 1);
      final job = container.read(downloadManagerProvider).jobs.first;
      expect(job.remoteIdentifier, '100');
      expect(job.fileName, 'DSC_0100.NEF');
      expect(job.status, DownloadJobStatus.queued);
    });

    test('cancelJob(id)：status → cancelled', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final notifier = container.read(downloadManagerProvider.notifier);
      final asset = PhotoAsset(
        id: '2',
        remoteIdentifier: '200',
        fileName: 'DSC_0200.JPG',
        kind: PhotoAssetKind.jpeg,
        byteSize: 5 * 1024 * 1024,
        captureDate: DateTime.now(),
      );

      notifier.enqueue(asset);
      final jobId = container.read(downloadManagerProvider).jobs.first.id;

      notifier.cancelJob(jobId);

      final cancelled = container.read(downloadManagerProvider).jobs.first;
      expect(cancelled.status, DownloadJobStatus.cancelled);
    });
  });
}
