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
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
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
    String remoteIdentifier,
    String fileName,
    PhotoAssetKind kind,
    int byteSize,
    DateTime captureDate,
    bool autoExportToPhotoLibrary,
    DownloadJobStatus status,
    int bytesTransferred,
    int totalBytes,
    DateTime? startedAt,
    DateTime? completedAt,
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
    Object? remoteIdentifier = null,
    Object? fileName = null,
    Object? kind = freezed,
    Object? byteSize = null,
    Object? captureDate = null,
    Object? autoExportToPhotoLibrary = null,
    Object? status = null,
    Object? bytesTransferred = null,
    Object? totalBytes = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? errorMessage = freezed,
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
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
    String remoteIdentifier,
    String fileName,
    PhotoAssetKind kind,
    int byteSize,
    DateTime captureDate,
    bool autoExportToPhotoLibrary,
    DownloadJobStatus status,
    int bytesTransferred,
    int totalBytes,
    DateTime? startedAt,
    DateTime? completedAt,
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
    Object? remoteIdentifier = null,
    Object? fileName = null,
    Object? kind = freezed,
    Object? byteSize = null,
    Object? captureDate = null,
    Object? autoExportToPhotoLibrary = null,
    Object? status = null,
    Object? bytesTransferred = null,
    Object? totalBytes = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$DownloadJobImpl(
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
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
    required this.remoteIdentifier,
    required this.fileName,
    required this.kind,
    this.byteSize = 0,
    required this.captureDate,
    this.autoExportToPhotoLibrary = false,
    this.status = DownloadJobStatus.queued,
    this.bytesTransferred = 0,
    this.totalBytes = 0,
    this.startedAt,
    this.completedAt,
    this.errorMessage,
  }) : super._();

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
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'DownloadJob(remoteIdentifier: $remoteIdentifier, fileName: $fileName, kind: $kind, byteSize: $byteSize, captureDate: $captureDate, autoExportToPhotoLibrary: $autoExportToPhotoLibrary, status: $status, bytesTransferred: $bytesTransferred, totalBytes: $totalBytes, startedAt: $startedAt, completedAt: $completedAt, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadJobImpl &&
            (identical(other.remoteIdentifier, remoteIdentifier) ||
                other.remoteIdentifier == remoteIdentifier) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            const DeepCollectionEquality().equals(other.kind, kind) &&
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
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    remoteIdentifier,
    fileName,
    const DeepCollectionEquality().hash(kind),
    byteSize,
    captureDate,
    autoExportToPhotoLibrary,
    status,
    bytesTransferred,
    totalBytes,
    startedAt,
    completedAt,
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
    required final String remoteIdentifier,
    required final String fileName,
    required final PhotoAssetKind kind,
    final int byteSize,
    required final DateTime captureDate,
    final bool autoExportToPhotoLibrary,
    final DownloadJobStatus status,
    final int bytesTransferred,
    final int totalBytes,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final String? errorMessage,
  }) = _$DownloadJobImpl;
  const _DownloadJob._() : super._();

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
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  String? get errorMessage;

  /// Create a copy of DownloadJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadJobImplCopyWith<_$DownloadJobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
