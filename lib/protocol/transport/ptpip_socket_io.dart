import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'ptpip_socket.dart';
import '../primitives/ptpip_data_types.dart';
import '../primitives/ptpip_data_structures.dart';
import '../primitives/ptpip_error.dart';

class IoPtpipSocket implements PtpipSocket {
  IoPtpipSocket({required this.host, required this.port});

  final String host;
  final int port;
  Socket? _socket;
  final List<int> _buffer = [];

  @override
  bool get isConnected => _socket != null;

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 10)}) async {
    _socket = await Socket.connect(host, port, timeout: timeout);
  }

  @override
  Future<void> send(Uint8List bytes) async {
    final s = _socket;
    if (s == null) throw StateError('not connected');
    s.add(bytes);
    await s.flush();
  }

  @override
  Future<PTPIPRawPacket> receivePacket({Duration timeout = const Duration(seconds: 10)}) async {
    final s = _socket;
    if (s == null) throw StateError('not connected');

    final header = await _readExact(8, timeout);
    final length = ByteData.sublistView(header).getUint32(0, Endian.little);
    if (length < 8) throw const PTPIPError.invalidPacketLength();
    final typeRaw = ByteData.sublistView(header).getUint32(4, Endian.little);
    final type = PTPIPPacketType.values.firstWhere(
      (t) => t.rawValue == typeRaw,
      orElse: () => throw PTPIPError.unsupportedPacketType(typeRaw),
    );
    final payloadLen = length - 8;
    final payload = payloadLen > 0
        ? await _readExact(payloadLen, timeout)
        : Uint8List(0);
    return PTPIPRawPacket(type: type, payload: payload);
  }

  Future<Uint8List> _readExact(int count, Duration timeout) async {
    if (count == 0) return Uint8List(0);
    final s = _socket;
    if (s == null) throw StateError('not connected');

    if (_buffer.length >= count) {
      final take = Uint8List.fromList(_buffer.sublist(0, count));
      _buffer.removeRange(0, count);
      return take;
    }

    final completer = Completer<Uint8List>();
    StreamSubscription<Uint8List>? subscription;

    void checkBuffer() {
      if (completer.isCompleted) return;
      if (_buffer.length >= count) {
        final take = Uint8List.fromList(_buffer.sublist(0, count));
        _buffer.removeRange(0, count);
        completer.complete(take);
      }
    }

    subscription = s.listen(
      (chunk) {
        _buffer.addAll(chunk);
        checkBuffer();
      },
      onError: (Object e) {
        if (!completer.isCompleted) {
          completer.completeError(const PTPIPError.connectionClosed());
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(const PTPIPError.connectionClosed());
        }
      },
      cancelOnError: true,
    );

    try {
      return await completer.future.timeout(
        timeout,
        onTimeout: () {
          if (!completer.isCompleted) {
            completer.completeError(
              PTPIPError.timeout('read $count bytes within ${timeout.inSeconds}s'),
            );
          }
          throw PTPIPError.timeout('read $count bytes within ${timeout.inSeconds}s');
        },
      );
    } finally {
      await subscription.cancel();
    }
  }

  @override
  Future<void> close() async {
    await _socket?.close();
    _socket = null;
    _buffer.clear();
  }
}
