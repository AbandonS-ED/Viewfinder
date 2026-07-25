import 'package:flutter_test/flutter_test.dart';

/// T3 真实验证需要 raw socket + Mac + iPhone。当前用 provider override 路径替代
/// 见 test/helpers/fake_camera_transport.dart
///
/// 完整 E2E flow（待 Mac 验证后补）：
/// 1. 启动 FakeNikonServer.bind(127.0.0.1:15740)
/// 2. ConnectionPage 点 "连接相机"
/// 3. workflowState: waitingForWifi → connecting → connected
/// 4. activeSession 非 null
/// 5. GalleryPage 切换 + onSessionChanged 触发 + 自动 mock data 替换
///
/// placeholder 测试避免空 test 目录
void main() {
  test('T3 placeholder', () {
    expect(1 + 1, 2);
  });
}