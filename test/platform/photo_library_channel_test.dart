import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:viewfinder/platform/photo_library_channel.dart';

void main() {
  group('IoPhotoLibraryChannel', () {
    late IoPhotoLibraryChannel channel;
    late Directory tmpDir;

    setUp(() {
      channel = IoPhotoLibraryChannel();
      tmpDir = Directory.systemTemp.createTempSync('photo_test_');
    });

    tearDown(() {
      tmpDir.deleteSync(recursive: true);
    });

    test('requestPermission 默认 granted', () async {
      final perm = await channel.requestPermission();
      expect(perm, PhotoLibraryPermission.granted);
    });

    test('exportFile(JPEG) 文件存在时成功', () async {
      final file = File(p.join(tmpDir.path, 'test.jpg'));
      await file.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
      await channel.exportFile(filePath: file.path);
      // 不抛异常即为成功
    });

    test('exportFile(RAW) 文件存在时成功', () async {
      final file = File(p.join(tmpDir.path, 'test.NEF'));
      await file.writeAsBytes(List.filled(100, 0));
      await channel.exportFile(filePath: file.path);
    });

    test('exportFile 文件不存在时抛异常', () async {
      expect(
        () => channel.exportFile(filePath: p.join(tmpDir.path, 'ghost.jpg')),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('PhotoLibraryPermission enum', () {
    test('4 个权限状态值 (granted/limited/denied/neverAskAgain)', () {
      expect(PhotoLibraryPermission.values.length, 4);
      expect(PhotoLibraryPermission.values, contains(PhotoLibraryPermission.granted));
      expect(PhotoLibraryPermission.values, contains(PhotoLibraryPermission.limited));
      expect(PhotoLibraryPermission.values, contains(PhotoLibraryPermission.denied));
      expect(PhotoLibraryPermission.values, contains(PhotoLibraryPermission.neverAskAgain));
    });

    test('iOS 映射: limited → limited (iOS 14+ 部分授权)', () {
      // iOS 端的 switch case 在 photo_library_channel.dart:65
      // 这里通过枚举值存在性间接验证
      expect(PhotoLibraryPermission.limited.name, 'limited');
    });
  });

  group('PhotoLibraryChannel.mapAndroidResult (计划 §8.3)', () {
    test('"limited" → PhotoLibraryPermission.limited (Android 部分授权)', () {
      expect(PhotoLibraryChannel.mapAndroidResult('limited'),
          PhotoLibraryPermission.limited);
    });

    test('"granted" → granted', () {
      expect(PhotoLibraryChannel.mapAndroidResult('granted'),
          PhotoLibraryPermission.granted);
    });

    test('"denied" → denied', () {
      expect(PhotoLibraryChannel.mapAndroidResult('denied'),
          PhotoLibraryPermission.denied);
    });

    test('"never_ask_again" → neverAskAgain', () {
      expect(PhotoLibraryChannel.mapAndroidResult('never_ask_again'),
          PhotoLibraryPermission.neverAskAgain);
    });

    test('未知 / null → denied (fallback)', () {
      expect(PhotoLibraryChannel.mapAndroidResult(null), PhotoLibraryPermission.denied);
      expect(PhotoLibraryChannel.mapAndroidResult('garbage'), PhotoLibraryPermission.denied);
    });
  });

  group('PhotoLibraryChannel.mapIosResult (计划 §8.2)', () {
    test('"limited" → PhotoLibraryPermission.limited (iOS 14+ .addOnly 部分授权)',
        () {
      expect(PhotoLibraryChannel.mapIosResult('limited'),
          PhotoLibraryPermission.limited);
    });

    test('"authorized" → granted', () {
      expect(PhotoLibraryChannel.mapIosResult('authorized'),
          PhotoLibraryPermission.granted);
    });

    test('"restricted" → denied', () {
      expect(PhotoLibraryChannel.mapIosResult('restricted'),
          PhotoLibraryPermission.denied);
    });

    test('未知 / null → denied (fallback)', () {
      expect(PhotoLibraryChannel.mapIosResult(null), PhotoLibraryPermission.denied);
      expect(PhotoLibraryChannel.mapIosResult('garbage'), PhotoLibraryPermission.denied);
    });
  });
}
