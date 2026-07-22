// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_throughput_diagnostics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DownloadThroughputDiagnostics {
  DownloadThroughputTransferMode get transferMode =>
      throw _privateConstructorUsedError;
  List<int> get samples => throw _privateConstructorUsedError;
  int get averageBps => throw _privateConstructorUsedError;
  int get peakBps => throw _privateConstructorUsedError;

  /// Create a copy of DownloadThroughputDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadThroughputDiagnosticsCopyWith<DownloadThroughputDiagnostics>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadThroughputDiagnosticsCopyWith<$Res> {
  factory $DownloadThroughputDiagnosticsCopyWith(
    DownloadThroughputDiagnostics value,
    $Res Function(DownloadThroughputDiagnostics) then,
  ) =
      _$DownloadThroughputDiagnosticsCopyWithImpl<
        $Res,
        DownloadThroughputDiagnostics
      >;
  @useResult
  $Res call({
    DownloadThroughputTransferMode transferMode,
    List<int> samples,
    int averageBps,
    int peakBps,
  });
}

/// @nodoc
class _$DownloadThroughputDiagnosticsCopyWithImpl<
  $Res,
  $Val extends DownloadThroughputDiagnostics
>
    implements $DownloadThroughputDiagnosticsCopyWith<$Res> {
  _$DownloadThroughputDiagnosticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadThroughputDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transferMode = null,
    Object? samples = null,
    Object? averageBps = null,
    Object? peakBps = null,
  }) {
    return _then(
      _value.copyWith(
            transferMode: null == transferMode
                ? _value.transferMode
                : transferMode // ignore: cast_nullable_to_non_nullable
                      as DownloadThroughputTransferMode,
            samples: null == samples
                ? _value.samples
                : samples // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            averageBps: null == averageBps
                ? _value.averageBps
                : averageBps // ignore: cast_nullable_to_non_nullable
                      as int,
            peakBps: null == peakBps
                ? _value.peakBps
                : peakBps // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DownloadThroughputDiagnosticsImplCopyWith<$Res>
    implements $DownloadThroughputDiagnosticsCopyWith<$Res> {
  factory _$$DownloadThroughputDiagnosticsImplCopyWith(
    _$DownloadThroughputDiagnosticsImpl value,
    $Res Function(_$DownloadThroughputDiagnosticsImpl) then,
  ) = __$$DownloadThroughputDiagnosticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DownloadThroughputTransferMode transferMode,
    List<int> samples,
    int averageBps,
    int peakBps,
  });
}

/// @nodoc
class __$$DownloadThroughputDiagnosticsImplCopyWithImpl<$Res>
    extends
        _$DownloadThroughputDiagnosticsCopyWithImpl<
          $Res,
          _$DownloadThroughputDiagnosticsImpl
        >
    implements _$$DownloadThroughputDiagnosticsImplCopyWith<$Res> {
  __$$DownloadThroughputDiagnosticsImplCopyWithImpl(
    _$DownloadThroughputDiagnosticsImpl _value,
    $Res Function(_$DownloadThroughputDiagnosticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadThroughputDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transferMode = null,
    Object? samples = null,
    Object? averageBps = null,
    Object? peakBps = null,
  }) {
    return _then(
      _$DownloadThroughputDiagnosticsImpl(
        transferMode: null == transferMode
            ? _value.transferMode
            : transferMode // ignore: cast_nullable_to_non_nullable
                  as DownloadThroughputTransferMode,
        samples: null == samples
            ? _value._samples
            : samples // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        averageBps: null == averageBps
            ? _value.averageBps
            : averageBps // ignore: cast_nullable_to_non_nullable
                  as int,
        peakBps: null == peakBps
            ? _value.peakBps
            : peakBps // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$DownloadThroughputDiagnosticsImpl
    implements _DownloadThroughputDiagnostics {
  const _$DownloadThroughputDiagnosticsImpl({
    required this.transferMode,
    final List<int> samples = const <int>[],
    this.averageBps = 0,
    this.peakBps = 0,
  }) : _samples = samples;

  @override
  final DownloadThroughputTransferMode transferMode;
  final List<int> _samples;
  @override
  @JsonKey()
  List<int> get samples {
    if (_samples is EqualUnmodifiableListView) return _samples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_samples);
  }

  @override
  @JsonKey()
  final int averageBps;
  @override
  @JsonKey()
  final int peakBps;

  @override
  String toString() {
    return 'DownloadThroughputDiagnostics(transferMode: $transferMode, samples: $samples, averageBps: $averageBps, peakBps: $peakBps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadThroughputDiagnosticsImpl &&
            (identical(other.transferMode, transferMode) ||
                other.transferMode == transferMode) &&
            const DeepCollectionEquality().equals(other._samples, _samples) &&
            (identical(other.averageBps, averageBps) ||
                other.averageBps == averageBps) &&
            (identical(other.peakBps, peakBps) || other.peakBps == peakBps));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    transferMode,
    const DeepCollectionEquality().hash(_samples),
    averageBps,
    peakBps,
  );

  /// Create a copy of DownloadThroughputDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadThroughputDiagnosticsImplCopyWith<
    _$DownloadThroughputDiagnosticsImpl
  >
  get copyWith =>
      __$$DownloadThroughputDiagnosticsImplCopyWithImpl<
        _$DownloadThroughputDiagnosticsImpl
      >(this, _$identity);
}

abstract class _DownloadThroughputDiagnostics
    implements DownloadThroughputDiagnostics {
  const factory _DownloadThroughputDiagnostics({
    required final DownloadThroughputTransferMode transferMode,
    final List<int> samples,
    final int averageBps,
    final int peakBps,
  }) = _$DownloadThroughputDiagnosticsImpl;

  @override
  DownloadThroughputTransferMode get transferMode;
  @override
  List<int> get samples;
  @override
  int get averageBps;
  @override
  int get peakBps;

  /// Create a copy of DownloadThroughputDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadThroughputDiagnosticsImplCopyWith<
    _$DownloadThroughputDiagnosticsImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DownloadThroughputChunkSample {
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime get finishedAt => throw _privateConstructorUsedError;
  int get bytesTransferred => throw _privateConstructorUsedError;
  int get deltaBytes => throw _privateConstructorUsedError;
  int get totalBytes => throw _privateConstructorUsedError;
  int get chunkSize => throw _privateConstructorUsedError;
  DownloadThroughputScene get scene => throw _privateConstructorUsedError;

  /// Create a copy of DownloadThroughputChunkSample
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadThroughputChunkSampleCopyWith<DownloadThroughputChunkSample>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadThroughputChunkSampleCopyWith<$Res> {
  factory $DownloadThroughputChunkSampleCopyWith(
    DownloadThroughputChunkSample value,
    $Res Function(DownloadThroughputChunkSample) then,
  ) =
      _$DownloadThroughputChunkSampleCopyWithImpl<
        $Res,
        DownloadThroughputChunkSample
      >;
  @useResult
  $Res call({
    DateTime startedAt,
    DateTime finishedAt,
    int bytesTransferred,
    int deltaBytes,
    int totalBytes,
    int chunkSize,
    DownloadThroughputScene scene,
  });
}

/// @nodoc
class _$DownloadThroughputChunkSampleCopyWithImpl<
  $Res,
  $Val extends DownloadThroughputChunkSample
>
    implements $DownloadThroughputChunkSampleCopyWith<$Res> {
  _$DownloadThroughputChunkSampleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadThroughputChunkSample
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startedAt = null,
    Object? finishedAt = null,
    Object? bytesTransferred = null,
    Object? deltaBytes = null,
    Object? totalBytes = null,
    Object? chunkSize = null,
    Object? scene = null,
  }) {
    return _then(
      _value.copyWith(
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            finishedAt: null == finishedAt
                ? _value.finishedAt
                : finishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            bytesTransferred: null == bytesTransferred
                ? _value.bytesTransferred
                : bytesTransferred // ignore: cast_nullable_to_non_nullable
                      as int,
            deltaBytes: null == deltaBytes
                ? _value.deltaBytes
                : deltaBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            totalBytes: null == totalBytes
                ? _value.totalBytes
                : totalBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            chunkSize: null == chunkSize
                ? _value.chunkSize
                : chunkSize // ignore: cast_nullable_to_non_nullable
                      as int,
            scene: null == scene
                ? _value.scene
                : scene // ignore: cast_nullable_to_non_nullable
                      as DownloadThroughputScene,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DownloadThroughputChunkSampleImplCopyWith<$Res>
    implements $DownloadThroughputChunkSampleCopyWith<$Res> {
  factory _$$DownloadThroughputChunkSampleImplCopyWith(
    _$DownloadThroughputChunkSampleImpl value,
    $Res Function(_$DownloadThroughputChunkSampleImpl) then,
  ) = __$$DownloadThroughputChunkSampleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime startedAt,
    DateTime finishedAt,
    int bytesTransferred,
    int deltaBytes,
    int totalBytes,
    int chunkSize,
    DownloadThroughputScene scene,
  });
}

/// @nodoc
class __$$DownloadThroughputChunkSampleImplCopyWithImpl<$Res>
    extends
        _$DownloadThroughputChunkSampleCopyWithImpl<
          $Res,
          _$DownloadThroughputChunkSampleImpl
        >
    implements _$$DownloadThroughputChunkSampleImplCopyWith<$Res> {
  __$$DownloadThroughputChunkSampleImplCopyWithImpl(
    _$DownloadThroughputChunkSampleImpl _value,
    $Res Function(_$DownloadThroughputChunkSampleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadThroughputChunkSample
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startedAt = null,
    Object? finishedAt = null,
    Object? bytesTransferred = null,
    Object? deltaBytes = null,
    Object? totalBytes = null,
    Object? chunkSize = null,
    Object? scene = null,
  }) {
    return _then(
      _$DownloadThroughputChunkSampleImpl(
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        finishedAt: null == finishedAt
            ? _value.finishedAt
            : finishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        bytesTransferred: null == bytesTransferred
            ? _value.bytesTransferred
            : bytesTransferred // ignore: cast_nullable_to_non_nullable
                  as int,
        deltaBytes: null == deltaBytes
            ? _value.deltaBytes
            : deltaBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        totalBytes: null == totalBytes
            ? _value.totalBytes
            : totalBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        chunkSize: null == chunkSize
            ? _value.chunkSize
            : chunkSize // ignore: cast_nullable_to_non_nullable
                  as int,
        scene: null == scene
            ? _value.scene
            : scene // ignore: cast_nullable_to_non_nullable
                  as DownloadThroughputScene,
      ),
    );
  }
}

/// @nodoc

class _$DownloadThroughputChunkSampleImpl
    extends _DownloadThroughputChunkSample {
  const _$DownloadThroughputChunkSampleImpl({
    required this.startedAt,
    required this.finishedAt,
    required this.bytesTransferred,
    required this.deltaBytes,
    required this.totalBytes,
    required this.chunkSize,
    required this.scene,
  }) : super._();

  @override
  final DateTime startedAt;
  @override
  final DateTime finishedAt;
  @override
  final int bytesTransferred;
  @override
  final int deltaBytes;
  @override
  final int totalBytes;
  @override
  final int chunkSize;
  @override
  final DownloadThroughputScene scene;

  @override
  String toString() {
    return 'DownloadThroughputChunkSample(startedAt: $startedAt, finishedAt: $finishedAt, bytesTransferred: $bytesTransferred, deltaBytes: $deltaBytes, totalBytes: $totalBytes, chunkSize: $chunkSize, scene: $scene)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadThroughputChunkSampleImpl &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt) &&
            (identical(other.bytesTransferred, bytesTransferred) ||
                other.bytesTransferred == bytesTransferred) &&
            (identical(other.deltaBytes, deltaBytes) ||
                other.deltaBytes == deltaBytes) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes) &&
            (identical(other.chunkSize, chunkSize) ||
                other.chunkSize == chunkSize) &&
            (identical(other.scene, scene) || other.scene == scene));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    startedAt,
    finishedAt,
    bytesTransferred,
    deltaBytes,
    totalBytes,
    chunkSize,
    scene,
  );

  /// Create a copy of DownloadThroughputChunkSample
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadThroughputChunkSampleImplCopyWith<
    _$DownloadThroughputChunkSampleImpl
  >
  get copyWith =>
      __$$DownloadThroughputChunkSampleImplCopyWithImpl<
        _$DownloadThroughputChunkSampleImpl
      >(this, _$identity);
}

abstract class _DownloadThroughputChunkSample
    extends DownloadThroughputChunkSample {
  const factory _DownloadThroughputChunkSample({
    required final DateTime startedAt,
    required final DateTime finishedAt,
    required final int bytesTransferred,
    required final int deltaBytes,
    required final int totalBytes,
    required final int chunkSize,
    required final DownloadThroughputScene scene,
  }) = _$DownloadThroughputChunkSampleImpl;
  const _DownloadThroughputChunkSample._() : super._();

  @override
  DateTime get startedAt;
  @override
  DateTime get finishedAt;
  @override
  int get bytesTransferred;
  @override
  int get deltaBytes;
  @override
  int get totalBytes;
  @override
  int get chunkSize;
  @override
  DownloadThroughputScene get scene;

  /// Create a copy of DownloadThroughputChunkSample
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadThroughputChunkSampleImplCopyWith<
    _$DownloadThroughputChunkSampleImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DownloadThroughputReport {
  String get id => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  PhotoAssetKind get fileKind => throw _privateConstructorUsedError;
  int get byteSize => throw _privateConstructorUsedError;
  int get itemNumber => throw _privateConstructorUsedError;
  int get totalItemCount => throw _privateConstructorUsedError;
  DownloadThroughputTransferMode get transferMode =>
      throw _privateConstructorUsedError;
  DownloadThroughputScene get initialScene =>
      throw _privateConstructorUsedError;
  DownloadThroughputScene get currentScene =>
      throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime get finishedAt => throw _privateConstructorUsedError;
  int get lastBytesTransferred => throw _privateConstructorUsedError;
  List<DownloadThroughputChunkSample> get chunkSamples =>
      throw _privateConstructorUsedError;
  int get liveActivityUpdateCount => throw _privateConstructorUsedError;
  int get queuePersistenceCount => throw _privateConstructorUsedError;
  int get backgroundExpirationCount => throw _privateConstructorUsedError;
  DownloadJobStatus get terminalStatus => throw _privateConstructorUsedError;

  /// Create a copy of DownloadThroughputReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadThroughputReportCopyWith<DownloadThroughputReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadThroughputReportCopyWith<$Res> {
  factory $DownloadThroughputReportCopyWith(
    DownloadThroughputReport value,
    $Res Function(DownloadThroughputReport) then,
  ) = _$DownloadThroughputReportCopyWithImpl<$Res, DownloadThroughputReport>;
  @useResult
  $Res call({
    String id,
    String fileName,
    PhotoAssetKind fileKind,
    int byteSize,
    int itemNumber,
    int totalItemCount,
    DownloadThroughputTransferMode transferMode,
    DownloadThroughputScene initialScene,
    DownloadThroughputScene currentScene,
    DateTime startedAt,
    DateTime finishedAt,
    int lastBytesTransferred,
    List<DownloadThroughputChunkSample> chunkSamples,
    int liveActivityUpdateCount,
    int queuePersistenceCount,
    int backgroundExpirationCount,
    DownloadJobStatus terminalStatus,
  });
}

/// @nodoc
class _$DownloadThroughputReportCopyWithImpl<
  $Res,
  $Val extends DownloadThroughputReport
>
    implements $DownloadThroughputReportCopyWith<$Res> {
  _$DownloadThroughputReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadThroughputReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fileName = null,
    Object? fileKind = null,
    Object? byteSize = null,
    Object? itemNumber = null,
    Object? totalItemCount = null,
    Object? transferMode = null,
    Object? initialScene = null,
    Object? currentScene = null,
    Object? startedAt = null,
    Object? finishedAt = null,
    Object? lastBytesTransferred = null,
    Object? chunkSamples = null,
    Object? liveActivityUpdateCount = null,
    Object? queuePersistenceCount = null,
    Object? backgroundExpirationCount = null,
    Object? terminalStatus = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            fileKind: null == fileKind
                ? _value.fileKind
                : fileKind // ignore: cast_nullable_to_non_nullable
                      as PhotoAssetKind,
            byteSize: null == byteSize
                ? _value.byteSize
                : byteSize // ignore: cast_nullable_to_non_nullable
                      as int,
            itemNumber: null == itemNumber
                ? _value.itemNumber
                : itemNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            totalItemCount: null == totalItemCount
                ? _value.totalItemCount
                : totalItemCount // ignore: cast_nullable_to_non_nullable
                      as int,
            transferMode: null == transferMode
                ? _value.transferMode
                : transferMode // ignore: cast_nullable_to_non_nullable
                      as DownloadThroughputTransferMode,
            initialScene: null == initialScene
                ? _value.initialScene
                : initialScene // ignore: cast_nullable_to_non_nullable
                      as DownloadThroughputScene,
            currentScene: null == currentScene
                ? _value.currentScene
                : currentScene // ignore: cast_nullable_to_non_nullable
                      as DownloadThroughputScene,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            finishedAt: null == finishedAt
                ? _value.finishedAt
                : finishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastBytesTransferred: null == lastBytesTransferred
                ? _value.lastBytesTransferred
                : lastBytesTransferred // ignore: cast_nullable_to_non_nullable
                      as int,
            chunkSamples: null == chunkSamples
                ? _value.chunkSamples
                : chunkSamples // ignore: cast_nullable_to_non_nullable
                      as List<DownloadThroughputChunkSample>,
            liveActivityUpdateCount: null == liveActivityUpdateCount
                ? _value.liveActivityUpdateCount
                : liveActivityUpdateCount // ignore: cast_nullable_to_non_nullable
                      as int,
            queuePersistenceCount: null == queuePersistenceCount
                ? _value.queuePersistenceCount
                : queuePersistenceCount // ignore: cast_nullable_to_non_nullable
                      as int,
            backgroundExpirationCount: null == backgroundExpirationCount
                ? _value.backgroundExpirationCount
                : backgroundExpirationCount // ignore: cast_nullable_to_non_nullable
                      as int,
            terminalStatus: null == terminalStatus
                ? _value.terminalStatus
                : terminalStatus // ignore: cast_nullable_to_non_nullable
                      as DownloadJobStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DownloadThroughputReportImplCopyWith<$Res>
    implements $DownloadThroughputReportCopyWith<$Res> {
  factory _$$DownloadThroughputReportImplCopyWith(
    _$DownloadThroughputReportImpl value,
    $Res Function(_$DownloadThroughputReportImpl) then,
  ) = __$$DownloadThroughputReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String fileName,
    PhotoAssetKind fileKind,
    int byteSize,
    int itemNumber,
    int totalItemCount,
    DownloadThroughputTransferMode transferMode,
    DownloadThroughputScene initialScene,
    DownloadThroughputScene currentScene,
    DateTime startedAt,
    DateTime finishedAt,
    int lastBytesTransferred,
    List<DownloadThroughputChunkSample> chunkSamples,
    int liveActivityUpdateCount,
    int queuePersistenceCount,
    int backgroundExpirationCount,
    DownloadJobStatus terminalStatus,
  });
}

/// @nodoc
class __$$DownloadThroughputReportImplCopyWithImpl<$Res>
    extends
        _$DownloadThroughputReportCopyWithImpl<
          $Res,
          _$DownloadThroughputReportImpl
        >
    implements _$$DownloadThroughputReportImplCopyWith<$Res> {
  __$$DownloadThroughputReportImplCopyWithImpl(
    _$DownloadThroughputReportImpl _value,
    $Res Function(_$DownloadThroughputReportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadThroughputReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fileName = null,
    Object? fileKind = null,
    Object? byteSize = null,
    Object? itemNumber = null,
    Object? totalItemCount = null,
    Object? transferMode = null,
    Object? initialScene = null,
    Object? currentScene = null,
    Object? startedAt = null,
    Object? finishedAt = null,
    Object? lastBytesTransferred = null,
    Object? chunkSamples = null,
    Object? liveActivityUpdateCount = null,
    Object? queuePersistenceCount = null,
    Object? backgroundExpirationCount = null,
    Object? terminalStatus = null,
  }) {
    return _then(
      _$DownloadThroughputReportImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        fileKind: null == fileKind
            ? _value.fileKind
            : fileKind // ignore: cast_nullable_to_non_nullable
                  as PhotoAssetKind,
        byteSize: null == byteSize
            ? _value.byteSize
            : byteSize // ignore: cast_nullable_to_non_nullable
                  as int,
        itemNumber: null == itemNumber
            ? _value.itemNumber
            : itemNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        totalItemCount: null == totalItemCount
            ? _value.totalItemCount
            : totalItemCount // ignore: cast_nullable_to_non_nullable
                  as int,
        transferMode: null == transferMode
            ? _value.transferMode
            : transferMode // ignore: cast_nullable_to_non_nullable
                  as DownloadThroughputTransferMode,
        initialScene: null == initialScene
            ? _value.initialScene
            : initialScene // ignore: cast_nullable_to_non_nullable
                  as DownloadThroughputScene,
        currentScene: null == currentScene
            ? _value.currentScene
            : currentScene // ignore: cast_nullable_to_non_nullable
                  as DownloadThroughputScene,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        finishedAt: null == finishedAt
            ? _value.finishedAt
            : finishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastBytesTransferred: null == lastBytesTransferred
            ? _value.lastBytesTransferred
            : lastBytesTransferred // ignore: cast_nullable_to_non_nullable
                  as int,
        chunkSamples: null == chunkSamples
            ? _value._chunkSamples
            : chunkSamples // ignore: cast_nullable_to_non_nullable
                  as List<DownloadThroughputChunkSample>,
        liveActivityUpdateCount: null == liveActivityUpdateCount
            ? _value.liveActivityUpdateCount
            : liveActivityUpdateCount // ignore: cast_nullable_to_non_nullable
                  as int,
        queuePersistenceCount: null == queuePersistenceCount
            ? _value.queuePersistenceCount
            : queuePersistenceCount // ignore: cast_nullable_to_non_nullable
                  as int,
        backgroundExpirationCount: null == backgroundExpirationCount
            ? _value.backgroundExpirationCount
            : backgroundExpirationCount // ignore: cast_nullable_to_non_nullable
                  as int,
        terminalStatus: null == terminalStatus
            ? _value.terminalStatus
            : terminalStatus // ignore: cast_nullable_to_non_nullable
                  as DownloadJobStatus,
      ),
    );
  }
}

/// @nodoc

class _$DownloadThroughputReportImpl extends _DownloadThroughputReport {
  const _$DownloadThroughputReportImpl({
    this.id = '',
    required this.fileName,
    required this.fileKind,
    this.byteSize = 0,
    this.itemNumber = 0,
    this.totalItemCount = 0,
    required this.transferMode,
    required this.initialScene,
    required this.currentScene,
    required this.startedAt,
    required this.finishedAt,
    this.lastBytesTransferred = 0,
    final List<DownloadThroughputChunkSample> chunkSamples =
        const <DownloadThroughputChunkSample>[],
    this.liveActivityUpdateCount = 0,
    this.queuePersistenceCount = 0,
    this.backgroundExpirationCount = 0,
    required this.terminalStatus,
  }) : _chunkSamples = chunkSamples,
       super._();

  @override
  @JsonKey()
  final String id;
  @override
  final String fileName;
  @override
  final PhotoAssetKind fileKind;
  @override
  @JsonKey()
  final int byteSize;
  @override
  @JsonKey()
  final int itemNumber;
  @override
  @JsonKey()
  final int totalItemCount;
  @override
  final DownloadThroughputTransferMode transferMode;
  @override
  final DownloadThroughputScene initialScene;
  @override
  final DownloadThroughputScene currentScene;
  @override
  final DateTime startedAt;
  @override
  final DateTime finishedAt;
  @override
  @JsonKey()
  final int lastBytesTransferred;
  final List<DownloadThroughputChunkSample> _chunkSamples;
  @override
  @JsonKey()
  List<DownloadThroughputChunkSample> get chunkSamples {
    if (_chunkSamples is EqualUnmodifiableListView) return _chunkSamples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chunkSamples);
  }

  @override
  @JsonKey()
  final int liveActivityUpdateCount;
  @override
  @JsonKey()
  final int queuePersistenceCount;
  @override
  @JsonKey()
  final int backgroundExpirationCount;
  @override
  final DownloadJobStatus terminalStatus;

  @override
  String toString() {
    return 'DownloadThroughputReport(id: $id, fileName: $fileName, fileKind: $fileKind, byteSize: $byteSize, itemNumber: $itemNumber, totalItemCount: $totalItemCount, transferMode: $transferMode, initialScene: $initialScene, currentScene: $currentScene, startedAt: $startedAt, finishedAt: $finishedAt, lastBytesTransferred: $lastBytesTransferred, chunkSamples: $chunkSamples, liveActivityUpdateCount: $liveActivityUpdateCount, queuePersistenceCount: $queuePersistenceCount, backgroundExpirationCount: $backgroundExpirationCount, terminalStatus: $terminalStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadThroughputReportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileKind, fileKind) ||
                other.fileKind == fileKind) &&
            (identical(other.byteSize, byteSize) ||
                other.byteSize == byteSize) &&
            (identical(other.itemNumber, itemNumber) ||
                other.itemNumber == itemNumber) &&
            (identical(other.totalItemCount, totalItemCount) ||
                other.totalItemCount == totalItemCount) &&
            (identical(other.transferMode, transferMode) ||
                other.transferMode == transferMode) &&
            (identical(other.initialScene, initialScene) ||
                other.initialScene == initialScene) &&
            (identical(other.currentScene, currentScene) ||
                other.currentScene == currentScene) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt) &&
            (identical(other.lastBytesTransferred, lastBytesTransferred) ||
                other.lastBytesTransferred == lastBytesTransferred) &&
            const DeepCollectionEquality().equals(
              other._chunkSamples,
              _chunkSamples,
            ) &&
            (identical(
                  other.liveActivityUpdateCount,
                  liveActivityUpdateCount,
                ) ||
                other.liveActivityUpdateCount == liveActivityUpdateCount) &&
            (identical(other.queuePersistenceCount, queuePersistenceCount) ||
                other.queuePersistenceCount == queuePersistenceCount) &&
            (identical(
                  other.backgroundExpirationCount,
                  backgroundExpirationCount,
                ) ||
                other.backgroundExpirationCount == backgroundExpirationCount) &&
            (identical(other.terminalStatus, terminalStatus) ||
                other.terminalStatus == terminalStatus));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fileName,
    fileKind,
    byteSize,
    itemNumber,
    totalItemCount,
    transferMode,
    initialScene,
    currentScene,
    startedAt,
    finishedAt,
    lastBytesTransferred,
    const DeepCollectionEquality().hash(_chunkSamples),
    liveActivityUpdateCount,
    queuePersistenceCount,
    backgroundExpirationCount,
    terminalStatus,
  );

  /// Create a copy of DownloadThroughputReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadThroughputReportImplCopyWith<_$DownloadThroughputReportImpl>
  get copyWith =>
      __$$DownloadThroughputReportImplCopyWithImpl<
        _$DownloadThroughputReportImpl
      >(this, _$identity);
}

