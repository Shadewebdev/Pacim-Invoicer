// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'validation_issue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ValidationIssue {

 ValidationIssueKind get kind; String? get lineItemId;
/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationIssueCopyWith<ValidationIssue> get copyWith => _$ValidationIssueCopyWithImpl<ValidationIssue>(this as ValidationIssue, _$identity);

  /// Serializes this ValidationIssue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ValidationIssue;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationIssue&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.lineItemId, _this.lineItemId) || other.lineItemId == _this.lineItemId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ValidationIssue;
  return Object.hash(runtimeType,_this.kind,_this.lineItemId);
}

@override
String toString() {
  final _this = this as ValidationIssue;
  return 'ValidationIssue(kind: ${_this.kind}, lineItemId: ${_this.lineItemId})';
}


}

/// @nodoc
abstract mixin class $ValidationIssueCopyWith<$Res>  {
  factory $ValidationIssueCopyWith(ValidationIssue value, $Res Function(ValidationIssue) _then) = _$ValidationIssueCopyWithImpl;
@useResult
$Res call({
 ValidationIssueKind kind, String? lineItemId
});




}
/// @nodoc
class _$ValidationIssueCopyWithImpl<$Res>
    implements $ValidationIssueCopyWith<$Res> {
  _$ValidationIssueCopyWithImpl(this._self, this._then);

  final ValidationIssue _self;
  final $Res Function(ValidationIssue) _then;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? lineItemId = freezed,}) {
  return _then(ValidationIssue(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ValidationIssueKind,lineItemId: freezed == lineItemId ? _self.lineItemId : lineItemId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ValidationIssue].
extension ValidationIssuePatterns on ValidationIssue {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ValidationIssue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ValidationIssue() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ValidationIssue value)  $default,){
final _that = this;
switch (_that) {
case _ValidationIssue():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ValidationIssue value)?  $default,){
final _that = this;
switch (_that) {
case _ValidationIssue() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ValidationIssueKind kind,  String? lineItemId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ValidationIssue() when $default != null:
return $default(_that.kind,_that.lineItemId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ValidationIssueKind kind,  String? lineItemId)  $default,) {final _that = this;
switch (_that) {
case _ValidationIssue():
return $default(_that.kind,_that.lineItemId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ValidationIssueKind kind,  String? lineItemId)?  $default,) {final _that = this;
switch (_that) {
case _ValidationIssue() when $default != null:
return $default(_that.kind,_that.lineItemId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ValidationIssue extends ValidationIssue {
  const _ValidationIssue({required this.kind, this.lineItemId}): super._();
  factory _ValidationIssue.fromJson(Map<String, dynamic> json) => _$ValidationIssueFromJson(json);

@override final  ValidationIssueKind kind;
@override final  String? lineItemId;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidationIssueCopyWith<_ValidationIssue> get copyWith => __$ValidationIssueCopyWithImpl<_ValidationIssue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ValidationIssueToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ValidationIssue&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.lineItemId, lineItemId) || other.lineItemId == lineItemId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,kind,lineItemId);
}

@override
String toString() {
    return 'ValidationIssue(kind: $kind, lineItemId: $lineItemId)';
}


}

/// @nodoc
abstract mixin class _$ValidationIssueCopyWith<$Res> implements $ValidationIssueCopyWith<$Res> {
  factory _$ValidationIssueCopyWith(_ValidationIssue value, $Res Function(_ValidationIssue) _then) = __$ValidationIssueCopyWithImpl;
@override @useResult
$Res call({
 ValidationIssueKind kind, String? lineItemId
});




}
/// @nodoc
class __$ValidationIssueCopyWithImpl<$Res>
    implements _$ValidationIssueCopyWith<$Res> {
  __$ValidationIssueCopyWithImpl(this._self, this._then);

  final _ValidationIssue _self;
  final $Res Function(_ValidationIssue) _then;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? lineItemId = freezed,}) {
  return _then(_ValidationIssue(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ValidationIssueKind,lineItemId: freezed == lineItemId ? _self.lineItemId : lineItemId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
