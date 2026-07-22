// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ptpip_data_structures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PTPIPDeviceInfo {
  String? get model => throw _privateConstructorUsedError;
  String? get manufacturer => throw _privateConstructorUsedError;
  Set<int> get operationsSupported => throw _privateConstructorUsedError;

  /// Create a copy of PTPIPDeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PTPIPDeviceInfoCopyWith<PTPIPDeviceInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PTPIPDeviceInfoCopyWith<$Res> {
  factory $PTPIPDeviceInfoCopyWith(
    PTPIPDeviceInfo value,
    $Res Function(PTPIPDeviceInfo) then,
  ) = _$PTPIPDeviceInfoCopyWithImpl<$Res, PTPIPDeviceInfo>;
  @useResult
  $Res call({
    String? model,
    String? manufacturer,
    Set<int> operationsSupported,
  });
}

/// @nodoc
class _$PTPIPDeviceInfoCopyWithImpl<$Res, $Val extends PTPIPDeviceInfo>
    implements $PTPIPDeviceInfoCopyWith<$Res> {
  _$PTPIPDeviceInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PTPIPDeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? model = freezed,
    Object? manufacturer = freezed,
    Object? operationsSupported = null,
  }) {
    return _then(
      _value.copyWith(
            model: freezed == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                      as String?,
            manufacturer: freezed == manufacturer
                ? _value.manufacturer
                : manufacturer // ignore: cast_nullable_to_non_nullable
                      as String?,
            operationsSupported: null == operationsSupported
                ? _value.operationsSupported
                : operationsSupported // ignore: cast_nullable_to_non_nullable
                      as Set<int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PTPIPDeviceInfoImplCopyWith<$Res>
    implements $PTPIPDeviceInfoCopyWith<$Res> {
  factory _$$PTPIPDeviceInfoImplCopyWith(
    _$PTPIPDeviceInfoImpl value,
    $Res Function(_$PTPIPDeviceInfoImpl) then,
  ) = __$$PTPIPDeviceInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? model,
    String? manufacturer,
    Set<int> operationsSupported,
  });
}

/// @nodoc
class __$$PTPIPDeviceInfoImplCopyWithImpl<$Res>
    extends _$PTPIPDeviceInfoCopyWithImpl<$Res, _$PTPIPDeviceInfoImpl>
    implements _$$PTPIPDeviceInfoImplCopyWith<$Res> {
  __$$PTPIPDeviceInfoImplCopyWithImpl(
    _$PTPIPDeviceInfoImpl _value,
    $Res Function(_$PTPIPDeviceInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PTPIPDeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? model = freezed,
    Object? manufacturer = freezed,
    Object? operationsSupported = null,
  }) {
    return _then(
      _$PTPIPDeviceInfoImpl(
        model: freezed == model
            ? _value.model
            : model // ignore: cast_nullable_to_non_nullable
                  as String?,
        manufacturer: freezed == manufacturer
            ? _value.manufacturer
            : manufacturer // ignore: cast_nullable_to_non_nullable
                  as String?,
        operationsSupported: null == operationsSupported
            ? _value._operationsSupported
            : operationsSupported // ignore: cast_nullable_to_non_nullable
                  as Set<int>,
      ),
    );
  }
}

/// @nodoc

class _$PTPIPDeviceInfoImpl implements _PTPIPDeviceInfo {
  const _$PTPIPDeviceInfoImpl({
    this.model,
    this.manufacturer,
    final Set<int> operationsSupported = const <int>{},
  }) : _operationsSupported = operationsSupported;

  @override
  final String? model;
  @override
  final String? manufacturer;
  final Set<int> _operationsSupported;
  @override
  @JsonKey()
  Set<int> get operationsSupported {
    if (_operationsSupported is EqualUnmodifiableSetView)
      return _operationsSupported;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_operationsSupported);
  }

  @override
  String toString() {
    return 'PTPIPDeviceInfo(model: $model, manufacturer: $manufacturer, operationsSupported: $operationsSupported)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PTPIPDeviceInfoImpl &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.manufacturer, manufacturer) ||
                other.manufacturer == manufacturer) &&
            const DeepCollectionEquality().equals(
              other._operationsSupported,
              _operationsSupported,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    model,
    manufacturer,
    const DeepCollectionEquality().hash(_operationsSupported),
  );

  /// Create a copy of PTPIPDeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PTPIPDeviceInfoImplCopyWith<_$PTPIPDeviceInfoImpl> get copyWith =>
      __$$PTPIPDeviceInfoImplCopyWithImpl<_$PTPIPDeviceInfoImpl>(
        this,
        _$identity,
      );
}

