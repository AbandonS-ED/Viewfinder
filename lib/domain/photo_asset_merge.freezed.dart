// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_asset_merge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PhotoAssetMerge {
  /// 主照片 (一般 JPEG，因为小)
  PhotoAsset get primary => throw _privateConstructorUsedError;

  /// 配对照片 (一般 RAW)
  PhotoAsset? get paired => throw _privateConstructorUsedError;

  /// Create a copy of PhotoAssetMerge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoAssetMergeCopyWith<PhotoAssetMerge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoAssetMergeCopyWith<$Res> {
  factory $PhotoAssetMergeCopyWith(
    PhotoAssetMerge value,
    $Res Function(PhotoAssetMerge) then,
  ) = _$PhotoAssetMergeCopyWithImpl<$Res, PhotoAssetMerge>;
  @useResult
  $Res call({PhotoAsset primary, PhotoAsset? paired});
}

/// @nodoc
class _$PhotoAssetMergeCopyWithImpl<$Res, $Val extends PhotoAssetMerge>
    implements $PhotoAssetMergeCopyWith<$Res> {
  _$PhotoAssetMergeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoAssetMerge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? primary = freezed, Object? paired = freezed}) {
    return _then(
      _value.copyWith(
            primary: freezed == primary
                ? _value.primary
                : primary // ignore: cast_nullable_to_non_nullable
                      as PhotoAsset,
            paired: freezed == paired
                ? _value.paired
                : paired // ignore: cast_nullable_to_non_nullable
                      as PhotoAsset?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PhotoAssetMergeImplCopyWith<$Res>
    implements $PhotoAssetMergeCopyWith<$Res> {
  factory _$$PhotoAssetMergeImplCopyWith(
    _$PhotoAssetMergeImpl value,
    $Res Function(_$PhotoAssetMergeImpl) then,
  ) = __$$PhotoAssetMergeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PhotoAsset primary, PhotoAsset? paired});
}

/// @nodoc
class __$$PhotoAssetMergeImplCopyWithImpl<$Res>
    extends _$PhotoAssetMergeCopyWithImpl<$Res, _$PhotoAssetMergeImpl>
    implements _$$PhotoAssetMergeImplCopyWith<$Res> {
  __$$PhotoAssetMergeImplCopyWithImpl(
    _$PhotoAssetMergeImpl _value,
    $Res Function(_$PhotoAssetMergeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PhotoAssetMerge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? primary = freezed, Object? paired = freezed}) {
    return _then(
      _$PhotoAssetMergeImpl(
        primary: freezed == primary
            ? _value.primary
            : primary // ignore: cast_nullable_to_non_nullable
                  as PhotoAsset,
        paired: freezed == paired
            ? _value.paired
            : paired // ignore: cast_nullable_to_non_nullable
                  as PhotoAsset?,
      ),
    );
  }
}

/// @nodoc

class _$PhotoAssetMergeImpl implements _PhotoAssetMerge {
  const _$PhotoAssetMergeImpl({required this.primary, this.paired});

  /// 主照片 (一般 JPEG，因为小)
  @override
  final PhotoAsset primary;

  /// 配对照片 (一般 RAW)
  @override
  final PhotoAsset? paired;

  @override
  String toString() {
    return 'PhotoAssetMerge(primary: $primary, paired: $paired)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoAssetMergeImpl &&
            const DeepCollectionEquality().equals(other.primary, primary) &&
            const DeepCollectionEquality().equals(other.paired, paired));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(primary),
    const DeepCollectionEquality().hash(paired),
  );

  /// Create a copy of PhotoAssetMerge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoAssetMergeImplCopyWith<_$PhotoAssetMergeImpl> get copyWith =>
      __$$PhotoAssetMergeImplCopyWithImpl<_$PhotoAssetMergeImpl>(
        this,
        _$identity,
      );
}

abstract class _PhotoAssetMerge implements PhotoAssetMerge {
  const factory _PhotoAssetMerge({
    required final PhotoAsset primary,
    final PhotoAsset? paired,
  }) = _$PhotoAssetMergeImpl;

  /// 主照片 (一般 JPEG，因为小)
  @override
  PhotoAsset get primary;

  /// 配对照片 (一般 RAW)
  @override
  PhotoAsset? get paired;

  /// Create a copy of PhotoAssetMerge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoAssetMergeImplCopyWith<_$PhotoAssetMergeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
