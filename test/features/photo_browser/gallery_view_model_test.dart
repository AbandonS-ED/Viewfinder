import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/features/photo_browser/gallery_view_model.dart';

void main() {
  group('GalleryNotifier', () {
    test('build() 初始 state：返回 12 个 mock assets', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final state = await container.read(galleryProvider.future);
      expect(state.photoAssets.length, 12);
      expect(state.isLoading, isFalse);
      expect(state.hasMorePhotos, isFalse);
      expect(state.hasSelection, isFalse);
    });

    test('refresh()：state 重置为 12 个 mock', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await container.read(galleryProvider.future);
      final notifier = container.read(galleryProvider.notifier);

      await notifier.refresh();
      final state = container.read(galleryProvider).requireValue;
      expect(state.photoAssets.length, 12);
    });

    test('loadMore()：Phase 2 mock 不变，验证 async 行为', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await container.read(galleryProvider.future);
      final notifier = container.read(galleryProvider.notifier);

      await notifier.loadMore();
      final state = container.read(galleryProvider).requireValue;
      expect(state.hasMorePhotos, isFalse);
    });

    test('toggleSelection(id)：选/取消改 selectedAssetIDs', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final state = await container.read(galleryProvider.future);
      expect(state.hasSelection, isFalse);

      final notifier = container.read(galleryProvider.notifier);
      notifier.toggleSelection('mock-0');
      expect(container.read(galleryProvider).requireValue.selectedAssetIDs, contains('mock-0'));
      expect(container.read(galleryProvider).requireValue.selectedAssetsCount, 1);

      notifier.toggleSelection('mock-0');
      expect(container.read(galleryProvider).requireValue.selectedAssetIDs, isNot(contains('mock-0')));
      expect(container.read(galleryProvider).requireValue.selectedAssetsCount, 0);
    });

    test('selectAllAssets() / clearSelection() 边界', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await container.read(galleryProvider.future);
      final notifier = container.read(galleryProvider.notifier);

      notifier.selectAllAssets();
      expect(
        container.read(galleryProvider).requireValue.selectedAssetIDs.length,
        12,
      );

      notifier.clearSelection();
      expect(
        container.read(galleryProvider).requireValue.selectedAssetIDs.length,
        0,
      );
    });
  });
}
