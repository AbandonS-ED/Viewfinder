import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gallery_page.dart';
import 'gallery_view_model.dart';

class GalleryContainer extends ConsumerWidget {
  const GalleryContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(galleryProvider);
    return asyncState.when(
      data: (state) => GalleryPage(
        state: state,
        onRefresh: () => ref.read(galleryProvider.notifier).refresh(),
        onLoadMore: () => ref.read(galleryProvider.notifier).loadMore(),
        onToggleSelection: (id) => ref.read(galleryProvider.notifier).toggleSelection(id),
        onSelectAll: () => ref.read(galleryProvider.notifier).selectAllAssets(),
        onClearSelection: () => ref.read(galleryProvider.notifier).clearSelection(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('$err')),
    );
  }
}
