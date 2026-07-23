import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/photo_asset.dart';

part 'gallery_state.freezed.dart';

@freezed
class GalleryState with _$GalleryState {
  const factory GalleryState({
    @Default(<PhotoAsset>[]) List<PhotoAsset> photoAssets,
    @Default(false) bool hasMorePhotos,
    @Default(<String>{}) Set<String> selectedAssetIDs,
    @Default(false) bool isLoading,
  }) = _GalleryState;

  const GalleryState._();

  bool get hasSelection => selectedAssetIDs.isNotEmpty;
  int get selectedAssetsCount => selectedAssetIDs.length;
}
