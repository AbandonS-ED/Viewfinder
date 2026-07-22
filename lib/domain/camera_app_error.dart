/// 相机操作错误模型 (sealed class，编译期穷举)
sealed class CameraAppError {
  const CameraAppError();

  /// 用户可读的错误描述
  String get message;

  const factory CameraAppError.missingHost() = _MissingHost;
  const factory CameraAppError.invalidPort() = _InvalidPort;
  const factory CameraAppError.notConnected() = _NotConnected;
  const factory CameraAppError.unsupportedOperation(String detail) = _UnsupportedOperation;
  const factory CameraAppError.fileSystemFailure(String detail) = _FileSystemFailure;
  const factory CameraAppError.networkProbeFailed(String detail) = _NetworkProbeFailed;
}

class _MissingHost extends CameraAppError {
  const _MissingHost();
  @override
  String get message => '相机 IP 地址为空，请在设置中填写。';
}

class _InvalidPort extends CameraAppError {
  const _InvalidPort();
  @override
  String get message => '端口号必须在 1-65535 之间。';
}

class _NotConnected extends CameraAppError {
  const _NotConnected();
  @override
  String get message => '相机未连接。';
}

class _UnsupportedOperation extends CameraAppError {
  final String detail;
  const _UnsupportedOperation(this.detail);
  @override
  String get message => '相机不支持该操作：\$detail';
}

class _FileSystemFailure extends CameraAppError {
  final String detail;
  const _FileSystemFailure(this.detail);
  @override
  String get message => '文件系统错误：\$detail';
}

class _NetworkProbeFailed extends CameraAppError {
  final String detail;
  const _NetworkProbeFailed(this.detail);
  @override
  String get message => '网络探测失败：\$detail';
}
