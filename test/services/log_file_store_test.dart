import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:viewfinder/services/log_file_store.dart';

Directory _tmpDir() {
  final dir = Directory(p.join(
    Directory.systemTemp.path,
    'log_test_${DateTime.now().millisecondsSinceEpoch}',
  ));
  dir.createSync(recursive: true);
  return dir;
}

void main() {
  group('FileLogStore', () {
    late Directory root;
    late FileLogStore store;

    setUp(() {
      root = _tmpDir();
      store = FileLogStore(rootDirectory: root);
    });

    tearDown(() {
      root.deleteSync(recursive: true);
    });

    test('append 写入一行到 viewfinder.log', () async {
      await store.append(message: 'hello', level: LogLevel.info);
      final content = await File(p.join(root.path, 'viewfinder.log')).readAsString();
      expect(content, contains('[INFO] hello'));
    });

    test('readAll 返回完整内容', () async {
      await store.append(message: 'line1', level: LogLevel.info);
      await store.append(message: 'line2', level: LogLevel.warning);
      final content = await store.readAll();
      expect(content, contains('[INFO] line1'));
      expect(content, contains('[WARNING] line2'));
    });

    test('超过 1MB 触发 rotation 生成 .1', () async {
      await store.append(message: 'x' * (FileLogStore.maxSizeBytes ~/ 2), level: LogLevel.info);
      await store.append(message: 'x' * (FileLogStore.maxSizeBytes ~/ 2 + 100), level: LogLevel.info);

      expect(await File(p.join(root.path, 'viewfinder.log.1')).exists(), isTrue);
      expect(await File(p.join(root.path, 'viewfinder.log.2')).exists(), isFalse);
    });

    test('连续 4 次 rotation 后最老的 .3 被删', () async {
      // 多次触发 rotation
      for (int i = 0; i < 5; i++) {
        await store.append(message: 'x' * (FileLogStore.maxSizeBytes ~/ 2), level: LogLevel.info);
      }

      // .3 存在且内容不为空（最多 3 个 backup）
      final files = <String>[];
      for (int i = 1; i <= 4; i++) {
        final f = File(p.join(root.path, 'viewfinder.log.$i'));
        if (await f.exists()) files.add('viewfinder.log.$i');
      }
      expect(files.length, lessThanOrEqualTo(3));
      // .4 不应存在
      expect(await File(p.join(root.path, 'viewfinder.log.4')).exists(), isFalse);
    });

    test('exportFile 复制 viewfinder.log', () async {
      await store.append(message: 'export me', level: LogLevel.info);
      final exported = await store.exportFile();
      final content = await exported.readAsString();
      expect(content, contains('export me'));
    });

    test('写入 2MB 触发多次 rotation，.1 / .2 存在', () async {
      final line = 'x' * 8192;
      final iterations = (2 * 1024 * 1024) ~/ line.length + 10;
      for (int i = 0; i < iterations; i++) {
        await store.append(message: line, level: LogLevel.info);
      }
      final log1 = File(p.join(root.path, 'viewfinder.log.1'));
      final log2 = File(p.join(root.path, 'viewfinder.log.2'));
      expect(await log1.exists(), isTrue);
      expect(await log2.exists(), isTrue);
      // .4 不应存在（最多 3 个 backup）
      expect(await File(p.join(root.path, 'viewfinder.log.4')).exists(), isFalse);
    });
  });
}
