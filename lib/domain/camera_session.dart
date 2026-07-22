import 'package:freezed_annotation/freezed_annotation.dart';

import 'camera_capability.dart';

part 'camera_session.freezed.dart';

/// 相机会话状态 (已成功连接后)
@freezed
class CameraSession with _$CameraSession {
  const factory CameraSession({
    /// 唯一标识 (Phase 0 用空字符串占位；Phase 1+ 可换 uuid 包)
    @Default('') String id,

    /// 相机显示名
    @Default('Nikon Camera') String cameraName,

    /// 实际连接的 IP
    @Default('192.168.1.1') String connectedHost,

    /// 实际连接的端口
    @Default(15740) int port,

    /// 连接建立时间
    required DateTime connectedAt,

    /// 相机声明的能力
    @Default(<CameraCapability>{}) Set<CameraCapability> capabilities,
  }) = _CameraSession;
}
