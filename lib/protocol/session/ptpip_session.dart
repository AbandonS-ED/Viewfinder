import 'dart:async';
import 'dart:typed_data';

import '../primitives/ptpip_data_types.dart';
import '../primitives/ptpip_data_structures.dart';
import '../primitives/ptpip_packet_codec.dart';
import '../primitives/ptpip_error.dart';
import '../transport/ptpip_connection.dart';

import '../../domain/photo_asset.dart';

class PtpipSession {
  PtpipSession({
    required this.host,
    required this.port,
    PtpipConnection? commandConnection,
    PtpipConnection? eventConnection,
  }) : _commandConnection = commandConnection ?? PtpipConnection(host: host, port: port),
       _eventConnection = eventConnection ?? PtpipConnection(host: host, port: port);

  final String host;
  final int port;
  final PtpipConnection _commandConnection;
  final PtpipConnection _eventConnection;
  int _nextTransactionID = 1;
  bool _eventMonitorRunning = false;

  // ============ Lifecycle ============

  Future<PTPIPDeviceInfo> openSession() async {

    await _commandConnection.open();
    final guid = Uint8List(16);
    await _commandConnection.send(
      PTPIPCodec.encodeInitCommandRequest(
        guid: guid,
        friendlyName: PTPIPBinary.defaultFriendlyName,
      ),
    );
    final cmdAck = await _commandConnection.receivePacket();
    if (cmdAck.type != PTPIPPacketType.initCommandAck) {
      throw PTPIPError.unexpectedPacket(
        expected: [PTPIPPacketType.initCommandAck],
        actual: cmdAck.type,
      );
    }
    final connectionNumber = _parseConnectionNumber(cmdAck.payload);

    await _eventConnection.open();
    await _eventConnection.send(
      PTPIPCodec.encodeInitEventRequest(connectionNumber),
    );
    final eventAck = await _eventConnection.receivePacket();
    if (eventAck.type != PTPIPPacketType.initEventAck) {
      throw PTPIPError.unexpectedPacket(
        expected: [PTPIPPacketType.initEventAck],
        actual: eventAck.type,
      );
    }

    final deviceInfoData = await _requestDataIn(
      operation: PTPOperationCode.getDeviceInfo,
      parameters: [],
    );
    final deviceInfo = _parseDeviceInfo(deviceInfoData);

    await _requestResponseOnly(
      operation: PTPOperationCode.openSession,
      parameters: [1],
    );

    _nextTransactionID = 1;
    _startEventMonitor();
    return deviceInfo;
  }

  Future<void> closeSession() async {
    _stopEventMonitor();

    try {
      await _requestResponseOnly(
        operation: PTPOperationCode.closeSession,
        parameters: [],
      );
    } catch (_) {
    }

    await _commandConnection.close();
    await _eventConnection.close();
  }

  // ============ Asset Traversal ============

  Future<List<int>> getObjectHandles({int storageID = 0xFFFFFFFF}) async {
    final handlesData = await _requestDataIn(
      operation: PTPOperationCode.getObjectHandles,
      parameters: [storageID, 0x00000000, 0x00000000],
    );
    return _readUInt32Array(handlesData);
  }

  Future<PTPIPObjectInfo> getObjectInfo(int handle) async {
    final data = await _requestDataIn(
      operation: PTPOperationCode.getObjectInfo,
      parameters: [handle],
    );
    return _parseObjectInfo(data, handle: handle);
  }

  // ============ Transfers ============

  Future<Uint8List> getObject(int handle) async {
    return _requestDataIn(
      operation: PTPOperationCode.getObject,
      parameters: [handle],
    );
  }

  Future<Uint8List?> getThumbnail(int handle) async {
    try {
      return await _requestDataIn(
        operation: PTPOperationCode.getThumb,
        parameters: [handle],
      );
    } on PTPIPError catch (e) {
      if (e.responseCode == PTPResponseCode.noThumbnailPresent.rawValue ||
          e.responseCode == PTPResponseCode.operationNotSupported.rawValue) {
        return null;
      }
      rethrow;
    }
  }

  // ============ Internal helpers ============

