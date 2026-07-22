// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DownloadJob {
  /// 唯一标识 (Phase 0 用空字符串占位)
  String get id => throw _privateConstructorUsedError;

  /// 相机对象 handle
  String get remoteIdentifier => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  PhotoAssetKind get kind => throw _privateConstructorUsedError;
  int get byteSize => throw _privateConstructorUsedError;
  DateTime get captureDate => throw _privateConstructorUsedError;
  bool get autoExportToPhotoLibrary => throw _privateConstructorUsedError;
  DownloadJobStatus get status => throw _privateConstructorUsedError;
  int get bytesTransferred => throw _privateConstructorUsedError;
  int get totalBytes => throw _privateConstructorUsedError;

  /// 当前已下载偏移 (用于续传)
  int get currentOffset => throw _privateConstructorUsedError;

  /// 续传次数
  int get resumedCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of DownloadJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadJobCopyWith<DownloadJob> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadJobCopyWith<$Res> {
  factory $DownloadJobCopyWith(
    DownloadJob value,
    $Res Function(DownloadJob) then,
  ) = _$DownloadJobCopyWithImpl<$Res, DownloadJob>;
  @useResult
  $Res call({
    String id,
    String remoteIdentifier,
    String fileName,
    PhotoAssetKind kind,
    int byteSize,
    DateTime captureDate,
    bool autoExportToPhotoLibrary,
    DownloadJobStatus status,
    int bytesTransferred,
    int totalBytes,
    int currentOffset,
    int resumedCount,
    DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime updatedAt,
    String? errorMessage,
  });
}

/// @nodoc
class _$DownloadJobCopyWithImpl<$Res, $Val extends DownloadJob>
    implements $DownloadJobCopyWith<$Res> {
  _$DownloadJobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadJob
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
    Object? autoExportToPhotoLibrary = null,
    Object? status = null,
    Object? bytesTransferred = null,
    Object? totalBytes = null,
    Object? currentOffset = null,
    Object? resumedCount = null,
    Object? createdAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? updatedAt = null,
    Object? errorMessage = freezed,
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
            autoExportToPhotoLibrary: null == autoExportToPhotoLibrary
                ? _value.autoExportToPhotoLibrary
                : autoExportToPhotoLibrary // ignore: cast_nullable_to_non_nullable
                      as bool,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as DownloadJobStatus,
            bytesTransferred: null == bytesTransferred
                ? _value.bytesTransferred
                : bytesTransferred // ignore: cast_nullable_to_non_nullable
                      as int,
            totalBytes: null == totalBytes
                ? _value.totalBytes
                : totalBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            currentOffset: null == currentOffset
                ? _value.currentOffset
                : currentOffset // ignore: cast_nullable_to_non_nullable
                      as int,
            resumedCount: null == resumedCount
                ? _value.resumedCount
                : resumedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DownloadJobImplCopyWith<$Res>
    implements $DownloadJobCopyWith<$Res> {
  factory _$$DownloadJobImplCopyWith(
    _$DownloadJobImpl value,
    $Res Function(_$DownloadJobImpl) then,
  ) = __$$DownloadJobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String remoteIdentifier,
    String fileName,
    PhotoAssetKind kind,
    int byteSize,
    DateTime captureDate,
    bool autoExportToPhotoLibrary,
    DownloadJobStatus status,
    int bytesTransferred,
    int totalBytes,
    int currentOffset,
    int resumedCount,
    DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime updatedAt,
    String? errorMessage,
  });
}

