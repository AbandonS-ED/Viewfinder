import 'package:freezed_annotation/freezed_annotation.dart';

import 'camera_capability.dart';

part 'camera_session.freezed.dart';

/// 相机会话状态 (已成功连接后)
@freezed
class CameraSession with _$CameraSession {
  const factory CameraSession({
    @Default('Nikon Camera') String cameraName,
    @Default('192.168.1.1') String connectedHost,
    @Default(15740) int port,
    @Default(<CameraCapability>{}) Set<CameraCapability> capabilities,
  }) = _CameraSession;
}