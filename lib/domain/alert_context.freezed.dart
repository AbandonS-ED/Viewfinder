// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AlertContext {
  String get title => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  AlertSeverity get severity => throw _privateConstructorUsedError;

  /// Create a copy of AlertContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlertContextCopyWith<AlertContext> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlertContextCopyWith<$Res> {
  factory $AlertContextCopyWith(
    AlertContext value,
    $Res Function(AlertContext) then,
  ) = _$AlertContextCopyWithImpl<$Res, AlertContext>;
  @useResult
  $Res call({String title, String message, AlertSeverity severity});
}

/// @nodoc
class _$AlertContextCopyWithImpl<$Res, $Val extends AlertContext>
    implements $AlertContextCopyWith<$Res> {
  _$AlertContextCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AlertContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? message = null,
    Object? severity = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as AlertSeverity,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AlertContextImplCopyWith<$Res>
    implements $AlertContextCopyWith<$Res> {
  factory _$$AlertContextImplCopyWith(
    _$AlertContextImpl value,
    $Res Function(_$AlertContextImpl) then,
  ) = __$$AlertContextImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, String message, AlertSeverity severity});
}

/// @nodoc
class __$$AlertContextImplCopyWithImpl<$Res>
    extends _$AlertContextCopyWithImpl<$Res, _$AlertContextImpl>
    implements _$$AlertContextImplCopyWith<$Res> {
  __$$AlertContextImplCopyWithImpl(
    _$AlertContextImpl _value,
    $Res Function(_$AlertContextImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AlertContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? message = null,
    Object? severity = null,
  }) {
    return _then(
      _$AlertContextImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as AlertSeverity,
      ),
    );
  }
}

/// @nodoc

class _$AlertContextImpl implements _AlertContext {
  const _$AlertContextImpl({
    required this.title,
    required this.message,
    this.severity = AlertSeverity.info,
  });

  @override
  final String title;
  @override
  final String message;
  @override
  @JsonKey()
  final AlertSeverity severity;

  @override
  String toString() {
    return 'AlertContext(title: $title, message: $message, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlertContextImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.severity, severity) ||
                other.severity == severity));
  }

  @override
  int get hashCode => Object.hash(runtimeType, title, message, severity);

  /// Create a copy of AlertContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlertContextImplCopyWith<_$AlertContextImpl> get copyWith =>
      __$$AlertContextImplCopyWithImpl<_$AlertContextImpl>(this, _$identity);
}

abstract class _AlertContext implements AlertContext {
  const factory _AlertContext({
    required final String title,
    required final String message,
    final AlertSeverity severity,
  }) = _$AlertContextImpl;

  @override
  String get title;
  @override
  String get message;
  @override
  AlertSeverity get severity;

  /// Create a copy of AlertContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlertContextImplCopyWith<_$AlertContextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
