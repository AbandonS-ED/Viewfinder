// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_transport.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DownloadTransferProgress {
  int get bytesTransferred => throw _privateConstructorUsedError;
  int get totalBytes => throw _privateConstructorUsedError;
  int get resumedCount => throw _privateConstructorUsedError;
  int get currentOffset => throw _privateConstructorUsedError;
  int get chunkSize => throw _privateConstructorUsedError;

  /// Create a copy of DownloadTransferProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadTransferProgressCopyWith<DownloadTransferProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadTransferProgressCopyWith<$Res> {
  factory $DownloadTransferProgressCopyWith(
    DownloadTransferProgress value,
    $Res Function(DownloadTransferProgress) then,
  ) = _$DownloadTransferProgressCopyWithImpl<$Res, DownloadTransferProgress>;
  @useResult
  $Res call({
    int bytesTransferred,
    int totalBytes,
    int resumedCount,
    int currentOffset,
    int chunkSize,
  });
}

/// @nodoc
class _$DownloadTransferProgressCopyWithImpl<
  $Res,
  $Val extends DownloadTransferProgress
>
    implements $DownloadTransferProgressCopyWith<$Res> {
  _$DownloadTransferProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadTransferProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bytesTransferred = null,
    Object? totalBytes = null,
    Object? resumedCount = null,
    Object? currentOffset = null,
    Object? chunkSize = null,
  }) {
    return _then(
      _value.copyWith(
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
abstract class _$$DownloadTransferProgressImplCopyWith<$Res>
    implements $DownloadTransferProgressCopyWith<$Res> {
  factory _$$DownloadTransferProgressImplCopyWith(
    _$DownloadTransferProgressImpl value,
    $Res Function(_$DownloadTransferProgressImpl) then,
  ) = __$$DownloadTransferProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int bytesTransferred,
    int totalBytes,
    int resumedCount,
    int currentOffset,
    int chunkSize,
  });
}

/// @nodoc
class __$$DownloadTransferProgressImplCopyWithImpl<$Res>
    extends
        _$DownloadTransferProgressCopyWithImpl<
          $Res,
          _$DownloadTransferProgressImpl
        >
    implements _$$DownloadTransferProgressImplCopyWith<$Res> {
  __$$DownloadTransferProgressImplCopyWithImpl(
    _$DownloadTransferProgressImpl _value,
    $Res Function(_$DownloadTransferProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadTransferProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bytesTransferred = null,
    Object? totalBytes = null,
    Object? resumedCount = null,
    Object? currentOffset = null,
    Object? chunkSize = null,
  }) {
    return _then(
      _$DownloadTransferProgressImpl(
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

class _$DownloadTransferProgressImpl extends _DownloadTransferProgress {
  const _$DownloadTransferProgressImpl({
    this.bytesTransferred = 0,
    this.totalBytes = 0,
    this.resumedCount = 0,
    this.currentOffset = 0,
    this.chunkSize = 0,
  }) : super._();

  @override
  @JsonKey()
  final int bytesTransferred;
  @override
  @JsonKey()
  final int totalBytes;
  @override
  @JsonKey()
  final int resumedCount;
  @override
  @JsonKey()
  final int currentOffset;
  @override
  @JsonKey()
  final int chunkSize;

  @override
  String toString() {
    return 'DownloadTransferProgress(bytesTransferred: $bytesTransferred, totalBytes: $totalBytes, resumedCount: $resumedCount, currentOffset: $currentOffset, chunkSize: $chunkSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadTransferProgressImpl &&
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
    bytesTransferred,
    totalBytes,
    resumedCount,
    currentOffset,
    chunkSize,
  );

  /// Create a copy of DownloadTransferProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadTransferProgressImplCopyWith<_$DownloadTransferProgressImpl>
  get copyWith =>
      __$$DownloadTransferProgressImplCopyWithImpl<
        _$DownloadTransferProgressImpl
      >(this, _$identity);
}

abstract class _DownloadTransferProgress extends DownloadTransferProgress {
  const factory _DownloadTransferProgress({
    final int bytesTransferred,
    final int totalBytes,
    final int resumedCount,
    final int currentOffset,
    final int chunkSize,
  }) = _$DownloadTransferProgressImpl;
  const _DownloadTransferProgress._() : super._();

  @override
  int get bytesTransferred;
  @override
  int get totalBytes;
  @override
  int get resumedCount;
  @override
  int get currentOffset;
  @override
  int get chunkSize;

  /// Create a copy of DownloadTransferProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadTransferProgressImplCopyWith<_$DownloadTransferProgressImpl>
  get copyWith => throw _privateConstructorUsedError;
}
