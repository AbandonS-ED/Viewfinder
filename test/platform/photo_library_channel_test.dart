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
}
