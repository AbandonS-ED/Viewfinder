// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DownloadRecord {
  /// 唯一标识
  String get id => throw _privateConstructorUsedError;

  /// 相机端对象 handle
  String get sourceAssetIdentifier => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;

  /// 本地保存路径 (iOS 用 URL 类型；Phase 0 用 String 简化)
  String get savedURL => throw _privateConstructorUsedError;
  int get byteSize => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;
  bool get exportedToPhotoLibrary => throw _privateConstructorUsedError;

  /// Create a copy of DownloadRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadRecordCopyWith<DownloadRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadRecordCopyWith<$Res> {
  factory $DownloadRecordCopyWith(
    DownloadRecord value,
    $Res Function(DownloadRecord) then,
  ) = _$DownloadRecordCopyWithImpl<$Res, DownloadRecord>;
  @useResult
  $Res call({
    String id,
    String sourceAssetIdentifier,
    String fileName,
    String savedURL,
    int byteSize,
    DateTime completedAt,
    bool exportedToPhotoLibrary,
  });
}

/// @nodoc
class _$DownloadRecordCopyWithImpl<$Res, $Val extends DownloadRecord>
    implements $DownloadRecordCopyWith<$Res> {
  _$DownloadRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceAssetIdentifier = null,
    Object? fileName = null,
    Object? savedURL = null,
    Object? byteSize = null,
    Object? completedAt = null,
    Object? exportedToPhotoLibrary = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sourceAssetIdentifier: null == sourceAssetIdentifier
                ? _value.sourceAssetIdentifier
                : sourceAssetIdentifier // ignore: cast_nullable_to_non_nullable
                      as String,
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            savedURL: null == savedURL
                ? _value.savedURL
                : savedURL // ignore: cast_nullable_to_non_nullable
                      as String,
            byteSize: null == byteSize
                ? _value.byteSize
                : byteSize // ignore: cast_nullable_to_non_nullable
                      as int,
            completedAt: null == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            exportedToPhotoLibrary: null == exportedToPhotoLibrary
                ? _value.exportedToPhotoLibrary
                : exportedToPhotoLibrary // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DownloadRecordImplCopyWith<$Res>
    implements $DownloadRecordCopyWith<$Res> {
  factory _$$DownloadRecordImplCopyWith(
    _$DownloadRecordImpl value,
    $Res Function(_$DownloadRecordImpl) then,
  ) = __$$DownloadRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String sourceAssetIdentifier,
    String fileName,
    String savedURL,
    int byteSize,
    DateTime completedAt,
    bool exportedToPhotoLibrary,
  });
}

/// @nodoc
class __$$DownloadRecordImplCopyWithImpl<$Res>
    extends _$DownloadRecordCopyWithImpl<$Res, _$DownloadRecordImpl>
    implements _$$DownloadRecordImplCopyWith<$Res> {
  __$$DownloadRecordImplCopyWithImpl(
    _$DownloadRecordImpl _value,
    $Res Function(_$DownloadRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceAssetIdentifier = null,
    Object? fileName = null,
    Object? savedURL = null,
    Object? byteSize = null,
    Object? completedAt = null,
    Object? exportedToPhotoLibrary = null,
  }) {
    return _then(
      _$DownloadRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sourceAssetIdentifier: null == sourceAssetIdentifier
            ? _value.sourceAssetIdentifier
            : sourceAssetIdentifier // ignore: cast_nullable_to_non_nullable
                  as String,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        savedURL: null == savedURL
            ? _value.savedURL
            : savedURL // ignore: cast_nullable_to_non_nullable
                  as String,
        byteSize: null == byteSize
            ? _value.byteSize
            : byteSize // ignore: cast_nullable_to_non_nullable
                  as int,
        completedAt: null == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        exportedToPhotoLibrary: null == exportedToPhotoLibrary
            ? _value.exportedToPhotoLibrary
            : exportedToPhotoLibrary // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$DownloadRecordImpl implements _DownloadRecord {
  const _$DownloadRecordImpl({
    this.id = '',
    required this.sourceAssetIdentifier,
    required this.fileName,
    required this.savedURL,
    this.byteSize = 0,
    required this.completedAt,
    this.exportedToPhotoLibrary = false,
  });

  /// 唯一标识
  @override
  @JsonKey()
  final String id;

  /// 相机端对象 handle
  @override
  final String sourceAssetIdentifier;
  @override
  final String fileName;

  /// 本地保存路径 (iOS 用 URL 类型；Phase 0 用 String 简化)
  @override
  final String savedURL;
  @override
  @JsonKey()
  final int byteSize;
  @override
  final DateTime completedAt;
  @override
  @JsonKey()
  final bool exportedToPhotoLibrary;

  @override
  String toString() {
    return 'DownloadRecord(id: $id, sourceAssetIdentifier: $sourceAssetIdentifier, fileName: $fileName, savedURL: $savedURL, byteSize: $byteSize, completedAt: $completedAt, exportedToPhotoLibrary: $exportedToPhotoLibrary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sourceAssetIdentifier, sourceAssetIdentifier) ||
                other.sourceAssetIdentifier == sourceAssetIdentifier) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.savedURL, savedURL) ||
                other.savedURL == savedURL) &&
            (identical(other.byteSize, byteSize) ||
                other.byteSize == byteSize) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.exportedToPhotoLibrary, exportedToPhotoLibrary) ||
                other.exportedToPhotoLibrary == exportedToPhotoLibrary));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sourceAssetIdentifier,
    fileName,
    savedURL,
    byteSize,
    completedAt,
    exportedToPhotoLibrary,
  );

  /// Create a copy of DownloadRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadRecordImplCopyWith<_$DownloadRecordImpl> get copyWith =>
      __$$DownloadRecordImplCopyWithImpl<_$DownloadRecordImpl>(
        this,
        _$identity,
      );
}

abstract class _DownloadRecord implements DownloadRecord {
  const factory _DownloadRecord({
    final String id,
    required final String sourceAssetIdentifier,
    required final String fileName,
    required final String savedURL,
    final int byteSize,
    required final DateTime completedAt,
    final bool exportedToPhotoLibrary,
  }) = _$DownloadRecordImpl;

  /// 唯一标识
  @override
  String get id;

  /// 相机端对象 handle
  @override
  String get sourceAssetIdentifier;
  @override
  String get fileName;

  /// 本地保存路径 (iOS 用 URL 类型；Phase 0 用 String 简化)
  @override
  String get savedURL;
  @override
  int get byteSize;
  @override
  DateTime get completedAt;
  @override
  bool get exportedToPhotoLibrary;

  /// Create a copy of DownloadRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadRecordImplCopyWith<_$DownloadRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
