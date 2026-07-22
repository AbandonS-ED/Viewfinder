/// 相机能力标签
enum CameraCapability {
  connectionProbe,    // 连通性探测
  listAssets,         // 读取照片列表
  downloadAssets,     // 下载照片
}

// 标题映射独立为顶级函数 (避免 freezed + 新 Dart 语法冲突)
// 等 freezed 升级到支持 Dart 3.12 后再改成 getter
String cameraCapabilityTitle(CameraCapability c) {
  switch (c) {
    case CameraCapability.connectionProbe: return '连通性探测';
    case CameraCapability.listAssets: return '读取照片列表';
    case CameraCapability.downloadAssets: return '下载照片';
  }
}