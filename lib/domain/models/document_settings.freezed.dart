// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentSettings {

 CompanyDetails get companyDetails; Map<DocumentType, DocumentLayoutOptions> get layoutOptionsByType; PricingTerms get pricingTerms; Map<DocumentType, String> get defaultTermsByType; String get defaultFooterNote; Map<DocumentType, SignatureBlock> get signatureBlockByType; Map<DocumentType, DocumentNumberingRule> get numberingRuleByType; int get quotationValidityDays;/// One of `system`, `light` or `dark`.
 String get appearance;
/// Create a copy of DocumentSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentSettingsCopyWith<DocumentSettings> get copyWith => _$DocumentSettingsCopyWithImpl<DocumentSettings>(this as DocumentSettings, _$identity);

  /// Serializes this DocumentSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DocumentSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentSettings&&(identical(other.companyDetails, _this.companyDetails) || other.companyDetails == _this.companyDetails)&&const DeepCollectionEquality().equals(other.layoutOptionsByType, _this.layoutOptionsByType)&&(identical(other.pricingTerms, _this.pricingTerms) || other.pricingTerms == _this.pricingTerms)&&const DeepCollectionEquality().equals(other.defaultTermsByType, _this.defaultTermsByType)&&(identical(other.defaultFooterNote, _this.defaultFooterNote) || other.defaultFooterNote == _this.defaultFooterNote)&&const DeepCollectionEquality().equals(other.signatureBlockByType, _this.signatureBlockByType)&&const DeepCollectionEquality().equals(other.numberingRuleByType, _this.numberingRuleByType)&&(identical(other.quotationValidityDays, _this.quotationValidityDays) || other.quotationValidityDays == _this.quotationValidityDays)&&(identical(other.appearance, _this.appearance) || other.appearance == _this.appearance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DocumentSettings;
  return Object.hash(runtimeType,_this.companyDetails,const DeepCollectionEquality().hash(_this.layoutOptionsByType),_this.pricingTerms,const DeepCollectionEquality().hash(_this.defaultTermsByType),_this.defaultFooterNote,const DeepCollectionEquality().hash(_this.signatureBlockByType),const DeepCollectionEquality().hash(_this.numberingRuleByType),_this.quotationValidityDays,_this.appearance);
}

@override
String toString() {
  final _this = this as DocumentSettings;
  return 'DocumentSettings(companyDetails: ${_this.companyDetails}, layoutOptionsByType: ${_this.layoutOptionsByType}, pricingTerms: ${_this.pricingTerms}, defaultTermsByType: ${_this.defaultTermsByType}, defaultFooterNote: ${_this.defaultFooterNote}, signatureBlockByType: ${_this.signatureBlockByType}, numberingRuleByType: ${_this.numberingRuleByType}, quotationValidityDays: ${_this.quotationValidityDays}, appearance: ${_this.appearance})';
}


}

