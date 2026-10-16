// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomerDetails {

 String get customerName; String get attentionTo; List<String> get addressLines; String get phone; String get email; List<String> get deliveryAddressLines;
/// Create a copy of CustomerDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerDetailsCopyWith<CustomerDetails> get copyWith => _$CustomerDetailsCopyWithImpl<CustomerDetails>(this as CustomerDetails, _$identity);

  /// Serializes this CustomerDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CustomerDetails;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerDetails&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.attentionTo, _this.attentionTo) || other.attentionTo == _this.attentionTo)&&const DeepCollectionEquality().equals(other.addressLines, _this.addressLines)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.email, _this.email) || other.email == _this.email)&&const DeepCollectionEquality().equals(other.deliveryAddressLines, _this.deliveryAddressLines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CustomerDetails;
  return Object.hash(runtimeType,_this.customerName,_this.attentionTo,const DeepCollectionEquality().hash(_this.addressLines),_this.phone,_this.email,const DeepCollectionEquality().hash(_this.deliveryAddressLines));
}

@override
String toString() {
  final _this = this as CustomerDetails;
  return 'CustomerDetails(customerName: ${_this.customerName}, attentionTo: ${_this.attentionTo}, addressLines: ${_this.addressLines}, phone: ${_this.phone}, email: ${_this.email}, deliveryAddressLines: ${_this.deliveryAddressLines})';
}


}

/// @nodoc
abstract mixin class $CustomerDetailsCopyWith<$Res>  {
  factory $CustomerDetailsCopyWith(CustomerDetails value, $Res Function(CustomerDetails) _then) = _$CustomerDetailsCopyWithImpl;
@useResult
$Res call({
 String customerName, String attentionTo, List<String> addressLines, String phone, String email, List<String> deliveryAddressLines
});




}
/// @nodoc
class _$CustomerDetailsCopyWithImpl<$Res>
    implements $CustomerDetailsCopyWith<$Res> {
  _$CustomerDetailsCopyWithImpl(this._self, this._then);

  final CustomerDetails _self;
  final $Res Function(CustomerDetails) _then;

/// Create a copy of CustomerDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerName = null,Object? attentionTo = null,Object? addressLines = null,Object? phone = null,Object? email = null,Object? deliveryAddressLines = null,}) {
  return _then(CustomerDetails(
customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,attentionTo: null == attentionTo ? _self.attentionTo : attentionTo // ignore: cast_nullable_to_non_nullable
as String,addressLines: null == addressLines ? _self.addressLines : addressLines // ignore: cast_nullable_to_non_nullable
as List<String>,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,deliveryAddressLines: null == deliveryAddressLines ? _self.deliveryAddressLines : deliveryAddressLines // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerDetails].
extension CustomerDetailsPatterns on CustomerDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerDetails value)  $default,){
final _that = this;
switch (_that) {
case _CustomerDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerDetails value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String customerName,  String attentionTo,  List<String> addressLines,  String phone,  String email,  List<String> deliveryAddressLines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerDetails() when $default != null:
return $default(_that.customerName,_that.attentionTo,_that.addressLines,_that.phone,_that.email,_that.deliveryAddressLines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String customerName,  String attentionTo,  List<String> addressLines,  String phone,  String email,  List<String> deliveryAddressLines)  $default,) {final _that = this;
switch (_that) {
case _CustomerDetails():
return $default(_that.customerName,_that.attentionTo,_that.addressLines,_that.phone,_that.email,_that.deliveryAddressLines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String customerName,  String attentionTo,  List<String> addressLines,  String phone,  String email,  List<String> deliveryAddressLines)?  $default,) {final _that = this;
switch (_that) {
case _CustomerDetails() when $default != null:
return $default(_that.customerName,_that.attentionTo,_that.addressLines,_that.phone,_that.email,_that.deliveryAddressLines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerDetails implements CustomerDetails {
  const _CustomerDetails({this.customerName = '', this.attentionTo = '',  List<String> addressLines = const <String>[], this.phone = '', this.email = '',  List<String> deliveryAddressLines = const <String>[]}): _addressLines = addressLines,_deliveryAddressLines = deliveryAddressLines;
  factory _CustomerDetails.fromJson(Map<String, dynamic> json) => _$CustomerDetailsFromJson(json);

@override@JsonKey() final  String customerName;
@override@JsonKey() final  String attentionTo;
 final  List<String> _addressLines;
@override@JsonKey() List<String> get addressLines {
  if (_addressLines is EqualUnmodifiableListView) return _addressLines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addressLines);
}

@override@JsonKey() final  String phone;
@override@JsonKey() final  String email;
 final  List<String> _deliveryAddressLines;
@override@JsonKey() List<String> get deliveryAddressLines {
  if (_deliveryAddressLines is EqualUnmodifiableListView) return _deliveryAddressLines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deliveryAddressLines);
}


/// Create a copy of CustomerDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerDetailsCopyWith<_CustomerDetails> get copyWith => __$CustomerDetailsCopyWithImpl<_CustomerDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerDetails&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.attentionTo, attentionTo) || other.attentionTo == attentionTo)&&const DeepCollectionEquality().equals(other.addressLines, _addressLines)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&const DeepCollectionEquality().equals(other.deliveryAddressLines, _deliveryAddressLines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,customerName,attentionTo,const DeepCollectionEquality().hash(_addressLines),phone,email,const DeepCollectionEquality().hash(_deliveryAddressLines));
}

@override
String toString() {
    return 'CustomerDetails(customerName: $customerName, attentionTo: $attentionTo, addressLines: $addressLines, phone: $phone, email: $email, deliveryAddressLines: $deliveryAddressLines)';
}


}

/// @nodoc
abstract mixin class _$CustomerDetailsCopyWith<$Res> implements $CustomerDetailsCopyWith<$Res> {
  factory _$CustomerDetailsCopyWith(_CustomerDetails value, $Res Function(_CustomerDetails) _then) = __$CustomerDetailsCopyWithImpl;
@override @useResult
$Res call({
 String customerName, String attentionTo, List<String> addressLines, String phone, String email, List<String> deliveryAddressLines
});




}
/// @nodoc
class __$CustomerDetailsCopyWithImpl<$Res>
    implements _$CustomerDetailsCopyWith<$Res> {
  __$CustomerDetailsCopyWithImpl(this._self, this._then);

  final _CustomerDetails _self;
  final $Res Function(_CustomerDetails) _then;

/// Create a copy of CustomerDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerName = null,Object? attentionTo = null,Object? addressLines = null,Object? phone = null,Object? email = null,Object? deliveryAddressLines = null,}) {
  return _then(_CustomerDetails(
customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,attentionTo: null == attentionTo ? _self.attentionTo : attentionTo // ignore: cast_nullable_to_non_nullable
as String,addressLines: null == addressLines ? _self._addressLines : addressLines // ignore: cast_nullable_to_non_nullable
as List<String>,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,deliveryAddressLines: null == deliveryAddressLines ? _self._deliveryAddressLines : deliveryAddressLines // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
