import 'package:freezed_annotation/freezed_annotation.dart';
import 'photo_asset.dart';

part 'download_record.freezed.dart';

/// 已下载记录 (持久化到本地)
@freezed
class DownloadRecord with _$DownloadRecord {
  const factory DownloadRecord({
    /// 相机对象 handle
    required String remoteIdentifier,
    required String fileName,
    required PhotoAssetKind kind,
    @Default(0) int byteSize,
    required DateTime captureDate,
    required DateTime completedAt,
    required String localPath,
    @Default(false) bool exportedToPhotoLibrary,
  }) = _DownloadRecord;
}
