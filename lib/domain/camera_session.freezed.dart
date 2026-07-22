// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CameraSession {
  /// 唯一标识 (Phase 0 用空字符串占位；Phase 1+ 可换 uuid 包)
  String get id => throw _privateConstructorUsedError;

  /// 相机显示名
  String get cameraName => throw _privateConstructorUsedError;

  /// 实际连接的 IP
  String get connectedHost => throw _privateConstructorUsedError;

  /// 实际连接的端口
  int get port => throw _privateConstructorUsedError;

  /// 连接建立时间
  DateTime get connectedAt => throw _privateConstructorUsedError;

  /// 相机声明的能力
  Set<CameraCapability> get capabilities => throw _privateConstructorUsedError;

  /// Create a copy of CameraSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CameraSessionCopyWith<CameraSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CameraSessionCopyWith<$Res> {
  factory $CameraSessionCopyWith(
    CameraSession value,
    $Res Function(CameraSession) then,
  ) = _$CameraSessionCopyWithImpl<$Res, CameraSession>;
  @useResult
  $Res call({
    String id,
    String cameraName,
    String connectedHost,
    int port,
    DateTime connectedAt,
    Set<CameraCapability> capabilities,
  });
}

/// @nodoc
class _$CameraSessionCopyWithImpl<$Res, $Val extends CameraSession>
    implements $CameraSessionCopyWith<$Res> {
  _$CameraSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CameraSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cameraName = null,
    Object? connectedHost = null,
    Object? port = null,
    Object? connectedAt = null,
    Object? capabilities = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            cameraName: null == cameraName
                ? _value.cameraName
                : cameraName // ignore: cast_nullable_to_non_nullable
                      as String,
            connectedHost: null == connectedHost
                ? _value.connectedHost
                : connectedHost // ignore: cast_nullable_to_non_nullable
                      as String,
            port: null == port
                ? _value.port
                : port // ignore: cast_nullable_to_non_nullable
                      as int,
            connectedAt: null == connectedAt
                ? _value.connectedAt
                : connectedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            capabilities: null == capabilities
                ? _value.capabilities
                : capabilities // ignore: cast_nullable_to_non_nullable
                      as Set<CameraCapability>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CameraSessionImplCopyWith<$Res>
    implements $CameraSessionCopyWith<$Res> {
  factory _$$CameraSessionImplCopyWith(
    _$CameraSessionImpl value,
    $Res Function(_$CameraSessionImpl) then,
  ) = __$$CameraSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String cameraName,
    String connectedHost,
    int port,
    DateTime connectedAt,
    Set<CameraCapability> capabilities,
  });
}

/// @nodoc
class __$$CameraSessionImplCopyWithImpl<$Res>
    extends _$CameraSessionCopyWithImpl<$Res, _$CameraSessionImpl>
    implements _$$CameraSessionImplCopyWith<$Res> {
  __$$CameraSessionImplCopyWithImpl(
    _$CameraSessionImpl _value,
    $Res Function(_$CameraSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CameraSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cameraName = null,
    Object? connectedHost = null,
    Object? port = null,
    Object? connectedAt = null,
    Object? capabilities = null,
  }) {
    return _then(
      _$CameraSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        cameraName: null == cameraName
            ? _value.cameraName
            : cameraName // ignore: cast_nullable_to_non_nullable
                  as String,
        connectedHost: null == connectedHost
            ? _value.connectedHost
            : connectedHost // ignore: cast_nullable_to_non_nullable
                  as String,
        port: null == port
            ? _value.port
            : port // ignore: cast_nullable_to_non_nullable
                  as int,
        connectedAt: null == connectedAt
            ? _value.connectedAt
            : connectedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        capabilities: null == capabilities
            ? _value._capabilities
            : capabilities // ignore: cast_nullable_to_non_nullable
                  as Set<CameraCapability>,
      ),
    );
  }
}

/// @nodoc

class _$CameraSessionImpl implements _CameraSession {
  const _$CameraSessionImpl({
    this.id = '',
    this.cameraName = 'Nikon Camera',
    this.connectedHost = '192.168.1.1',
    this.port = 15740,
    required this.connectedAt,
    final Set<CameraCapability> capabilities = const <CameraCapability>{},
  }) : _capabilities = capabilities;

  /// 唯一标识 (Phase 0 用空字符串占位；Phase 1+ 可换 uuid 包)
  @override
  @JsonKey()
  final String id;

  /// 相机显示名
  @override
  @JsonKey()
  final String cameraName;

  /// 实际连接的 IP
  @override
  @JsonKey()
  final String connectedHost;

  /// 实际连接的端口
  @override
  @JsonKey()
  final int port;

  /// 连接建立时间
  @override
  final DateTime connectedAt;

  /// 相机声明的能力
  final Set<CameraCapability> _capabilities;

  /// 相机声明的能力
  @override
  @JsonKey()
  Set<CameraCapability> get capabilities {
    if (_capabilities is EqualUnmodifiableSetView) return _capabilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_capabilities);
  }

  @override
  String toString() {
    return 'CameraSession(id: $id, cameraName: $cameraName, connectedHost: $connectedHost, port: $port, connectedAt: $connectedAt, capabilities: $capabilities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CameraSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.cameraName, cameraName) ||
                other.cameraName == cameraName) &&
            (identical(other.connectedHost, connectedHost) ||
                other.connectedHost == connectedHost) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.connectedAt, connectedAt) ||
                other.connectedAt == connectedAt) &&
            const DeepCollectionEquality().equals(
              other._capabilities,
              _capabilities,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    cameraName,
    connectedHost,
    port,
    connectedAt,
    const DeepCollectionEquality().hash(_capabilities),
  );

  /// Create a copy of CameraSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CameraSessionImplCopyWith<_$CameraSessionImpl> get copyWith =>
      __$$CameraSessionImplCopyWithImpl<_$CameraSessionImpl>(this, _$identity);
}

abstract class _CameraSession implements CameraSession {
  const factory _CameraSession({
    final String id,
    final String cameraName,
    final String connectedHost,
    final int port,
    required final DateTime connectedAt,
    final Set<CameraCapability> capabilities,
  }) = _$CameraSessionImpl;

  /// 唯一标识 (Phase 0 用空字符串占位；Phase 1+ 可换 uuid 包)
  @override
  String get id;

  /// 相机显示名
  @override
  String get cameraName;

  /// 实际连接的 IP
  @override
  String get connectedHost;

  /// 实际连接的端口
  @override
  int get port;

  /// 连接建立时间
  @override
  DateTime get connectedAt;

  /// 相机声明的能力
  @override
  Set<CameraCapability> get capabilities;

  /// Create a copy of CameraSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CameraSessionImplCopyWith<_$CameraSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
