// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_totals.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentTotals {

 Map<String, int> get lineAmountMinorById; int get subtotalBeforeDiscountMinor; int get discountTotalMinor; int get subtotalMinor; int get taxMinor; int get grandTotalMinor;
/// Create a copy of DocumentTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentTotalsCopyWith<DocumentTotals> get copyWith => _$DocumentTotalsCopyWithImpl<DocumentTotals>(this as DocumentTotals, _$identity);

  /// Serializes this DocumentTotals to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DocumentTotals;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentTotals&&const DeepCollectionEquality().equals(other.lineAmountMinorById, _this.lineAmountMinorById)&&(identical(other.subtotalBeforeDiscountMinor, _this.subtotalBeforeDiscountMinor) || other.subtotalBeforeDiscountMinor == _this.subtotalBeforeDiscountMinor)&&(identical(other.discountTotalMinor, _this.discountTotalMinor) || other.discountTotalMinor == _this.discountTotalMinor)&&(identical(other.subtotalMinor, _this.subtotalMinor) || other.subtotalMinor == _this.subtotalMinor)&&(identical(other.taxMinor, _this.taxMinor) || other.taxMinor == _this.taxMinor)&&(identical(other.grandTotalMinor, _this.grandTotalMinor) || other.grandTotalMinor == _this.grandTotalMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DocumentTotals;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.lineAmountMinorById),_this.subtotalBeforeDiscountMinor,_this.discountTotalMinor,_this.subtotalMinor,_this.taxMinor,_this.grandTotalMinor);
}

@override
String toString() {
  final _this = this as DocumentTotals;
  return 'DocumentTotals(lineAmountMinorById: ${_this.lineAmountMinorById}, subtotalBeforeDiscountMinor: ${_this.subtotalBeforeDiscountMinor}, discountTotalMinor: ${_this.discountTotalMinor}, subtotalMinor: ${_this.subtotalMinor}, taxMinor: ${_this.taxMinor}, grandTotalMinor: ${_this.grandTotalMinor})';
}


}