  Future<Uint8List> _collectDataStream(int expectedTxId) async {
    final first = await _commandConnection.receivePacket();
    if (first.type == PTPIPPacketType.operationResponse) {
      final resp = PTPIPCodec.parseResponsePacket(first);
      if (resp.transactionID != expectedTxId) {
        throw PTPIPError.invalidTransaction(
          expected: expectedTxId, actual: resp.transactionID);
      }
      if (resp.code != PTPResponseCode.ok.rawValue) {
        throw PTPIPError.unexpectedResponse(resp.code);
      }
      return Uint8List(0);
    }
    if (first.type != PTPIPPacketType.startData) {
      throw PTPIPError.unexpectedPacket(
        expected: [PTPIPPacketType.operationResponse, PTPIPPacketType.startData],
        actual: first.type,
      );
    }
    final startInfo = PTPIPCodec.parseStartDataPayload(first.payload);
    if (startInfo.transactionID != expectedTxId) {
      throw PTPIPError.invalidTransaction(
        expected: expectedTxId, actual: startInfo.transactionID);
    }
    final buffer = BytesBuilder(copy: false);

    while (true) {
      final packet = await _commandConnection.receivePacket();
      switch (packet.type) {
        case PTPIPPacketType.data:
          final dataInfo = PTPIPCodec.parseDataPayload(packet.payload);
          if (dataInfo.transactionID != expectedTxId) {
            throw PTPIPError.invalidTransaction(
              expected: expectedTxId, actual: dataInfo.transactionID);
          }
          buffer.add(dataInfo.bytes);
        case PTPIPPacketType.endData:
          final dataInfo = PTPIPCodec.parseDataPayload(packet.payload);
          if (dataInfo.transactionID != expectedTxId) {
            throw PTPIPError.invalidTransaction(
              expected: expectedTxId, actual: dataInfo.transactionID);
          }
          buffer.add(dataInfo.bytes);
          final finalResp = await _commandConnection.receivePacket();
          final parsed = PTPIPCodec.parseResponsePacket(finalResp);
          if (parsed.transactionID != expectedTxId) {
            throw PTPIPError.invalidTransaction(
              expected: expectedTxId, actual: parsed.transactionID);
          }
          if (parsed.code != PTPResponseCode.ok.rawValue) {
            throw PTPIPError.unexpectedResponse(parsed.code);
          }
          return buffer.toBytes();
        case PTPIPPacketType.operationResponse:
          final parsed = PTPIPCodec.parseResponsePacket(packet);
          if (parsed.transactionID != expectedTxId) {
            throw PTPIPError.invalidTransaction(
              expected: expectedTxId, actual: parsed.transactionID);
          }
          if (parsed.code != PTPResponseCode.ok.rawValue) {
            throw PTPIPError.unexpectedResponse(parsed.code);
          }
          return buffer.toBytes();
        default:
          throw PTPIPError.unexpectedPacket(
            expected: [
              PTPIPPacketType.data,
              PTPIPPacketType.endData,
              PTPIPPacketType.operationResponse,
            ],
            actual: packet.type,
          );
      }
    }
  }

  Future<Uint8List> _requestDataIn({
    required PTPOperationCode operation,
    required List<int> parameters,
  }) async {
    final txId = _nextTransactionID++;
    await _commandConnection.send(
      PTPIPCodec.encodeOperationRequest(
        operation: operation,
        transactionID: txId,
        parameters: parameters,
        dataPhase: PTPIPDataPhaseInfo.noDataOrDataIn,
      ),
    );
    return await _collectDataStream(txId);
  }

  Future<void> _requestResponseOnly({
    required PTPOperationCode operation,
    required List<int> parameters,
  }) async {
    final txId = _nextTransactionID++;
    await _commandConnection.send(
      PTPIPCodec.encodeOperationRequest(
        operation: operation,
        transactionID: txId,
        parameters: parameters,
        dataPhase: PTPIPDataPhaseInfo.noDataOrDataIn,
      ),
    );
    final resp = await _commandConnection.receivePacket();
    final parsed = PTPIPCodec.parseResponsePacket(resp);
    if (parsed.transactionID != txId) {
      throw PTPIPError.invalidTransaction(expected: txId, actual: parsed.transactionID);
    }
    if (parsed.code != PTPResponseCode.ok.rawValue) {
      throw PTPIPError.unexpectedResponse(parsed.code);
    }
  }

