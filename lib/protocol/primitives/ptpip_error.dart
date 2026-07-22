import 'ptpip_data_types.dart';

sealed class PTPIPError {
  const PTPIPError();
  String get message;

  int? get responseCode => null;

  const factory PTPIPError.invalidPacketLength() = _InvalidPacketLength;
  const factory PTPIPError.unsupportedPacketType(int value) = _UnsupportedPacketType;
  const factory PTPIPError.unexpectedPacket({
    required List<PTPIPPacketType> expected,
    required PTPIPPacketType actual,
  }) = _UnexpectedPacket;
  const factory PTPIPError.connectionClosed() = _ConnectionClosed;
  const factory PTPIPError.invalidProtocolVersion(int version) = _InvalidProtocolVersion;
  const factory PTPIPError.invalidTransaction({
    required int expected,
    required int actual,
  }) = _InvalidTransaction;
  const factory PTPIPError.unexpectedResponse(int code) = _UnexpectedResponse;
  const factory PTPIPError.malformedPayload(String detail) = _MalformedPayload;
  const factory PTPIPError.sessionUnavailable() = _SessionUnavailable;
  const factory PTPIPError.timeout(String detail) = _Timeout;
}

class _InvalidPacketLength extends PTPIPError {
  const _InvalidPacketLength();
  @override
  String get message => 'PTP/IP 数据包长度无效。';
}

class _UnsupportedPacketType extends PTPIPError {
  const _UnsupportedPacketType(this.value);
  final int value;
  @override
  String get message => '遇到未知的 PTP/IP 包类型：0x${value.toRadixString(16)}。';
}

class _UnexpectedPacket extends PTPIPError {
  const _UnexpectedPacket({required this.expected, required this.actual});
  final List<PTPIPPacketType> expected;
  final PTPIPPacketType actual;
  @override
  String get message {
    final expectedText = expected.map((t) => t.name).join(', ');
    return '收到的 PTP/IP 包类型不符合预期。期望：$expectedText，实际：${actual.name}。';
  }
}

class _ConnectionClosed extends PTPIPError {
  const _ConnectionClosed();
  @override
  String get message => '相机连接已关闭。';
}

class _InvalidProtocolVersion extends PTPIPError {
  const _InvalidProtocolVersion(this.version);
  final int version;
  @override
  String get message => '相机返回了不兼容的 PTP/IP 协议版本：0x${version.toRadixString(16)}。';
}

class _InvalidTransaction extends PTPIPError {
  const _InvalidTransaction({required this.expected, required this.actual});
  final int expected;
  final int actual;
  @override
  String get message => 'PTP 事务号不匹配。期望 $expected，实际 $actual。';
}

class _UnexpectedResponse extends PTPIPError {
  const _UnexpectedResponse(this.code);
  final int code;
  @override
  int? get responseCode => code;
  @override
  String get message => '相机返回了错误响应：0x${code.toRadixString(16)}。';
}

class _MalformedPayload extends PTPIPError {
  const _MalformedPayload(this.detail);
  final String detail;
  @override
  String get message => '相机返回的数据格式无法解析：$detail';
}

class _SessionUnavailable extends PTPIPError {
  const _SessionUnavailable();
  @override
  String get message => 'PTP/IP 会话尚未建立。';
}

class _Timeout extends PTPIPError {
  const _Timeout(this.detail);
  final String detail;
  @override
  String get message => '等待相机响应超时：$detail';
}
