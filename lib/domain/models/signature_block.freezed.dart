// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signature_block.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SignatureBlock {

 String get signatoryName; String get signatoryTitle; String? get signatureAssetId; String get signatureCaption;
/// Create a copy of SignatureBlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignatureBlockCopyWith<SignatureBlock> get copyWith => _$SignatureBlockCopyWithImpl<SignatureBlock>(this as SignatureBlock, _$identity);

  /// Serializes this SignatureBlock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SignatureBlock;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignatureBlock&&(identical(other.signatoryName, _this.signatoryName) || other.signatoryName == _this.signatoryName)&&(identical(other.signatoryTitle, _this.signatoryTitle) || other.signatoryTitle == _this.signatoryTitle)&&(identical(other.signatureAssetId, _this.signatureAssetId) || other.signatureAssetId == _this.signatureAssetId)&&(identical(other.signatureCaption, _this.signatureCaption) || other.signatureCaption == _this.signatureCaption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SignatureBlock;
  return Object.hash(runtimeType,_this.signatoryName,_this.signatoryTitle,_this.signatureAssetId,_this.signatureCaption);
}

@override
String toString() {
  final _this = this as SignatureBlock;
  return 'SignatureBlock(signatoryName: ${_this.signatoryName}, signatoryTitle: ${_this.signatoryTitle}, signatureAssetId: ${_this.signatureAssetId}, signatureCaption: ${_this.signatureCaption})';
}


}

/// @nodoc
abstract mixin class $SignatureBlockCopyWith<$Res>  {
  factory $SignatureBlockCopyWith(SignatureBlock value, $Res Function(SignatureBlock) _then) = _$SignatureBlockCopyWithImpl;
@useResult
$Res call({
 String signatoryName, String signatoryTitle, String? signatureAssetId, String signatureCaption
});




}
/// @nodoc
class _$SignatureBlockCopyWithImpl<$Res>
    implements $SignatureBlockCopyWith<$Res> {
  _$SignatureBlockCopyWithImpl(this._self, this._then);

  final SignatureBlock _self;
  final $Res Function(SignatureBlock) _then;

/// Create a copy of SignatureBlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? signatoryName = null,Object? signatoryTitle = null,Object? signatureAssetId = freezed,Object? signatureCaption = null,}) {
  return _then(SignatureBlock(
signatoryName: null == signatoryName ? _self.signatoryName : signatoryName // ignore: cast_nullable_to_non_nullable
as String,signatoryTitle: null == signatoryTitle ? _self.signatoryTitle : signatoryTitle // ignore: cast_nullable_to_non_nullable
as String,signatureAssetId: freezed == signatureAssetId ? _self.signatureAssetId : signatureAssetId // ignore: cast_nullable_to_non_nullable
as String?,signatureCaption: null == signatureCaption ? _self.signatureCaption : signatureCaption // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SignatureBlock].
extension SignatureBlockPatterns on SignatureBlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignatureBlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignatureBlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignatureBlock value)  $default,){
final _that = this;
switch (_that) {
case _SignatureBlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignatureBlock value)?  $default,){
final _that = this;
switch (_that) {
case _SignatureBlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String signatoryName,  String signatoryTitle,  String? signatureAssetId,  String signatureCaption)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignatureBlock() when $default != null:
return $default(_that.signatoryName,_that.signatoryTitle,_that.signatureAssetId,_that.signatureCaption);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String signatoryName,  String signatoryTitle,  String? signatureAssetId,  String signatureCaption)  $default,) {final _that = this;
switch (_that) {
case _SignatureBlock():
return $default(_that.signatoryName,_that.signatoryTitle,_that.signatureAssetId,_that.signatureCaption);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String signatoryName,  String signatoryTitle,  String? signatureAssetId,  String signatureCaption)?  $default,) {final _that = this;
switch (_that) {
case _SignatureBlock() when $default != null:
return $default(_that.signatoryName,_that.signatoryTitle,_that.signatureAssetId,_that.signatureCaption);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SignatureBlock implements SignatureBlock {
  const _SignatureBlock({this.signatoryName = '', this.signatoryTitle = '', this.signatureAssetId, this.signatureCaption = ''});
  factory _SignatureBlock.fromJson(Map<String, dynamic> json) => _$SignatureBlockFromJson(json);

@override@JsonKey() final  String signatoryName;
@override@JsonKey() final  String signatoryTitle;
@override final  String? signatureAssetId;
@override@JsonKey() final  String signatureCaption;

/// Create a copy of SignatureBlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignatureBlockCopyWith<_SignatureBlock> get copyWith => __$SignatureBlockCopyWithImpl<_SignatureBlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SignatureBlockToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignatureBlock&&(identical(other.signatoryName, signatoryName) || other.signatoryName == signatoryName)&&(identical(other.signatoryTitle, signatoryTitle) || other.signatoryTitle == signatoryTitle)&&(identical(other.signatureAssetId, signatureAssetId) || other.signatureAssetId == signatureAssetId)&&(identical(other.signatureCaption, signatureCaption) || other.signatureCaption == signatureCaption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,signatoryName,signatoryTitle,signatureAssetId,signatureCaption);
}

@override
String toString() {
    return 'SignatureBlock(signatoryName: $signatoryName, signatoryTitle: $signatoryTitle, signatureAssetId: $signatureAssetId, signatureCaption: $signatureCaption)';
}


}

/// @nodoc
abstract mixin class _$SignatureBlockCopyWith<$Res> implements $SignatureBlockCopyWith<$Res> {
  factory _$SignatureBlockCopyWith(_SignatureBlock value, $Res Function(_SignatureBlock) _then) = __$SignatureBlockCopyWithImpl;
@override @useResult
$Res call({
 String signatoryName, String signatoryTitle, String? signatureAssetId, String signatureCaption
});




}
/// @nodoc
class __$SignatureBlockCopyWithImpl<$Res>
    implements _$SignatureBlockCopyWith<$Res> {
  __$SignatureBlockCopyWithImpl(this._self, this._then);

  final _SignatureBlock _self;
  final $Res Function(_SignatureBlock) _then;

/// Create a copy of SignatureBlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? signatoryName = null,Object? signatoryTitle = null,Object? signatureAssetId = freezed,Object? signatureCaption = null,}) {
  return _then(_SignatureBlock(
signatoryName: null == signatoryName ? _self.signatoryName : signatoryName // ignore: cast_nullable_to_non_nullable
as String,signatoryTitle: null == signatoryTitle ? _self.signatoryTitle : signatoryTitle // ignore: cast_nullable_to_non_nullable
as String,signatureAssetId: freezed == signatureAssetId ? _self.signatureAssetId : signatureAssetId // ignore: cast_nullable_to_non_nullable
as String?,signatureCaption: null == signatureCaption ? _self.signatureCaption : signatureCaption // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
