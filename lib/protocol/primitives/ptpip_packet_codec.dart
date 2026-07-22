import 'dart:typed_data';

import 'ptpip_data_structures.dart';
import 'ptpip_data_types.dart';
import 'ptpip_error.dart';

BytesBuilder _bb() => BytesBuilder(copy: false);

extension _BytesBuilderX on BytesBuilder {
  void putUint16LE(int value) {
    final bytes = Uint8List(2);
    ByteData.sublistView(bytes).setUint16(0, value, Endian.little);
    add(bytes);
  }

  void putUint32LE(int value) {
    final bytes = Uint8List(4);
    ByteData.sublistView(bytes).setUint32(0, value, Endian.little);
    add(bytes);
  }

}

class PTPDataReader {
  PTPDataReader(this._data) : _offset = 0;

  final Uint8List _data;
  int _offset;

  int get remainingCount => _data.length - _offset;

  int readUInt8() {
    if (remainingCount < 1) {
      throw const PTPIPError.malformedPayload('缺少 UInt8 字段。');
    }
    return _data[_offset++];
  }

  int readUInt16LE() {
    if (remainingCount < 2) {
      throw const PTPIPError.malformedPayload('缺少 UInt16 字段。');
    }
    final value = ByteData.sublistView(_data).getUint16(_offset, Endian.little);
    _offset += 2;
    return value;
  }

  int readUInt32LE() {
    if (remainingCount < 4) {
      throw const PTPIPError.malformedPayload('缺少 UInt32 字段。');
    }
    final value = ByteData.sublistView(_data).getUint32(_offset, Endian.little);
    _offset += 4;
    return value;
  }

  int readUInt64LE() {
    if (remainingCount < 8) {
      throw const PTPIPError.malformedPayload('缺少 UInt64 字段。');
    }
    final value = ByteData.sublistView(_data).getUint64(_offset, Endian.little);
    _offset += 8;
    return value;
  }

  Uint8List readBytes(int count) {
    if (remainingCount < count) {
      throw PTPIPError.malformedPayload('缺少 $count 字节数据。');
    }
    final slice = _data.sublist(_offset, _offset + count);
    _offset += count;
    return slice;
  }

  List<int> readPTPArrayUInt16() {
    final count = readUInt32LE();
    return List.generate(count, (_) => readUInt16LE());
  }

  List<int> readPTPArrayUInt32() {
    final count = readUInt32LE();
    return List.generate(count, (_) => readUInt32LE());
  }

  String readPTPString() {
    final characterCount = readUInt8();
    if (characterCount == 0) return '';
    final raw = readBytes(characterCount * 2);
    return PTPIPCodec.decodeUTF16NullTerminated(raw);
  }

  String readUTF16NullTerminatedString() {
    final startOffset = _offset;
    while (remainingCount >= 2) {
      final codeUnit = readUInt16LE();
      if (codeUnit == 0) {
        final length = _offset - startOffset;
        final raw = _data.sublist(startOffset, startOffset + length);
        return PTPIPCodec.decodeUTF16NullTerminated(raw);
      }
    }
    throw const PTPIPError.malformedPayload('UTF-16 字符串缺少终止符。');
  }
}

class PTPIPCodec {
  PTPIPCodec._();

  static Uint8List encodePacket({
    required PTPIPPacketType type,
    required Uint8List payload,
  }) {
    final bb = _bb();
    bb.putUint32LE(payload.length + 8);
    bb.putUint32LE(type.rawValue);
    bb.add(payload);
    return bb.toBytes();
  }

  static Uint8List encodeInitCommandRequest({
    required Uint8List guid,
    required String friendlyName,
  }) {
    final bb = _bb();
    bb.add(guid);
    bb.add(encodeUTF16NullTerminatedString(friendlyName));
    bb.putUint32LE(PTPIPBinary.protocolVersion);
    return encodePacket(type: PTPIPPacketType.initCommandRequest, payload: bb.toBytes());
  }

  static Uint8List encodeInitEventRequest(int connectionNumber) {
    final bb = _bb();
    bb.putUint32LE(connectionNumber);
    return encodePacket(type: PTPIPPacketType.initEventRequest, payload: bb.toBytes());
  }

  static Uint8List encodeProbeRequest() {
    return encodePacket(type: PTPIPPacketType.probeRequest, payload: Uint8List(0));
  }

  static Uint8List encodeProbeResponse() {
    return encodePacket(type: PTPIPPacketType.probeResponse, payload: Uint8List(0));
  }

  static Uint8List encodeOperationRequest({
    required PTPOperationCode operation,
    required int transactionID,
    List<int> parameters = const [],
    required PTPIPDataPhaseInfo dataPhase,
  }) {
    final bb = _bb();
    bb.putUint32LE(dataPhase.rawValue);
    bb.putUint16LE(operation.rawValue);
    bb.putUint32LE(transactionID);
    for (final param in parameters.take(5)) {
      bb.putUint32LE(param);
    }
    return encodePacket(type: PTPIPPacketType.operationRequest, payload: bb.toBytes());
  }

  static Uint8List encodeUTF16NullTerminatedString(String string) {
    final trimmed = string.length > 39 ? string.substring(0, 39) : string;
    final codeUnits = trimmed.codeUnits.toList()..add(0);
    final bb = _bb();
    for (final cu in codeUnits) {
      bb.putUint16LE(cu);
    }
    return bb.toBytes();
  }

  static String decodeUTF16NullTerminated(Uint8List data) {
    final codeUnits = <int>[];
    var offset = 0;
    while (offset + 1 < data.length) {
      final value = ByteData.sublistView(data).getUint16(offset, Endian.little);
      if (value == 0) break;
      codeUnits.add(value);
      offset += 2;
    }
    return String.fromCharCodes(codeUnits);
  }

  static PTPIPResponse parseResponsePacket(PTPIPRawPacket packet) {
    if (packet.type != PTPIPPacketType.operationResponse) {
      throw PTPIPError.unexpectedPacket(
        expected: [PTPIPPacketType.operationResponse],
        actual: packet.type,
      );
    }
    final reader = PTPDataReader(packet.payload);
    final code = reader.readUInt16LE();
    final transactionID = reader.readUInt32LE();
    final parameters = <int>[];
    while (reader.remainingCount >= 4) {
      parameters.add(reader.readUInt32LE());
    }
    return PTPIPResponse(code: code, transactionID: transactionID, parameters: parameters);
  }

  static ({int transactionID, int totalLength}) parseStartDataPayload(Uint8List payload) {
    final reader = PTPDataReader(payload);
    final transactionID = reader.readUInt32LE();
    final totalLength = reader.readUInt64LE();
    return (transactionID: transactionID, totalLength: totalLength);
  }

  static ({int transactionID, Uint8List bytes}) parseDataPayload(Uint8List payload) {
    final reader = PTPDataReader(payload);
    final transactionID = reader.readUInt32LE();
    final bytes = reader.readBytes(reader.remainingCount);
    return (transactionID: transactionID, bytes: bytes);
  }
}