abstract class _PTPIPDeviceInfo implements PTPIPDeviceInfo {
  const factory _PTPIPDeviceInfo({
    final String? model,
    final String? manufacturer,
    final Set<int> operationsSupported,
  }) = _$PTPIPDeviceInfoImpl;

  @override
  String? get model;
  @override
  String? get manufacturer;
  @override
  Set<int> get operationsSupported;

  /// Create a copy of PTPIPDeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PTPIPDeviceInfoImplCopyWith<_$PTPIPDeviceInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PTPIPObjectInfo {
  int get handle => throw _privateConstructorUsedError;
  int get storageID => throw _privateConstructorUsedError;
  int get objectFormat => throw _privateConstructorUsedError;
  int get compressedSize => throw _privateConstructorUsedError;
  PhotoAssetThumbnailInfo? get thumbnailInfo =>
      throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  DateTime? get captureDate => throw _privateConstructorUsedError;
  DateTime? get modificationDate => throw _privateConstructorUsedError;

  /// Create a copy of PTPIPObjectInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PTPIPObjectInfoCopyWith<PTPIPObjectInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PTPIPObjectInfoCopyWith<$Res> {
  factory $PTPIPObjectInfoCopyWith(
    PTPIPObjectInfo value,
    $Res Function(PTPIPObjectInfo) then,
  ) = _$PTPIPObjectInfoCopyWithImpl<$Res, PTPIPObjectInfo>;
  @useResult
  $Res call({
    int handle,
    int storageID,
    int objectFormat,
    int compressedSize,
    PhotoAssetThumbnailInfo? thumbnailInfo,
    String fileName,
    DateTime? captureDate,
    DateTime? modificationDate,
  });

  $PhotoAssetThumbnailInfoCopyWith<$Res>? get thumbnailInfo;
}

