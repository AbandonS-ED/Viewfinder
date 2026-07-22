import 'dart:async';
import 'dart:typed_data';

import 'ptpip_socket.dart';
import 'ptpip_socket_io.dart';
import '../primitives/ptpip_data_structures.dart';

class PtpipConnection {
  PtpipConnection({required this.host, required this.port, PtpipSocket? socket})
    : _socket = socket ?? IoPtpipSocket(host: host, port: port);

  final String host;
  final int port;
  final PtpipSocket _socket;

  Future<void> open({Duration timeout = const Duration(seconds: 10)}) =>
    _socket.connect(timeout: timeout);

  Future<void> close() => _socket.close();

  Future<void> send(Uint8List packet) => _socket.send(packet);

  Future<PTPIPRawPacket> receivePacket({Duration timeout = const Duration(seconds: 10)}) =>
    _socket.receivePacket(timeout: timeout);

  bool get isConnected => _socket.isConnected;
}
