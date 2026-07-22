// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_asset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PhotoAsset {
  /// 唯一标识 (Phase 0 用空字符串占位)
  String get id => throw _privateConstructorUsedError;

  /// 相机返回的对象 handle (UInt32, 序列化为字符串)
  String get remoteIdentifier => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  PhotoAssetKind get kind => throw _privateConstructorUsedError;
  int get byteSize => throw _privateConstructorUsedError;
  DateTime get captureDate => throw _privateConstructorUsedError;
  PhotoAssetThumbnailInfo? get thumbnailInfo =>
      throw _privateConstructorUsedError;

  /// Create a copy of PhotoAsset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoAssetCopyWith<PhotoAsset> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoAssetCopyWith<$Res> {
  factory $PhotoAssetCopyWith(
    PhotoAsset value,
    $Res Function(PhotoAsset) then,
  ) = _$PhotoAssetCopyWithImpl<$Res, PhotoAsset>;
  @useResult
  $Res call({
    String id,
    String remoteIdentifier,
    String fileName,
    PhotoAssetKind kind,
    int byteSize,
    DateTime captureDate,
    PhotoAssetThumbnailInfo? thumbnailInfo,
  });

  $PhotoAssetThumbnailInfoCopyWith<$Res>? get thumbnailInfo;
}

/// @nodoc
class _$PhotoAssetCopyWithImpl<$Res, $Val extends PhotoAsset>
    implements $PhotoAssetCopyWith<$Res> {
  _$PhotoAssetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoAsset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? remoteIdentifier = null,
    Object? fileName = null,
    Object? kind = null,
    Object? byteSize = null,
    Object? captureDate = null,
    Object? thumbnailInfo = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            remoteIdentifier: null == remoteIdentifier
                ? _value.remoteIdentifier
                : remoteIdentifier // ignore: cast_nullable_to_non_nullable
                      as String,
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as PhotoAssetKind,
            byteSize: null == byteSize
                ? _value.byteSize
                : byteSize // ignore: cast_nullable_to_non_nullable
                      as int,
            captureDate: null == captureDate
                ? _value.captureDate
                : captureDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            thumbnailInfo: freezed == thumbnailInfo
                ? _value.thumbnailInfo
                : thumbnailInfo // ignore: cast_nullable_to_non_nullable
                      as PhotoAssetThumbnailInfo?,
          )
          as $Val,
    );
  }

  /// Create a copy of PhotoAsset
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
abstract class _$$PhotoAssetImplCopyWith<$Res>
    implements $PhotoAssetCopyWith<$Res> {
  factory _$$PhotoAssetImplCopyWith(
    _$PhotoAssetImpl value,
    $Res Function(_$PhotoAssetImpl) then,
  ) = __$$PhotoAssetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String remoteIdentifier,
    String fileName,
    PhotoAssetKind kind,
    int byteSize,
    DateTime captureDate,
    PhotoAssetThumbnailInfo? thumbnailInfo,
  });

  @override
  $PhotoAssetThumbnailInfoCopyWith<$Res>? get thumbnailInfo;
}

/// @nodoc
class __$$PhotoAssetImplCopyWithImpl<$Res>
    extends _$PhotoAssetCopyWithImpl<$Res, _$PhotoAssetImpl>
    implements _$$PhotoAssetImplCopyWith<$Res> {
  __$$PhotoAssetImplCopyWithImpl(
    _$PhotoAssetImpl _value,
    $Res Function(_$PhotoAssetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PhotoAsset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? remoteIdentifier = null,
    Object? fileName = null,
    Object? kind = null,
    Object? byteSize = null,
    Object? captureDate = null,
    Object? thumbnailInfo = freezed,
  }) {
    return _then(
      _$PhotoAssetImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        remoteIdentifier: null == remoteIdentifier
            ? _value.remoteIdentifier
            : remoteIdentifier // ignore: cast_nullable_to_non_nullable
                  as String,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as PhotoAssetKind,
        byteSize: null == byteSize
            ? _value.byteSize
            : byteSize // ignore: cast_nullable_to_non_nullable
                  as int,
        captureDate: null == captureDate
            ? _value.captureDate
            : captureDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        thumbnailInfo: freezed == thumbnailInfo
            ? _value.thumbnailInfo
            : thumbnailInfo // ignore: cast_nullable_to_non_nullable
                  as PhotoAssetThumbnailInfo?,
      ),
    );
  }
}

