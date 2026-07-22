import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_entry.freezed.dart';

/// 日志条目
@freezed
class LogEntry with _$LogEntry {
  const factory LogEntry({
    required DateTime timestamp,
    @Default(LogLevel.info) LogLevel level,
    required String message,
  }) = _LogEntry;
}

/// 日志级别
enum LogLevel {
  debug,
  info,
  warning,
  error;
}
