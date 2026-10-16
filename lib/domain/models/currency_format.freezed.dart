// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'currency_format.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurrencyFormat {

 String get currencyCode; String get symbol; int get decimalPlaces; CurrencySymbolPosition get symbolPosition; String get thousandsSeparator; String get decimalSeparator;
/// Create a copy of CurrencyFormat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrencyFormatCopyWith<CurrencyFormat> get copyWith => _$CurrencyFormatCopyWithImpl<CurrencyFormat>(this as CurrencyFormat, _$identity);

  /// Serializes this CurrencyFormat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CurrencyFormat;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrencyFormat&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&(identical(other.symbol, _this.symbol) || other.symbol == _this.symbol)&&(identical(other.decimalPlaces, _this.decimalPlaces) || other.decimalPlaces == _this.decimalPlaces)&&(identical(other.symbolPosition, _this.symbolPosition) || other.symbolPosition == _this.symbolPosition)&&(identical(other.thousandsSeparator, _this.thousandsSeparator) || other.thousandsSeparator == _this.thousandsSeparator)&&(identical(other.decimalSeparator, _this.decimalSeparator) || other.decimalSeparator == _this.decimalSeparator));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CurrencyFormat;
  return Object.hash(runtimeType,_this.currencyCode,_this.symbol,_this.decimalPlaces,_this.symbolPosition,_this.thousandsSeparator,_this.decimalSeparator);
}

@override
String toString() {
  final _this = this as CurrencyFormat;
  return 'CurrencyFormat(currencyCode: ${_this.currencyCode}, symbol: ${_this.symbol}, decimalPlaces: ${_this.decimalPlaces}, symbolPosition: ${_this.symbolPosition}, thousandsSeparator: ${_this.thousandsSeparator}, decimalSeparator: ${_this.decimalSeparator})';
}


}

