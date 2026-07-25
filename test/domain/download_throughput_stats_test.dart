import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/download_job.dart';
import 'package:viewfinder/domain/download_queue_state.dart';
import 'package:viewfinder/domain/download_throughput_stats.dart';
import 'package:viewfinder/domain/photo_asset.dart';

PhotoAsset _asset(String id, int byteSize) {
  return PhotoAsset(
    id: id,
    remoteIdentifier: id,
    fileName: '$id.jpg',
    kind: PhotoAssetKind.jpeg,
    byteSize: byteSize,
    captureDate: DateTime(2026, 7, 23),
  );
}

DownloadJob _job({
  required String id,
  required int byteSize,
  DownloadJobStatus status = DownloadJobStatus.completed,
}) {
  final base = DownloadJob.fromAsset(_asset(id, byteSize));
  return base.copyWith(status: status);
}

void main() {
  group('DownloadThroughputStats.format', () {
    test('0 B', () {
      expect(
        const DownloadThroughputStats(
          totalBytes: 0,
          completedItems: 0,
          avgBytesPerItem: 0,
        ).totalBytesLabel,
        '0 B',
      );
    });

    test('< 1024 B 用 B', () {
      expect(
        const DownloadThroughputStats(
          totalBytes: 500,
          completedItems: 1,
          avgBytesPerItem: 500,
        ).totalBytesLabel,
        '500 B',
      );
    });

    test('KB', () {
      expect(
        const DownloadThroughputStats(
          totalBytes: 5 * 1024,
          completedItems: 1,
          avgBytesPerItem: 5 * 1024,
        ).totalBytesLabel,
        '5.0 KB',
      );
    });

    test('MB', () {
      expect(
        const DownloadThroughputStats(
          totalBytes: 12 * 1024 * 1024,
          completedItems: 1,
          avgBytesPerItem: 12 * 1024 * 1024,
        ).totalBytesLabel,
        '12.00 MB',
      );
    });

    test('GB', () {
      expect(
        const DownloadThroughputStats(
          totalBytes: 2 * 1024 * 1024 * 1024,
          completedItems: 1,
          avgBytesPerItem: 2 * 1024 * 1024 * 1024,
        ).totalBytesLabel,
        '2.00 GB',
      );
    });
  });

  group('DownloadQueueState.throughputStats', () {
    test('空队列：0 / 0 / 0 B', () {
      final stats = const DownloadQueueState().throughputStats;
      expect(stats.completedItems, 0);
      expect(stats.totalBytes, 0);
      expect(stats.avgBytesPerItem, 0);
      expect(stats.totalBytesLabel, '0 B');
    });

    test('只有非 completed：仍 0', () {
      final state = DownloadQueueState(
        jobs: [
          _job(id: 'a', byteSize: 1000, status: DownloadJobStatus.queued),
          _job(id: 'b', byteSize: 2000, status: DownloadJobStatus.running),
        ],
      );
      final stats = state.throughputStats;
      expect(stats.completedItems, 0);
      expect(stats.totalBytes, 0);
      expect(stats.avgBytesPerItem, 0);
    });

    test('completed 总字节数 = sum(byteSize)', () {
      final state = DownloadQueueState(
        jobs: [
          _job(id: 'a', byteSize: 1024 * 1024),
          _job(id: 'b', byteSize: 2 * 1024 * 1024),
          _job(id: 'c', byteSize: 3 * 1024 * 1024),
        ],
      );
      final stats = state.throughputStats;
      expect(stats.completedItems, 3);
      expect(stats.totalBytes, 6 * 1024 * 1024);
      expect(stats.avgBytesPerItem, 2 * 1024 * 1024);
    });

    test('混合状态：只算 completed', () {
      final state = DownloadQueueState(
        jobs: [
          _job(id: 'a', byteSize: 1000, status: DownloadJobStatus.completed),
          _job(id: 'b', byteSize: 9999, status: DownloadJobStatus.failed),
          _job(id: 'c', byteSize: 9999, status: DownloadJobStatus.running),
        ],
      );
      final stats = state.throughputStats;
      expect(stats.completedItems, 1);
      expect(stats.totalBytes, 1000);
    });
  });
}