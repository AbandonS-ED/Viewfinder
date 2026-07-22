import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../domain/camera_connection_config.dart';
import '../domain/camera_capability.dart';
import '../domain/camera_session.dart';
import '../domain/photo_asset.dart';
import '../domain/camera_app_error.dart';
import '../domain/download_throughput_diagnostics.dart';
import 'camera_transport.dart';
import 'primitives/ptpip_data_types.dart';
import 'primitives/ptpip_error.dart';
import 'session/ptpip_session.dart';

class ExperimentalNikonTransport implements CameraTransport {
  PtpipSession? _session;
  final List<String> _pendingDiagnostics = [];

  @override
  Future<CameraSession> connect({required CameraConnectionConfig config}) async {
    final host = config.normalizedHost;
    if (host.isEmpty) {
      throw const CameraAppError.missingHost();
    }
    if (config.port < 1 || config.port > 65535) {
      throw const CameraAppError.invalidPort();
    }

    if (_session != null) {
      await _session!.closeSession();
      _session = null;
    }

    final session = PtpipSession(host: host, port: config.port);

    try {
      final deviceInfo = await session.openSession();
      _session = session;

      final capabilities = <CameraCapability>{
        if (deviceInfo.operationsSupported.contains(PTPOperationCode.getObjectHandles.rawValue))
          CameraCapability.listAssets,
        if (deviceInfo.operationsSupported.contains(PTPOperationCode.getObject.rawValue))
          CameraCapability.downloadAssets,
      };

      return CameraSession(
        cameraName: deviceInfo.model ?? 'Nikon Camera',
        connectedHost: host,
        port: config.port,
        connectedAt: DateTime.now(),
        capabilities: capabilities,
      );
    } catch (e) {
      await session.closeSession();
      _session = null;
      if (e is CameraAppError) rethrow;
      throw CameraAppError.networkProbeFailed(e.toString());
    }
  }

  @override
  Future<PhotoAssetPage> fetchAssetsPage({
    required CameraSession session,
    required bool resetTraversal,
    required int limit,
  }) async {
    final s = _session;
    if (s == null) throw const CameraAppError.notConnected();

    try {
      final handles = await s.getObjectHandles(storageID: 0xFFFFFFFF);
      final assets = <PhotoAsset>[];
      for (final handle in handles.take(limit)) {
        final info = await s.getObjectInfo(handle);
        assets.add(PhotoAsset(
          id: handle.toString(),
          remoteIdentifier: handle.toString(),
          fileName: info.fileName.isNotEmpty ? info.fileName : 'DSC_$handle',
          kind: _classifyObjectFormat(info.objectFormat),
          byteSize: info.compressedSize,
          captureDate: info.captureDate ?? DateTime.now(),
          thumbnailInfo: info.thumbnailInfo,
        ));
      }
      return PhotoAssetPage(assets: assets, hasMore: handles.length > limit);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<Uint8List> downloadAsset(PhotoAsset asset, CameraSession session) async {
    final s = _session;
    if (s == null) throw const CameraAppError.notConnected();

    final handle = int.tryParse(asset.remoteIdentifier);
    if (handle == null) {
      throw CameraAppError.unsupportedOperation('bad handle: ${asset.remoteIdentifier}');
    }

    try {
      return await s.getObject(handle);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<Uint8List?> downloadThumbnail(PhotoAsset asset, CameraSession session) async {
    final s = _session;
    if (s == null) throw const CameraAppError.notConnected();

    final handle = int.tryParse(asset.remoteIdentifier);
    if (handle == null) return null;

    try {
      return await s.getThumbnail(handle);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<String> downloadAssetToTemporaryFile(
    PhotoAsset asset,
    CameraSession session, {
    void Function(DownloadTransferProgress)? onProgress,
  }) async {
    final bytes = await downloadAsset(asset, session);
    final tempDir = Directory.systemTemp.createTempSync();
    final file = File('${tempDir.path}/${asset.fileName}');
    await file.writeAsBytes(bytes);
    return file.path;
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
    final messages = List<String>.from(_pendingDiagnostics);
    _pendingDiagnostics.clear();
    return messages;
  }

  @override
  Future<void> disconnect(CameraSession session) async {
    final s = _session;
    if (s != null) {
      await s.closeSession();
      _session = null;
    }
  }

  PhotoAssetKind _classifyObjectFormat(int format) {
    if (format == 0x3001) return PhotoAssetKind.movie;
    if (format == 0x3801 || format == 0x3808) return PhotoAssetKind.jpeg;
    if (format == 0x380B) return PhotoAssetKind.png;
    if (format == 0x3000) return PhotoAssetKind.raw;
    if (format == 0x380D || format == 0x3802 || format == 0x3810 || format == 0x3811) {
      return PhotoAssetKind.raw;
    }
    if (format == 0xB200) return PhotoAssetKind.jpeg;
    if (format == 0x1001 || format == 0x1003 || format == 0x100D || format == 0xB97E) {
      return PhotoAssetKind.movie;
    }
    return PhotoAssetKind.raw;
  }

  CameraAppError _mapError(Object e) {
    if (e is CameraAppError) return e;
    if (e is PTPIPError) return CameraAppError.networkProbeFailed(e.message);
    return CameraAppError.networkProbeFailed(e.toString());
  }
}
