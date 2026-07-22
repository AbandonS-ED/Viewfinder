// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_queue_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DownloadQueueState {
  List<DownloadJob> get jobs => throw _privateConstructorUsedError;
  String? get activeJobID => throw _privateConstructorUsedError;
  DownloadQueueStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of DownloadQueueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadQueueStateCopyWith<DownloadQueueState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadQueueStateCopyWith<$Res> {
  factory $DownloadQueueStateCopyWith(
    DownloadQueueState value,
    $Res Function(DownloadQueueState) then,
  ) = _$DownloadQueueStateCopyWithImpl<$Res, DownloadQueueState>;
  @useResult
  $Res call({
    List<DownloadJob> jobs,
    String? activeJobID,
    DownloadQueueStatus status,
  });
}

/// @nodoc
class _$DownloadQueueStateCopyWithImpl<$Res, $Val extends DownloadQueueState>
    implements $DownloadQueueStateCopyWith<$Res> {
  _$DownloadQueueStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadQueueState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobs = null,
    Object? activeJobID = freezed,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            jobs: null == jobs
                ? _value.jobs
                : jobs // ignore: cast_nullable_to_non_nullable
                      as List<DownloadJob>,
            activeJobID: freezed == activeJobID
                ? _value.activeJobID
                : activeJobID // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as DownloadQueueStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DownloadQueueStateImplCopyWith<$Res>
    implements $DownloadQueueStateCopyWith<$Res> {
  factory _$$DownloadQueueStateImplCopyWith(
    _$DownloadQueueStateImpl value,
    $Res Function(_$DownloadQueueStateImpl) then,
  ) = __$$DownloadQueueStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<DownloadJob> jobs,
    String? activeJobID,
    DownloadQueueStatus status,
  });
}

/// @nodoc
class __$$DownloadQueueStateImplCopyWithImpl<$Res>
    extends _$DownloadQueueStateCopyWithImpl<$Res, _$DownloadQueueStateImpl>
    implements _$$DownloadQueueStateImplCopyWith<$Res> {
  __$$DownloadQueueStateImplCopyWithImpl(
    _$DownloadQueueStateImpl _value,
    $Res Function(_$DownloadQueueStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadQueueState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobs = null,
    Object? activeJobID = freezed,
    Object? status = null,
  }) {
    return _then(
      _$DownloadQueueStateImpl(
        jobs: null == jobs
            ? _value._jobs
            : jobs // ignore: cast_nullable_to_non_nullable
                  as List<DownloadJob>,
        activeJobID: freezed == activeJobID
            ? _value.activeJobID
            : activeJobID // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as DownloadQueueStatus,
      ),
    );
  }
}

/// @nodoc

class _$DownloadQueueStateImpl extends _DownloadQueueState {
  const _$DownloadQueueStateImpl({
    final List<DownloadJob> jobs = const <DownloadJob>[],
    this.activeJobID,
    this.status = DownloadQueueStatus.idle,
  }) : _jobs = jobs,
       super._();

  final List<DownloadJob> _jobs;
  @override
  @JsonKey()
  List<DownloadJob> get jobs {
    if (_jobs is EqualUnmodifiableListView) return _jobs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_jobs);
  }

  @override
  final String? activeJobID;
  @override
  @JsonKey()
  final DownloadQueueStatus status;

  @override
  String toString() {
    return 'DownloadQueueState(jobs: $jobs, activeJobID: $activeJobID, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadQueueStateImpl &&
            const DeepCollectionEquality().equals(other._jobs, _jobs) &&
            (identical(other.activeJobID, activeJobID) ||
                other.activeJobID == activeJobID) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_jobs),
    activeJobID,
    status,
  );

  /// Create a copy of DownloadQueueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadQueueStateImplCopyWith<_$DownloadQueueStateImpl> get copyWith =>
      __$$DownloadQueueStateImplCopyWithImpl<_$DownloadQueueStateImpl>(
        this,
        _$identity,
      );
}

abstract class _DownloadQueueState extends DownloadQueueState {
  const factory _DownloadQueueState({
    final List<DownloadJob> jobs,
    final String? activeJobID,
    final DownloadQueueStatus status,
  }) = _$DownloadQueueStateImpl;
  const _DownloadQueueState._() : super._();

  @override
  List<DownloadJob> get jobs;
  @override
  String? get activeJobID;
  @override
  DownloadQueueStatus get status;

  /// Create a copy of DownloadQueueState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadQueueStateImplCopyWith<_$DownloadQueueStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
