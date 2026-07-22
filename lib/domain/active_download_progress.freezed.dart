// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'active_download_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ActiveDownloadProgress {
  String get fileName => throw _privateConstructorUsedError;
  int get currentItemNumber => throw _privateConstructorUsedError;
  int get totalItemCount => throw _privateConstructorUsedError;
  int get bytesTransferred => throw _privateConstructorUsedError;
  int get totalBytes => throw _privateConstructorUsedError;

  /// 续传次数
  int get resumedCount => throw _privateConstructorUsedError;

  /// 当前已下载偏移
  int get currentOffset => throw _privateConstructorUsedError;

  /// 分块大小
  int get chunkSize => throw _privateConstructorUsedError;

  /// Create a copy of ActiveDownloadProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActiveDownloadProgressCopyWith<ActiveDownloadProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActiveDownloadProgressCopyWith<$Res> {
  factory $ActiveDownloadProgressCopyWith(
    ActiveDownloadProgress value,
    $Res Function(ActiveDownloadProgress) then,
  ) = _$ActiveDownloadProgressCopyWithImpl<$Res, ActiveDownloadProgress>;
  @useResult
  $Res call({
    String fileName,
    int currentItemNumber,
    int totalItemCount,
    int bytesTransferred,
    int totalBytes,
    int resumedCount,
    int currentOffset,
    int chunkSize,
  });
}

/// @nodoc
class _$ActiveDownloadProgressCopyWithImpl<
  $Res,
  $Val extends ActiveDownloadProgress
