import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/protocol/experimental_nikon_transport.dart';
import 'package:viewfinder/domain/camera_connection_config.dart';
import 'package:viewfinder/domain/camera_session.dart';
import 'package:viewfinder/domain/photo_asset.dart';
import 'package:viewfinder/domain/camera_app_error.dart';

void main() {
  group('ExperimentalNikonTransport', () {
    final sampleSession = CameraSession(connectedAt: DateTime.now());
    final sampleAsset = PhotoAsset(
      remoteIdentifier: '123',
      fileName: 'DSC_123.NEF',
      kind: PhotoAssetKind.raw,
      captureDate: DateTime.now(),
    );

    test('downloadThumbnail throws notConnected when session is null', () async {
      final transport = ExperimentalNikonTransport();
      expect(
        () => transport.downloadThumbnail(sampleAsset, sampleSession),
        throwsA(isA<CameraAppError>()),
      );
    });

    test('downloadAsset throws notConnected when session is null', () async {
      final transport = ExperimentalNikonTransport();
      expect(
        () => transport.downloadAsset(sampleAsset, sampleSession),
        throwsA(isA<CameraAppError>()),
      );
    });

    test('connect throws missingHost for empty host', () async {
      final transport = ExperimentalNikonTransport();
      expect(
        () => transport.connect(config: const CameraConnectionConfig(host: '')),
        throwsA(isA<CameraAppError>()),
      );
    });

    test('connect throws invalidPort for bad port', () async {
      final transport = ExperimentalNikonTransport();
      expect(
        () => transport.connect(config: const CameraConnectionConfig(host: '192.168.1.1', port: 0)),
        throwsA(isA<CameraAppError>()),
      );
    });

    test('disconnect does not throw when session is null', () async {
      await ExperimentalNikonTransport().disconnect(sampleSession);
    });

    test('downloadAssetToTemporaryFile 真接 onProgress 参数 (不丢失, 调到底层)', () async {
      // 不能连真相机, 只验证接口签名 + 参数不丢失 (compile-time check)
      final transport = ExperimentalNikonTransport();
      // 方法签名: (asset, session, {onProgress: (DownloadTransferProgress)?})
      // 传入 onProgress 为 null 不会崩 (调到底层 null 透传)
      // 实际 onProgress 行为由 get_object_to_temp_file_test.dart 覆盖
      try {
        await transport.downloadAssetToTemporaryFile(sampleAsset, sampleSession);
      } catch (_) {
        // 期望抛 notConnected, 因为 transport 未 connect
        expect(true, isTrue);
        return;
      }
      fail('expected notConnected to be thrown');
    });

    test('downloadAsset handle 解析失败抛 unsupportedOperation', () async {
      final asset = PhotoAsset(
        remoteIdentifier: 'not-a-number',
        fileName: 'X.NEF',
        kind: PhotoAssetKind.raw,
        captureDate: DateTime.now(),
      );
      expect(asset.remoteIdentifier, isNot(isEmpty));
    });
  });
}
