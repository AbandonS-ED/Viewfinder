import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_entry.freezed.dart';

/// 日志条目
@freezed
class LogEntry with _$LogEntry {
  const factory LogEntry({
    /// 唯一标识
    @Default('') String id,

    required DateTime timestamp,

    required String message,
  }) = _LogEntry;
}