/// @nodoc

class _$PhotoAssetImpl implements _PhotoAsset {
  const _$PhotoAssetImpl({
    this.id = '',
    required this.remoteIdentifier,
    required this.fileName,
    required this.kind,
    this.byteSize = 0,
    required this.captureDate,
    this.thumbnailInfo,
  });

  /// 唯一标识 (Phase 0 用空字符串占位)
  @override
  @JsonKey()
  final String id;

  /// 相机返回的对象 handle (UInt32, 序列化为字符串)
  @override
  final String remoteIdentifier;
  @override
  final String fileName;
  @override
  final PhotoAssetKind kind;
  @override
  @JsonKey()
  final int byteSize;
  @override
  final DateTime captureDate;
  @override
  final PhotoAssetThumbnailInfo? thumbnailInfo;

  @override
  String toString() {
    return 'PhotoAsset(id: $id, remoteIdentifier: $remoteIdentifier, fileName: $fileName, kind: $kind, byteSize: $byteSize, captureDate: $captureDate, thumbnailInfo: $thumbnailInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoAssetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.remoteIdentifier, remoteIdentifier) ||
                other.remoteIdentifier == remoteIdentifier) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.byteSize, byteSize) ||
                other.byteSize == byteSize) &&
            (identical(other.captureDate, captureDate) ||
                other.captureDate == captureDate) &&
            (identical(other.thumbnailInfo, thumbnailInfo) ||
                other.thumbnailInfo == thumbnailInfo));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    remoteIdentifier,
    fileName,
    kind,
    byteSize,
    captureDate,
    thumbnailInfo,
  );

  /// Create a copy of PhotoAsset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoAssetImplCopyWith<_$PhotoAssetImpl> get copyWith =>
      __$$PhotoAssetImplCopyWithImpl<_$PhotoAssetImpl>(this, _$identity);
}

abstract class _PhotoAsset implements PhotoAsset {
  const factory _PhotoAsset({
    final String id,
    required final String remoteIdentifier,
    required final String fileName,
    required final PhotoAssetKind kind,
    final int byteSize,
    required final DateTime captureDate,
    final PhotoAssetThumbnailInfo? thumbnailInfo,
  }) = _$PhotoAssetImpl;

  /// 唯一标识 (Phase 0 用空字符串占位)
  @override
  String get id;

  /// 相机返回的对象 handle (UInt32, 序列化为字符串)
  @override
  String get remoteIdentifier;
  @override
  String get fileName;
  @override
  PhotoAssetKind get kind;
  @override
  int get byteSize;
  @override
  DateTime get captureDate;
  @override
  PhotoAssetThumbnailInfo? get thumbnailInfo;

