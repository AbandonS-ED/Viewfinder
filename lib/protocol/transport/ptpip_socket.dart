import 'dart:async';
import 'dart:typed_data';

import '../primitives/ptpip_data_structures.dart';

abstract class PtpipSocket {
  Future<void> connect({Duration timeout = const Duration(seconds: 10)});

  Future<void> send(Uint8List bytes);

  Future<PTPIPRawPacket> receivePacket({Duration timeout = const Duration(seconds: 10)});

  Future<void> close();

  bool get isConnected;
}