abstract class _DownloadThroughputReport extends DownloadThroughputReport {
  const factory _DownloadThroughputReport({
    final String id,
    required final String fileName,
    required final PhotoAssetKind fileKind,
    final int byteSize,
    final int itemNumber,
    final int totalItemCount,
    required final DownloadThroughputTransferMode transferMode,
    required final DownloadThroughputScene initialScene,
    required final DownloadThroughputScene currentScene,
    required final DateTime startedAt,
    required final DateTime finishedAt,
    final int lastBytesTransferred,
    final List<DownloadThroughputChunkSample> chunkSamples,
    final int liveActivityUpdateCount,
    final int queuePersistenceCount,
    final int backgroundExpirationCount,
    required final DownloadJobStatus terminalStatus,
  }) = _$DownloadThroughputReportImpl;
  const _DownloadThroughputReport._() : super._();

  @override
  String get id;
  @override
  String get fileName;
  @override
  PhotoAssetKind get fileKind;
  @override
  int get byteSize;
  @override
  int get itemNumber;
  @override
  int get totalItemCount;
  @override
  DownloadThroughputTransferMode get transferMode;
  @override
  DownloadThroughputScene get initialScene;
  @override
  DownloadThroughputScene get currentScene;
  @override
  DateTime get startedAt;
  @override
  DateTime get finishedAt;
  @override
  int get lastBytesTransferred;
  @override
  List<DownloadThroughputChunkSample> get chunkSamples;
  @override
  int get liveActivityUpdateCount;
  @override
  int get queuePersistenceCount;
  @override
  int get backgroundExpirationCount;
  @override
  DownloadJobStatus get terminalStatus;

  /// Create a copy of DownloadThroughputReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadThroughputReportImplCopyWith<_$DownloadThroughputReportImpl>
  get copyWith => throw _privateConstructorUsedError;
}
