import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/protocol/primitives/ptpip_data_types.dart';
import 'package:viewfinder/protocol/primitives/ptpip_data_structures.dart';
import 'package:viewfinder/protocol/primitives/ptpip_packet_codec.dart';
import 'package:viewfinder/protocol/primitives/ptpip_error.dart';
import 'package:viewfinder/protocol/transport/ptpip_connection.dart';
import 'package:viewfinder/protocol/session/ptpip_session.dart';
import '../helpers/fake_ptpip_socket.dart';

Uint8List _encodeResponsePayload({
  required PTPIPPacketType type,
  required Uint8List payload,
}) {
  return PTPIPBinaryX.encodePacket(type: type, payload: payload);
}

Uint8List _okResponse(int transactionID) {
  final payload = Uint8List(8);
  ByteData.sublistView(payload).setUint16(0, PTPResponseCode.ok.rawValue, Endian.little);
  ByteData.sublistView(payload).setUint32(2, transactionID, Endian.little);
  return _encodeResponsePayload(
    type: PTPIPPacketType.operationResponse,
    payload: payload,
  );
}

void main() {
  group('PtpipSession', () {
    test('getObjectHandles returns parsed handle list', () async {
      // 编排 openSession 握手 + getObjectHandles 响应

      // InitCommandAck
      final initCmdAckPayload = Uint8List(24);
      ByteData.sublistView(initCmdAckPayload).setUint32(0, 1, Endian.little); // connectionNumber
      // responderGUID: 16 bytes zero
      // responderFriendlyName: empty UTF-16
      // protocolVersion: 0x00010000
      ByteData.sublistView(initCmdAckPayload).setUint32(20, 0x00010000, Endian.little);
      final initCmdAck = _encodeResponsePayload(
        type: PTPIPPacketType.initCommandAck,
        payload: initCmdAckPayload,
      );

      // InitEventAck
      final initEventAck = _encodeResponsePayload(
        type: PTPIPPacketType.initEventAck,
        payload: Uint8List(0),
      );

      // GetDeviceInfo 返回数据
      // 简化版 DeviceInfo payload: 最小有效 PTP dataset
      final deviceInfoPayload = Uint8List.fromList([
        0x00, 0x00, // StandardVersion
        0x00, 0x00, 0x00, 0x00, // VendorExtensionID
        0x00, 0x00, // VendorExtensionVersion
        0x01, 0x00, 0x00, 0x00, 0x00, 0x00, // VendorExtensionDesc (PTP string: empty?)
        // Actually, VendorExtensionDesc is a PTP string: count byte + chars*2
        0x00, // empty string
        0x00, 0x00, // FunctionalMode
        0x00, 0x00, 0x00, 0x00, // OperationsSupported array - empty
        0x00, 0x00, 0x00, 0x00, // EventsSupported array - empty
        0x00, 0x00, 0x00, 0x00, // DevicePropertiesSupported - empty
        0x00, 0x00, 0x00, 0x00, // CaptureFormats - empty
        0x00, 0x00, 0x00, 0x00, // ImageFormats - empty
        0x00, // Manufacturer (empty string)
        0x00, // Model (empty string)
        0x00, // DeviceVersion (empty string)
        0x00, // SerialNumber (empty string)
      ]);
      final deviceInfoStartDataPayload = Uint8List(12);
      ByteData.sublistView(deviceInfoStartDataPayload).setUint32(0, 1, Endian.little); // transactionID
      ByteData.sublistView(deviceInfoStartDataPayload).setUint64(4, deviceInfoPayload.length, Endian.little);
      final deviceInfoStartData = _encodeResponsePayload(
        type: PTPIPPacketType.startData,
        payload: deviceInfoStartDataPayload,
      );
      final deviceInfoDataPayload = Uint8List(4 + deviceInfoPayload.length);
      ByteData.sublistView(deviceInfoDataPayload).setUint32(0, 1, Endian.little); // transactionID
      deviceInfoDataPayload.setRange(4, deviceInfoDataPayload.length, deviceInfoPayload);
      final deviceInfoData = _encodeResponsePayload(
        type: PTPIPPacketType.data,
        payload: deviceInfoDataPayload,
      );
      final deviceInfoEndDataPayload = Uint8List(4);
      ByteData.sublistView(deviceInfoEndDataPayload).setUint32(0, 1, Endian.little); // transactionID
      final deviceInfoEndData = _encodeResponsePayload(
        type: PTPIPPacketType.endData,
        payload: deviceInfoEndDataPayload,
      );
      final deviceInfoOk = _okResponse(1);

      // OpenSession 响应
      final openSessionOk = _okResponse(2);

      // GetObjectHandles 返回两个 handle: 0x00001001, 0x00001002
      final handlesPayload = Uint8List(12);
      ByteData.sublistView(handlesPayload).setUint32(0, 2, Endian.little); // count = 2
      ByteData.sublistView(handlesPayload).setUint32(4, 0x00001001, Endian.little);
      ByteData.sublistView(handlesPayload).setUint32(8, 0x00001002, Endian.little);
      final handlesStartDataPayload = Uint8List(12);
      ByteData.sublistView(handlesStartDataPayload).setUint32(0, 3, Endian.little); // transactionID
      ByteData.sublistView(handlesStartDataPayload).setUint64(4, handlesPayload.length, Endian.little);
      final handlesStartData = _encodeResponsePayload(
        type: PTPIPPacketType.startData,
        payload: handlesStartDataPayload,
      );
      final handlesDataPayload = Uint8List(4 + handlesPayload.length);
      ByteData.sublistView(handlesDataPayload).setUint32(0, 3, Endian.little); // transactionID
      handlesDataPayload.setRange(4, handlesDataPayload.length, handlesPayload);
      final handlesData = _encodeResponsePayload(
        type: PTPIPPacketType.data,
        payload: handlesDataPayload,
      );
      final handlesEndDataPayload = Uint8List(4);
      ByteData.sublistView(handlesEndDataPayload).setUint32(0, 3, Endian.little);
      final handlesEndData = _encodeResponsePayload(
        type: PTPIPPacketType.endData,
        payload: handlesEndDataPayload,
      );
      final handlesOk = _okResponse(3);

      final cmdFake = FakePtpipSocket(scriptedResponses: [
        // openSession: initCommandAck
        initCmdAck,
        // openSession: getDeviceInfo data stream
        deviceInfoStartData,
        deviceInfoData,
        deviceInfoEndData,
        deviceInfoOk,
        // openSession: openSession response
        openSessionOk,
        // getObjectHandles data stream
        handlesStartData,
        handlesData,
        handlesEndData,
        handlesOk,
      ]);

      final evtFake = FakePtpipSocket(scriptedResponses: [
        // openSession: initEventAck
        initEventAck,
      ]);

      final cmdConn = PtpipConnection(
        host: '127.0.0.1',
        port: 15740,
        socket: cmdFake,
      );
      final evtConn = PtpipConnection(
        host: '127.0.0.1',
        port: 15740,
        socket: evtFake,
      );

      final session = PtpipSession(
        host: '127.0.0.1',
        port: 15740,
        commandConnection: cmdConn,
        eventConnection: evtConn,
      );

      await session.openSession();
      final handles = await session.getObjectHandles();

      expect(handles, [0x00001001, 0x00001002]);
    });

    test('openSession throws on initFail', () async {
      final initFail = _encodeResponsePayload(
        type: PTPIPPacketType.initFail,
        payload: Uint8List(0),
      );

      final fakeSocket = FakePtpipSocket(scriptedResponses: [initFail]);
      final cmdConn = PtpipConnection(
        host: '127.0.0.1',
        port: 15740,
        socket: fakeSocket,
      );
      final evtConn = PtpipConnection(
        host: '127.0.0.1',
        port: 15740,
        socket: fakeSocket,
      );

      final session = PtpipSession(
        host: '127.0.0.1',
        port: 15740,
        commandConnection: cmdConn,
        eventConnection: evtConn,
      );

      expect(
        () => session.openSession(),
        throwsA(isA<PTPIPError>()),
      );
    }, timeout: const Timeout(Duration(seconds: 5)));
  });
}
