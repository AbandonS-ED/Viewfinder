/// UI 工作流状态机 (严格对齐 iOS CameraWorkflowState)
enum CameraWorkflowState {
  waitingForWifi,    // 等待连接相机 Wi-Fi
  connecting,        // 正在连接
  connected,         // 已连接
  loadingPhotos,     // 读取照片中
  downloading,       // 下载中
  error;             // 出错
}

/// 显示标题 (顶级函数避开 freezed + Dart 3.12 enum getter bug)
String cameraWorkflowStateTitle(CameraWorkflowState s) {
  switch (s) {
    case CameraWorkflowState.waitingForWifi: return '等待 Wi-Fi';
    case CameraWorkflowState.connecting: return '连接中';
    case CameraWorkflowState.connected: return '已连接';
    case CameraWorkflowState.loadingPhotos: return '读取照片中';
    case CameraWorkflowState.downloading: return '下载中';
    case CameraWorkflowState.error: return '需要处理';
  }
}

/// SF Symbol 名称 (iOS 风格；Flutter 端可映射到 Icons.xxx)
String cameraWorkflowStateSymbol(CameraWorkflowState s) {
  switch (s) {
    case CameraWorkflowState.waitingForWifi: return 'wifi';
    case CameraWorkflowState.connecting: return 'antenna.radiowaves.left.and.right';
    case CameraWorkflowState.connected: return 'checkmark.circle.fill';
    case CameraWorkflowState.loadingPhotos: return 'rectangle.stack';
    case CameraWorkflowState.downloading: return 'arrow.down.circle';
    case CameraWorkflowState.error: return 'exclamationmark.triangle.fill';
  }
}
