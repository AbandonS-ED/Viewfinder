import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/alert_context.dart';
import '../../domain/camera_app_error.dart';
import '../../domain/camera_workflow_state.dart';
import '../../domain/log_entry.dart';
import '../connection_setup/connection_view_model.dart';
import '../photo_browser/gallery_view_model.dart';
import 'app_shell_state.dart';

final appShellProvider =
    NotifierProvider<AppShellNotifier, AppShellState>(AppShellNotifier.new);

class AppShellNotifier extends Notifier<AppShellState> {
  int _idCounter = 0;

  String _newId() {
    _idCounter += 1;
    return 'app-shell-${DateTime.now().millisecondsSinceEpoch}-$_idCounter';
  }

  @override
  AppShellState build() {
    ref.listen(connectionProvider, (prev, next) {
      if (next.workflowState == CameraWorkflowState.error &&
          prev?.workflowState != CameraWorkflowState.error) {
        appendLog('连接错误: ${next.lastSummary}');
      }
    });
    ref.listen(galleryProvider, (prev, next) {
      next.whenOrNull(
        error: (err, _) => appendLog('相册错误: $err'),
      );
    });
    return const AppShellState();
  }

  void setGlobalActivityTitle(String? title) {
    state = state.copyWith(globalActivityTitle: title);
  }

  void showAlert({required String title, required String message}) {
    state = state.copyWith(
      alertContext: AlertContext(id: _newId(), title: title, message: message),
    );
  }

  void dismissAlert() {
    state = state.copyWith(alertContext: null);
  }

  void appendLog(String message) {
    final entry = LogEntry(
      id: _newId(),
      timestamp: DateTime.now(),
      message: message,
    );
    final newLog = [entry, ...state.activityLog].take(30).toList();
    state = state.copyWith(activityLog: newLog);
  }

  String handleError(Object error) {
    final message = error is CameraAppError ? error.message : error.toString();
    appendLog(message);
    showAlert(title: '出现问题', message: message);
    return message;
  }
}
