import 'package:flutter/material.dart';

import '../../domain/camera_session.dart';
import '../../domain/photo_asset.dart';
import '../../protocol/camera_transport.dart';
import '../../services/asset_thumbnail_service.dart';
import '../shared/app_theme.dart';
import '../shared/shared_components.dart';
import 'gallery_state.dart';
import 'thumbnail_widget.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onToggleSelection,
    required this.onSelectAll,
    required this.onClearSelection,
    this.onDownloadSelected,
    this.thumbnailService,
    this.transport,
    this.session,
  });

  final GalleryState state;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final void Function(String id) onToggleSelection;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;
  final VoidCallback? onDownloadSelected;
  final AssetThumbnailServing? thumbnailService;
  final CameraTransport? transport;
  final CameraSession? session;

  bool get _canShowThumbnails =>
      thumbnailService != null && transport != null && session != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _metricBar(context),
        if (state.hasSelection) _selectionBar(context),
        _filterBar(context),
        Expanded(child: _grid(context)),
      ],
    );
  }

  Widget _metricBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: MetricTile(
              label: '已加载',
              value: '${state.photoAssets.length}',
              icon: Icons.photo_library_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MetricTile(
              label: '已选择',
              value: '${state.selectedAssetsCount}',
              icon: Icons.check_circle_outline,
              accent: AppThemeColors.a,
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectionBar(BuildContext context) {
    final downloadCb = onDownloadSelected;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          SecondaryActionButton(
            title: '全选',
            expands: false,
            onPressed: onSelectAll,
          ),
          const SizedBox(width: 8),
          SecondaryActionButton(
            title: '取消选择',
            expands: false,
            onPressed: onClearSelection,
          ),
          const SizedBox(width: 8),
          if (downloadCb != null)
            SecondaryActionButton(
              title: '下载所选',
              expands: false,
              onPressed: downloadCb,
            ),
        ],
      ),
    );
  }

  Widget _filterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('全部'),
            const SizedBox(width: 8),
            _chip('RAW'),
            const SizedBox(width: 8),
            _chip('JPEG'),
            const SizedBox(width: 8),
            _chip('视频'),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppThemeColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppThemeRadius.pill),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, color: AppThemeColors.t2)),
    );
  }

  Widget _grid(BuildContext context) {
    if (state.photoAssets.isEmpty) {
      return Center(
        child: Text('暂无照片', style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: state.photoAssets.length,
        itemBuilder: (context, index) => _thumbnail(state.photoAssets[index]),
      ),
    );
  }

  Widget _thumbnail(PhotoAsset asset) {
    final selected = state.selectedAssetIDs.contains(asset.id);
    return GestureDetector(
      onTap: () => onToggleSelection(asset.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppThemeColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: AppThemeColors.a, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            if (_canShowThumbnails)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ThumbnailWidget(
                  asset: asset,
                  service: thumbnailService!,
                  transport: transport!,
                  session: session!,
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      asset.kind == PhotoAssetKind.raw
                          ? Icons.camera_alt_outlined
                          : Icons.photo_outlined,
                      color: AppThemeColors.t2,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        asset.fileName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9, color: AppThemeColors.tm),
                      ),
                    ),
                  ],
                ),
              ),
            if (selected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppThemeColors.a,
                  ),
                  child: const Icon(Icons.check, size: 14, color: AppThemeColors.btnT),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
