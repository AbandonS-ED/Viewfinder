/// 相机操作错误模型 (sealed class，编译期穷举；严格对齐 iOS CameraAppError)
sealed class CameraAppError {
  const CameraAppError();

  /// 用户可读的错误描述
  String get message;

  /// 用户可读的恢复建议
  String get recoverySuggestion;

  const factory CameraAppError.missingHost() = _MissingHost;
  const factory CameraAppError.invalidPort() = _InvalidPort;
  const factory CameraAppError.notConnected() = _NotConnected;
  const factory CameraAppError.networkProbeFailed(String detail) = _NetworkProbeFailed;
  const factory CameraAppError.unsupportedOperation(String detail) = _UnsupportedOperation;
  const factory CameraAppError.fileSystemFailure(String detail) = _FileSystemFailure;
  const factory CameraAppError.photoLibraryAccessDenied() = _PhotoLibraryAccessDenied;
  const factory CameraAppError.photoLibraryExportFailed(String detail) = _PhotoLibraryExportFailed;
}

class _MissingHost extends CameraAppError {
  const _MissingHost();
  @override
  String get message => '请输入相机地址。';
  @override
  String get recoverySuggestion => '先在 iPhone 设置里连接相机 Wi-Fi，再输入相机 IP 地址。';
}

class _InvalidPort extends CameraAppError {
  const _InvalidPort();
  @override
  String get message => '端口号无效。';
  @override
  String get recoverySuggestion => '请确认端口为 1 到 65535 之间的数字。';
}

class _NotConnected extends CameraAppError {
  const _NotConnected();
  @override
  String get message => '当前没有可用的相机会话。';
  @override
  String get recoverySuggestion => '先建立连接，再读取照片列表或执行下载。';
}

class _NetworkProbeFailed extends CameraAppError {
  final String detail;
  const _NetworkProbeFailed(this.detail);
  @override
  String get message => '连接相机失败：\$detail';
  @override
  String get recoverySuggestion => '确认 iPhone 已连接到相机热点，并允许本地网络访问。';
}

class _UnsupportedOperation extends CameraAppError {
  final String detail;
  const _UnsupportedOperation(this.detail);
  @override
  String get message => detail;
  @override
  String get recoverySuggestion =>
    '当前工程已经预留了协议层接口，下一步可以在这里接入 Nikon 真实传输实现。';
}

class _FileSystemFailure extends CameraAppError {
  final String detail;
  const _FileSystemFailure(this.detail);
  @override
  String get message => '本地文件写入失败：\$detail';
  @override
  String get recoverySuggestion => '检查设备存储空间是否充足。';
}

class _PhotoLibraryAccessDenied extends CameraAppError {
  const _PhotoLibraryAccessDenied();
  @override
  String get message => '系统相册权限未授予。';
  @override
  String get recoverySuggestion => '到系统设置里为 App 开启"照片"写入权限。';
}

class _PhotoLibraryExportFailed extends CameraAppError {
  final String detail;
  const _PhotoLibraryExportFailed(this.detail);
  @override
  String get message => '保存到系统相册失败：\$detail';
  @override
  String get recoverySuggestion => '可以先保存在 App 本地目录，再稍后导出。';
}