/// @nodoc
abstract mixin class $DocumentSettingsCopyWith<$Res>  {
  factory $DocumentSettingsCopyWith(DocumentSettings value, $Res Function(DocumentSettings) _then) = _$DocumentSettingsCopyWithImpl;
@useResult
$Res call({
 CompanyDetails companyDetails, Map<DocumentType, DocumentLayoutOptions> layoutOptionsByType, PricingTerms pricingTerms, Map<DocumentType, String> defaultTermsByType, String defaultFooterNote, Map<DocumentType, SignatureBlock> signatureBlockByType, Map<DocumentType, DocumentNumberingRule> numberingRuleByType, int quotationValidityDays, String appearance
});


$CompanyDetailsCopyWith<$Res> get companyDetails;$PricingTermsCopyWith<$Res> get pricingTerms;

}
/// @nodoc
class _$DocumentSettingsCopyWithImpl<$Res>
    implements $DocumentSettingsCopyWith<$Res> {
  _$DocumentSettingsCopyWithImpl(this._self, this._then);

  final DocumentSettings _self;
  final $Res Function(DocumentSettings) _then;

/// Create a copy of DocumentSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? companyDetails = null,Object? layoutOptionsByType = null,Object? pricingTerms = null,Object? defaultTermsByType = null,Object? defaultFooterNote = null,Object? signatureBlockByType = null,Object? numberingRuleByType = null,Object? quotationValidityDays = null,Object? appearance = null,}) {
  return _then(DocumentSettings(
companyDetails: null == companyDetails ? _self.companyDetails : companyDetails // ignore: cast_nullable_to_non_nullable
as CompanyDetails,layoutOptionsByType: null == layoutOptionsByType ? _self.layoutOptionsByType : layoutOptionsByType // ignore: cast_nullable_to_non_nullable
as Map<DocumentType, DocumentLayoutOptions>,pricingTerms: null == pricingTerms ? _self.pricingTerms : pricingTerms // ignore: cast_nullable_to_non_nullable
as PricingTerms,defaultTermsByType: null == defaultTermsByType ? _self.defaultTermsByType : defaultTermsByType // ignore: cast_nullable_to_non_nullable
as Map<DocumentType, String>,defaultFooterNote: null == defaultFooterNote ? _self.defaultFooterNote : defaultFooterNote // ignore: cast_nullable_to_non_nullable
as String,signatureBlockByType: null == signatureBlockByType ? _self.signatureBlockByType : signatureBlockByType // ignore: cast_nullable_to_non_nullable
as Map<DocumentType, SignatureBlock>,numberingRuleByType: null == numberingRuleByType ? _self.numberingRuleByType : numberingRuleByType // ignore: cast_nullable_to_non_nullable
as Map<DocumentType, DocumentNumberingRule>,quotationValidityDays: null == quotationValidityDays ? _self.quotationValidityDays : quotationValidityDays // ignore: cast_nullable_to_non_nullable
as int,appearance: null == appearance ? _self.appearance : appearance // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of DocumentSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyDetailsCopyWith<$Res> get companyDetails {
  
  return $CompanyDetailsCopyWith<$Res>(_self.companyDetails, (value) {
    return _then(_self.copyWith(companyDetails: value));
  });
}/// Create a copy of DocumentSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PricingTermsCopyWith<$Res> get pricingTerms {
  
  return $PricingTermsCopyWith<$Res>(_self.pricingTerms, (value) {
    return _then(_self.copyWith(pricingTerms: value));
  });
}
}


