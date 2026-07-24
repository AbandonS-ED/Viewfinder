import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/protocol/primitives/ptpip_data_types.dart';
import 'package:viewfinder/protocol/primitives/ptpip_packet_codec.dart';
import 'package:viewfinder/protocol/transport/ptpip_connection.dart';
import 'package:viewfinder/protocol/session/ptpip_session.dart';
import '../helpers/fake_ptpip_socket.dart';

Uint8List _packet(PTPIPPacketType type, Uint8List payload) {
  return PTPIPCodec.encodePacket(type: type, payload: payload);
}

Uint8List _okResponse(int txId) {
  final p = Uint8List(8);
  ByteData.sublistView(p).setUint16(0, PTPResponseCode.ok.rawValue, Endian.little);
  ByteData.sublistView(p).setUint32(2, txId, Endian.little);
  return _packet(PTPIPPacketType.operationResponse, p);
}

Future<PtpipSession> _openSession(List<Uint8List> cmdResponses) {
  // initCommandAck
  final initCmdAckPayload = Uint8List(24);
  ByteData.sublistView(initCmdAckPayload).setUint32(0, 1, Endian.little);
  ByteData.sublistView(initCmdAckPayload).setUint32(20, 0x00010000, Endian.little);
  final initCmdAck = _packet(PTPIPPacketType.initCommandAck, initCmdAckPayload);

  // getDeviceInfo data
  // 35 字节: stdVersion(2) + vendorExtID(4) + vendorExtVer(2) + emptyString(1)
  // + functionalMode(2) + opsArray(4=count+0 elem) + eventsArray(4)
  // + devicePropsArray(4) + captureFormatsArray(4) + imageFormatsArray(4)
  // + 4 empty strings(4) = 2+4+2+1+2+4+4+4+4+4+4 = 35
  final deviceInfoPayload = Uint8List.fromList([
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00,
  ]);
  final deviceInfoStart = Uint8List(12);
  ByteData.sublistView(deviceInfoStart).setUint32(0, 1, Endian.little);
  ByteData.sublistView(deviceInfoStart).setUint64(4, deviceInfoPayload.length, Endian.little);
  final deviceInfoData = Uint8List(4 + deviceInfoPayload.length);
  ByteData.sublistView(deviceInfoData).setUint32(0, 1, Endian.little);
  deviceInfoData.setRange(4, deviceInfoData.length, deviceInfoPayload);
  final deviceInfoEnd = Uint8List(4);
  ByteData.sublistView(deviceInfoEnd).setUint32(0, 1, Endian.little);

  // Event ack
  final initEventAck = _packet(PTPIPPacketType.initEventAck, Uint8List(0));

  // Pre-pend openSession packets to the test's cmd responses
  final allResponses = <Uint8List>[
    initCmdAck,
    _packet(PTPIPPacketType.startData, deviceInfoStart),
    _packet(PTPIPPacketType.data, deviceInfoData),
    _packet(PTPIPPacketType.endData, deviceInfoEnd),
    _okResponse(1),
    _okResponse(2),
    ...cmdResponses,
  ];

  final cmdSocket = FakePtpipSocket(scriptedResponses: allResponses);
  final evtSocket = FakePtpipSocket(scriptedResponses: [initEventAck]);
  final cmdConn = PtpipConnection(
    host: '127.0.0.1',
    port: 15740,
    socket: cmdSocket,
  );
  final evtConn = PtpipConnection(
    host: '127.0.0.1',
    port: 15740,
    socket: evtSocket,
  );
  final session = PtpipSession(
    host: '127.0.0.1',
    port: 15740,
    commandConnection: cmdConn,
    eventConnection: evtConn,
  );
  return session.openSession().then((_) => session);
}

void main() {
  group('PtpipSession.getObjectToTempFile', () {
    test('streamed write: 多 chunk + per-chunk onProgress + 返回 temp file path', () async {
      // After openSession, _nextTransactionID is reset to 1.
      // So getObjectToTempFile will use txId=1.
      const chunk1Size = 4;
      const chunk2Size = 6;
      const totalSize = chunk1Size + chunk2Size;

      final startData = Uint8List(12);
      ByteData.sublistView(startData).setUint32(0, 1, Endian.little);
      ByteData.sublistView(startData).setUint64(4, totalSize, Endian.little);

      final data1 = Uint8List(4 + chunk1Size);
      ByteData.sublistView(data1).setUint32(0, 1, Endian.little);
      data1.setRange(4, 8, [0xAA, 0xBB, 0xCC, 0xDD]);

      final data2 = Uint8List(4 + chunk2Size);
      ByteData.sublistView(data2).setUint32(0, 1, Endian.little);
      data2.setRange(4, 10, [0x11, 0x22, 0x33, 0x44, 0x55, 0x66]);

      final endData = Uint8List(4);
      ByteData.sublistView(endData).setUint32(0, 1, Endian.little);

      final session = await _openSession([
        _packet(PTPIPPacketType.startData, startData),
        _packet(PTPIPPacketType.data, data1),
        _packet(PTPIPPacketType.data, data2),
        _packet(PTPIPPacketType.endData, endData),
        _okResponse(1),
      ]);

      final progress = <(int, int)>[];
      final path = await session.getObjectToTempFile(
        handle: 0x1001,
        suggestedFileName: 'DSC_0001.NEF',
        expectedByteSize: totalSize,
        onProgress: (transferred, total) {
          progress.add((transferred, total));
        },
      );

      // 写盘内容正确
      final bytes = await File(path).readAsBytes();
      expect(bytes, [0xAA, 0xBB, 0xCC, 0xDD, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66]);

      // onProgress 被调 2 次（每次 data packet 一次）
      expect(progress.length, 2);
      expect(progress[0], (4, 10));
      expect(progress[1], (10, 10));

      // 清理
      await File(path).delete();
    });

    test('camera 返回 error response → 抛 PTPIPError', () async {
      // error response with non-OK code (e.g. 0xA001 generalError)
      final errPayload = Uint8List(8);
      ByteData.sublistView(errPayload).setUint16(0, 0xA001, Endian.little);
      ByteData.sublistView(errPayload).setUint32(2, 1, Endian.little);

      final session = await _openSession([
        _packet(PTPIPPacketType.operationResponse, errPayload),
      ]);

      expect(
        () => session.getObjectToTempFile(
          handle: 0x1001,
          suggestedFileName: 'X.NEF',
          expectedByteSize: 1024,
          onProgress: null,
        ),
        throwsA(isA<Object>()),
      );
    });

    test('unexpected packet type → 抛 PTPIPError', () async {
      // 推一个错误包：operationResponse 但 code OK (模拟"开始包实际是响应")
      final session = await _openSession([
        _okResponse(1),
      ]);

      expect(
        () => session.getObjectToTempFile(
          handle: 0x1001,
          suggestedFileName: 'X.NEF',
          expectedByteSize: 1024,
          onProgress: null,
        ),
        throwsA(isA<Object>()),
      );
    });
  });
}
