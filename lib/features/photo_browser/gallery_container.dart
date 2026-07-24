import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connection_setup/connection_view_model.dart';
import '../downloads/download_manager_view_model.dart';
import 'gallery_page.dart';
import 'gallery_view_model.dart';

class GalleryContainer extends ConsumerWidget {
  const GalleryContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(galleryProvider);
    final transport = ref.watch(cameraTransportProvider);
    final session = ref.watch(cameraSessionProvider);
    final thumbService = ref.watch(assetThumbnailServiceProvider);
    return asyncState.when(
      data: (state) {
        return GalleryPage(
          state: state,
          onRefresh: () => ref.read(galleryProvider.notifier).refresh(),
          onLoadMore: () => ref.read(galleryProvider.notifier).loadMore(),
          onToggleSelection: (id) => ref.read(galleryProvider.notifier).toggleSelection(id),
          onSelectAll: () => ref.read(galleryProvider.notifier).selectAllAssets(),
          onClearSelection: () => ref.read(galleryProvider.notifier).clearSelection(),
          onDownloadSelected: state.hasSelection
              ? () {
                  final selected = state.photoAssets
                      .where((a) => state.selectedAssetIDs.contains(a.id))
                      .toList();
                  ref.read(downloadManagerProvider.notifier).downloadSelected(
                        selected,
                        autoExport: false,
                        prioritizeJPEG: true,
                      );
                }
              : null,
          thumbnailService: thumbService,
          transport: transport,
          session: session,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('$err')),
    );
  }
}