/// Adds pattern-matching-related methods to [DocumentSettings].
extension DocumentSettingsPatterns on DocumentSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentSettings value)  $default,){
final _that = this;
switch (_that) {
case _DocumentSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentSettings value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CompanyDetails companyDetails,  Map<DocumentType, DocumentLayoutOptions> layoutOptionsByType,  PricingTerms pricingTerms,  Map<DocumentType, String> defaultTermsByType,  String defaultFooterNote,  Map<DocumentType, SignatureBlock> signatureBlockByType,  Map<DocumentType, DocumentNumberingRule> numberingRuleByType,  int quotationValidityDays,  String appearance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentSettings() when $default != null:
return $default(_that.companyDetails,_that.layoutOptionsByType,_that.pricingTerms,_that.defaultTermsByType,_that.defaultFooterNote,_that.signatureBlockByType,_that.numberingRuleByType,_that.quotationValidityDays,_that.appearance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CompanyDetails companyDetails,  Map<DocumentType, DocumentLayoutOptions> layoutOptionsByType,  PricingTerms pricingTerms,  Map<DocumentType, String> defaultTermsByType,  String defaultFooterNote,  Map<DocumentType, SignatureBlock> signatureBlockByType,  Map<DocumentType, DocumentNumberingRule> numberingRuleByType,  int quotationValidityDays,  String appearance)  $default,) {final _that = this;
switch (_that) {
case _DocumentSettings():
return $default(_that.companyDetails,_that.layoutOptionsByType,_that.pricingTerms,_that.defaultTermsByType,_that.defaultFooterNote,_that.signatureBlockByType,_that.numberingRuleByType,_that.quotationValidityDays,_that.appearance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CompanyDetails companyDetails,  Map<DocumentType, DocumentLayoutOptions> layoutOptionsByType,  PricingTerms pricingTerms,  Map<DocumentType, String> defaultTermsByType,  String defaultFooterNote,  Map<DocumentType, SignatureBlock> signatureBlockByType,  Map<DocumentType, DocumentNumberingRule> numberingRuleByType,  int quotationValidityDays,  String appearance)?  $default,) {final _that = this;
switch (_that) {
case _DocumentSettings() when $default != null:
return $default(_that.companyDetails,_that.layoutOptionsByType,_that.pricingTerms,_that.defaultTermsByType,_that.defaultFooterNote,_that.signatureBlockByType,_that.numberingRuleByType,_that.quotationValidityDays,_that.appearance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentSettings implements DocumentSettings {
  const _DocumentSettings({required this.companyDetails, required  Map<DocumentType, DocumentLayoutOptions> layoutOptionsByType, required this.pricingTerms, required  Map<DocumentType, String> defaultTermsByType, required this.defaultFooterNote, required  Map<DocumentType, SignatureBlock> signatureBlockByType, required  Map<DocumentType, DocumentNumberingRule> numberingRuleByType, this.quotationValidityDays = 30, this.appearance = 'system'}): _layoutOptionsByType = layoutOptionsByType,_defaultTermsByType = defaultTermsByType,_signatureBlockByType = signatureBlockByType,_numberingRuleByType = numberingRuleByType;
  factory _DocumentSettings.fromJson(Map<String, dynamic> json) => _$DocumentSettingsFromJson(json);

@override final  CompanyDetails companyDetails;
 final  Map<DocumentType, DocumentLayoutOptions> _layoutOptionsByType;
@override Map<DocumentType, DocumentLayoutOptions> get layoutOptionsByType {
  if (_layoutOptionsByType is EqualUnmodifiableMapView) return _layoutOptionsByType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_layoutOptionsByType);
}

@override final  PricingTerms pricingTerms;
 final  Map<DocumentType, String> _defaultTermsByType;
@override Map<DocumentType, String> get defaultTermsByType {
  if (_defaultTermsByType is EqualUnmodifiableMapView) return _defaultTermsByType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_defaultTermsByType);
}

@override final  String defaultFooterNote;
 final  Map<DocumentType, SignatureBlock> _signatureBlockByType;
@override Map<DocumentType, SignatureBlock> get signatureBlockByType {
  if (_signatureBlockByType is EqualUnmodifiableMapView) return _signatureBlockByType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_signatureBlockByType);
}

 final  Map<DocumentType, DocumentNumberingRule> _numberingRuleByType;
@override Map<DocumentType, DocumentNumberingRule> get numberingRuleByType {
  if (_numberingRuleByType is EqualUnmodifiableMapView) return _numberingRuleByType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_numberingRuleByType);
}

@override@JsonKey() final  int quotationValidityDays;
/// One of `system`, `light` or `dark`.
@override@JsonKey() final  String appearance;

/// Create a copy of DocumentSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentSettingsCopyWith<_DocumentSettings> get copyWith => __$DocumentSettingsCopyWithImpl<_DocumentSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentSettings&&(identical(other.companyDetails, companyDetails) || other.companyDetails == companyDetails)&&const DeepCollectionEquality().equals(other.layoutOptionsByType, _layoutOptionsByType)&&(identical(other.pricingTerms, pricingTerms) || other.pricingTerms == pricingTerms)&&const DeepCollectionEquality().equals(other.defaultTermsByType, _defaultTermsByType)&&(identical(other.defaultFooterNote, defaultFooterNote) || other.defaultFooterNote == defaultFooterNote)&&const DeepCollectionEquality().equals(other.signatureBlockByType, _signatureBlockByType)&&const DeepCollectionEquality().equals(other.numberingRuleByType, _numberingRuleByType)&&(identical(other.quotationValidityDays, quotationValidityDays) || other.quotationValidityDays == quotationValidityDays)&&(identical(other.appearance, appearance) || other.appearance == appearance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,companyDetails,const DeepCollectionEquality().hash(_layoutOptionsByType),pricingTerms,const DeepCollectionEquality().hash(_defaultTermsByType),defaultFooterNote,const DeepCollectionEquality().hash(_signatureBlockByType),const DeepCollectionEquality().hash(_numberingRuleByType),quotationValidityDays,appearance);
}

@override
String toString() {
    return 'DocumentSettings(companyDetails: $companyDetails, layoutOptionsByType: $layoutOptionsByType, pricingTerms: $pricingTerms, defaultTermsByType: $defaultTermsByType, defaultFooterNote: $defaultFooterNote, signatureBlockByType: $signatureBlockByType, numberingRuleByType: $numberingRuleByType, quotationValidityDays: $quotationValidityDays, appearance: $appearance)';
}


}

