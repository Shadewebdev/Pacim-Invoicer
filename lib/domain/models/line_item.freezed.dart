// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'line_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LineItem {

 String get lineItemId; String? get sourceLineItemId; String get description; String get unit; int get quantityScaled; int get unitPriceMinor; int get discountPercentScaled;
/// Create a copy of LineItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineItemCopyWith<LineItem> get copyWith => _$LineItemCopyWithImpl<LineItem>(this as LineItem, _$identity);

  /// Serializes this LineItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LineItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineItem&&(identical(other.lineItemId, _this.lineItemId) || other.lineItemId == _this.lineItemId)&&(identical(other.sourceLineItemId, _this.sourceLineItemId) || other.sourceLineItemId == _this.sourceLineItemId)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.quantityScaled, _this.quantityScaled) || other.quantityScaled == _this.quantityScaled)&&(identical(other.unitPriceMinor, _this.unitPriceMinor) || other.unitPriceMinor == _this.unitPriceMinor)&&(identical(other.discountPercentScaled, _this.discountPercentScaled) || other.discountPercentScaled == _this.discountPercentScaled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LineItem;
  return Object.hash(runtimeType,_this.lineItemId,_this.sourceLineItemId,_this.description,_this.unit,_this.quantityScaled,_this.unitPriceMinor,_this.discountPercentScaled);
}

@override
String toString() {
  final _this = this as LineItem;
  return 'LineItem(lineItemId: ${_this.lineItemId}, sourceLineItemId: ${_this.sourceLineItemId}, description: ${_this.description}, unit: ${_this.unit}, quantityScaled: ${_this.quantityScaled}, unitPriceMinor: ${_this.unitPriceMinor}, discountPercentScaled: ${_this.discountPercentScaled})';
}


}

