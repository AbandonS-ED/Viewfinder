import 'dart:typed_data';

import 'package:viewfinder/domain/camera_app_error.dart';
import 'package:viewfinder/domain/camera_connection_config.dart';
import 'package:viewfinder/domain/camera_session.dart';
import 'package:viewfinder/domain/photo_asset.dart';
import 'package:viewfinder/domain/download_throughput_diagnostics.dart';
import 'package:viewfinder/protocol/camera_transport.dart';
import 'package:viewfinder/protocol/camera_transport_factory.dart';

class FakeCameraTransport implements CameraTransport {
  FakeCameraTransport({
    this.sessionToReturn,
    this.errorToThrow,
  });

  final CameraSession? sessionToReturn;
  final CameraAppError? errorToThrow;

  @override
  Future<CameraSession> connect({required CameraConnectionConfig config}) async {
    if (errorToThrow != null) throw errorToThrow!;
    return sessionToReturn ?? CameraSession(connectedAt: DateTime.now());
  }

  @override
  Future<void> disconnect(CameraSession session) async {}

  @override
  Future<PhotoAssetPage> fetchAssetsPage({
    required CameraSession session,
    required bool resetTraversal,
    required int limit,
  }) async {
    return const PhotoAssetPage(assets: [], hasMore: false);
  }

  @override
  Future<Uint8List> downloadAsset(PhotoAsset asset, CameraSession session) async {
    return Uint8List(0);
  }

  @override
  Future<Uint8List?> downloadThumbnail(PhotoAsset asset, CameraSession session) async {
    return null;
  }

  @override
  Future<String> downloadAssetToTemporaryFile(
    PhotoAsset asset,
    CameraSession session, {
    void Function(DownloadTransferProgress)? onProgress,
  }) async {
    return '';
  }

  @override
  Future<DownloadThroughputTransferMode> downloadTransferMode(
    PhotoAsset asset,
    CameraSession session,
  ) async {
    return DownloadThroughputTransferMode.unknown;
  }

  @override
  Future<List<String>> consumeDiagnostics(CameraSession session) async {
    return [];
  }
}

class FakeCameraTransportFactory implements CameraTransportFactory {
  FakeCameraTransportFactory({required this.fakeTransport});

  final FakeCameraTransport fakeTransport;

  @override
  CameraTransport makeTransport() => fakeTransport;
}
