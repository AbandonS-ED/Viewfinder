/// Fake Nikon PTP/IP server placeholder.
///
/// 等用户拿到 Mac + iPhone 后改用 raw socket + PTP/IP codec 实现：
/// - bind 127.0.0.1:15740
/// - 接受 init_command_request → 返 init_command_ack
/// - 接受 get_device_info → 返 Nikon 假设备信息
/// - 接受 get_object_handles → 返 12 个 fake handle
/// - 接受 get_object_info → 返 fake PhotoAsset 元数据
/// - 接受 get_object (二进制) → 返 fake JPEG 字节
///
/// 当前 Phase 4c 代码骨架阶段：先用 `test/helpers/fake_camera_transport.dart`
/// 走 provider override 路径，已能完整跑 8 个 test path。
///
/// 已知坑：raw socket 需要 macOS 权限，Windows 不能直接跑。
class FakeNikonServer {
  /// 占位构造；真实实现需要 host + port
  FakeNikonServer({this.host = '127.0.0.1', this.port = 15740});

  final String host;
  final int port;

  /// 占位启动；真实实现要 listen socket
  Future<void> start() async {
    throw UnimplementedError(
      'FakeNikonServer 真实实现需 Mac + iPhone 验证（依赖 raw socket）。'
      '当前用 test/helpers/fake_camera_transport.dart 替代。',
    );
  }

  Future<void> stop() async {
    throw UnimplementedError('未实现');
  }
}