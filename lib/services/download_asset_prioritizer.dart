import '../domain/photo_asset.dart';

/// JPEG/PNG 优先于 RAW/视频的排序策略。
/// 对齐 iOS DownloadAssetPrioritizer enum。
enum DownloadAssetPrioritizer {
  cameraOrder,
  jpegFirst;

  List<PhotoAsset> sort(List<PhotoAsset> assets) {
    switch (this) {
      case DownloadAssetPrioritizer.cameraOrder:
        return List.from(assets);
      case DownloadAssetPrioritizer.jpegFirst:
        final copy = List<PhotoAsset>.from(assets);
        copy.sort((a, b) {
          final aScore = _priorityScore(a.kind);
          final bScore = _priorityScore(b.kind);
          return aScore.compareTo(bScore);
        });
        return copy;
    }
  }

  static int _priorityScore(PhotoAssetKind kind) {
    return switch (kind) {
      PhotoAssetKind.jpeg => 0,
      PhotoAssetKind.png => 0,
      PhotoAssetKind.raw => 1,
      PhotoAssetKind.movie => 2,
    };
  }
}
