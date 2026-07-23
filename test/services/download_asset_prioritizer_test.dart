import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/photo_asset.dart';
import 'package:viewfinder/services/download_asset_prioritizer.dart';

PhotoAsset _asset(PhotoAssetKind kind, int index) {
  return PhotoAsset(
    id: 'id-$index',
    remoteIdentifier: '$index',
    fileName: 'DSC_$index',
    kind: kind,
    byteSize: 1024 * 1024 * 10,
    captureDate: DateTime.now().subtract(Duration(hours: index)),
  );
}

void main() {
  group('DownloadAssetPrioritizer.cameraOrder', () {
    test('保持原顺序', () {
      final list = [
        _asset(PhotoAssetKind.raw, 1),
        _asset(PhotoAssetKind.jpeg, 2),
        _asset(PhotoAssetKind.movie, 3),
      ];
      final sorted = DownloadAssetPrioritizer.cameraOrder.sort(list);
      expect(sorted.map((a) => a.id).toList(), ['id-1', 'id-2', 'id-3']);
    });

    test('不修改原始列表', () {
      final list = [_asset(PhotoAssetKind.raw, 1), _asset(PhotoAssetKind.jpeg, 2)];
      final originalOrder = list.map((a) => a.id).toList();
      DownloadAssetPrioritizer.cameraOrder.sort(list);
      expect(list.map((a) => a.id).toList(), originalOrder);
    });
  });

  group('DownloadAssetPrioritizer.jpegFirst', () {
    test('JPEG / PNG 排在 RAW / 视频前', () {
      final list = [
        _asset(PhotoAssetKind.raw, 1),
        _asset(PhotoAssetKind.jpeg, 2),
        _asset(PhotoAssetKind.movie, 3),
      ];
      final sorted = DownloadAssetPrioritizer.jpegFirst.sort(list);
      expect(sorted.map((a) => a.kind).toList(), [
        PhotoAssetKind.jpeg,
        PhotoAssetKind.raw,
        PhotoAssetKind.movie,
      ]);
    });

    test('PNG 与 JPEG 同级 (score=0)，保持原顺序', () {
      final list = [
        _asset(PhotoAssetKind.png, 1),
        _asset(PhotoAssetKind.jpeg, 2),
        _asset(PhotoAssetKind.raw, 3),
      ];
      final sorted = DownloadAssetPrioritizer.jpegFirst.sort(list);
      expect(sorted.map((a) => a.kind).toList(), [
        PhotoAssetKind.png,
        PhotoAssetKind.jpeg,
        PhotoAssetKind.raw,
      ]);
    });

    test('全 JPEG 排前面', () {
      final list = [
        _asset(PhotoAssetKind.raw, 1),
        _asset(PhotoAssetKind.jpeg, 2),
        _asset(PhotoAssetKind.jpeg, 3),
        _asset(PhotoAssetKind.movie, 4),
      ];
      final sorted = DownloadAssetPrioritizer.jpegFirst.sort(list);
      final firstKind = sorted.first.kind;
      expect(firstKind, anyOf(PhotoAssetKind.jpeg, PhotoAssetKind.png));
      expect(sorted.last.kind, PhotoAssetKind.movie);
    });
  });
}
