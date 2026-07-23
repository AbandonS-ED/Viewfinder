import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/alert_context.dart';
import '../../domain/log_entry.dart';

part 'app_shell_state.freezed.dart';

@freezed
class AppShellState with _$AppShellState {
  const AppShellState._();

  const factory AppShellState({
    @Default(<LogEntry>[]) List<LogEntry> activityLog,
    AlertContext? alertContext,
    String? globalActivityTitle,
  }) = _AppShellState;

  bool get isShowingGlobalActivity => globalActivityTitle != null;
}
