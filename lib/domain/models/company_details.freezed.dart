// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CompanyDetails {

 String get companyName; String get registrationNumber; List<String> get addressLines; String get phone; String get email; String get website; String? get logoAssetId;
/// Create a copy of CompanyDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyDetailsCopyWith<CompanyDetails> get copyWith => _$CompanyDetailsCopyWithImpl<CompanyDetails>(this as CompanyDetails, _$identity);

  /// Serializes this CompanyDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CompanyDetails;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanyDetails&&(identical(other.companyName, _this.companyName) || other.companyName == _this.companyName)&&(identical(other.registrationNumber, _this.registrationNumber) || other.registrationNumber == _this.registrationNumber)&&const DeepCollectionEquality().equals(other.addressLines, _this.addressLines)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.website, _this.website) || other.website == _this.website)&&(identical(other.logoAssetId, _this.logoAssetId) || other.logoAssetId == _this.logoAssetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CompanyDetails;
  return Object.hash(runtimeType,_this.companyName,_this.registrationNumber,const DeepCollectionEquality().hash(_this.addressLines),_this.phone,_this.email,_this.website,_this.logoAssetId);
}

@override
String toString() {
  final _this = this as CompanyDetails;
  return 'CompanyDetails(companyName: ${_this.companyName}, registrationNumber: ${_this.registrationNumber}, addressLines: ${_this.addressLines}, phone: ${_this.phone}, email: ${_this.email}, website: ${_this.website}, logoAssetId: ${_this.logoAssetId})';
}


}

/// @nodoc
abstract mixin class $CompanyDetailsCopyWith<$Res>  {
  factory $CompanyDetailsCopyWith(CompanyDetails value, $Res Function(CompanyDetails) _then) = _$CompanyDetailsCopyWithImpl;
@useResult
$Res call({
 String companyName, String registrationNumber, List<String> addressLines, String phone, String email, String website, String? logoAssetId
});




}
/// @nodoc
class _$CompanyDetailsCopyWithImpl<$Res>
    implements $CompanyDetailsCopyWith<$Res> {
  _$CompanyDetailsCopyWithImpl(this._self, this._then);

  final CompanyDetails _self;
  final $Res Function(CompanyDetails) _then;

/// Create a copy of CompanyDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? companyName = null,Object? registrationNumber = null,Object? addressLines = null,Object? phone = null,Object? email = null,Object? website = null,Object? logoAssetId = freezed,}) {
  return _then(CompanyDetails(
companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,registrationNumber: null == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String,addressLines: null == addressLines ? _self.addressLines : addressLines // ignore: cast_nullable_to_non_nullable
as List<String>,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,website: null == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String,logoAssetId: freezed == logoAssetId ? _self.logoAssetId : logoAssetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompanyDetails].
extension CompanyDetailsPatterns on CompanyDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanyDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanyDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanyDetails value)  $default,){
final _that = this;
switch (_that) {
case _CompanyDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanyDetails value)?  $default,){
final _that = this;
switch (_that) {
case _CompanyDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String companyName,  String registrationNumber,  List<String> addressLines,  String phone,  String email,  String website,  String? logoAssetId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanyDetails() when $default != null:
return $default(_that.companyName,_that.registrationNumber,_that.addressLines,_that.phone,_that.email,_that.website,_that.logoAssetId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String companyName,  String registrationNumber,  List<String> addressLines,  String phone,  String email,  String website,  String? logoAssetId)  $default,) {final _that = this;
switch (_that) {
case _CompanyDetails():
return $default(_that.companyName,_that.registrationNumber,_that.addressLines,_that.phone,_that.email,_that.website,_that.logoAssetId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String companyName,  String registrationNumber,  List<String> addressLines,  String phone,  String email,  String website,  String? logoAssetId)?  $default,) {final _that = this;
switch (_that) {
case _CompanyDetails() when $default != null:
return $default(_that.companyName,_that.registrationNumber,_that.addressLines,_that.phone,_that.email,_that.website,_that.logoAssetId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompanyDetails implements CompanyDetails {
  const _CompanyDetails({this.companyName = '', this.registrationNumber = '',  List<String> addressLines = const <String>[], this.phone = '', this.email = '', this.website = '', this.logoAssetId}): _addressLines = addressLines;
  factory _CompanyDetails.fromJson(Map<String, dynamic> json) => _$CompanyDetailsFromJson(json);

@override@JsonKey() final  String companyName;
@override@JsonKey() final  String registrationNumber;
 final  List<String> _addressLines;
@override@JsonKey() List<String> get addressLines {
  if (_addressLines is EqualUnmodifiableListView) return _addressLines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addressLines);
}

@override@JsonKey() final  String phone;
@override@JsonKey() final  String email;
@override@JsonKey() final  String website;
@override final  String? logoAssetId;

/// Create a copy of CompanyDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyDetailsCopyWith<_CompanyDetails> get copyWith => __$CompanyDetailsCopyWithImpl<_CompanyDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompanyDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyDetails&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&const DeepCollectionEquality().equals(other.addressLines, _addressLines)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.website, website) || other.website == website)&&(identical(other.logoAssetId, logoAssetId) || other.logoAssetId == logoAssetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,companyName,registrationNumber,const DeepCollectionEquality().hash(_addressLines),phone,email,website,logoAssetId);
}

@override
String toString() {
    return 'CompanyDetails(companyName: $companyName, registrationNumber: $registrationNumber, addressLines: $addressLines, phone: $phone, email: $email, website: $website, logoAssetId: $logoAssetId)';
}


}

/// @nodoc
abstract mixin class _$CompanyDetailsCopyWith<$Res> implements $CompanyDetailsCopyWith<$Res> {
  factory _$CompanyDetailsCopyWith(_CompanyDetails value, $Res Function(_CompanyDetails) _then) = __$CompanyDetailsCopyWithImpl;
@override @useResult
$Res call({
 String companyName, String registrationNumber, List<String> addressLines, String phone, String email, String website, String? logoAssetId
});




}
/// @nodoc
class __$CompanyDetailsCopyWithImpl<$Res>
    implements _$CompanyDetailsCopyWith<$Res> {
  __$CompanyDetailsCopyWithImpl(this._self, this._then);

  final _CompanyDetails _self;
  final $Res Function(_CompanyDetails) _then;

/// Create a copy of CompanyDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? companyName = null,Object? registrationNumber = null,Object? addressLines = null,Object? phone = null,Object? email = null,Object? website = null,Object? logoAssetId = freezed,}) {
  return _then(_CompanyDetails(
companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,registrationNumber: null == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String,addressLines: null == addressLines ? _self._addressLines : addressLines // ignore: cast_nullable_to_non_nullable
as List<String>,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,website: null == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String,logoAssetId: freezed == logoAssetId ? _self.logoAssetId : logoAssetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
