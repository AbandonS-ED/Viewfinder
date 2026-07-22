import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/camera_connection_config.dart';
import '../domain/camera_session.dart';
import '../domain/photo_asset.dart';
import '../domain/download_throughput_diagnostics.dart';

part 'camera_transport.freezed.dart';

@freezed
class DownloadTransferProgress with _$DownloadTransferProgress {
  const factory DownloadTransferProgress({
    @Default(0) int bytesTransferred,
    @Default(0) int totalBytes,
    @Default(0) int resumedCount,
    @Default(0) int currentOffset,
    @Default(0) int chunkSize,
  }) = _DownloadTransferProgress;

  const DownloadTransferProgress._();

  double get fractionCompleted {
    if (totalBytes <= 0) return 0;
    return (bytesTransferred / totalBytes).clamp(0.0, 1.0);
  }
}

abstract class CameraTransport {
  Future<CameraSession> connect({required CameraConnectionConfig config});

  Future<PhotoAssetPage> fetchAssetsPage({
    required CameraSession session,
    required bool resetTraversal,
    required int limit,
  });

  Future<Uint8List> downloadAsset(PhotoAsset asset, CameraSession session);

  Future<Uint8List?> downloadThumbnail(PhotoAsset asset, CameraSession session);

  Future<String> downloadAssetToTemporaryFile(
    PhotoAsset asset,
    CameraSession session, {
    void Function(DownloadTransferProgress)? onProgress,
  });

  Future<DownloadThroughputTransferMode> downloadTransferMode(
    PhotoAsset asset,
    CameraSession session,
  );

  Future<List<String>> consumeDiagnostics(CameraSession session);

  Future<void> disconnect(CameraSession session);
}
