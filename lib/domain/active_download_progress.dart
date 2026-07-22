import 'package:freezed_annotation/freezed_annotation.dart';

part 'active_download_progress.freezed.dart';

/// 实时下载进度 (通知中心显示)
@freezed
class ActiveDownloadProgress with _$ActiveDownloadProgress {
  const factory ActiveDownloadProgress({
    required String currentFileName,
    @Default(0) int currentItemNumber,
    @Default(0) int totalItemCount,
    @Default(0) int bytesTransferred,
    @Default(0) int totalBytes,
    @Default(0.0) double fractionCompleted,
    @Default('') String status,
    @Default('') String message,
  }) = _ActiveDownloadProgress;

  const ActiveDownloadProgress._();

  /// 百分比文本，如 "42%"
  String get percentageText => '${(fractionCompleted * 100).round()}%';
}
