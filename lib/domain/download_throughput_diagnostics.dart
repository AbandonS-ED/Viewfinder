import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_throughput_diagnostics.freezed.dart';

/// 吞吐诊断 (调试用)
@freezed
class DownloadThroughputDiagnostics with _$DownloadThroughputDiagnostics {
  const factory DownloadThroughputDiagnostics({
    required DownloadThroughputTransferMode transferMode,
    @Default(<int>[]) List<int> samples,
    @Default(0) int averageBps,
    @Default(0) int peakBps,
  }) = _DownloadThroughputDiagnostics;
}

/// 传输模式
enum DownloadThroughputTransferMode {
  unknown,           // 未知
  getObject,         // 完整 GetObject
  getPartialObject;  // 分段 GetPartialObject (自适应)
}