>
    implements $ActiveDownloadProgressCopyWith<$Res> {
  _$ActiveDownloadProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActiveDownloadProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? currentItemNumber = null,
    Object? totalItemCount = null,
    Object? bytesTransferred = null,
    Object? totalBytes = null,
    Object? resumedCount = null,
    Object? currentOffset = null,
    Object? chunkSize = null,
  }) {
    return _then(
      _value.copyWith(
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            currentItemNumber: null == currentItemNumber
                ? _value.currentItemNumber
                : currentItemNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            totalItemCount: null == totalItemCount
                ? _value.totalItemCount
                : totalItemCount // ignore: cast_nullable_to_non_nullable
                      as int,
            bytesTransferred: null == bytesTransferred
                ? _value.bytesTransferred
                : bytesTransferred // ignore: cast_nullable_to_non_nullable
                      as int,
            totalBytes: null == totalBytes
                ? _value.totalBytes
                : totalBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            resumedCount: null == resumedCount
                ? _value.resumedCount
                : resumedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            currentOffset: null == currentOffset
                ? _value.currentOffset
                : currentOffset // ignore: cast_nullable_to_non_nullable
                      as int,
            chunkSize: null == chunkSize
                ? _value.chunkSize
                : chunkSize // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActiveDownloadProgressImplCopyWith<$Res>
    implements $ActiveDownloadProgressCopyWith<$Res> {
  factory _$$ActiveDownloadProgressImplCopyWith(
    _$ActiveDownloadProgressImpl value,
    $Res Function(_$ActiveDownloadProgressImpl) then,
  ) = __$$ActiveDownloadProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String fileName,
    int currentItemNumber,
    int totalItemCount,
    int bytesTransferred,
    int totalBytes,
    int resumedCount,
    int currentOffset,
    int chunkSize,
  });
}

/// @nodoc
class __$$ActiveDownloadProgressImplCopyWithImpl<$Res>
    extends
        _$ActiveDownloadProgressCopyWithImpl<$Res, _$ActiveDownloadProgressImpl>
    implements _$$ActiveDownloadProgressImplCopyWith<$Res> {
  __$$ActiveDownloadProgressImplCopyWithImpl(
    _$ActiveDownloadProgressImpl _value,
    $Res Function(_$ActiveDownloadProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActiveDownloadProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? currentItemNumber = null,
    Object? totalItemCount = null,
    Object? bytesTransferred = null,
    Object? totalBytes = null,
    Object? resumedCount = null,
    Object? currentOffset = null,
    Object? chunkSize = null,
  }) {
    return _then(
      _$ActiveDownloadProgressImpl(
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        currentItemNumber: null == currentItemNumber
            ? _value.currentItemNumber
            : currentItemNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        totalItemCount: null == totalItemCount
            ? _value.totalItemCount
            : totalItemCount // ignore: cast_nullable_to_non_nullable
                  as int,
        bytesTransferred: null == bytesTransferred
            ? _value.bytesTransferred
            : bytesTransferred // ignore: cast_nullable_to_non_nullable
                  as int,
        totalBytes: null == totalBytes
            ? _value.totalBytes
            : totalBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        resumedCount: null == resumedCount
            ? _value.resumedCount
            : resumedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        currentOffset: null == currentOffset
            ? _value.currentOffset
            : currentOffset // ignore: cast_nullable_to_non_nullable
                  as int,
        chunkSize: null == chunkSize
            ? _value.chunkSize
            : chunkSize // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ActiveDownloadProgressImpl extends _ActiveDownloadProgress {
  const _$ActiveDownloadProgressImpl({
    required this.fileName,
    this.currentItemNumber = 0,
    this.totalItemCount = 0,
    this.bytesTransferred = 0,
    this.totalBytes = 0,
    this.resumedCount = 0,
    this.currentOffset = 0,
    this.chunkSize = 0,
  }) : super._();

  @override
  final String fileName;
  @override
  @JsonKey()
  final int currentItemNumber;
  @override
  @JsonKey()
  final int totalItemCount;
  @override
  @JsonKey()
  final int bytesTransferred;
  @override
  @JsonKey()
  final int totalBytes;

  /// 续传次数
  @override
  @JsonKey()
  final int resumedCount;

  /// 当前已下载偏移
  @override
  @JsonKey()
  final int currentOffset;

  /// 分块大小
  @override
  @JsonKey()
  final int chunkSize;

  @override
  String toString() {
    return 'ActiveDownloadProgress(fileName: $fileName, currentItemNumber: $currentItemNumber, totalItemCount: $totalItemCount, bytesTransferred: $bytesTransferred, totalBytes: $totalBytes, resumedCount: $resumedCount, currentOffset: $currentOffset, chunkSize: $chunkSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActiveDownloadProgressImpl &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.currentItemNumber, currentItemNumber) ||
                other.currentItemNumber == currentItemNumber) &&
            (identical(other.totalItemCount, totalItemCount) ||
                other.totalItemCount == totalItemCount) &&
            (identical(other.bytesTransferred, bytesTransferred) ||
                other.bytesTransferred == bytesTransferred) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes) &&
            (identical(other.resumedCount, resumedCount) ||
                other.resumedCount == resumedCount) &&
            (identical(other.currentOffset, currentOffset) ||
                other.currentOffset == currentOffset) &&
            (identical(other.chunkSize, chunkSize) ||
                other.chunkSize == chunkSize));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    fileName,
    currentItemNumber,
    totalItemCount,
    bytesTransferred,
    totalBytes,
    resumedCount,
    currentOffset,
    chunkSize,
  );

  /// Create a copy of ActiveDownloadProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActiveDownloadProgressImplCopyWith<_$ActiveDownloadProgressImpl>
  get copyWith =>
      __$$ActiveDownloadProgressImplCopyWithImpl<_$ActiveDownloadProgressImpl>(
        this,
        _$identity,
      );
}

abstract class _ActiveDownloadProgress extends ActiveDownloadProgress {
  const factory _ActiveDownloadProgress({
    required final String fileName,
    final int currentItemNumber,
    final int totalItemCount,
    final int bytesTransferred,
    final int totalBytes,
    final int resumedCount,
    final int currentOffset,
    final int chunkSize,
  }) = _$ActiveDownloadProgressImpl;
  const _ActiveDownloadProgress._() : super._();

  @override
  String get fileName;
  @override
  int get currentItemNumber;
  @override
  int get totalItemCount;
  @override
  int get bytesTransferred;
  @override
  int get totalBytes;

  /// 续传次数
  @override
  int get resumedCount;

  /// 当前已下载偏移
  @override
  int get currentOffset;

  /// 分块大小
  @override
  int get chunkSize;

  /// Create a copy of ActiveDownloadProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActiveDownloadProgressImplCopyWith<_$ActiveDownloadProgressImpl>
  get copyWith => throw _privateConstructorUsedError;
}
