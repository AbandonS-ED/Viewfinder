// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ConnectionState {
  CameraWorkflowState get workflowState => throw _privateConstructorUsedError;
  CameraSession? get activeSession => throw _privateConstructorUsedError;
  String get hostInput => throw _privateConstructorUsedError;
  String get portInput => throw _privateConstructorUsedError;
  CameraTransportMode get transportMode => throw _privateConstructorUsedError;
  bool get autoExportToPhotoLibrary => throw _privateConstructorUsedError;
  bool get prioritizeJPEGDownloads => throw _privateConstructorUsedError;
  bool get isWorking => throw _privateConstructorUsedError;
  String get lastSummary => throw _privateConstructorUsedError;

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionStateCopyWith<ConnectionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionStateCopyWith<$Res> {
  factory $ConnectionStateCopyWith(
    ConnectionState value,
    $Res Function(ConnectionState) then,
  ) = _$ConnectionStateCopyWithImpl<$Res, ConnectionState>;
  @useResult
  $Res call({
    CameraWorkflowState workflowState,
    CameraSession? activeSession,
    String hostInput,
    String portInput,
    CameraTransportMode transportMode,
    bool autoExportToPhotoLibrary,
    bool prioritizeJPEGDownloads,
    bool isWorking,
    String lastSummary,
  });

  $CameraSessionCopyWith<$Res>? get activeSession;
}