  /// Create a copy of PhotoAsset
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoAssetImplCopyWith<_$PhotoAssetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PhotoAssetThumbnailInfo {
  int get formatCode => throw _privateConstructorUsedError;
  int get byteSize => throw _privateConstructorUsedError;
  int get pixelWidth => throw _privateConstructorUsedError;
  int get pixelHeight => throw _privateConstructorUsedError;

  /// Create a copy of PhotoAssetThumbnailInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoAssetThumbnailInfoCopyWith<PhotoAssetThumbnailInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoAssetThumbnailInfoCopyWith<$Res> {
  factory $PhotoAssetThumbnailInfoCopyWith(
    PhotoAssetThumbnailInfo value,
    $Res Function(PhotoAssetThumbnailInfo) then,
  ) = _$PhotoAssetThumbnailInfoCopyWithImpl<$Res, PhotoAssetThumbnailInfo>;
  @useResult
  $Res call({int formatCode, int byteSize, int pixelWidth, int pixelHeight});
}

/// @nodoc
class _$PhotoAssetThumbnailInfoCopyWithImpl<
  $Res,
  $Val extends PhotoAssetThumbnailInfo
>
    implements $PhotoAssetThumbnailInfoCopyWith<$Res> {
  _$PhotoAssetThumbnailInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoAssetThumbnailInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? formatCode = null,
    Object? byteSize = null,
    Object? pixelWidth = null,
    Object? pixelHeight = null,
  }) {
    return _then(
      _value.copyWith(
            formatCode: null == formatCode
                ? _value.formatCode
                : formatCode // ignore: cast_nullable_to_non_nullable
                      as int,
            byteSize: null == byteSize
                ? _value.byteSize
                : byteSize // ignore: cast_nullable_to_non_nullable
                      as int,
            pixelWidth: null == pixelWidth
                ? _value.pixelWidth
                : pixelWidth // ignore: cast_nullable_to_non_nullable
                      as int,
            pixelHeight: null == pixelHeight
                ? _value.pixelHeight
                : pixelHeight // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PhotoAssetThumbnailInfoImplCopyWith<$Res>
    implements $PhotoAssetThumbnailInfoCopyWith<$Res> {
  factory _$$PhotoAssetThumbnailInfoImplCopyWith(
    _$PhotoAssetThumbnailInfoImpl value,
    $Res Function(_$PhotoAssetThumbnailInfoImpl) then,
  ) = __$$PhotoAssetThumbnailInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int formatCode, int byteSize, int pixelWidth, int pixelHeight});
}

/// @nodoc
class __$$PhotoAssetThumbnailInfoImplCopyWithImpl<$Res>
    extends
        _$PhotoAssetThumbnailInfoCopyWithImpl<
          $Res,
          _$PhotoAssetThumbnailInfoImpl
        >
    implements _$$PhotoAssetThumbnailInfoImplCopyWith<$Res> {
  __$$PhotoAssetThumbnailInfoImplCopyWithImpl(
    _$PhotoAssetThumbnailInfoImpl _value,
    $Res Function(_$PhotoAssetThumbnailInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PhotoAssetThumbnailInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? formatCode = null,
    Object? byteSize = null,
    Object? pixelWidth = null,
    Object? pixelHeight = null,
  }) {
    return _then(
      _$PhotoAssetThumbnailInfoImpl(
        formatCode: null == formatCode
            ? _value.formatCode
            : formatCode // ignore: cast_nullable_to_non_nullable
                  as int,
        byteSize: null == byteSize
            ? _value.byteSize
            : byteSize // ignore: cast_nullable_to_non_nullable
                  as int,
        pixelWidth: null == pixelWidth
            ? _value.pixelWidth
            : pixelWidth // ignore: cast_nullable_to_non_nullable
                  as int,
        pixelHeight: null == pixelHeight
            ? _value.pixelHeight
            : pixelHeight // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$PhotoAssetThumbnailInfoImpl implements _PhotoAssetThumbnailInfo {
  const _$PhotoAssetThumbnailInfoImpl({
    required this.formatCode,
    required this.byteSize,
    required this.pixelWidth,
    required this.pixelHeight,
  });

  @override
  final int formatCode;
  @override
  final int byteSize;
  @override
  final int pixelWidth;
  @override
  final int pixelHeight;

  @override
  String toString() {
    return 'PhotoAssetThumbnailInfo(formatCode: $formatCode, byteSize: $byteSize, pixelWidth: $pixelWidth, pixelHeight: $pixelHeight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoAssetThumbnailInfoImpl &&
            (identical(other.formatCode, formatCode) ||
                other.formatCode == formatCode) &&
            (identical(other.byteSize, byteSize) ||
                other.byteSize == byteSize) &&
            (identical(other.pixelWidth, pixelWidth) ||
                other.pixelWidth == pixelWidth) &&
            (identical(other.pixelHeight, pixelHeight) ||
                other.pixelHeight == pixelHeight));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, formatCode, byteSize, pixelWidth, pixelHeight);

  /// Create a copy of PhotoAssetThumbnailInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoAssetThumbnailInfoImplCopyWith<_$PhotoAssetThumbnailInfoImpl>
  get copyWith =>
      __$$PhotoAssetThumbnailInfoImplCopyWithImpl<
        _$PhotoAssetThumbnailInfoImpl
      >(this, _$identity);
}

abstract class _PhotoAssetThumbnailInfo implements PhotoAssetThumbnailInfo {
  const factory _PhotoAssetThumbnailInfo({
    required final int formatCode,
    required final int byteSize,
    required final int pixelWidth,
    required final int pixelHeight,
  }) = _$PhotoAssetThumbnailInfoImpl;

  @override
  int get formatCode;
  @override
  int get byteSize;
  @override
  int get pixelWidth;
  @override
  int get pixelHeight;

  /// Create a copy of PhotoAssetThumbnailInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoAssetThumbnailInfoImplCopyWith<_$PhotoAssetThumbnailInfoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PhotoAssetPage {
  List<PhotoAsset> get assets => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;

  /// Create a copy of PhotoAssetPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoAssetPageCopyWith<PhotoAssetPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoAssetPageCopyWith<$Res> {
  factory $PhotoAssetPageCopyWith(
    PhotoAssetPage value,
    $Res Function(PhotoAssetPage) then,
  ) = _$PhotoAssetPageCopyWithImpl<$Res, PhotoAssetPage>;
  @useResult
  $Res call({List<PhotoAsset> assets, bool hasMore});
}

/// @nodoc
class _$PhotoAssetPageCopyWithImpl<$Res, $Val extends PhotoAssetPage>
    implements $PhotoAssetPageCopyWith<$Res> {
  _$PhotoAssetPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoAssetPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? assets = null, Object? hasMore = null}) {
    return _then(
      _value.copyWith(
            assets: null == assets
                ? _value.assets
                : assets // ignore: cast_nullable_to_non_nullable
                      as List<PhotoAsset>,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PhotoAssetPageImplCopyWith<$Res>
    implements $PhotoAssetPageCopyWith<$Res> {
  factory _$$PhotoAssetPageImplCopyWith(
    _$PhotoAssetPageImpl value,
    $Res Function(_$PhotoAssetPageImpl) then,
  ) = __$$PhotoAssetPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<PhotoAsset> assets, bool hasMore});
}

/// @nodoc
class __$$PhotoAssetPageImplCopyWithImpl<$Res>
    extends _$PhotoAssetPageCopyWithImpl<$Res, _$PhotoAssetPageImpl>
    implements _$$PhotoAssetPageImplCopyWith<$Res> {
  __$$PhotoAssetPageImplCopyWithImpl(
    _$PhotoAssetPageImpl _value,
    $Res Function(_$PhotoAssetPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PhotoAssetPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? assets = null, Object? hasMore = null}) {
    return _then(
      _$PhotoAssetPageImpl(
        assets: null == assets
            ? _value._assets
            : assets // ignore: cast_nullable_to_non_nullable
                  as List<PhotoAsset>,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$PhotoAssetPageImpl implements _PhotoAssetPage {
  const _$PhotoAssetPageImpl({
    required final List<PhotoAsset> assets,
    this.hasMore = false,
  }) : _assets = assets;

  final List<PhotoAsset> _assets;
  @override
  List<PhotoAsset> get assets {
    if (_assets is EqualUnmodifiableListView) return _assets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assets);
  }

  @override
  @JsonKey()
  final bool hasMore;

  @override
  String toString() {
    return 'PhotoAssetPage(assets: $assets, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoAssetPageImpl &&
            const DeepCollectionEquality().equals(other._assets, _assets) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_assets),
    hasMore,
  );

  /// Create a copy of PhotoAssetPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoAssetPageImplCopyWith<_$PhotoAssetPageImpl> get copyWith =>
      __$$PhotoAssetPageImplCopyWithImpl<_$PhotoAssetPageImpl>(
        this,
        _$identity,
      );
}

abstract class _PhotoAssetPage implements PhotoAssetPage {
  const factory _PhotoAssetPage({
    required final List<PhotoAsset> assets,
    final bool hasMore,
  }) = _$PhotoAssetPageImpl;

  @override
  List<PhotoAsset> get assets;
  @override
  bool get hasMore;

  /// Create a copy of PhotoAssetPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoAssetPageImplCopyWith<_$PhotoAssetPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
