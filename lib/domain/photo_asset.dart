import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_asset.freezed.dart';

/// 照片资产
@freezed
class PhotoAsset with _$PhotoAsset {
  const factory PhotoAsset({
    /// 唯一标识 (Phase 0 用空字符串占位)
    @Default('') String id,

    /// 相机返回的对象 handle (UInt32, 序列化为字符串)
    required String remoteIdentifier,

    required String fileName,

    required PhotoAssetKind kind,

    @Default(0) int byteSize,

    required DateTime captureDate,

    PhotoAssetThumbnailInfo? thumbnailInfo,
  }) = _PhotoAsset;
}

/// 照片类型
enum PhotoAssetKind {
  png,
  jpeg,
  raw,
  movie;

  String get badgeTitle {
    switch (this) {
      case PhotoAssetKind.png: return 'PNG';
      case PhotoAssetKind.jpeg: return 'JPEG';
      case PhotoAssetKind.raw: return 'RAW';
      case PhotoAssetKind.movie: return 'MOV';
    }
  }

  String get systemImageName {
    switch (this) {
      case PhotoAssetKind.png:
      case PhotoAssetKind.jpeg: return 'photo';
      case PhotoAssetKind.raw: return 'camera.aperture';
      case PhotoAssetKind.movie: return 'film';
    }
  }
}

/// 缩略图元数据
@freezed
class PhotoAssetThumbnailInfo with _$PhotoAssetThumbnailInfo {
  const factory PhotoAssetThumbnailInfo({
    required int formatCode,
    required int byteSize,
    required int pixelWidth,
    required int pixelHeight,
  }) = _PhotoAssetThumbnailInfo;
}

/// 列表分页返回
@freezed
class PhotoAssetPage with _$PhotoAssetPage {
  const factory PhotoAssetPage({
    required List<PhotoAsset> assets,
    @Default(false) bool hasMore,
  }) = _PhotoAssetPage;
}
