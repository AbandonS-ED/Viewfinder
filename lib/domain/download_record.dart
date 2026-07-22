import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_record.freezed.dart';

/// 已下载记录 (持久化到本地)
@freezed
class DownloadRecord with _$DownloadRecord {
  const factory DownloadRecord({
    /// 唯一标识
    @Default('') String id,

    /// 相机端对象 handle
    required String sourceAssetIdentifier,

    required String fileName,

    /// 本地保存路径 (iOS 用 URL 类型；Phase 0 用 String 简化)
    required String savedURL,

    @Default(0) int byteSize,

    required DateTime completedAt,

    @Default(false) bool exportedToPhotoLibrary,
  }) = _DownloadRecord;
}
