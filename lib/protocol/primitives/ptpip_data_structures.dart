import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/photo_asset.dart';
import 'ptpip_data_types.dart';

part 'ptpip_data_structures.freezed.dart';

@freezed
class PTPIPDeviceInfo with _$PTPIPDeviceInfo {
  const factory PTPIPDeviceInfo({
    String? model,
    String? manufacturer,
    @Default(<int>{}) Set<int> operationsSupported,
  }) = _PTPIPDeviceInfo;
}

extension PTPIPDeviceInfoX on PTPIPDeviceInfo {
  bool supportsOperation(PTPOperationCode op) =>
    operationsSupported.contains(op.rawValue);
}

@freezed
class PTPIPObjectInfo with _$PTPIPObjectInfo {
  const factory PTPIPObjectInfo({
    required int handle,
    required int storageID,
    required int objectFormat,
    required int compressedSize,
    PhotoAssetThumbnailInfo? thumbnailInfo,
    @Default('') String fileName,
    DateTime? captureDate,
    DateTime? modificationDate,
  }) = _PTPIPObjectInfo;
}

@freezed
class PTPIPRawPacket with _$PTPIPRawPacket {
  const factory PTPIPRawPacket({
    required PTPIPPacketType type,
    required Uint8List payload,
  }) = _PTPIPRawPacket;
}

@freezed
class PTPIPResponse with _$PTPIPResponse {
  const factory PTPIPResponse({
    required int code,
    required int transactionID,
    @Default(<int>[]) List<int> parameters,
  }) = _PTPIPResponse;
}
