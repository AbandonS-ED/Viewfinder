// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gallery_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GalleryState {
  List<PhotoAsset> get photoAssets => throw _privateConstructorUsedError;
  bool get hasMorePhotos => throw _privateConstructorUsedError;
  Set<String> get selectedAssetIDs => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;

  /// Create a copy of GalleryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GalleryStateCopyWith<GalleryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GalleryStateCopyWith<$Res> {
  factory $GalleryStateCopyWith(
    GalleryState value,
    $Res Function(GalleryState) then,
  ) = _$GalleryStateCopyWithImpl<$Res, GalleryState>;
  @useResult
  $Res call({
    List<PhotoAsset> photoAssets,
    bool hasMorePhotos,
    Set<String> selectedAssetIDs,
    bool isLoading,
  });
}

/// @nodoc
class _$GalleryStateCopyWithImpl<$Res, $Val extends GalleryState>
    implements $GalleryStateCopyWith<$Res> {
  _$GalleryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GalleryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoAssets = null,
    Object? hasMorePhotos = null,
    Object? selectedAssetIDs = null,
    Object? isLoading = null,
  }) {
    return _then(
      _value.copyWith(
            photoAssets: null == photoAssets
                ? _value.photoAssets
                : photoAssets // ignore: cast_nullable_to_non_nullable
                      as List<PhotoAsset>,
            hasMorePhotos: null == hasMorePhotos
                ? _value.hasMorePhotos
                : hasMorePhotos // ignore: cast_nullable_to_non_nullable
                      as bool,
            selectedAssetIDs: null == selectedAssetIDs
                ? _value.selectedAssetIDs
                : selectedAssetIDs // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GalleryStateImplCopyWith<$Res>
    implements $GalleryStateCopyWith<$Res> {
  factory _$$GalleryStateImplCopyWith(
    _$GalleryStateImpl value,
    $Res Function(_$GalleryStateImpl) then,
  ) = __$$GalleryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<PhotoAsset> photoAssets,
    bool hasMorePhotos,
    Set<String> selectedAssetIDs,
    bool isLoading,
  });
}

/// @nodoc
class __$$GalleryStateImplCopyWithImpl<$Res>
    extends _$GalleryStateCopyWithImpl<$Res, _$GalleryStateImpl>
    implements _$$GalleryStateImplCopyWith<$Res> {
  __$$GalleryStateImplCopyWithImpl(
    _$GalleryStateImpl _value,
    $Res Function(_$GalleryStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GalleryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoAssets = null,
    Object? hasMorePhotos = null,
    Object? selectedAssetIDs = null,
    Object? isLoading = null,
  }) {
    return _then(
      _$GalleryStateImpl(
        photoAssets: null == photoAssets
            ? _value._photoAssets
            : photoAssets // ignore: cast_nullable_to_non_nullable
                  as List<PhotoAsset>,
        hasMorePhotos: null == hasMorePhotos
            ? _value.hasMorePhotos
            : hasMorePhotos // ignore: cast_nullable_to_non_nullable
                  as bool,
        selectedAssetIDs: null == selectedAssetIDs
            ? _value._selectedAssetIDs
            : selectedAssetIDs // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$GalleryStateImpl extends _GalleryState {
  const _$GalleryStateImpl({
    final List<PhotoAsset> photoAssets = const <PhotoAsset>[],
    this.hasMorePhotos = false,
    final Set<String> selectedAssetIDs = const <String>{},
    this.isLoading = false,
  }) : _photoAssets = photoAssets,
       _selectedAssetIDs = selectedAssetIDs,
       super._();

  final List<PhotoAsset> _photoAssets;
  @override
  @JsonKey()
  List<PhotoAsset> get photoAssets {
    if (_photoAssets is EqualUnmodifiableListView) return _photoAssets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoAssets);
  }

  @override
  @JsonKey()
  final bool hasMorePhotos;
  final Set<String> _selectedAssetIDs;
  @override
  @JsonKey()
  Set<String> get selectedAssetIDs {
    if (_selectedAssetIDs is EqualUnmodifiableSetView) return _selectedAssetIDs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedAssetIDs);
  }

  @override
  @JsonKey()
  final bool isLoading;

  @override
  String toString() {
    return 'GalleryState(photoAssets: $photoAssets, hasMorePhotos: $hasMorePhotos, selectedAssetIDs: $selectedAssetIDs, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GalleryStateImpl &&
            const DeepCollectionEquality().equals(
              other._photoAssets,
              _photoAssets,
            ) &&
            (identical(other.hasMorePhotos, hasMorePhotos) ||
                other.hasMorePhotos == hasMorePhotos) &&
            const DeepCollectionEquality().equals(
              other._selectedAssetIDs,
              _selectedAssetIDs,
            ) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_photoAssets),
    hasMorePhotos,
    const DeepCollectionEquality().hash(_selectedAssetIDs),
    isLoading,
  );

  /// Create a copy of GalleryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GalleryStateImplCopyWith<_$GalleryStateImpl> get copyWith =>
      __$$GalleryStateImplCopyWithImpl<_$GalleryStateImpl>(this, _$identity);
}

abstract class _GalleryState extends GalleryState {
  const factory _GalleryState({
    final List<PhotoAsset> photoAssets,
    final bool hasMorePhotos,
    final Set<String> selectedAssetIDs,
    final bool isLoading,
  }) = _$GalleryStateImpl;
  const _GalleryState._() : super._();

  @override
  List<PhotoAsset> get photoAssets;
  @override
  bool get hasMorePhotos;
  @override
  Set<String> get selectedAssetIDs;
  @override
  bool get isLoading;

  /// Create a copy of GalleryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GalleryStateImplCopyWith<_$GalleryStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
