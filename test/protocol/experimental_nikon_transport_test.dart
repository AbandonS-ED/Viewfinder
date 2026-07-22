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

    test('downloadAsset throws notConnected for bad handle with no session', () async {
      final transport = ExperimentalNikonTransport();
      final badAsset = PhotoAsset(
        remoteIdentifier: 'bad-handle',
        fileName: 'test.jpg',
        kind: PhotoAssetKind.jpeg,
        captureDate: DateTime.now(),
      );
      expect(
        () => transport.downloadAsset(badAsset, sampleSession),
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
  });
}
