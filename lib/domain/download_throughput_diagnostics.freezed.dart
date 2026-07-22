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
