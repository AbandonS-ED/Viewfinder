// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_shell_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AppShellState {
  List<LogEntry> get activityLog => throw _privateConstructorUsedError;
  AlertContext? get alertContext => throw _privateConstructorUsedError;
  String? get globalActivityTitle => throw _privateConstructorUsedError;

  /// Create a copy of AppShellState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppShellStateCopyWith<AppShellState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppShellStateCopyWith<$Res> {
  factory $AppShellStateCopyWith(
    AppShellState value,
    $Res Function(AppShellState) then,
  ) = _$AppShellStateCopyWithImpl<$Res, AppShellState>;
  @useResult
  $Res call({
    List<LogEntry> activityLog,
    AlertContext? alertContext,
    String? globalActivityTitle,
  });

  $AlertContextCopyWith<$Res>? get alertContext;
}

/// @nodoc
class _$AppShellStateCopyWithImpl<$Res, $Val extends AppShellState>
    implements $AppShellStateCopyWith<$Res> {
  _$AppShellStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppShellState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activityLog = null,
    Object? alertContext = freezed,
    Object? globalActivityTitle = freezed,
  }) {
    return _then(
      _value.copyWith(
            activityLog: null == activityLog
                ? _value.activityLog
                : activityLog // ignore: cast_nullable_to_non_nullable
                      as List<LogEntry>,
            alertContext: freezed == alertContext
                ? _value.alertContext
                : alertContext // ignore: cast_nullable_to_non_nullable
                      as AlertContext?,
            globalActivityTitle: freezed == globalActivityTitle
                ? _value.globalActivityTitle
                : globalActivityTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of AppShellState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AlertContextCopyWith<$Res>? get alertContext {
    if (_value.alertContext == null) {
      return null;
    }

    return $AlertContextCopyWith<$Res>(_value.alertContext!, (value) {
      return _then(_value.copyWith(alertContext: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppShellStateImplCopyWith<$Res>
    implements $AppShellStateCopyWith<$Res> {
  factory _$$AppShellStateImplCopyWith(
    _$AppShellStateImpl value,
    $Res Function(_$AppShellStateImpl) then,
  ) = __$$AppShellStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<LogEntry> activityLog,
    AlertContext? alertContext,
    String? globalActivityTitle,
  });

  @override
  $AlertContextCopyWith<$Res>? get alertContext;
}

/// @nodoc
class __$$AppShellStateImplCopyWithImpl<$Res>
    extends _$AppShellStateCopyWithImpl<$Res, _$AppShellStateImpl>
    implements _$$AppShellStateImplCopyWith<$Res> {
  __$$AppShellStateImplCopyWithImpl(
    _$AppShellStateImpl _value,
    $Res Function(_$AppShellStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppShellState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activityLog = null,
    Object? alertContext = freezed,
    Object? globalActivityTitle = freezed,
  }) {
    return _then(
      _$AppShellStateImpl(
        activityLog: null == activityLog
            ? _value._activityLog
            : activityLog // ignore: cast_nullable_to_non_nullable
                  as List<LogEntry>,
        alertContext: freezed == alertContext
            ? _value.alertContext
            : alertContext // ignore: cast_nullable_to_non_nullable
                  as AlertContext?,
        globalActivityTitle: freezed == globalActivityTitle
            ? _value.globalActivityTitle
            : globalActivityTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$AppShellStateImpl extends _AppShellState {
  const _$AppShellStateImpl({
    final List<LogEntry> activityLog = const <LogEntry>[],
    this.alertContext,
    this.globalActivityTitle,
  }) : _activityLog = activityLog,
       super._();

  final List<LogEntry> _activityLog;
  @override
  @JsonKey()
  List<LogEntry> get activityLog {
    if (_activityLog is EqualUnmodifiableListView) return _activityLog;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activityLog);
  }

  @override
  final AlertContext? alertContext;
  @override
  final String? globalActivityTitle;

  @override
  String toString() {
    return 'AppShellState(activityLog: $activityLog, alertContext: $alertContext, globalActivityTitle: $globalActivityTitle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppShellStateImpl &&
            const DeepCollectionEquality().equals(
              other._activityLog,
              _activityLog,
            ) &&
            (identical(other.alertContext, alertContext) ||
                other.alertContext == alertContext) &&
            (identical(other.globalActivityTitle, globalActivityTitle) ||
                other.globalActivityTitle == globalActivityTitle));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_activityLog),
    alertContext,
    globalActivityTitle,
  );

  /// Create a copy of AppShellState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppShellStateImplCopyWith<_$AppShellStateImpl> get copyWith =>
      __$$AppShellStateImplCopyWithImpl<_$AppShellStateImpl>(this, _$identity);
}

abstract class _AppShellState extends AppShellState {
  const factory _AppShellState({
    final List<LogEntry> activityLog,
    final AlertContext? alertContext,
    final String? globalActivityTitle,
  }) = _$AppShellStateImpl;
  const _AppShellState._() : super._();

  @override
  List<LogEntry> get activityLog;
  @override
  AlertContext? get alertContext;
  @override
  String? get globalActivityTitle;

  /// Create a copy of AppShellState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppShellStateImplCopyWith<_$AppShellStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
