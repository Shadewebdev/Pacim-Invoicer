// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_numbering_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentNumberingRule {

 String get pattern; bool get resetsYearly;
/// Create a copy of DocumentNumberingRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentNumberingRuleCopyWith<DocumentNumberingRule> get copyWith => _$DocumentNumberingRuleCopyWithImpl<DocumentNumberingRule>(this as DocumentNumberingRule, _$identity);

  /// Serializes this DocumentNumberingRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DocumentNumberingRule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentNumberingRule&&(identical(other.pattern, _this.pattern) || other.pattern == _this.pattern)&&(identical(other.resetsYearly, _this.resetsYearly) || other.resetsYearly == _this.resetsYearly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DocumentNumberingRule;
  return Object.hash(runtimeType,_this.pattern,_this.resetsYearly);
}

@override
String toString() {
  final _this = this as DocumentNumberingRule;
  return 'DocumentNumberingRule(pattern: ${_this.pattern}, resetsYearly: ${_this.resetsYearly})';
}


}

/// @nodoc
abstract mixin class $DocumentNumberingRuleCopyWith<$Res>  {
  factory $DocumentNumberingRuleCopyWith(DocumentNumberingRule value, $Res Function(DocumentNumberingRule) _then) = _$DocumentNumberingRuleCopyWithImpl;
@useResult
$Res call({
 String pattern, bool resetsYearly
});




}
/// @nodoc
class _$DocumentNumberingRuleCopyWithImpl<$Res>
    implements $DocumentNumberingRuleCopyWith<$Res> {
  _$DocumentNumberingRuleCopyWithImpl(this._self, this._then);

  final DocumentNumberingRule _self;
  final $Res Function(DocumentNumberingRule) _then;

/// Create a copy of DocumentNumberingRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pattern = null,Object? resetsYearly = null,}) {
  return _then(DocumentNumberingRule(
pattern: null == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String,resetsYearly: null == resetsYearly ? _self.resetsYearly : resetsYearly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentNumberingRule].
extension DocumentNumberingRulePatterns on DocumentNumberingRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentNumberingRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentNumberingRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentNumberingRule value)  $default,){
final _that = this;
switch (_that) {
case _DocumentNumberingRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentNumberingRule value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentNumberingRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String pattern,  bool resetsYearly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentNumberingRule() when $default != null:
return $default(_that.pattern,_that.resetsYearly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String pattern,  bool resetsYearly)  $default,) {final _that = this;
switch (_that) {
case _DocumentNumberingRule():
return $default(_that.pattern,_that.resetsYearly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String pattern,  bool resetsYearly)?  $default,) {final _that = this;
switch (_that) {
case _DocumentNumberingRule() when $default != null:
return $default(_that.pattern,_that.resetsYearly);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentNumberingRule implements DocumentNumberingRule {
  const _DocumentNumberingRule({required this.pattern, this.resetsYearly = false});
  factory _DocumentNumberingRule.fromJson(Map<String, dynamic> json) => _$DocumentNumberingRuleFromJson(json);

@override final  String pattern;
@override@JsonKey() final  bool resetsYearly;

/// Create a copy of DocumentNumberingRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentNumberingRuleCopyWith<_DocumentNumberingRule> get copyWith => __$DocumentNumberingRuleCopyWithImpl<_DocumentNumberingRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentNumberingRuleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentNumberingRule&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.resetsYearly, resetsYearly) || other.resetsYearly == resetsYearly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,pattern,resetsYearly);
}

@override
String toString() {
    return 'DocumentNumberingRule(pattern: $pattern, resetsYearly: $resetsYearly)';
}


}

/// @nodoc
abstract mixin class _$DocumentNumberingRuleCopyWith<$Res> implements $DocumentNumberingRuleCopyWith<$Res> {
  factory _$DocumentNumberingRuleCopyWith(_DocumentNumberingRule value, $Res Function(_DocumentNumberingRule) _then) = __$DocumentNumberingRuleCopyWithImpl;
@override @useResult
$Res call({
 String pattern, bool resetsYearly
});




}
/// @nodoc
class __$DocumentNumberingRuleCopyWithImpl<$Res>
    implements _$DocumentNumberingRuleCopyWith<$Res> {
  __$DocumentNumberingRuleCopyWithImpl(this._self, this._then);

  final _DocumentNumberingRule _self;
  final $Res Function(_DocumentNumberingRule) _then;

/// Create a copy of DocumentNumberingRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pattern = null,Object? resetsYearly = null,}) {
  return _then(_DocumentNumberingRule(
pattern: null == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String,resetsYearly: null == resetsYearly ? _self.resetsYearly : resetsYearly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
