/// UI 工作流状态机
enum CameraWorkflowState {
  idle,           // 初始 / 空闲
  connecting,     // 正在连接
  browsing,       // 已连接，浏览照片
  downloading,    // 下载中
  error,          // 出错
}
