import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/photo_asset.dart';
import 'gallery_state.dart';

final galleryProvider =
    AsyncNotifierProvider<GalleryNotifier, GalleryState>(GalleryNotifier.new);

class GalleryNotifier extends AsyncNotifier<GalleryState> {
  @override
  Future<GalleryState> build() async {
    return _mockState();
  }

  Future<void> refresh() async {
    state = AsyncValue.data(_mockState());
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(hasMorePhotos: false));
  }

  void toggleSelection(String id) {
    final current = state.asData?.value;
    if (current == null) return;
    final updated = Set<String>.from(current.selectedAssetIDs);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = AsyncValue.data(current.copyWith(selectedAssetIDs: updated));
  }

  void selectAllAssets() {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncValue.data(
      current.copyWith(
        selectedAssetIDs: current.photoAssets.map((a) => a.id).toSet(),
      ),
    );
  }

  void clearSelection() {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(selectedAssetIDs: {}));
  }

  GalleryState _mockState() {
    return GalleryState(
      photoAssets: List.generate(12, (i) => PhotoAsset(
        id: 'mock-$i',
        remoteIdentifier: '$i',
        fileName: 'DSC_0${i + 100}.NEF',
        kind: i.isEven ? PhotoAssetKind.raw : PhotoAssetKind.jpeg,
        byteSize: 1024 * 1024 * (10 + i),
        captureDate: DateTime.now().subtract(Duration(hours: i)),
        thumbnailInfo: null,
      )),
      hasMorePhotos: false,
    );
  }
}