/// @nodoc
class _$PTPIPObjectInfoCopyWithImpl<$Res, $Val extends PTPIPObjectInfo>
    implements $PTPIPObjectInfoCopyWith<$Res> {
  _$PTPIPObjectInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PTPIPObjectInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? handle = null,
    Object? storageID = null,
    Object? objectFormat = null,
    Object? compressedSize = null,
    Object? thumbnailInfo = freezed,
    Object? fileName = null,
    Object? captureDate = freezed,
    Object? modificationDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            handle: null == handle
                ? _value.handle
                : handle // ignore: cast_nullable_to_non_nullable
                      as int,
            storageID: null == storageID
                ? _value.storageID
                : storageID // ignore: cast_nullable_to_non_nullable
                      as int,
            objectFormat: null == objectFormat
                ? _value.objectFormat
                : objectFormat // ignore: cast_nullable_to_non_nullable
                      as int,
            compressedSize: null == compressedSize
                ? _value.compressedSize
                : compressedSize // ignore: cast_nullable_to_non_nullable
                      as int,
            thumbnailInfo: freezed == thumbnailInfo
                ? _value.thumbnailInfo
                : thumbnailInfo // ignore: cast_nullable_to_non_nullable
                      as PhotoAssetThumbnailInfo?,
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            captureDate: freezed == captureDate
                ? _value.captureDate
                : captureDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            modificationDate: freezed == modificationDate
                ? _value.modificationDate
                : modificationDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of PTPIPObjectInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PhotoAssetThumbnailInfoCopyWith<$Res>? get thumbnailInfo {
    if (_value.thumbnailInfo == null) {
      return null;
    }

    return $PhotoAssetThumbnailInfoCopyWith<$Res>(_value.thumbnailInfo!, (
      value,
    ) {
      return _then(_value.copyWith(thumbnailInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PTPIPObjectInfoImplCopyWith<$Res>
    implements $PTPIPObjectInfoCopyWith<$Res> {
  factory _$$PTPIPObjectInfoImplCopyWith(
    _$PTPIPObjectInfoImpl value,
    $Res Function(_$PTPIPObjectInfoImpl) then,
  ) = __$$PTPIPObjectInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int handle,
    int storageID,
    int objectFormat,
    int compressedSize,
    PhotoAssetThumbnailInfo? thumbnailInfo,
    String fileName,
    DateTime? captureDate,
    DateTime? modificationDate,
  });

  @override
  $PhotoAssetThumbnailInfoCopyWith<$Res>? get thumbnailInfo;
}

/// @nodoc
class __$$PTPIPObjectInfoImplCopyWithImpl<$Res>
    extends _$PTPIPObjectInfoCopyWithImpl<$Res, _$PTPIPObjectInfoImpl>
    implements _$$PTPIPObjectInfoImplCopyWith<$Res> {
  __$$PTPIPObjectInfoImplCopyWithImpl(
    _$PTPIPObjectInfoImpl _value,
    $Res Function(_$PTPIPObjectInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PTPIPObjectInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? handle = null,
    Object? storageID = null,
    Object? objectFormat = null,
    Object? compressedSize = null,
    Object? thumbnailInfo = freezed,
    Object? fileName = null,
    Object? captureDate = freezed,
    Object? modificationDate = freezed,
  }) {
    return _then(
      _$PTPIPObjectInfoImpl(
        handle: null == handle
            ? _value.handle
            : handle // ignore: cast_nullable_to_non_nullable
                  as int,
        storageID: null == storageID
            ? _value.storageID
            : storageID // ignore: cast_nullable_to_non_nullable
                  as int,
        objectFormat: null == objectFormat
            ? _value.objectFormat
            : objectFormat // ignore: cast_nullable_to_non_nullable
                  as int,
        compressedSize: null == compressedSize
            ? _value.compressedSize
            : compressedSize // ignore: cast_nullable_to_non_nullable
                  as int,
        thumbnailInfo: freezed == thumbnailInfo
            ? _value.thumbnailInfo
            : thumbnailInfo // ignore: cast_nullable_to_non_nullable
                  as PhotoAssetThumbnailInfo?,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        captureDate: freezed == captureDate
            ? _value.captureDate
            : captureDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        modificationDate: freezed == modificationDate
            ? _value.modificationDate
            : modificationDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$PTPIPObjectInfoImpl implements _PTPIPObjectInfo {
  const _$PTPIPObjectInfoImpl({
    required this.handle,
    required this.storageID,
    required this.objectFormat,
    required this.compressedSize,
    this.thumbnailInfo,
    this.fileName = '',
    this.captureDate,
    this.modificationDate,
  });

  @override
  final int handle;
  @override
  final int storageID;
  @override
  final int objectFormat;
  @override
  final int compressedSize;
  @override
  final PhotoAssetThumbnailInfo? thumbnailInfo;
  @override
  @JsonKey()
  final String fileName;
  @override
  final DateTime? captureDate;
  @override
  final DateTime? modificationDate;

  @override
  String toString() {
    return 'PTPIPObjectInfo(handle: $handle, storageID: $storageID, objectFormat: $objectFormat, compressedSize: $compressedSize, thumbnailInfo: $thumbnailInfo, fileName: $fileName, captureDate: $captureDate, modificationDate: $modificationDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PTPIPObjectInfoImpl &&
            (identical(other.handle, handle) || other.handle == handle) &&
            (identical(other.storageID, storageID) ||
                other.storageID == storageID) &&
            (identical(other.objectFormat, objectFormat) ||
                other.objectFormat == objectFormat) &&
            (identical(other.compressedSize, compressedSize) ||
                other.compressedSize == compressedSize) &&
            (identical(other.thumbnailInfo, thumbnailInfo) ||
                other.thumbnailInfo == thumbnailInfo) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.captureDate, captureDate) ||
                other.captureDate == captureDate) &&
            (identical(other.modificationDate, modificationDate) ||
                other.modificationDate == modificationDate));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    handle,
    storageID,
    objectFormat,
    compressedSize,
    thumbnailInfo,
    fileName,
    captureDate,
    modificationDate,
  );

  /// Create a copy of PTPIPObjectInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PTPIPObjectInfoImplCopyWith<_$PTPIPObjectInfoImpl> get copyWith =>
      __$$PTPIPObjectInfoImplCopyWithImpl<_$PTPIPObjectInfoImpl>(
        this,
        _$identity,
      );
}

abstract class _PTPIPObjectInfo implements PTPIPObjectInfo {
  const factory _PTPIPObjectInfo({
    required final int handle,
    required final int storageID,
    required final int objectFormat,
    required final int compressedSize,
    final PhotoAssetThumbnailInfo? thumbnailInfo,
    final String fileName,
    final DateTime? captureDate,
    final DateTime? modificationDate,
  }) = _$PTPIPObjectInfoImpl;

  @override
  int get handle;
  @override
  int get storageID;
  @override
  int get objectFormat;
  @override
  int get compressedSize;
  @override
  PhotoAssetThumbnailInfo? get thumbnailInfo;
  @override
  String get fileName;
  @override
  DateTime? get captureDate;
  @override
  DateTime? get modificationDate;

  /// Create a copy of PTPIPObjectInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PTPIPObjectInfoImplCopyWith<_$PTPIPObjectInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PTPIPRawPacket {
  PTPIPPacketType get type => throw _privateConstructorUsedError;
  Uint8List get payload => throw _privateConstructorUsedError;

  /// Create a copy of PTPIPRawPacket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PTPIPRawPacketCopyWith<PTPIPRawPacket> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PTPIPRawPacketCopyWith<$Res> {
  factory $PTPIPRawPacketCopyWith(
    PTPIPRawPacket value,
    $Res Function(PTPIPRawPacket) then,
  ) = _$PTPIPRawPacketCopyWithImpl<$Res, PTPIPRawPacket>;
  @useResult
  $Res call({PTPIPPacketType type, Uint8List payload});
}

/// @nodoc
class _$PTPIPRawPacketCopyWithImpl<$Res, $Val extends PTPIPRawPacket>
    implements $PTPIPRawPacketCopyWith<$Res> {
  _$PTPIPRawPacketCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PTPIPRawPacket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? type = null, Object? payload = null}) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as PTPIPPacketType,
            payload: null == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as Uint8List,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PTPIPRawPacketImplCopyWith<$Res>
    implements $PTPIPRawPacketCopyWith<$Res> {
  factory _$$PTPIPRawPacketImplCopyWith(
    _$PTPIPRawPacketImpl value,
    $Res Function(_$PTPIPRawPacketImpl) then,
  ) = __$$PTPIPRawPacketImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PTPIPPacketType type, Uint8List payload});
}

/// @nodoc
class __$$PTPIPRawPacketImplCopyWithImpl<$Res>
    extends _$PTPIPRawPacketCopyWithImpl<$Res, _$PTPIPRawPacketImpl>
    implements _$$PTPIPRawPacketImplCopyWith<$Res> {
  __$$PTPIPRawPacketImplCopyWithImpl(
    _$PTPIPRawPacketImpl _value,
    $Res Function(_$PTPIPRawPacketImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PTPIPRawPacket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? type = null, Object? payload = null}) {
    return _then(
      _$PTPIPRawPacketImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as PTPIPPacketType,
        payload: null == payload
            ? _value.payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as Uint8List,
      ),
    );
  }
}

/// @nodoc

class _$PTPIPRawPacketImpl implements _PTPIPRawPacket {
  const _$PTPIPRawPacketImpl({required this.type, required this.payload});

  @override
  final PTPIPPacketType type;
  @override
  final Uint8List payload;

  @override
  String toString() {
    return 'PTPIPRawPacket(type: $type, payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PTPIPRawPacketImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other.payload, payload));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    const DeepCollectionEquality().hash(payload),
  );

  /// Create a copy of PTPIPRawPacket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PTPIPRawPacketImplCopyWith<_$PTPIPRawPacketImpl> get copyWith =>
      __$$PTPIPRawPacketImplCopyWithImpl<_$PTPIPRawPacketImpl>(
        this,
        _$identity,
      );
}

abstract class _PTPIPRawPacket implements PTPIPRawPacket {
  const factory _PTPIPRawPacket({
    required final PTPIPPacketType type,
    required final Uint8List payload,
  }) = _$PTPIPRawPacketImpl;

  @override
  PTPIPPacketType get type;
  @override
  Uint8List get payload;

  /// Create a copy of PTPIPRawPacket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PTPIPRawPacketImplCopyWith<_$PTPIPRawPacketImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PTPIPResponse {
  int get code => throw _privateConstructorUsedError;
  int get transactionID => throw _privateConstructorUsedError;
  List<int> get parameters => throw _privateConstructorUsedError;

  /// Create a copy of PTPIPResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PTPIPResponseCopyWith<PTPIPResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PTPIPResponseCopyWith<$Res> {
  factory $PTPIPResponseCopyWith(
    PTPIPResponse value,
    $Res Function(PTPIPResponse) then,
  ) = _$PTPIPResponseCopyWithImpl<$Res, PTPIPResponse>;
  @useResult
  $Res call({int code, int transactionID, List<int> parameters});
}

/// @nodoc
class _$PTPIPResponseCopyWithImpl<$Res, $Val extends PTPIPResponse>
    implements $PTPIPResponseCopyWith<$Res> {
  _$PTPIPResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PTPIPResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? transactionID = null,
    Object? parameters = null,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as int,
            transactionID: null == transactionID
                ? _value.transactionID
                : transactionID // ignore: cast_nullable_to_non_nullable
                      as int,
            parameters: null == parameters
                ? _value.parameters
                : parameters // ignore: cast_nullable_to_non_nullable
                      as List<int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PTPIPResponseImplCopyWith<$Res>
    implements $PTPIPResponseCopyWith<$Res> {
  factory _$$PTPIPResponseImplCopyWith(
    _$PTPIPResponseImpl value,
    $Res Function(_$PTPIPResponseImpl) then,
  ) = __$$PTPIPResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int code, int transactionID, List<int> parameters});
}

