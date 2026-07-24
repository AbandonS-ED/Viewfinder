import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/camera_session.dart';
import '../../domain/photo_asset.dart';
import '../app_shell/app_shell_view_model.dart';
import '../connection_setup/connection_view_model.dart';
import 'gallery_state.dart';

final galleryProvider =
    AsyncNotifierProvider<GalleryNotifier, GalleryState>(GalleryNotifier.new);

class GalleryNotifier extends AsyncNotifier<GalleryState> {
  @override
  Future<GalleryState> build() async {
    return _mockState();
  }

  /// Session 状态变化时由外部监听器调用 (避免在 build() 中 ref.listen
  /// 触发 connection 链的连锁 read, 影响测试与启动性能)。
  void onSessionChanged(CameraSession? previous, CameraSession? next) {
    if (next != null && (previous == null || previous.id != next.id)) {
      // ignore: discarded_futures
      _loadFromCamera();
    } else if (next == null && previous != null) {
      state = AsyncValue.data(_mockState());
    }
  }

  Future<void> refresh() async {
    await _loadFromCamera();
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null) return;
    final session = ref.read(cameraSessionProvider);
    final transport = ref.read(cameraTransportProvider);
    if (session == null || transport == null) {
      state = AsyncValue.data(current.copyWith(hasMorePhotos: false));
      return;
    }
    state = AsyncValue.data(current.copyWith(isLoading: true));
    try {
      final page = await transport.fetchAssetsPage(
        session: session,
        resetTraversal: false,
        limit: 50,
      );
      state = AsyncValue.data(current.copyWith(
        photoAssets: [...current.photoAssets, ...page.assets],
        hasMorePhotos: page.hasMore,
        isLoading: false,
      ));
    } on Object catch (e) {
      state = AsyncValue.data(current.copyWith(isLoading: false));
      ref.read(appShellProvider.notifier).appendLog('loadMore 失败: $e');
    }
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

  Future<void> _loadFromCamera() async {
    final session = ref.read(cameraSessionProvider);
    final transport = ref.read(cameraTransportProvider);
    if (session == null || transport == null) {
      state = AsyncValue.data(_mockState());
      return;
    }
    state = const AsyncValue.loading();
    try {
      final page = await transport.fetchAssetsPage(
        session: session,
        resetTraversal: true,
        limit: 50,
      );
      state = AsyncValue.data(GalleryState(
        photoAssets: page.assets,
        hasMorePhotos: page.hasMore,
        selectedAssetIDs: const {},
        isLoading: false,
      ));
    } on Object catch (e, st) {
      state = AsyncValue.error(e, st);
    }
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
