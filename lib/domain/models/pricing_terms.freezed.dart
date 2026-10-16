// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pricing_terms.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PricingTerms {

 CurrencyFormat get currencyFormat; String get taxLabel;/// Tax rate times 100, so 800 means 8%.
 int get taxRatePercentScaled; bool get isTaxEnabled;
/// Create a copy of PricingTerms
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PricingTermsCopyWith<PricingTerms> get copyWith => _$PricingTermsCopyWithImpl<PricingTerms>(this as PricingTerms, _$identity);

  /// Serializes this PricingTerms to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PricingTerms;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PricingTerms&&(identical(other.currencyFormat, _this.currencyFormat) || other.currencyFormat == _this.currencyFormat)&&(identical(other.taxLabel, _this.taxLabel) || other.taxLabel == _this.taxLabel)&&(identical(other.taxRatePercentScaled, _this.taxRatePercentScaled) || other.taxRatePercentScaled == _this.taxRatePercentScaled)&&(identical(other.isTaxEnabled, _this.isTaxEnabled) || other.isTaxEnabled == _this.isTaxEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PricingTerms;
  return Object.hash(runtimeType,_this.currencyFormat,_this.taxLabel,_this.taxRatePercentScaled,_this.isTaxEnabled);
}

@override
String toString() {
  final _this = this as PricingTerms;
  return 'PricingTerms(currencyFormat: ${_this.currencyFormat}, taxLabel: ${_this.taxLabel}, taxRatePercentScaled: ${_this.taxRatePercentScaled}, isTaxEnabled: ${_this.isTaxEnabled})';
}


}