/// @nodoc
class __$$PTPIPResponseImplCopyWithImpl<$Res>
    extends _$PTPIPResponseCopyWithImpl<$Res, _$PTPIPResponseImpl>
    implements _$$PTPIPResponseImplCopyWith<$Res> {
  __$$PTPIPResponseImplCopyWithImpl(
    _$PTPIPResponseImpl _value,
    $Res Function(_$PTPIPResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PTPIPResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? transactionID = null,
    Object? parameters = null,
  }) {
    return _then(
      _$PTPIPResponseImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as int,
        transactionID: null == transactionID
            ? _value.transactionID
            : transactionID // ignore: cast_nullable_to_non_nullable
                  as int,
        parameters: null == parameters
            ? _value._parameters
            : parameters // ignore: cast_nullable_to_non_nullable
                  as List<int>,
      ),
    );
  }
}

/// @nodoc

class _$PTPIPResponseImpl implements _PTPIPResponse {
  const _$PTPIPResponseImpl({
    required this.code,
    required this.transactionID,
    final List<int> parameters = const <int>[],
  }) : _parameters = parameters;

  @override
  final int code;
  @override
  final int transactionID;
  final List<int> _parameters;
  @override
  @JsonKey()
  List<int> get parameters {
    if (_parameters is EqualUnmodifiableListView) return _parameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_parameters);
  }

  @override
  String toString() {
    return 'PTPIPResponse(code: $code, transactionID: $transactionID, parameters: $parameters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PTPIPResponseImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.transactionID, transactionID) ||
                other.transactionID == transactionID) &&
            const DeepCollectionEquality().equals(
              other._parameters,
              _parameters,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    code,
    transactionID,
    const DeepCollectionEquality().hash(_parameters),
  );

  /// Create a copy of PTPIPResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PTPIPResponseImplCopyWith<_$PTPIPResponseImpl> get copyWith =>
      __$$PTPIPResponseImplCopyWithImpl<_$PTPIPResponseImpl>(this, _$identity);
}

abstract class _PTPIPResponse implements PTPIPResponse {
  const factory _PTPIPResponse({
    required final int code,
    required final int transactionID,
    final List<int> parameters,
  }) = _$PTPIPResponseImpl;

  @override
  int get code;
  @override
  int get transactionID;
  @override
  List<int> get parameters;

  /// Create a copy of PTPIPResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PTPIPResponseImplCopyWith<_$PTPIPResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
