import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/camera_session.dart';
import 'package:viewfinder/domain/photo_asset.dart';
import 'package:viewfinder/features/connection_setup/connection_view_model.dart';
import 'package:viewfinder/features/photo_browser/gallery_view_model.dart';

import '../../helpers/fake_camera_transport.dart';

class _FakeTransportWithAssets extends FakeCameraTransport {
  _FakeTransportWithAssets({required this.assets, this.hasMore = false})
      : super(sessionToReturn: CameraSession(id: 'session-1', connectedAt: DateTime.now()));

  final List<PhotoAsset> assets;
  final bool hasMore;

  @override
  Future<PhotoAssetPage> fetchAssetsPage({
    required CameraSession session,
    required bool resetTraversal,
    required int limit,
  }) async {
    return PhotoAssetPage(assets: assets, hasMore: hasMore);
  }
}

void main() {
  group('GalleryNotifier', () {
    test('build() 初始 state：返回 12 个 mock assets', () async {
      final container = ProviderContainer(
        overrides: [
          cameraSessionProvider.overrideWith((ref) => null),
          cameraTransportProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(() => container.dispose());

      final state = await container.read(galleryProvider.future);
      expect(state.photoAssets.length, 12);
      expect(state.isLoading, isFalse);
      expect(state.hasMorePhotos, isFalse);
      expect(state.hasSelection, isFalse);
    });

    test('refresh() 无 session 时回退 mock 12 张', () async {
      final container = ProviderContainer(
        overrides: [
          cameraSessionProvider.overrideWith((ref) => null),
          cameraTransportProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(() => container.dispose());

      await container.read(galleryProvider.future);
      final notifier = container.read(galleryProvider.notifier);

      await notifier.refresh();
      final state = container.read(galleryProvider).requireValue;
      expect(state.photoAssets.length, 12);
    });

    test('loadMore() 无 session 时 hasMorePhotos = false', () async {
      final container = ProviderContainer(
        overrides: [
          cameraSessionProvider.overrideWith((ref) => null),
          cameraTransportProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(() => container.dispose());

      await container.read(galleryProvider.future);
      final notifier = container.read(galleryProvider.notifier);

      await notifier.loadMore();
      final state = container.read(galleryProvider).requireValue;
      expect(state.hasMorePhotos, isFalse);
    });

    test('toggleSelection(id)：选/取消改 selectedAssetIDs', () async {
      final container = ProviderContainer(
        overrides: [
          cameraSessionProvider.overrideWith((ref) => null),
          cameraTransportProvider.overrideWith((ref) => null),
        ],
      );
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
      final container = ProviderContainer(
        overrides: [
          cameraSessionProvider.overrideWith((ref) => null),
          cameraTransportProvider.overrideWith((ref) => null),
        ],
      );
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

    test('有 session 时 refresh() 调 transport.fetchAssetsPage() 并返回真实数据', () async {
      final transport = _FakeTransportWithAssets(
        assets: List.generate(5, (i) => PhotoAsset(
          id: 'real-$i',
          remoteIdentifier: '$i',
          fileName: 'REAL_$i.NEF',
          kind: PhotoAssetKind.raw,
          byteSize: 1024,
          captureDate: DateTime(2026, 7, 24, 12),
        )),
        hasMore: true,
      );
      final container = ProviderContainer(
        overrides: [
          cameraSessionProvider.overrideWith((ref) =>
              CameraSession(id: 'session-1', connectedAt: DateTime.now())),
          cameraTransportProvider.overrideWith((ref) => transport),
        ],
      );
      addTearDown(() => container.dispose());

      await container.read(galleryProvider.future);
      await container.read(galleryProvider.notifier).refresh();
      final state = container.read(galleryProvider).requireValue;
      expect(state.photoAssets.length, 5);
      expect(state.photoAssets.first.id, 'real-0');
      expect(state.hasMorePhotos, isTrue);
    });

    test('onSessionChanged(null → session) 触发 _loadFromCamera', () async {
      final transport = _FakeTransportWithAssets(
        assets: [PhotoAsset(
          id: 'real-1',
          remoteIdentifier: '1',
          fileName: 'REAL_1.NEF',
          kind: PhotoAssetKind.jpeg,
          byteSize: 2048,
          captureDate: DateTime(2026, 7, 24, 12),
        )],
      );
      final container = ProviderContainer(
        overrides: [
          cameraSessionProvider.overrideWith((ref) =>
              CameraSession(id: 'session-2', connectedAt: DateTime.now())),
          cameraTransportProvider.overrideWith((ref) => transport),
        ],
      );
      addTearDown(() => container.dispose());

      await container.read(galleryProvider.future);
      container.read(galleryProvider.notifier).onSessionChanged(null, CameraSession(
        id: 'session-2',
        connectedAt: DateTime.now(),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final state = container.read(galleryProvider).requireValue;
      expect(state.photoAssets.length, 1);
      expect(state.photoAssets.first.id, 'real-1');
    });
  });
}
