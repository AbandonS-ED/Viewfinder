import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/protocol/transport/ptpip_connection.dart';
import 'package:viewfinder/protocol/primitives/ptpip_data_types.dart';
import 'package:viewfinder/protocol/primitives/ptpip_error.dart';
import '../../helpers/fake_ptpip_socket.dart';

void main() {
  group('PtpipConnection', () {
    test('open delegates to socket connect', () async {
      final socket = FakePtpipSocket();
      final conn = PtpipConnection(host: '127.0.0.1', port: 15740, socket: socket);
      expect(socket.isConnected, false);
      await conn.open();
      expect(socket.isConnected, true);
    });

    test('isConnected reflects socket state', () async {
      final socket = FakePtpipSocket();
      final conn = PtpipConnection(host: '127.0.0.1', port: 15740, socket: socket);
      expect(conn.isConnected, false);
      await conn.open();
      expect(conn.isConnected, true);
      await conn.close();
      expect(conn.isConnected, false);
    });

    test('send forwards bytes to socket', () async {
      final socket = FakePtpipSocket();
      final conn = PtpipConnection(host: '127.0.0.1', port: 15740, socket: socket);
      await conn.open();
      final data = Uint8List.fromList([0x01, 0x02, 0x03]);
      await conn.send(data);
      expect(socket.sentPackets.length, 1);
      expect(socket.sentPackets[0], data);
    });

    test('receivePacket returns response from socket', () async {
      final raw = Uint8List(12);
      ByteData.sublistView(raw).setUint32(0, 12, Endian.little);
      ByteData.sublistView(raw).setUint32(4, PTPIPPacketType.initCommandAck.rawValue, Endian.little);
      final socket = FakePtpipSocket(scriptedResponses: [raw]);
      final conn = PtpipConnection(host: '127.0.0.1', port: 15740, socket: socket);
      await conn.open();
      final resp = await conn.receivePacket();
      expect(resp.type, PTPIPPacketType.initCommandAck);
    });

    test('receivePacket propagates timeout', () async {
      final socket = FakePtpipSocket(scriptedErrors: [const PTPIPError.timeout('test timeout')]);
      final conn = PtpipConnection(host: '127.0.0.1', port: 15740, socket: socket);
      await conn.open();
      expect(
        () => conn.receivePacket(),
        throwsA(isA<PTPIPError>()),
      );
    });

    test('receivePacket propagates connectionClosed', () async {
      final socket = FakePtpipSocket(scriptedErrors: [const PTPIPError.connectionClosed()]);
      final conn = PtpipConnection(host: '127.0.0.1', port: 15740, socket: socket);
      await conn.open();
      expect(
        () => conn.receivePacket(),
        throwsA(isA<PTPIPError>()),
      );
    });

    test('receivePacket rejects invalid packet length', () async {
      final raw = Uint8List(4);
      ByteData.sublistView(raw).setUint32(0, 4, Endian.little);
      final socket = FakePtpipSocket(scriptedResponses: [raw]);
      final conn = PtpipConnection(host: '127.0.0.1', port: 15740, socket: socket);
      await conn.open();
      expect(
        () => conn.receivePacket(),
        throwsA(isA<PTPIPError>()),
      );
    });
  });
}
