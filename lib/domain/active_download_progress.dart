import 'package:freezed_annotation/freezed_annotation.dart';

part 'active_download_progress.freezed.dart';

/// 实时下载进度 (原始字节数据，UI 自己算百分比)
@freezed
class ActiveDownloadProgress with _$ActiveDownloadProgress {
  const factory ActiveDownloadProgress({
    required String fileName,

    @Default(0) int currentItemNumber,

    @Default(0) int totalItemCount,

    @Default(0) int bytesTransferred,

    @Default(0) int totalBytes,

    /// 续传次数
    @Default(0) int resumedCount,

    /// 当前已下载偏移
    @Default(0) int currentOffset,

    /// 分块大小
    @Default(0) int chunkSize,
  }) = _ActiveDownloadProgress;

  const ActiveDownloadProgress._();

  /// 下载进度 0.0-1.0
  double get fractionCompleted {
    if (totalBytes <= 0) return 0;
    final progress = bytesTransferred / totalBytes;
    return progress.clamp(0.0, 1.0);
  }

  /// 百分比文本
  String get percentageText => '${(fractionCompleted * 100).round()}%';
}
