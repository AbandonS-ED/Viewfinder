import 'package:logging/logging.dart' as logging;

import 'log_file_store.dart';

final AppLogger appLogger = AppLogger('Viewfinder');

class AppLogger {
  AppLogger(String name) : _logger = logging.Logger(name);

  final logging.Logger _logger;

  void info(String message) => _logger.info(message);
  void warning(String message) => _logger.warning(message);
  void severe(String message) => _logger.severe(message);
}

LogFileStore? _logStore;

void setupLogging(LogFileStore store) {
  _logStore = store;
  logging.hierarchicalLoggingEnabled = true;
  logging.Logger.root.level = logging.Level.ALL;
  logging.Logger.root.onRecord.listen((record) {
    final level = switch (record.level.name) {
      'INFO' => LogLevel.info,
      'WARNING' => LogLevel.warning,
      _ => LogLevel.severe,
    };
    _logStore?.append(
      message: '${record.loggerName}: ${record.message}',
      level: level,
    );
  });
}
