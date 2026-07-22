import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_context.freezed.dart';

/// 错误提示上下文 (UI 弹窗用)
@freezed
class AlertContext with _$AlertContext {
  const factory AlertContext({
    required String title,
    required String message,
    @Default(AlertSeverity.info) AlertSeverity severity,
  }) = _AlertContext;
}

enum AlertSeverity {
  info,
  warning,
  error,
  success;
}
