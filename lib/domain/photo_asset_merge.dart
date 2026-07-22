import 'photo_asset.dart';

/// 照片列表合并工具 (对齐 iOS PhotoAssetMerge.preservingCameraOrder)
class PhotoAssetMerge {
  /// 合并新旧照片列表，去重保持相机顺序
  /// - [resetTraversal]=true: 用 incoming 替换 existing
  /// - [resetTraversal]=false: 把 incoming 追加到 existing 末尾
  static List<PhotoAsset> preservingCameraOrder({
    required List<PhotoAsset> existing,
    required List<PhotoAsset> incoming,
    required bool resetTraversal,
  }) {
    final merged = resetTraversal ? incoming : (existing + incoming);
    final seen = <String>{};
    return merged
        .where((asset) => seen.add(asset.remoteIdentifier))
        .toList(growable: false);
  }
}