  void _startEventMonitor() {
    if (_eventMonitorRunning) return;
    _eventMonitorRunning = true;
    Future.doWhile(() async {
      if (!_eventMonitorRunning) return false;
      try {
        final packet = await _eventConnection.receivePacket(
          timeout: const Duration(seconds: 30),
        );
        switch (packet.type) {
          case PTPIPPacketType.probeRequest:
            await _eventConnection.send(PTPIPCodec.encodeProbeResponse());
          case PTPIPPacketType.probeResponse:
          case PTPIPPacketType.event:
          default:
        }
      } on PTPIPError catch (e) {
        if (e.isTimeout) return _eventMonitorRunning;
        return false;
      } catch (_) {
        return false;
      }
      return _eventMonitorRunning;
    });
  }

  void _stopEventMonitor() {
    _eventMonitorRunning = false;
  }

  int _parseConnectionNumber(Uint8List payload) {
    final reader = PTPDataReader(payload);
    return reader.readUInt32LE();
  }

  PTPIPDeviceInfo _parseDeviceInfo(Uint8List data) {
    final reader = PTPDataReader(data);
    reader.readUInt16LE();
    reader.readUInt32LE();
    reader.readUInt16LE();
    reader.readPTPString();
    reader.readUInt16LE();
    final operationsSupported = reader.readPTPArrayUInt16();

    reader.readPTPArrayUInt16();
    reader.readPTPArrayUInt16();
    reader.readPTPArrayUInt16();
    reader.readPTPArrayUInt16();
    final manufacturer = reader.readPTPString();
    final model = reader.readPTPString();

    return PTPIPDeviceInfo(
      model: model.isEmpty ? null : model,
      manufacturer: manufacturer.isEmpty ? null : manufacturer,
      operationsSupported: operationsSupported.toSet(),
    );
  }

  PTPIPObjectInfo _parseObjectInfo(Uint8List data, {required int handle}) {
    final reader = PTPDataReader(data);
    final storageID = reader.readUInt32LE();
    final objectFormat = reader.readUInt16LE();
    reader.readUInt16LE();
    final compressedSize = reader.readUInt32LE();
    final thumbFormat = reader.readUInt16LE();
    final thumbCompressedSize = reader.readUInt32LE();
    final thumbPixWidth = reader.readUInt32LE();
    final thumbPixHeight = reader.readUInt32LE();

    reader.readUInt32LE();
    reader.readUInt32LE();
    reader.readUInt32LE();
    reader.readUInt32LE();
    reader.readUInt16LE();
    reader.readUInt32LE();
    reader.readUInt32LE();
    final fileName = reader.readPTPString();
    final captureDate = _parsePTPDate(reader.readPTPString());
    final modificationDate = _parsePTPDate(reader.readPTPString());

    final thumbnailInfo = thumbCompressedSize > 0
        ? PhotoAssetThumbnailInfo(
            formatCode: thumbFormat,
            byteSize: thumbCompressedSize,
            pixelWidth: thumbPixWidth,
            pixelHeight: thumbPixHeight,
          )
        : null;

    return PTPIPObjectInfo(
      handle: handle,
      storageID: storageID,
      objectFormat: objectFormat,
      compressedSize: compressedSize,
      thumbnailInfo: thumbnailInfo,
      fileName: fileName,
      captureDate: captureDate,
      modificationDate: modificationDate,
    );
  }

  List<int> _readUInt32Array(Uint8List data) {
    final reader = PTPDataReader(data);
    return reader.readPTPArrayUInt32();
  }

  DateTime? _parsePTPDate(String value) {
    if (value.isEmpty) return null;
    final trimmed = value.length > 15 ? value.substring(0, 15) : value;
    if (trimmed.length < 15) return null;

    try {
      final year = int.parse(trimmed.substring(0, 4));
      final month = int.parse(trimmed.substring(4, 6));
      final day = int.parse(trimmed.substring(6, 8));
      final hour = int.parse(trimmed.substring(9, 11));
      final minute = int.parse(trimmed.substring(11, 13));
      final second = int.parse(trimmed.substring(13, 15));
      return DateTime(year, month, day, hour, minute, second);
    } catch (_) {
      return null;
    }
  }
}
