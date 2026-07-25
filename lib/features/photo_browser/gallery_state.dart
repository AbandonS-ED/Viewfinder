import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/photo_asset.dart';

part 'gallery_state.freezed.dart';

/// 网格密度
enum GridDensity {
  standard(3, '标准'),
  compact(5, '紧凑');

  const GridDensity(this.crossAxisCount, this.label);

  final int crossAxisCount;
  final String label;
}

@freezed
class GalleryState with _$GalleryState {
  const factory GalleryState({
    @Default(<PhotoAsset>[]) List<PhotoAsset> photoAssets,
    @Default(false) bool hasMorePhotos,
    @Default(<String>{}) Set<String> selectedAssetIDs,
    @Default(false) bool isLoading,
    @Default(GridDensity.standard) GridDensity gridDensity,
  }) = _GalleryState;

  const GalleryState._();

  bool get hasSelection => selectedAssetIDs.isNotEmpty;
  int get selectedAssetsCount => selectedAssetIDs.length;
}
