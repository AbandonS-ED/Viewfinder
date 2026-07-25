import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../domain/camera_session.dart';
import '../../domain/photo_asset.dart';
import '../../protocol/camera_transport.dart';
import '../../services/asset_thumbnail_service.dart';
import '../shared/viewfinder_theme.dart';

class ThumbnailWidget extends StatelessWidget {
  const ThumbnailWidget({
    super.key,
    required this.asset,
    required this.service,
    required this.transport,
    required this.session,
  });

  final PhotoAsset asset;
  final AssetThumbnailServing service;
  final CameraTransport transport;
  final CameraSession session;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: service.thumbnailData(
        asset: asset,
        transport: transport,
        session: session,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final data = snapshot.data;
        if (data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              data,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          );
        }
        return _fallbackIcon(context);
      },
    );
  }

  Widget _fallbackIcon(BuildContext context) {
    final t = ViewfinderTheme.of(context);
    return Center(
      child: Icon(
        asset.kind == PhotoAssetKind.raw
            ? Icons.camera_alt_outlined
            : Icons.photo_outlined,
        color: t.t2,
        size: 28,
      ),
    );
  }
}
