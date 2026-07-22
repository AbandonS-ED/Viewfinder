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
  /// 相机对象 handle
  String get remoteIdentifier => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  PhotoAssetKind get kind => throw _privateConstructorUsedError;
  int get byteSize => throw _privateConstructorUsedError;
  DateTime get captureDate => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;
  String get localPath => throw _privateConstructorUsedError;
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
    String remoteIdentifier,
    String fileName,
    PhotoAssetKind kind,
    int byteSize,
    DateTime captureDate,
    DateTime completedAt,
    String localPath,
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
    Object? remoteIdentifier = null,
    Object? fileName = null,
    Object? kind = freezed,
    Object? byteSize = null,
    Object? captureDate = null,
    Object? completedAt = null,
    Object? localPath = null,
    Object? exportedToPhotoLibrary = null,
  }) {
    return _then(
      _value.copyWith(
            remoteIdentifier: null == remoteIdentifier
                ? _value.remoteIdentifier
                : remoteIdentifier // ignore: cast_nullable_to_non_nullable
                      as String,
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            kind: freezed == kind
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
            completedAt: null == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            localPath: null == localPath
                ? _value.localPath
                : localPath // ignore: cast_nullable_to_non_nullable
                      as String,
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
    String remoteIdentifier,
    String fileName,
    PhotoAssetKind kind,
    int byteSize,
    DateTime captureDate,
    DateTime completedAt,
    String localPath,
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
    Object? remoteIdentifier = null,
    Object? fileName = null,
    Object? kind = freezed,
    Object? byteSize = null,
    Object? captureDate = null,
    Object? completedAt = null,
    Object? localPath = null,
    Object? exportedToPhotoLibrary = null,
  }) {
    return _then(
      _$DownloadRecordImpl(
        remoteIdentifier: null == remoteIdentifier
            ? _value.remoteIdentifier
            : remoteIdentifier // ignore: cast_nullable_to_non_nullable
                  as String,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        kind: freezed == kind
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
        completedAt: null == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        localPath: null == localPath
            ? _value.localPath
            : localPath // ignore: cast_nullable_to_non_nullable
                  as String,
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
    required this.remoteIdentifier,
    required this.fileName,
    required this.kind,
    this.byteSize = 0,
    required this.captureDate,
    required this.completedAt,
    required this.localPath,
    this.exportedToPhotoLibrary = false,
  });

  /// 相机对象 handle
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
  final DateTime completedAt;
  @override
  final String localPath;
  @override
  @JsonKey()
  final bool exportedToPhotoLibrary;

  @override
  String toString() {
    return 'DownloadRecord(remoteIdentifier: $remoteIdentifier, fileName: $fileName, kind: $kind, byteSize: $byteSize, captureDate: $captureDate, completedAt: $completedAt, localPath: $localPath, exportedToPhotoLibrary: $exportedToPhotoLibrary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadRecordImpl &&
            (identical(other.remoteIdentifier, remoteIdentifier) ||
                other.remoteIdentifier == remoteIdentifier) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            const DeepCollectionEquality().equals(other.kind, kind) &&
            (identical(other.byteSize, byteSize) ||
                other.byteSize == byteSize) &&
            (identical(other.captureDate, captureDate) ||
                other.captureDate == captureDate) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath) &&
            (identical(other.exportedToPhotoLibrary, exportedToPhotoLibrary) ||
                other.exportedToPhotoLibrary == exportedToPhotoLibrary));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    remoteIdentifier,
    fileName,
    const DeepCollectionEquality().hash(kind),
    byteSize,
    captureDate,
    completedAt,
    localPath,
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
    required final String remoteIdentifier,
    required final String fileName,
    required final PhotoAssetKind kind,
    final int byteSize,
    required final DateTime captureDate,
    required final DateTime completedAt,
    required final String localPath,
    final bool exportedToPhotoLibrary,
  }) = _$DownloadRecordImpl;

  /// 相机对象 handle
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
  DateTime get completedAt;
  @override
  String get localPath;
  @override
  bool get exportedToPhotoLibrary;

  /// Create a copy of DownloadRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadRecordImplCopyWith<_$DownloadRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
