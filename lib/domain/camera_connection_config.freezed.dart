// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_connection_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CameraConnectionConfig {
  /// 相机 IP 地址，默认 Nikon 相机热点
  String get host => throw _privateConstructorUsedError;

  /// CIPA PTP/IP 标准端口
  int get port => throw _privateConstructorUsedError;

  /// 传输模式
  CameraTransportMode get transportMode => throw _privateConstructorUsedError;

  /// 是否下载后自动写入相册
  bool get autoExportToPhotoLibrary => throw _privateConstructorUsedError;

  /// 下载队列中 JPEG 是否优先于 RAW
  bool get prioritizeJPEGDownloads => throw _privateConstructorUsedError;

  /// Create a copy of CameraConnectionConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CameraConnectionConfigCopyWith<CameraConnectionConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CameraConnectionConfigCopyWith<$Res> {
  factory $CameraConnectionConfigCopyWith(
    CameraConnectionConfig value,
    $Res Function(CameraConnectionConfig) then,
  ) = _$CameraConnectionConfigCopyWithImpl<$Res, CameraConnectionConfig>;
  @useResult
  $Res call({
    String host,
    int port,
    CameraTransportMode transportMode,
    bool autoExportToPhotoLibrary,
    bool prioritizeJPEGDownloads,
  });
}

/// @nodoc
class _$CameraConnectionConfigCopyWithImpl<
  $Res,
  $Val extends CameraConnectionConfig
>
    implements $CameraConnectionConfigCopyWith<$Res> {
  _$CameraConnectionConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CameraConnectionConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? host = null,
    Object? port = null,
    Object? transportMode = freezed,
    Object? autoExportToPhotoLibrary = null,
    Object? prioritizeJPEGDownloads = null,
  }) {
    return _then(
      _value.copyWith(
            host: null == host
                ? _value.host
                : host // ignore: cast_nullable_to_non_nullable
                      as String,
            port: null == port
                ? _value.port
                : port // ignore: cast_nullable_to_non_nullable
                      as int,
            transportMode: freezed == transportMode
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CameraConnectionConfigImplCopyWith<$Res>
    implements $CameraConnectionConfigCopyWith<$Res> {
  factory _$$CameraConnectionConfigImplCopyWith(
    _$CameraConnectionConfigImpl value,
    $Res Function(_$CameraConnectionConfigImpl) then,
  ) = __$$CameraConnectionConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String host,
    int port,
    CameraTransportMode transportMode,
    bool autoExportToPhotoLibrary,
    bool prioritizeJPEGDownloads,
  });
}

/// @nodoc
class __$$CameraConnectionConfigImplCopyWithImpl<$Res>
    extends
        _$CameraConnectionConfigCopyWithImpl<$Res, _$CameraConnectionConfigImpl>
    implements _$$CameraConnectionConfigImplCopyWith<$Res> {
  __$$CameraConnectionConfigImplCopyWithImpl(
    _$CameraConnectionConfigImpl _value,
    $Res Function(_$CameraConnectionConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CameraConnectionConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? host = null,
    Object? port = null,
    Object? transportMode = freezed,
    Object? autoExportToPhotoLibrary = null,
    Object? prioritizeJPEGDownloads = null,
  }) {
    return _then(
      _$CameraConnectionConfigImpl(
        host: null == host
            ? _value.host
            : host // ignore: cast_nullable_to_non_nullable
                  as String,
        port: null == port
            ? _value.port
            : port // ignore: cast_nullable_to_non_nullable
                  as int,
        transportMode: freezed == transportMode
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
      ),
    );
  }
}

/// @nodoc

class _$CameraConnectionConfigImpl extends _CameraConnectionConfig {
  const _$CameraConnectionConfigImpl({
    this.host = '192.168.1.1',
    this.port = 15740,
    this.transportMode = CameraTransportMode.experimentalNikon,
    this.autoExportToPhotoLibrary = false,
    this.prioritizeJPEGDownloads = false,
  }) : super._();

  /// 相机 IP 地址，默认 Nikon 相机热点
  @override
  @JsonKey()
  final String host;

  /// CIPA PTP/IP 标准端口
  @override
  @JsonKey()
  final int port;

  /// 传输模式
  @override
  @JsonKey()
  final CameraTransportMode transportMode;

  /// 是否下载后自动写入相册
  @override
  @JsonKey()
  final bool autoExportToPhotoLibrary;

  /// 下载队列中 JPEG 是否优先于 RAW
  @override
  @JsonKey()
  final bool prioritizeJPEGDownloads;

  @override
  String toString() {
    return 'CameraConnectionConfig(host: $host, port: $port, transportMode: $transportMode, autoExportToPhotoLibrary: $autoExportToPhotoLibrary, prioritizeJPEGDownloads: $prioritizeJPEGDownloads)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CameraConnectionConfigImpl &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.port, port) || other.port == port) &&
            const DeepCollectionEquality().equals(
              other.transportMode,
              transportMode,
            ) &&
            (identical(
                  other.autoExportToPhotoLibrary,
                  autoExportToPhotoLibrary,
                ) ||
                other.autoExportToPhotoLibrary == autoExportToPhotoLibrary) &&
            (identical(
                  other.prioritizeJPEGDownloads,
                  prioritizeJPEGDownloads,
                ) ||
                other.prioritizeJPEGDownloads == prioritizeJPEGDownloads));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    host,
    port,
    const DeepCollectionEquality().hash(transportMode),
    autoExportToPhotoLibrary,
    prioritizeJPEGDownloads,
  );

  /// Create a copy of CameraConnectionConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CameraConnectionConfigImplCopyWith<_$CameraConnectionConfigImpl>
  get copyWith =>
      __$$CameraConnectionConfigImplCopyWithImpl<_$CameraConnectionConfigImpl>(
        this,
        _$identity,
      );
}

abstract class _CameraConnectionConfig extends CameraConnectionConfig {
  const factory _CameraConnectionConfig({
    final String host,
    final int port,
    final CameraTransportMode transportMode,
    final bool autoExportToPhotoLibrary,
    final bool prioritizeJPEGDownloads,
  }) = _$CameraConnectionConfigImpl;
  const _CameraConnectionConfig._() : super._();

  /// 相机 IP 地址，默认 Nikon 相机热点
  @override
  String get host;

  /// CIPA PTP/IP 标准端口
  @override
  int get port;

  /// 传输模式
  @override
  CameraTransportMode get transportMode;

  /// 是否下载后自动写入相册
  @override
  bool get autoExportToPhotoLibrary;

  /// 下载队列中 JPEG 是否优先于 RAW
  @override
  bool get prioritizeJPEGDownloads;

  /// Create a copy of CameraConnectionConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CameraConnectionConfigImplCopyWith<_$CameraConnectionConfigImpl>
  get copyWith => throw _privateConstructorUsedError;
}
