import 'dart:async';
import 'dart:typed_data';

import 'package:viewfinder/protocol/transport/ptpip_socket.dart';
import 'package:viewfinder/protocol/primitives/ptpip_data_types.dart';
import 'package:viewfinder/protocol/primitives/ptpip_data_structures.dart';
import 'package:viewfinder/protocol/primitives/ptpip_error.dart';

class FakePtpipSocket implements PtpipSocket {
  FakePtpipSocket({
    this.scriptedResponses = const [],
    this.scriptedErrors = const [],
  });

  final List<Uint8List> scriptedResponses;
  final List<Object> scriptedErrors;
  int _responseIndex = 0;
  final List<Uint8List> sentPackets = [];
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 10)}) async {
    _connected = true;
  }

  @override
  Future<void> send(Uint8List bytes) async {
    sentPackets.add(bytes);
  }

  @override
  Future<PTPIPRawPacket> receivePacket({Duration timeout = const Duration(seconds: 10)}) async {
    final idx = _responseIndex++;
    if (idx < scriptedErrors.length) {
      final err = scriptedErrors[idx];
      if (err is PTPIPError) throw err;
      if (err is Exception) throw err;
      throw Exception('$err');
    }
    if (idx >= scriptedResponses.length) {
      throw Exception('no more scripted responses');
    }
    final raw = scriptedResponses[idx];
    final length = ByteData.sublistView(raw).getUint32(0, Endian.little);
    if (length < 8 || length != raw.length) {
      throw const PTPIPError.invalidPacketLength();
    }
    final typeRaw = ByteData.sublistView(raw).getUint32(4, Endian.little);
    final type = PTPIPPacketType.values.firstWhere(
      (t) => t.rawValue == typeRaw,
      orElse: () => throw PTPIPError.unsupportedPacketType(typeRaw),
    );
    final payload = raw.sublist(8);
    return PTPIPRawPacket(type: type, payload: payload);
  }

  @override
  Future<void> close() async {
    _connected = false;
  }
}