/// @nodoc
abstract mixin class _$DocumentSettingsCopyWith<$Res> implements $DocumentSettingsCopyWith<$Res> {
  factory _$DocumentSettingsCopyWith(_DocumentSettings value, $Res Function(_DocumentSettings) _then) = __$DocumentSettingsCopyWithImpl;
@override @useResult
$Res call({
 CompanyDetails companyDetails, Map<DocumentType, DocumentLayoutOptions> layoutOptionsByType, PricingTerms pricingTerms, Map<DocumentType, String> defaultTermsByType, String defaultFooterNote, Map<DocumentType, SignatureBlock> signatureBlockByType, Map<DocumentType, DocumentNumberingRule> numberingRuleByType, int quotationValidityDays, String appearance
});


@override $CompanyDetailsCopyWith<$Res> get companyDetails;@override $PricingTermsCopyWith<$Res> get pricingTerms;

}
/// @nodoc
class __$DocumentSettingsCopyWithImpl<$Res>
    implements _$DocumentSettingsCopyWith<$Res> {
  __$DocumentSettingsCopyWithImpl(this._self, this._then);

  final _DocumentSettings _self;
  final $Res Function(_DocumentSettings) _then;

/// Create a copy of DocumentSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? companyDetails = null,Object? layoutOptionsByType = null,Object? pricingTerms = null,Object? defaultTermsByType = null,Object? defaultFooterNote = null,Object? signatureBlockByType = null,Object? numberingRuleByType = null,Object? quotationValidityDays = null,Object? appearance = null,}) {
  return _then(_DocumentSettings(
companyDetails: null == companyDetails ? _self.companyDetails : companyDetails // ignore: cast_nullable_to_non_nullable
as CompanyDetails,layoutOptionsByType: null == layoutOptionsByType ? _self._layoutOptionsByType : layoutOptionsByType // ignore: cast_nullable_to_non_nullable
as Map<DocumentType, DocumentLayoutOptions>,pricingTerms: null == pricingTerms ? _self.pricingTerms : pricingTerms // ignore: cast_nullable_to_non_nullable
as PricingTerms,defaultTermsByType: null == defaultTermsByType ? _self._defaultTermsByType : defaultTermsByType // ignore: cast_nullable_to_non_nullable
as Map<DocumentType, String>,defaultFooterNote: null == defaultFooterNote ? _self.defaultFooterNote : defaultFooterNote // ignore: cast_nullable_to_non_nullable
as String,signatureBlockByType: null == signatureBlockByType ? _self._signatureBlockByType : signatureBlockByType // ignore: cast_nullable_to_non_nullable
as Map<DocumentType, SignatureBlock>,numberingRuleByType: null == numberingRuleByType ? _self._numberingRuleByType : numberingRuleByType // ignore: cast_nullable_to_non_nullable
as Map<DocumentType, DocumentNumberingRule>,quotationValidityDays: null == quotationValidityDays ? _self.quotationValidityDays : quotationValidityDays // ignore: cast_nullable_to_non_nullable
as int,appearance: null == appearance ? _self.appearance : appearance // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of DocumentSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyDetailsCopyWith<$Res> get companyDetails {
  
  return $CompanyDetailsCopyWith<$Res>(_self.companyDetails, (value) {
    return _then(_self.copyWith(companyDetails: value));
  });
}/// Create a copy of DocumentSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PricingTermsCopyWith<$Res> get pricingTerms {
  
  return $PricingTermsCopyWith<$Res>(_self.pricingTerms, (value) {
    return _then(_self.copyWith(pricingTerms: value));
  });
}
}

// dart format on