/// @nodoc
class _$ConnectionStateCopyWithImpl<$Res, $Val extends ConnectionState>
    implements $ConnectionStateCopyWith<$Res> {
  _$ConnectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workflowState = null,
    Object? activeSession = freezed,
    Object? hostInput = null,
    Object? portInput = null,
    Object? transportMode = null,
    Object? autoExportToPhotoLibrary = null,
    Object? prioritizeJPEGDownloads = null,
    Object? isWorking = null,
    Object? lastSummary = null,
  }) {
    return _then(
      _value.copyWith(
            workflowState: null == workflowState
                ? _value.workflowState
                : workflowState // ignore: cast_nullable_to_non_nullable
                      as CameraWorkflowState,
            activeSession: freezed == activeSession
                ? _value.activeSession
                : activeSession // ignore: cast_nullable_to_non_nullable
                      as CameraSession?,
            hostInput: null == hostInput
                ? _value.hostInput
                : hostInput // ignore: cast_nullable_to_non_nullable
                      as String,
            portInput: null == portInput
                ? _value.portInput
                : portInput // ignore: cast_nullable_to_non_nullable
                      as String,
            transportMode: null == transportMode
                ? _value.transportMode
                : transportMode // ignore: cast_nullable_to_non_nullable
                      as CameraTransportMode,
            autoExportToPhotoLibrary: null == autoExportToPhotoLibrary
                ? _value.autoExportToPhotoLibrary
                : autoExportToPhotoLibrary // ignore: cast_nullable_to_non_nullable
                      as bool,
            prioritizeJPEGDownloads: null == prioritizeJPEGDownloads
                ? _value.prioritizeJPEGDownloads
                : prioritizeJPEGDownloads // ignore: cast_nullable_to_non_nullable
                      as bool,
            isWorking: null == isWorking
                ? _value.isWorking
                : isWorking // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastSummary: null == lastSummary
                ? _value.lastSummary
                : lastSummary // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CameraSessionCopyWith<$Res>? get activeSession {
    if (_value.activeSession == null) {
      return null;
    }

    return $CameraSessionCopyWith<$Res>(_value.activeSession!, (value) {
      return _then(_value.copyWith(activeSession: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConnectionStateImplCopyWith<$Res>
    implements $ConnectionStateCopyWith<$Res> {
  factory _$$ConnectionStateImplCopyWith(
    _$ConnectionStateImpl value,
    $Res Function(_$ConnectionStateImpl) then,
  ) = __$$ConnectionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    CameraWorkflowState workflowState,
    CameraSession? activeSession,
    String hostInput,
    String portInput,
    CameraTransportMode transportMode,
    bool autoExportToPhotoLibrary,
    bool prioritizeJPEGDownloads,
    bool isWorking,
    String lastSummary,
  });

  @override
  $CameraSessionCopyWith<$Res>? get activeSession;
}

/// @nodoc
class __$$ConnectionStateImplCopyWithImpl<$Res>
    extends _$ConnectionStateCopyWithImpl<$Res, _$ConnectionStateImpl>
    implements _$$ConnectionStateImplCopyWith<$Res> {
  __$$ConnectionStateImplCopyWithImpl(
    _$ConnectionStateImpl _value,
    $Res Function(_$ConnectionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workflowState = null,
    Object? activeSession = freezed,
    Object? hostInput = null,
    Object? portInput = null,
    Object? transportMode = null,
    Object? autoExportToPhotoLibrary = null,
    Object? prioritizeJPEGDownloads = null,
    Object? isWorking = null,
    Object? lastSummary = null,
  }) {
    return _then(
      _$ConnectionStateImpl(
        workflowState: null == workflowState
            ? _value.workflowState
            : workflowState // ignore: cast_nullable_to_non_nullable
                  as CameraWorkflowState,
        activeSession: freezed == activeSession
            ? _value.activeSession
            : activeSession // ignore: cast_nullable_to_non_nullable
                  as CameraSession?,
        hostInput: null == hostInput
            ? _value.hostInput
            : hostInput // ignore: cast_nullable_to_non_nullable
                  as String,
        portInput: null == portInput
            ? _value.portInput
            : portInput // ignore: cast_nullable_to_non_nullable
                  as String,
        transportMode: null == transportMode
            ? _value.transportMode
            : transportMode // ignore: cast_nullable_to_non_nullable
                  as CameraTransportMode,
        autoExportToPhotoLibrary: null == autoExportToPhotoLibrary
            ? _value.autoExportToPhotoLibrary
            : autoExportToPhotoLibrary // ignore: cast_nullable_to_non_nullable
                  as bool,
        prioritizeJPEGDownloads: null == prioritizeJPEGDownloads
            ? _value.prioritizeJPEGDownloads
            : prioritizeJPEGDownloads // ignore: cast_nullable_to_non_nullable
                  as bool,
        isWorking: null == isWorking
            ? _value.isWorking
            : isWorking // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastSummary: null == lastSummary
            ? _value.lastSummary
            : lastSummary // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ConnectionStateImpl extends _ConnectionState {
  const _$ConnectionStateImpl({
    this.workflowState = CameraWorkflowState.waitingForWifi,
    this.activeSession,
    this.hostInput = '',
    this.portInput = '',
    this.transportMode = CameraTransportMode.experimentalNikon,
    this.autoExportToPhotoLibrary = true,
    this.prioritizeJPEGDownloads = true,
    this.isWorking = false,
    this.lastSummary = '先在系统设置里连接 Nikon 相机的 Wi-Fi，然后回到这里开始。',
  }) : super._();

  @override
  @JsonKey()
  final CameraWorkflowState workflowState;
  @override
  final CameraSession? activeSession;
  @override
  @JsonKey()
  final String hostInput;
  @override
  @JsonKey()
  final String portInput;
  @override
  @JsonKey()
  final CameraTransportMode transportMode;
  @override
  @JsonKey()
  final bool autoExportToPhotoLibrary;
  @override
  @JsonKey()
  final bool prioritizeJPEGDownloads;
  @override
  @JsonKey()
  final bool isWorking;
  @override
  @JsonKey()
  final String lastSummary;

  @override
  String toString() {
    return 'ConnectionState(workflowState: $workflowState, activeSession: $activeSession, hostInput: $hostInput, portInput: $portInput, transportMode: $transportMode, autoExportToPhotoLibrary: $autoExportToPhotoLibrary, prioritizeJPEGDownloads: $prioritizeJPEGDownloads, isWorking: $isWorking, lastSummary: $lastSummary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionStateImpl &&
            (identical(other.workflowState, workflowState) ||
                other.workflowState == workflowState) &&
            (identical(other.activeSession, activeSession) ||
                other.activeSession == activeSession) &&
            (identical(other.hostInput, hostInput) ||
                other.hostInput == hostInput) &&
            (identical(other.portInput, portInput) ||
                other.portInput == portInput) &&
            (identical(other.transportMode, transportMode) ||
                other.transportMode == transportMode) &&
            (identical(
                  other.autoExportToPhotoLibrary,
                  autoExportToPhotoLibrary,
                ) ||
                other.autoExportToPhotoLibrary == autoExportToPhotoLibrary) &&
            (identical(
                  other.prioritizeJPEGDownloads,
                  prioritizeJPEGDownloads,
                ) ||
                other.prioritizeJPEGDownloads == prioritizeJPEGDownloads) &&
            (identical(other.isWorking, isWorking) ||
                other.isWorking == isWorking) &&
            (identical(other.lastSummary, lastSummary) ||
                other.lastSummary == lastSummary));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    workflowState,
    activeSession,
    hostInput,
    portInput,
    transportMode,
    autoExportToPhotoLibrary,
    prioritizeJPEGDownloads,
    isWorking,
    lastSummary,
  );

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionStateImplCopyWith<_$ConnectionStateImpl> get copyWith =>
      __$$ConnectionStateImplCopyWithImpl<_$ConnectionStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ConnectionState extends ConnectionState {
  const factory _ConnectionState({
    final CameraWorkflowState workflowState,
    final CameraSession? activeSession,
    final String hostInput,
    final String portInput,
    final CameraTransportMode transportMode,
    final bool autoExportToPhotoLibrary,
    final bool prioritizeJPEGDownloads,
    final bool isWorking,
    final String lastSummary,
  }) = _$ConnectionStateImpl;
  const _ConnectionState._() : super._();

  @override
  CameraWorkflowState get workflowState;
  @override
  CameraSession? get activeSession;
  @override
  String get hostInput;
  @override
  String get portInput;
  @override
  CameraTransportMode get transportMode;
  @override
  bool get autoExportToPhotoLibrary;
  @override
  bool get prioritizeJPEGDownloads;
  @override
  bool get isWorking;
  @override
  String get lastSummary;

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionStateImplCopyWith<_$ConnectionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