/// @nodoc
abstract mixin class $DocumentTotalsCopyWith<$Res>  {
  factory $DocumentTotalsCopyWith(DocumentTotals value, $Res Function(DocumentTotals) _then) = _$DocumentTotalsCopyWithImpl;
@useResult
$Res call({
 Map<String, int> lineAmountMinorById, int subtotalBeforeDiscountMinor, int discountTotalMinor, int subtotalMinor, int taxMinor, int grandTotalMinor
});




}
/// @nodoc
class _$DocumentTotalsCopyWithImpl<$Res>
    implements $DocumentTotalsCopyWith<$Res> {
  _$DocumentTotalsCopyWithImpl(this._self, this._then);

  final DocumentTotals _self;
  final $Res Function(DocumentTotals) _then;

/// Create a copy of DocumentTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineAmountMinorById = null,Object? subtotalBeforeDiscountMinor = null,Object? discountTotalMinor = null,Object? subtotalMinor = null,Object? taxMinor = null,Object? grandTotalMinor = null,}) {
  return _then(DocumentTotals(
lineAmountMinorById: null == lineAmountMinorById ? _self.lineAmountMinorById : lineAmountMinorById // ignore: cast_nullable_to_non_nullable
as Map<String, int>,subtotalBeforeDiscountMinor: null == subtotalBeforeDiscountMinor ? _self.subtotalBeforeDiscountMinor : subtotalBeforeDiscountMinor // ignore: cast_nullable_to_non_nullable
as int,discountTotalMinor: null == discountTotalMinor ? _self.discountTotalMinor : discountTotalMinor // ignore: cast_nullable_to_non_nullable
as int,subtotalMinor: null == subtotalMinor ? _self.subtotalMinor : subtotalMinor // ignore: cast_nullable_to_non_nullable
as int,taxMinor: null == taxMinor ? _self.taxMinor : taxMinor // ignore: cast_nullable_to_non_nullable
as int,grandTotalMinor: null == grandTotalMinor ? _self.grandTotalMinor : grandTotalMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentTotals].
extension DocumentTotalsPatterns on DocumentTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentTotals value)  $default,){
final _that = this;
switch (_that) {
case _DocumentTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentTotals value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, int> lineAmountMinorById,  int subtotalBeforeDiscountMinor,  int discountTotalMinor,  int subtotalMinor,  int taxMinor,  int grandTotalMinor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentTotals() when $default != null:
return $default(_that.lineAmountMinorById,_that.subtotalBeforeDiscountMinor,_that.discountTotalMinor,_that.subtotalMinor,_that.taxMinor,_that.grandTotalMinor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, int> lineAmountMinorById,  int subtotalBeforeDiscountMinor,  int discountTotalMinor,  int subtotalMinor,  int taxMinor,  int grandTotalMinor)  $default,) {final _that = this;
switch (_that) {
case _DocumentTotals():
return $default(_that.lineAmountMinorById,_that.subtotalBeforeDiscountMinor,_that.discountTotalMinor,_that.subtotalMinor,_that.taxMinor,_that.grandTotalMinor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, int> lineAmountMinorById,  int subtotalBeforeDiscountMinor,  int discountTotalMinor,  int subtotalMinor,  int taxMinor,  int grandTotalMinor)?  $default,) {final _that = this;
switch (_that) {
case _DocumentTotals() when $default != null:
return $default(_that.lineAmountMinorById,_that.subtotalBeforeDiscountMinor,_that.discountTotalMinor,_that.subtotalMinor,_that.taxMinor,_that.grandTotalMinor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentTotals implements DocumentTotals {
  const _DocumentTotals({required  Map<String, int> lineAmountMinorById, required this.subtotalBeforeDiscountMinor, required this.discountTotalMinor, required this.subtotalMinor, required this.taxMinor, required this.grandTotalMinor}): _lineAmountMinorById = lineAmountMinorById;
  factory _DocumentTotals.fromJson(Map<String, dynamic> json) => _$DocumentTotalsFromJson(json);

 final  Map<String, int> _lineAmountMinorById;
@override Map<String, int> get lineAmountMinorById {
  if (_lineAmountMinorById is EqualUnmodifiableMapView) return _lineAmountMinorById;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_lineAmountMinorById);
}

@override final  int subtotalBeforeDiscountMinor;
@override final  int discountTotalMinor;
@override final  int subtotalMinor;
@override final  int taxMinor;
@override final  int grandTotalMinor;

/// Create a copy of DocumentTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentTotalsCopyWith<_DocumentTotals> get copyWith => __$DocumentTotalsCopyWithImpl<_DocumentTotals>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentTotalsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentTotals&&const DeepCollectionEquality().equals(other.lineAmountMinorById, _lineAmountMinorById)&&(identical(other.subtotalBeforeDiscountMinor, subtotalBeforeDiscountMinor) || other.subtotalBeforeDiscountMinor == subtotalBeforeDiscountMinor)&&(identical(other.discountTotalMinor, discountTotalMinor) || other.discountTotalMinor == discountTotalMinor)&&(identical(other.subtotalMinor, subtotalMinor) || other.subtotalMinor == subtotalMinor)&&(identical(other.taxMinor, taxMinor) || other.taxMinor == taxMinor)&&(identical(other.grandTotalMinor, grandTotalMinor) || other.grandTotalMinor == grandTotalMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_lineAmountMinorById),subtotalBeforeDiscountMinor,discountTotalMinor,subtotalMinor,taxMinor,grandTotalMinor);
}

@override
String toString() {
    return 'DocumentTotals(lineAmountMinorById: $lineAmountMinorById, subtotalBeforeDiscountMinor: $subtotalBeforeDiscountMinor, discountTotalMinor: $discountTotalMinor, subtotalMinor: $subtotalMinor, taxMinor: $taxMinor, grandTotalMinor: $grandTotalMinor)';
}


}

/// @nodoc
abstract mixin class _$DocumentTotalsCopyWith<$Res> implements $DocumentTotalsCopyWith<$Res> {
  factory _$DocumentTotalsCopyWith(_DocumentTotals value, $Res Function(_DocumentTotals) _then) = __$DocumentTotalsCopyWithImpl;
@override @useResult
$Res call({
 Map<String, int> lineAmountMinorById, int subtotalBeforeDiscountMinor, int discountTotalMinor, int subtotalMinor, int taxMinor, int grandTotalMinor
});




}
/// @nodoc
class __$DocumentTotalsCopyWithImpl<$Res>
    implements _$DocumentTotalsCopyWith<$Res> {
  __$DocumentTotalsCopyWithImpl(this._self, this._then);

  final _DocumentTotals _self;
  final $Res Function(_DocumentTotals) _then;

/// Create a copy of DocumentTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineAmountMinorById = null,Object? subtotalBeforeDiscountMinor = null,Object? discountTotalMinor = null,Object? subtotalMinor = null,Object? taxMinor = null,Object? grandTotalMinor = null,}) {
  return _then(_DocumentTotals(
lineAmountMinorById: null == lineAmountMinorById ? _self._lineAmountMinorById : lineAmountMinorById // ignore: cast_nullable_to_non_nullable
as Map<String, int>,subtotalBeforeDiscountMinor: null == subtotalBeforeDiscountMinor ? _self.subtotalBeforeDiscountMinor : subtotalBeforeDiscountMinor // ignore: cast_nullable_to_non_nullable
as int,discountTotalMinor: null == discountTotalMinor ? _self.discountTotalMinor : discountTotalMinor // ignore: cast_nullable_to_non_nullable
as int,subtotalMinor: null == subtotalMinor ? _self.subtotalMinor : subtotalMinor // ignore: cast_nullable_to_non_nullable
as int,taxMinor: null == taxMinor ? _self.taxMinor : taxMinor // ignore: cast_nullable_to_non_nullable
as int,grandTotalMinor: null == grandTotalMinor ? _self.grandTotalMinor : grandTotalMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
