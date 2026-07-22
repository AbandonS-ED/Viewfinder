import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_context.freezed.dart';

/// 错误提示上下文 (UI 弹窗用)
@freezed
class AlertContext with _$AlertContext {
  const factory AlertContext({
    /// 唯一标识
    @Default('') String id,

    required String title,

    required String message,
  }) = _AlertContext;
}
