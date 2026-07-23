import 'package:logging/logging.dart' as logging;

final AppLogger appLogger = AppLogger('Viewfinder');

class AppLogger {
  AppLogger(String name) : _logger = logging.Logger(name);

  final logging.Logger _logger;

  void info(String message) => _logger.info(message);
  void warning(String message) => _logger.warning(message);
  void severe(String message) => _logger.severe(message);
}

void setupLogging() {
  logging.hierarchicalLoggingEnabled = true;
  logging.Logger.root.level = logging.Level.ALL;
  logging.Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('[${record.level.name}] ${record.loggerName}: ${record.message}');
  });
}
