import 'dart:async';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../domain/camera_session.dart';
import '../domain/photo_asset.dart';
import '../protocol/camera_transport.dart';

/// Phase 3 §3. 缩略图服务（v2 修订：仅内存 cache，不写磁盘 fallback）。
abstract class AssetThumbnailServing {
  Future<Uint8List?> thumbnailData({
    required PhotoAsset asset,
    required CameraTransport transport,
    required CameraSession session,
  });

  /// 清内存 cache + in-flight map。磁盘 cache 永远保留（无）。
  Future<void> clear();
}

/// 默认实现：内存 cache + in-flight 去重。
class AssetThumbnailService implements AssetThumbnailServing {
  AssetThumbnailService();

  // 内存 cache
  final Map<String, Uint8List> _cache = {};
  // in-flight 去重（同 key 并发只下载一次）
  final Map<String, Future<Uint8List?>> _inFlight = {};

  String _cacheKey(PhotoAsset asset) {
    final raw = [
      asset.remoteIdentifier,
      asset.fileName,
      asset.byteSize.toString(),
      asset.kind.name,
      asset.thumbnailInfo?.byteSize.toString() ?? '0',
      asset.thumbnailInfo?.pixelWidth.toString() ?? '0',
      asset.thumbnailInfo?.pixelHeight.toString() ?? '0',
    ].join('|');
    final digest = sha256.convert(utf8.encode(raw));
    return digest.toString();
  }

  @override
  Future<Uint8List?> thumbnailData({
    required PhotoAsset asset,
    required CameraTransport transport,
    required CameraSession session,
  }) async {
    final key = _cacheKey(asset);

    // 1. 内存 cache hit（同步读；Dart 单线程 event loop 下安全）
    final cached = _cache[key];
    if (cached != null) return cached;

    // 2. in-flight hit
    final existing = _inFlight[key];
    if (existing != null) return existing;

    // 3. 新建 task
    final future = _download(transport, session, asset);
    _inFlight[key] = future;
    try {
      final data = await future;
      if (data != null) _cache[key] = data;
      return data;
    } finally {
      unawaited(_inFlight.remove(key));
    }
  }

  Future<Uint8List?> _download(
    CameraTransport transport,
    CameraSession session,
    PhotoAsset asset,
  ) async {
    try {
      return await transport.downloadThumbnail(asset, session);
    } catch (_) {
      // 失败返回 null（不缓存负结果；下次同 key 调用会重试）
      return null;
    }
  }

  @override
  Future<void> clear() async {
    _cache.clear();
    _inFlight.clear();
  }
}