/// @nodoc
abstract mixin class $LineItemCopyWith<$Res>  {
  factory $LineItemCopyWith(LineItem value, $Res Function(LineItem) _then) = _$LineItemCopyWithImpl;
@useResult
$Res call({
 String lineItemId, String? sourceLineItemId, String description, String unit, int quantityScaled, int unitPriceMinor, int discountPercentScaled
});




}
/// @nodoc
class _$LineItemCopyWithImpl<$Res>
    implements $LineItemCopyWith<$Res> {
  _$LineItemCopyWithImpl(this._self, this._then);

  final LineItem _self;
  final $Res Function(LineItem) _then;

/// Create a copy of LineItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineItemId = null,Object? sourceLineItemId = freezed,Object? description = null,Object? unit = null,Object? quantityScaled = null,Object? unitPriceMinor = null,Object? discountPercentScaled = null,}) {
  return _then(LineItem(
lineItemId: null == lineItemId ? _self.lineItemId : lineItemId // ignore: cast_nullable_to_non_nullable
as String,sourceLineItemId: freezed == sourceLineItemId ? _self.sourceLineItemId : sourceLineItemId // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,quantityScaled: null == quantityScaled ? _self.quantityScaled : quantityScaled // ignore: cast_nullable_to_non_nullable
as int,unitPriceMinor: null == unitPriceMinor ? _self.unitPriceMinor : unitPriceMinor // ignore: cast_nullable_to_non_nullable
as int,discountPercentScaled: null == discountPercentScaled ? _self.discountPercentScaled : discountPercentScaled // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LineItem].
extension LineItemPatterns on LineItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineItem value)  $default,){
final _that = this;
switch (_that) {
case _LineItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineItem value)?  $default,){
final _that = this;
switch (_that) {
case _LineItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String lineItemId,  String? sourceLineItemId,  String description,  String unit,  int quantityScaled,  int unitPriceMinor,  int discountPercentScaled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineItem() when $default != null:
return $default(_that.lineItemId,_that.sourceLineItemId,_that.description,_that.unit,_that.quantityScaled,_that.unitPriceMinor,_that.discountPercentScaled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String lineItemId,  String? sourceLineItemId,  String description,  String unit,  int quantityScaled,  int unitPriceMinor,  int discountPercentScaled)  $default,) {final _that = this;
switch (_that) {
case _LineItem():
return $default(_that.lineItemId,_that.sourceLineItemId,_that.description,_that.unit,_that.quantityScaled,_that.unitPriceMinor,_that.discountPercentScaled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String lineItemId,  String? sourceLineItemId,  String description,  String unit,  int quantityScaled,  int unitPriceMinor,  int discountPercentScaled)?  $default,) {final _that = this;
switch (_that) {
case _LineItem() when $default != null:
return $default(_that.lineItemId,_that.sourceLineItemId,_that.description,_that.unit,_that.quantityScaled,_that.unitPriceMinor,_that.discountPercentScaled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LineItem implements LineItem {
  const _LineItem({required this.lineItemId, this.sourceLineItemId, this.description = '', this.unit = '', this.quantityScaled = 1000, this.unitPriceMinor = 0, this.discountPercentScaled = 0});
  factory _LineItem.fromJson(Map<String, dynamic> json) => _$LineItemFromJson(json);

@override final  String lineItemId;
@override final  String? sourceLineItemId;
@override@JsonKey() final  String description;
@override@JsonKey() final  String unit;
@override@JsonKey() final  int quantityScaled;
@override@JsonKey() final  int unitPriceMinor;
@override@JsonKey() final  int discountPercentScaled;

/// Create a copy of LineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineItemCopyWith<_LineItem> get copyWith => __$LineItemCopyWithImpl<_LineItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LineItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineItem&&(identical(other.lineItemId, lineItemId) || other.lineItemId == lineItemId)&&(identical(other.sourceLineItemId, sourceLineItemId) || other.sourceLineItemId == sourceLineItemId)&&(identical(other.description, description) || other.description == description)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.quantityScaled, quantityScaled) || other.quantityScaled == quantityScaled)&&(identical(other.unitPriceMinor, unitPriceMinor) || other.unitPriceMinor == unitPriceMinor)&&(identical(other.discountPercentScaled, discountPercentScaled) || other.discountPercentScaled == discountPercentScaled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineItemId,sourceLineItemId,description,unit,quantityScaled,unitPriceMinor,discountPercentScaled);
}

@override
String toString() {
    return 'LineItem(lineItemId: $lineItemId, sourceLineItemId: $sourceLineItemId, description: $description, unit: $unit, quantityScaled: $quantityScaled, unitPriceMinor: $unitPriceMinor, discountPercentScaled: $discountPercentScaled)';
}


}

/// @nodoc
abstract mixin class _$LineItemCopyWith<$Res> implements $LineItemCopyWith<$Res> {
  factory _$LineItemCopyWith(_LineItem value, $Res Function(_LineItem) _then) = __$LineItemCopyWithImpl;
@override @useResult
$Res call({
 String lineItemId, String? sourceLineItemId, String description, String unit, int quantityScaled, int unitPriceMinor, int discountPercentScaled
});




}
/// @nodoc
class __$LineItemCopyWithImpl<$Res>
    implements _$LineItemCopyWith<$Res> {
  __$LineItemCopyWithImpl(this._self, this._then);

  final _LineItem _self;
  final $Res Function(_LineItem) _then;

/// Create a copy of LineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineItemId = null,Object? sourceLineItemId = freezed,Object? description = null,Object? unit = null,Object? quantityScaled = null,Object? unitPriceMinor = null,Object? discountPercentScaled = null,}) {
  return _then(_LineItem(
lineItemId: null == lineItemId ? _self.lineItemId : lineItemId // ignore: cast_nullable_to_non_nullable
as String,sourceLineItemId: freezed == sourceLineItemId ? _self.sourceLineItemId : sourceLineItemId // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,quantityScaled: null == quantityScaled ? _self.quantityScaled : quantityScaled // ignore: cast_nullable_to_non_nullable
as int,unitPriceMinor: null == unitPriceMinor ? _self.unitPriceMinor : unitPriceMinor // ignore: cast_nullable_to_non_nullable
as int,discountPercentScaled: null == discountPercentScaled ? _self.discountPercentScaled : discountPercentScaled // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
