import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/protocol/primitives/ptpip_data_types.dart';
import 'package:viewfinder/protocol/primitives/ptpip_data_structures.dart';
import 'package:viewfinder/protocol/primitives/ptpip_packet_codec.dart';
import 'package:viewfinder/protocol/primitives/ptpip_error.dart';

void main() {
  group('PTPIPPacketType', () {
    test('has 14 values', () {
      expect(PTPIPPacketType.values.length, 14);
    });

    test('initCommandRequest has raw value 1', () {
      expect(PTPIPPacketType.initCommandRequest.rawValue, 0x00000001);
    });

    test('probeResponse has raw value 14', () {
      expect(PTPIPPacketType.probeResponse.rawValue, 0x0000000E);
    });
  });

  group('PTPOperationCode', () {
    test('has 12 values', () {
      expect(PTPOperationCode.values.length, 12);
    });

    test('getDeviceInfo has raw value 0x1001', () {
      expect(PTPOperationCode.getDeviceInfo.rawValue, 0x1001);
    });

    test('getObjectsMetaData has raw value 0x9434', () {
      expect(PTPOperationCode.getObjectsMetaData.rawValue, 0x9434);
    });
  });

  group('PTPResponseCode', () {
    test('has 32 values', () {
      expect(PTPResponseCode.values.length, 32);
    });

    test('ok has raw value 0x2001', () {
      expect(PTPResponseCode.ok.rawValue, 0x2001);
    });

    test('ok is first value in enum', () {
      expect(PTPResponseCode.values.first, PTPResponseCode.ok);
    });

    test('specificationOfDestinationUnsupported is last', () {
      expect(PTPResponseCode.values.last, PTPResponseCode.specificationOfDestinationUnsupported);
    });
  });

  group('PTPIPBinary constants', () {
    test('protocolVersion is 0x00010000', () {
      expect(PTPIPBinary.protocolVersion, 0x00010000);
    });

    test('defaultFriendlyName is NikonConnectIOS', () {
      expect(PTPIPBinary.defaultFriendlyName, 'NikonConnectIOS');
    });
  });

  group('PTPDataReader', () {
    test('readUInt8 reads single byte', () {
      final data = Uint8List.fromList([0x42, 0x00]);
      final reader = PTPDataReader(data);
      expect(reader.readUInt8(), 0x42);
      expect(reader.readUInt8(), 0x00);
      expect(reader.remainingCount, 0);
    });

    test('readUInt16LE reads little-endian', () {
      final data = Uint8List.fromList([0x01, 0x10]);
      final reader = PTPDataReader(data);
      expect(reader.readUInt16LE(), 0x1001);
    });

    test('readUInt32LE reads little-endian', () {
      final data = Uint8List.fromList([0x01, 0x00, 0x00, 0x00]);
      final reader = PTPDataReader(data);
      expect(reader.readUInt32LE(), 1);
    });

    test('readPTPArrayUInt32 reads count then elements', () {
      final data = Uint8List.fromList([
        0x02, 0x00, 0x00, 0x00, // count = 2
        0x01, 0x10, 0x00, 0x00, // 0x1001
        0x02, 0x10, 0x00, 0x00, // 0x1002
      ]);
      final reader = PTPDataReader(data);
      expect(reader.readPTPArrayUInt32(), [0x1001, 0x1002]);
    });

    test('readPTPString handles empty string', () {
      final data = Uint8List.fromList([0x00]);
      final reader = PTPDataReader(data);
      expect(reader.readPTPString(), '');
    });

    test('readPTPString decodes UTF-16', () {
      final data = Uint8List.fromList([
        0x05, // character count
        0x48, 0x00, // H
        0x65, 0x00, // e
        0x6C, 0x00, // l
        0x6C, 0x00, // l
        0x6F, 0x00, // o
      ]);
      final reader = PTPDataReader(data);
      expect(reader.readPTPString(), 'Hello');
    });
  });

  group('PTPIPCodec encodePacket / decode', () {
    test('encodePacket adds 8-byte header', () {
      final payload = Uint8List.fromList([0x01, 0x02, 0x03]);
      final packet = PTPIPCodec.encodePacket(
        type: PTPIPPacketType.operationRequest,
        payload: payload,
      );
      expect(packet.length, 8 + 3);
      final length = ByteData.sublistView(packet).getUint32(0, Endian.little);
      expect(length, 11);
      final type = ByteData.sublistView(packet).getUint32(4, Endian.little);
      expect(type, PTPIPPacketType.operationRequest.rawValue);
    });

    test('encodeInitCommandRequest produces valid packet', () {
      final guid = Uint8List(16);
      final packet = PTPIPCodec.encodeInitCommandRequest(
        guid: guid,
        friendlyName: 'Test',
      );
      expect(packet.length, greaterThan(24));
      final type = ByteData.sublistView(packet).getUint32(4, Endian.little);
      expect(type, PTPIPPacketType.initCommandRequest.rawValue);
    });

    test('parseResponsePacket rejects wrong packet type', () {
      final payload = Uint8List(0);
      final packet = PTPIPRawPacket(type: PTPIPPacketType.startData, payload: payload);
      expect(
        () => PTPIPCodec.parseResponsePacket(packet),
        throwsA(isA<PTPIPError>()),
      );
    });

    test('parseResponsePacket parses valid response', () {
      final bytes = Uint8List.fromList([
        0x01, 0x20, // code = 0x2001 (ok)
        0x05, 0x00, 0x00, 0x00, // transactionID = 5
      ]);
      final packet = PTPIPRawPacket(type: PTPIPPacketType.operationResponse, payload: bytes);
      final response = PTPIPCodec.parseResponsePacket(packet);
      expect(response.code, PTPResponseCode.ok.rawValue);
      expect(response.transactionID, 5);
    });

    test('encodeOperationRequest packs parameters in order', () {
      final packet = PTPIPCodec.encodeOperationRequest(
        operation: PTPOperationCode.getObjectInfo,
        transactionID: 1,
        parameters: [0x00001001],
        dataPhase: PTPIPDataPhaseInfo.noDataOrDataIn,
      );
      final reader = PTPDataReader(packet.sublist(8));
      expect(reader.readUInt32LE(), PTPIPDataPhaseInfo.noDataOrDataIn.rawValue);
      expect(reader.readUInt16LE(), PTPOperationCode.getObjectInfo.rawValue);
      expect(reader.readUInt32LE(), 1);
    });
  });

  group('PTPIPError sealed class', () {
    test('invalidPacketLength has correct message', () {
      final err = const PTPIPError.invalidPacketLength();
      expect(err.message, contains('数据包长度'));
    });

    test('unexpectedResponse exposes responseCode', () {
      const err = PTPIPError.unexpectedResponse(0x2005);
      expect(err.responseCode, 0x2005);
      expect(err.message, contains('0x2005'));
    });

    test('timeout has correct message', () {
      final err = PTPIPError.timeout('failed to read 8 bytes');
      expect(err.message, contains('超时'));
      expect(err.message, contains('failed'));
    });

    test('connectionClosed has correct message', () {
      const err = PTPIPError.connectionClosed();
      expect(err.message, contains('已关闭'));
    });
  });

  group('PTPIPDeviceInfo', () {
    test('supportsOperation checks set membership', () {
      final info = PTPIPDeviceInfo(
        model: 'Nikon Z5',
        manufacturer: 'Nikon',
        operationsSupported: {0x1001, 0x1002},
      );
      expect(info.supportsOperation(PTPOperationCode.getDeviceInfo), isTrue);
      expect(info.supportsOperation(PTPOperationCode.getObject), isFalse);
    });

    test('supportsOperation returns false for empty set', () {
      final info = PTPIPDeviceInfo();
      expect(info.supportsOperation(PTPOperationCode.openSession), isFalse);
    });
  });
}
