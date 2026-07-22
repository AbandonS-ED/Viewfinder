import 'package:freezed_annotation/freezed_annotation.dart';
import 'photo_asset.dart';

part 'photo_asset_merge.freezed.dart';

/// RAW + JPEG 配对 (相机同时间拍 RAW+JPEG，合并显示)
@freezed
class PhotoAssetMerge with _$PhotoAssetMerge {
  const factory PhotoAssetMerge({
    /// 主照片 (一般 JPEG，因为小)
    required PhotoAsset primary,

    /// 配对照片 (一般 RAW)
    PhotoAsset? paired,
  }) = _PhotoAssetMerge;
}
