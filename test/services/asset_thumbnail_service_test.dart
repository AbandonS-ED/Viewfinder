import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/camera_session.dart';
import 'package:viewfinder/domain/photo_asset.dart';
import 'package:viewfinder/protocol/camera_transport.dart';
import 'package:viewfinder/services/asset_thumbnail_service.dart';

class _MockTransport implements CameraTransport {
  bool throwOnThumbnail = false;
  int callCount = 0;

  @override
  Future<Uint8List?> downloadThumbnail(
    PhotoAsset asset,
    CameraSession session,
  ) async {
    callCount++;
    if (throwOnThumbnail) throw Exception('mock err');
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PhotoAsset _makeAsset({int i = 0}) {
  return PhotoAsset(
    remoteIdentifier: 'id_$i',
    fileName: 'pic_$i.jpg',
    kind: PhotoAssetKind.jpeg,
    byteSize: 1024 + i,
    captureDate: DateTime(2024, 1, 1),
    thumbnailInfo: PhotoAssetThumbnailInfo(
      formatCode: 0x0001,
      byteSize: 400 + i,
      pixelWidth: 160,
      pixelHeight: 120,
    ),
  );
}

void main() {
  group('AssetThumbnailService', () {
    late AssetThumbnailService service;
    late _MockTransport transport;
    late CameraSession session;

    setUp(() {
      service = AssetThumbnailService();
      transport = _MockTransport();
      session = CameraSession(connectedAt: DateTime(2024, 1, 1));
    });

    test('返回原始缩略图 data', () async {
      final data = await service.thumbnailData(
        asset: _makeAsset(),
        transport: transport,
        session: session,
      );
      expect(data, [1, 2, 3]);
    });

    test('第二次调用走缓存，不再走 transport', () async {
      await service.thumbnailData(
        asset: _makeAsset(),
        transport: transport,
        session: session,
      );
      await service.thumbnailData(
        asset: _makeAsset(),
        transport: transport,
        session: session,
      );
      expect(transport.callCount, 1);
    });

    test('相同文件（不同对象）走缓存', () async {
      await service.thumbnailData(
        asset: _makeAsset(i: 1),
        transport: transport,
        session: session,
      );
      await service.thumbnailData(
        asset: _makeAsset(i: 1),
        transport: transport,
        session: session,
      );
      expect(transport.callCount, 1);
    });

    test('不同文件走不同 key', () async {
      await service.thumbnailData(
        asset: _makeAsset(i: 1),
        transport: transport,
        session: session,
      );
      await service.thumbnailData(
        asset: _makeAsset(i: 2),
        transport: transport,
        session: session,
      );
      expect(transport.callCount, 2);
    });

    test('transport 抛异常时返回 null，下次重试', () async {
      transport.throwOnThumbnail = true;
      final data1 = await service.thumbnailData(
        asset: _makeAsset(),
        transport: transport,
        session: session,
      );
      expect(data1, isNull);

      transport.throwOnThumbnail = false;
      final data2 = await service.thumbnailData(
        asset: _makeAsset(),
        transport: transport,
        session: session,
      );
      expect(data2, [1, 2, 3]);
    });

    test('clear() 清除 cache，下次重新下载', () async {
      await service.thumbnailData(
        asset: _makeAsset(),
        transport: transport,
        session: session,
      );
      await service.clear();
      await service.thumbnailData(
        asset: _makeAsset(),
        transport: transport,
        session: session,
      );
      expect(transport.callCount, 2);
    });

    test('并行调用同 asset 只下载一次', () async {
      final f1 = service.thumbnailData(
        asset: _makeAsset(),
        transport: transport,
        session: session,
      );
      final f2 = service.thumbnailData(
        asset: _makeAsset(),
        transport: transport,
        session: session,
      );
      final r1 = await f1;
      final r2 = await f2;
      expect(r1, [1, 2, 3]);
      expect(r2, [1, 2, 3]);
      expect(transport.callCount, 1);
    });

    test('in-flight 下载完成后仍会写入 cache', () async {
      // clear() 时 in-flight 已完成或无 in-flight
      await service.thumbnailData(
        asset: _makeAsset(),
        transport: transport,
        session: session,
      );
      expect(transport.callCount, 1);
    });

    test('12 不同 asset 并发：12 次 transport 调用', () async {
      final futures = <Future<Uint8List?>>[];
      for (int i = 0; i < 12; i++) {
        futures.add(service.thumbnailData(
          asset: _makeAsset(i: i),
          transport: transport,
          session: session,
        ));
      }
      final results = await Future.wait(futures);
      expect(results.length, 12);
      for (final r in results) {
        expect(r, [1, 2, 3]);
      }
      expect(transport.callCount, 12);
    });
  });
}
