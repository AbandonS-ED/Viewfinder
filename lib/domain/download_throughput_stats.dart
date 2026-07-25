/// 下载吞吐量诊断数据。直接派生自 DownloadQueueState，无需持久化
class DownloadThroughputStats {
  const DownloadThroughputStats({
    required this.totalBytes,
    required this.completedItems,
    required this.avgBytesPerItem,
  });

  final int totalBytes;
  final int completedItems;
  final int avgBytesPerItem;

  String get totalBytesLabel => _formatBytes(totalBytes);

  String get avgBytesPerItemLabel => _formatBytes(avgBytesPerItem);

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
    }
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }
}