import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sync/sync.dart';

abstract class LogFileStore {
  Future<void> append({required String message, required LogLevel level});
  Future<String> readAll();
  Future<File> exportFile();
}

enum LogLevel { info, warning, severe }

class FileLogStore implements LogFileStore {
  static const int maxSizeBytes = 1024 * 1024;
  static const int maxRotatedFiles = 3;

  FileLogStore({required Directory rootDirectory})
      : _basePath = rootDirectory.path,
        _currentPath = p.join(rootDirectory.path, 'viewfinder.log'),
        _lock = Mutex();

  final String _basePath;
  final String _currentPath;
  final Mutex _lock;

  @override
  Future<void> append({required String message, required LogLevel level}) async {
    await _lock.acquire();
    try {
      final timestamp = DateTime.now().toIso8601String().substring(11, 19);
      final line = '$timestamp [${level.name.toUpperCase()}] $message\n';
      final file = File(_currentPath);
      if (!await file.exists()) await file.create(recursive: true);

      if (await file.length() + line.length > maxSizeBytes) {
        await _rotate();
      }

      await file.writeAsString(line, mode: FileMode.append, flush: true);
    } finally {
      _lock.release();
    }
  }

  Future<void> _rotate() async {
    final oldest = File(p.join(_basePath, 'viewfinder.log.$maxRotatedFiles'));
    if (await oldest.exists()) await oldest.delete();

    for (int i = maxRotatedFiles - 1; i >= 1; i--) {
      final src = File(p.join(_basePath, 'viewfinder.log.$i'));
      if (await src.exists()) {
        await src.rename(p.join(_basePath, 'viewfinder.log.${i + 1}'));
      }
    }

    final current = File(_currentPath);
    if (await current.exists()) {
      await current.rename(p.join(_basePath, 'viewfinder.log.1'));
    }
  }

  @override
  Future<String> readAll() async {
    final file = File(_currentPath);
    if (!await file.exists()) return '';
    return file.readAsString();
  }

  @override
  Future<File> exportFile() async {
    final src = File(_currentPath);
    // 计划 §10.2: 用 timestamp 命名, 多次导出不会互相覆盖.
    final ts = DateTime.now().millisecondsSinceEpoch;
    final dst = File(p.join(_basePath, 'viewfinder-$ts.log'));
    if (await src.exists()) {
      await src.copy(dst.path);
    } else {
      await dst.create(recursive: true);
    }
    return dst;
  }
}