/// @nodoc
class __$$DownloadJobImplCopyWithImpl<$Res>
    extends _$DownloadJobCopyWithImpl<$Res, _$DownloadJobImpl>
    implements _$$DownloadJobImplCopyWith<$Res> {
  __$$DownloadJobImplCopyWithImpl(
    _$DownloadJobImpl _value,
    $Res Function(_$DownloadJobImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadJob
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
    Object? autoExportToPhotoLibrary = null,
    Object? status = null,
    Object? bytesTransferred = null,
    Object? totalBytes = null,
    Object? currentOffset = null,
    Object? resumedCount = null,
    Object? createdAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? updatedAt = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$DownloadJobImpl(
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
        autoExportToPhotoLibrary: null == autoExportToPhotoLibrary
            ? _value.autoExportToPhotoLibrary
            : autoExportToPhotoLibrary // ignore: cast_nullable_to_non_nullable
                  as bool,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as DownloadJobStatus,
        bytesTransferred: null == bytesTransferred
            ? _value.bytesTransferred
            : bytesTransferred // ignore: cast_nullable_to_non_nullable
                  as int,
        totalBytes: null == totalBytes
            ? _value.totalBytes
            : totalBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        currentOffset: null == currentOffset
            ? _value.currentOffset
            : currentOffset // ignore: cast_nullable_to_non_nullable
                  as int,
        resumedCount: null == resumedCount
            ? _value.resumedCount
            : resumedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$DownloadJobImpl extends _DownloadJob {
  const _$DownloadJobImpl({
    this.id = '',
    required this.remoteIdentifier,
    required this.fileName,
    required this.kind,
    this.byteSize = 0,
    required this.captureDate,
    this.autoExportToPhotoLibrary = false,
    this.status = DownloadJobStatus.queued,
    this.bytesTransferred = 0,
    this.totalBytes = 0,
    this.currentOffset = 0,
    this.resumedCount = 0,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    required this.updatedAt,
    this.errorMessage,
  }) : super._();

  /// 唯一标识 (Phase 0 用空字符串占位)
  @override
  @JsonKey()
  final String id;

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
  @JsonKey()
  final bool autoExportToPhotoLibrary;
  @override
  @JsonKey()
  final DownloadJobStatus status;
  @override
  @JsonKey()
  final int bytesTransferred;
  @override
  @JsonKey()
  final int totalBytes;

  /// 当前已下载偏移 (用于续传)
  @override
  @JsonKey()
  final int currentOffset;

  /// 续传次数
  @override
  @JsonKey()
  final int resumedCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final DateTime updatedAt;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'DownloadJob(id: $id, remoteIdentifier: $remoteIdentifier, fileName: $fileName, kind: $kind, byteSize: $byteSize, captureDate: $captureDate, autoExportToPhotoLibrary: $autoExportToPhotoLibrary, status: $status, bytesTransferred: $bytesTransferred, totalBytes: $totalBytes, currentOffset: $currentOffset, resumedCount: $resumedCount, createdAt: $createdAt, startedAt: $startedAt, completedAt: $completedAt, updatedAt: $updatedAt, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadJobImpl &&
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
            (identical(
                  other.autoExportToPhotoLibrary,
                  autoExportToPhotoLibrary,
                ) ||
                other.autoExportToPhotoLibrary == autoExportToPhotoLibrary) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.bytesTransferred, bytesTransferred) ||
                other.bytesTransferred == bytesTransferred) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes) &&
            (identical(other.currentOffset, currentOffset) ||
                other.currentOffset == currentOffset) &&
            (identical(other.resumedCount, resumedCount) ||
                other.resumedCount == resumedCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
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
    autoExportToPhotoLibrary,
    status,
    bytesTransferred,
    totalBytes,
    currentOffset,
    resumedCount,
    createdAt,
    startedAt,
    completedAt,
    updatedAt,
    errorMessage,
  );

  /// Create a copy of DownloadJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadJobImplCopyWith<_$DownloadJobImpl> get copyWith =>
      __$$DownloadJobImplCopyWithImpl<_$DownloadJobImpl>(this, _$identity);
}

abstract class _DownloadJob extends DownloadJob {
  const factory _DownloadJob({
    final String id,
    required final String remoteIdentifier,
    required final String fileName,
    required final PhotoAssetKind kind,
    final int byteSize,
    required final DateTime captureDate,
    final bool autoExportToPhotoLibrary,
    final DownloadJobStatus status,
    final int bytesTransferred,
    final int totalBytes,
    final int currentOffset,
    final int resumedCount,
    required final DateTime createdAt,
    final DateTime? startedAt,
    final DateTime? completedAt,
    required final DateTime updatedAt,
    final String? errorMessage,
  }) = _$DownloadJobImpl;
  const _DownloadJob._() : super._();

  /// 唯一标识 (Phase 0 用空字符串占位)
  @override
  String get id;

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
  bool get autoExportToPhotoLibrary;
  @override
  DownloadJobStatus get status;
  @override
  int get bytesTransferred;
  @override
  int get totalBytes;

  /// 当前已下载偏移 (用于续传)
  @override
  int get currentOffset;

  /// 续传次数
  @override
  int get resumedCount;
  @override
  DateTime get createdAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  DateTime get updatedAt;
  @override
  String? get errorMessage;

  /// Create a copy of DownloadJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadJobImplCopyWith<_$DownloadJobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
