import 'package:freezed_annotation/freezed_annotation.dart';
import 'camera_transport_mode.dart';

part 'camera_connection_config.freezed.dart';

/// 相机连接配置。持久化到 UserDefaults (Android: SharedPreferences)。
@freezed
class CameraConnectionConfig with _$CameraConnectionConfig {
  const factory CameraConnectionConfig({
    /// 相机 IP 地址，默认 Nikon 相机热点
    @Default('192.168.1.1') String host,

    /// CIPA PTP/IP 标准端口
    @Default(15740) int port,

    /// 传输模式
    @Default(CameraTransportMode.experimentalNikon) CameraTransportMode transportMode,

    /// 是否下载后自动写入相册
    @Default(false) bool autoExportToPhotoLibrary,

    /// 下载队列中 JPEG 是否优先于 RAW
    @Default(false) bool prioritizeJPEGDownloads,
  }) = _CameraConnectionConfig;

  const CameraConnectionConfig._();

  /// 修剪 host 首尾空白（用户输入的容错）
  String get normalizedHost => host.trim();
}