/// @nodoc
abstract mixin class $PricingTermsCopyWith<$Res>  {
  factory $PricingTermsCopyWith(PricingTerms value, $Res Function(PricingTerms) _then) = _$PricingTermsCopyWithImpl;
@useResult
$Res call({
 CurrencyFormat currencyFormat, String taxLabel, int taxRatePercentScaled, bool isTaxEnabled
});


$CurrencyFormatCopyWith<$Res> get currencyFormat;

}
/// @nodoc
class _$PricingTermsCopyWithImpl<$Res>
    implements $PricingTermsCopyWith<$Res> {
  _$PricingTermsCopyWithImpl(this._self, this._then);

  final PricingTerms _self;
  final $Res Function(PricingTerms) _then;

/// Create a copy of PricingTerms
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currencyFormat = null,Object? taxLabel = null,Object? taxRatePercentScaled = null,Object? isTaxEnabled = null,}) {
  return _then(PricingTerms(
currencyFormat: null == currencyFormat ? _self.currencyFormat : currencyFormat // ignore: cast_nullable_to_non_nullable
as CurrencyFormat,taxLabel: null == taxLabel ? _self.taxLabel : taxLabel // ignore: cast_nullable_to_non_nullable
as String,taxRatePercentScaled: null == taxRatePercentScaled ? _self.taxRatePercentScaled : taxRatePercentScaled // ignore: cast_nullable_to_non_nullable
as int,isTaxEnabled: null == isTaxEnabled ? _self.isTaxEnabled : isTaxEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PricingTerms
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurrencyFormatCopyWith<$Res> get currencyFormat {
  
  return $CurrencyFormatCopyWith<$Res>(_self.currencyFormat, (value) {
    return _then(_self.copyWith(currencyFormat: value));
  });
}
}


/// Adds pattern-matching-related methods to [PricingTerms].
extension PricingTermsPatterns on PricingTerms {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PricingTerms value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PricingTerms() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PricingTerms value)  $default,){
final _that = this;
switch (_that) {
case _PricingTerms():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PricingTerms value)?  $default,){
final _that = this;
switch (_that) {
case _PricingTerms() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CurrencyFormat currencyFormat,  String taxLabel,  int taxRatePercentScaled,  bool isTaxEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PricingTerms() when $default != null:
return $default(_that.currencyFormat,_that.taxLabel,_that.taxRatePercentScaled,_that.isTaxEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CurrencyFormat currencyFormat,  String taxLabel,  int taxRatePercentScaled,  bool isTaxEnabled)  $default,) {final _that = this;
switch (_that) {
case _PricingTerms():
return $default(_that.currencyFormat,_that.taxLabel,_that.taxRatePercentScaled,_that.isTaxEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CurrencyFormat currencyFormat,  String taxLabel,  int taxRatePercentScaled,  bool isTaxEnabled)?  $default,) {final _that = this;
switch (_that) {
case _PricingTerms() when $default != null:
return $default(_that.currencyFormat,_that.taxLabel,_that.taxRatePercentScaled,_that.isTaxEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PricingTerms implements PricingTerms {
  const _PricingTerms({required this.currencyFormat, this.taxLabel = 'Tax', this.taxRatePercentScaled = 0, this.isTaxEnabled = false});
  factory _PricingTerms.fromJson(Map<String, dynamic> json) => _$PricingTermsFromJson(json);

@override final  CurrencyFormat currencyFormat;
@override@JsonKey() final  String taxLabel;
/// Tax rate times 100, so 800 means 8%.
@override@JsonKey() final  int taxRatePercentScaled;
@override@JsonKey() final  bool isTaxEnabled;

/// Create a copy of PricingTerms
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PricingTermsCopyWith<_PricingTerms> get copyWith => __$PricingTermsCopyWithImpl<_PricingTerms>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PricingTermsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PricingTerms&&(identical(other.currencyFormat, currencyFormat) || other.currencyFormat == currencyFormat)&&(identical(other.taxLabel, taxLabel) || other.taxLabel == taxLabel)&&(identical(other.taxRatePercentScaled, taxRatePercentScaled) || other.taxRatePercentScaled == taxRatePercentScaled)&&(identical(other.isTaxEnabled, isTaxEnabled) || other.isTaxEnabled == isTaxEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,currencyFormat,taxLabel,taxRatePercentScaled,isTaxEnabled);
}

@override
String toString() {
    return 'PricingTerms(currencyFormat: $currencyFormat, taxLabel: $taxLabel, taxRatePercentScaled: $taxRatePercentScaled, isTaxEnabled: $isTaxEnabled)';
}


}

/// @nodoc
abstract mixin class _$PricingTermsCopyWith<$Res> implements $PricingTermsCopyWith<$Res> {
  factory _$PricingTermsCopyWith(_PricingTerms value, $Res Function(_PricingTerms) _then) = __$PricingTermsCopyWithImpl;
@override @useResult
$Res call({
 CurrencyFormat currencyFormat, String taxLabel, int taxRatePercentScaled, bool isTaxEnabled
});


@override $CurrencyFormatCopyWith<$Res> get currencyFormat;

}
/// @nodoc
class __$PricingTermsCopyWithImpl<$Res>
    implements _$PricingTermsCopyWith<$Res> {
  __$PricingTermsCopyWithImpl(this._self, this._then);

  final _PricingTerms _self;
  final $Res Function(_PricingTerms) _then;

/// Create a copy of PricingTerms
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currencyFormat = null,Object? taxLabel = null,Object? taxRatePercentScaled = null,Object? isTaxEnabled = null,}) {
  return _then(_PricingTerms(
currencyFormat: null == currencyFormat ? _self.currencyFormat : currencyFormat // ignore: cast_nullable_to_non_nullable
as CurrencyFormat,taxLabel: null == taxLabel ? _self.taxLabel : taxLabel // ignore: cast_nullable_to_non_nullable
as String,taxRatePercentScaled: null == taxRatePercentScaled ? _self.taxRatePercentScaled : taxRatePercentScaled // ignore: cast_nullable_to_non_nullable
as int,isTaxEnabled: null == isTaxEnabled ? _self.isTaxEnabled : isTaxEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PricingTerms
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurrencyFormatCopyWith<$Res> get currencyFormat {
  
  return $CurrencyFormatCopyWith<$Res>(_self.currencyFormat, (value) {
    return _then(_self.copyWith(currencyFormat: value));
  });
}
}

// dart format on