/// @nodoc
abstract mixin class $CurrencyFormatCopyWith<$Res>  {
  factory $CurrencyFormatCopyWith(CurrencyFormat value, $Res Function(CurrencyFormat) _then) = _$CurrencyFormatCopyWithImpl;
@useResult
$Res call({
 String currencyCode, String symbol, int decimalPlaces, CurrencySymbolPosition symbolPosition, String thousandsSeparator, String decimalSeparator
});




}
/// @nodoc
class _$CurrencyFormatCopyWithImpl<$Res>
    implements $CurrencyFormatCopyWith<$Res> {
  _$CurrencyFormatCopyWithImpl(this._self, this._then);

  final CurrencyFormat _self;
  final $Res Function(CurrencyFormat) _then;

/// Create a copy of CurrencyFormat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currencyCode = null,Object? symbol = null,Object? decimalPlaces = null,Object? symbolPosition = null,Object? thousandsSeparator = null,Object? decimalSeparator = null,}) {
  return _then(CurrencyFormat(
currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,decimalPlaces: null == decimalPlaces ? _self.decimalPlaces : decimalPlaces // ignore: cast_nullable_to_non_nullable
as int,symbolPosition: null == symbolPosition ? _self.symbolPosition : symbolPosition // ignore: cast_nullable_to_non_nullable
as CurrencySymbolPosition,thousandsSeparator: null == thousandsSeparator ? _self.thousandsSeparator : thousandsSeparator // ignore: cast_nullable_to_non_nullable
as String,decimalSeparator: null == decimalSeparator ? _self.decimalSeparator : decimalSeparator // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CurrencyFormat].
extension CurrencyFormatPatterns on CurrencyFormat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrencyFormat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrencyFormat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrencyFormat value)  $default,){
final _that = this;
switch (_that) {
case _CurrencyFormat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrencyFormat value)?  $default,){
final _that = this;
switch (_that) {
case _CurrencyFormat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currencyCode,  String symbol,  int decimalPlaces,  CurrencySymbolPosition symbolPosition,  String thousandsSeparator,  String decimalSeparator)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrencyFormat() when $default != null:
return $default(_that.currencyCode,_that.symbol,_that.decimalPlaces,_that.symbolPosition,_that.thousandsSeparator,_that.decimalSeparator);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currencyCode,  String symbol,  int decimalPlaces,  CurrencySymbolPosition symbolPosition,  String thousandsSeparator,  String decimalSeparator)  $default,) {final _that = this;
switch (_that) {
case _CurrencyFormat():
return $default(_that.currencyCode,_that.symbol,_that.decimalPlaces,_that.symbolPosition,_that.thousandsSeparator,_that.decimalSeparator);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currencyCode,  String symbol,  int decimalPlaces,  CurrencySymbolPosition symbolPosition,  String thousandsSeparator,  String decimalSeparator)?  $default,) {final _that = this;
switch (_that) {
case _CurrencyFormat() when $default != null:
return $default(_that.currencyCode,_that.symbol,_that.decimalPlaces,_that.symbolPosition,_that.thousandsSeparator,_that.decimalSeparator);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurrencyFormat extends CurrencyFormat {
  const _CurrencyFormat({required this.currencyCode, required this.symbol, required this.decimalPlaces, required this.symbolPosition, this.thousandsSeparator = ',', this.decimalSeparator = '.'}): super._();
  factory _CurrencyFormat.fromJson(Map<String, dynamic> json) => _$CurrencyFormatFromJson(json);

@override final  String currencyCode;
@override final  String symbol;
@override final  int decimalPlaces;
@override final  CurrencySymbolPosition symbolPosition;
@override@JsonKey() final  String thousandsSeparator;
@override@JsonKey() final  String decimalSeparator;

/// Create a copy of CurrencyFormat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrencyFormatCopyWith<_CurrencyFormat> get copyWith => __$CurrencyFormatCopyWithImpl<_CurrencyFormat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrencyFormatToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrencyFormat&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.decimalPlaces, decimalPlaces) || other.decimalPlaces == decimalPlaces)&&(identical(other.symbolPosition, symbolPosition) || other.symbolPosition == symbolPosition)&&(identical(other.thousandsSeparator, thousandsSeparator) || other.thousandsSeparator == thousandsSeparator)&&(identical(other.decimalSeparator, decimalSeparator) || other.decimalSeparator == decimalSeparator));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,currencyCode,symbol,decimalPlaces,symbolPosition,thousandsSeparator,decimalSeparator);
}

@override
String toString() {
    return 'CurrencyFormat(currencyCode: $currencyCode, symbol: $symbol, decimalPlaces: $decimalPlaces, symbolPosition: $symbolPosition, thousandsSeparator: $thousandsSeparator, decimalSeparator: $decimalSeparator)';
}


}

/// @nodoc
abstract mixin class _$CurrencyFormatCopyWith<$Res> implements $CurrencyFormatCopyWith<$Res> {
  factory _$CurrencyFormatCopyWith(_CurrencyFormat value, $Res Function(_CurrencyFormat) _then) = __$CurrencyFormatCopyWithImpl;
@override @useResult
$Res call({
 String currencyCode, String symbol, int decimalPlaces, CurrencySymbolPosition symbolPosition, String thousandsSeparator, String decimalSeparator
});




}
/// @nodoc
class __$CurrencyFormatCopyWithImpl<$Res>
    implements _$CurrencyFormatCopyWith<$Res> {
  __$CurrencyFormatCopyWithImpl(this._self, this._then);

  final _CurrencyFormat _self;
  final $Res Function(_CurrencyFormat) _then;

/// Create a copy of CurrencyFormat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currencyCode = null,Object? symbol = null,Object? decimalPlaces = null,Object? symbolPosition = null,Object? thousandsSeparator = null,Object? decimalSeparator = null,}) {
  return _then(_CurrencyFormat(
currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,decimalPlaces: null == decimalPlaces ? _self.decimalPlaces : decimalPlaces // ignore: cast_nullable_to_non_nullable
as int,symbolPosition: null == symbolPosition ? _self.symbolPosition : symbolPosition // ignore: cast_nullable_to_non_nullable
as CurrencySymbolPosition,thousandsSeparator: null == thousandsSeparator ? _self.thousandsSeparator : thousandsSeparator // ignore: cast_nullable_to_non_nullable
as String,decimalSeparator: null == decimalSeparator ? _self.decimalSeparator : decimalSeparator // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
