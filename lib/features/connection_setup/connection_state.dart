import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/camera_session.dart';
import '../../domain/camera_transport_mode.dart';
import '../../domain/camera_workflow_state.dart';

part 'connection_state.freezed.dart';

@freezed
class ConnectionState with _$ConnectionState {
  const factory ConnectionState({
    @Default(CameraWorkflowState.waitingForWifi) CameraWorkflowState workflowState,
    CameraSession? activeSession,
    @Default('') String hostInput,
    @Default('') String portInput,
    @Default(CameraTransportMode.experimentalNikon) CameraTransportMode transportMode,
    @Default(true) bool autoExportToPhotoLibrary,
    @Default(true) bool prioritizeJPEGDownloads,
    @Default(false) bool isWorking,
    @Default('先在系统设置里连接 Nikon 相机的 Wi-Fi，然后回到这里开始。') String lastSummary,
  }) = _ConnectionState;

  const ConnectionState._();

  bool get canAttemptConnection => true;
}
