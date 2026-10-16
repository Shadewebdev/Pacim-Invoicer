// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_layout_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentLayoutOptions {

 bool get showLogo; bool get showCompanyRegistration; bool get showCustomerReference; bool get showNotes; bool get showTermsAndConditions; bool get showFooterNote; bool get showSignature; bool get showPageNumbers; bool get showDiscountColumn; bool get showUnitColumn;
/// Create a copy of DocumentLayoutOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentLayoutOptionsCopyWith<DocumentLayoutOptions> get copyWith => _$DocumentLayoutOptionsCopyWithImpl<DocumentLayoutOptions>(this as DocumentLayoutOptions, _$identity);

  /// Serializes this DocumentLayoutOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DocumentLayoutOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentLayoutOptions&&(identical(other.showLogo, _this.showLogo) || other.showLogo == _this.showLogo)&&(identical(other.showCompanyRegistration, _this.showCompanyRegistration) || other.showCompanyRegistration == _this.showCompanyRegistration)&&(identical(other.showCustomerReference, _this.showCustomerReference) || other.showCustomerReference == _this.showCustomerReference)&&(identical(other.showNotes, _this.showNotes) || other.showNotes == _this.showNotes)&&(identical(other.showTermsAndConditions, _this.showTermsAndConditions) || other.showTermsAndConditions == _this.showTermsAndConditions)&&(identical(other.showFooterNote, _this.showFooterNote) || other.showFooterNote == _this.showFooterNote)&&(identical(other.showSignature, _this.showSignature) || other.showSignature == _this.showSignature)&&(identical(other.showPageNumbers, _this.showPageNumbers) || other.showPageNumbers == _this.showPageNumbers)&&(identical(other.showDiscountColumn, _this.showDiscountColumn) || other.showDiscountColumn == _this.showDiscountColumn)&&(identical(other.showUnitColumn, _this.showUnitColumn) || other.showUnitColumn == _this.showUnitColumn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DocumentLayoutOptions;
  return Object.hash(runtimeType,_this.showLogo,_this.showCompanyRegistration,_this.showCustomerReference,_this.showNotes,_this.showTermsAndConditions,_this.showFooterNote,_this.showSignature,_this.showPageNumbers,_this.showDiscountColumn,_this.showUnitColumn);
}

@override
String toString() {
  final _this = this as DocumentLayoutOptions;
  return 'DocumentLayoutOptions(showLogo: ${_this.showLogo}, showCompanyRegistration: ${_this.showCompanyRegistration}, showCustomerReference: ${_this.showCustomerReference}, showNotes: ${_this.showNotes}, showTermsAndConditions: ${_this.showTermsAndConditions}, showFooterNote: ${_this.showFooterNote}, showSignature: ${_this.showSignature}, showPageNumbers: ${_this.showPageNumbers}, showDiscountColumn: ${_this.showDiscountColumn}, showUnitColumn: ${_this.showUnitColumn})';
}


}

/// @nodoc
abstract mixin class $DocumentLayoutOptionsCopyWith<$Res>  {
  factory $DocumentLayoutOptionsCopyWith(DocumentLayoutOptions value, $Res Function(DocumentLayoutOptions) _then) = _$DocumentLayoutOptionsCopyWithImpl;
@useResult
$Res call({
 bool showLogo, bool showCompanyRegistration, bool showCustomerReference, bool showNotes, bool showTermsAndConditions, bool showFooterNote, bool showSignature, bool showPageNumbers, bool showDiscountColumn, bool showUnitColumn
});




}
/// @nodoc
class _$DocumentLayoutOptionsCopyWithImpl<$Res>
    implements $DocumentLayoutOptionsCopyWith<$Res> {
  _$DocumentLayoutOptionsCopyWithImpl(this._self, this._then);

  final DocumentLayoutOptions _self;
  final $Res Function(DocumentLayoutOptions) _then;

/// Create a copy of DocumentLayoutOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? showLogo = null,Object? showCompanyRegistration = null,Object? showCustomerReference = null,Object? showNotes = null,Object? showTermsAndConditions = null,Object? showFooterNote = null,Object? showSignature = null,Object? showPageNumbers = null,Object? showDiscountColumn = null,Object? showUnitColumn = null,}) {
  return _then(DocumentLayoutOptions(
showLogo: null == showLogo ? _self.showLogo : showLogo // ignore: cast_nullable_to_non_nullable
as bool,showCompanyRegistration: null == showCompanyRegistration ? _self.showCompanyRegistration : showCompanyRegistration // ignore: cast_nullable_to_non_nullable
as bool,showCustomerReference: null == showCustomerReference ? _self.showCustomerReference : showCustomerReference // ignore: cast_nullable_to_non_nullable
as bool,showNotes: null == showNotes ? _self.showNotes : showNotes // ignore: cast_nullable_to_non_nullable
as bool,showTermsAndConditions: null == showTermsAndConditions ? _self.showTermsAndConditions : showTermsAndConditions // ignore: cast_nullable_to_non_nullable
as bool,showFooterNote: null == showFooterNote ? _self.showFooterNote : showFooterNote // ignore: cast_nullable_to_non_nullable
as bool,showSignature: null == showSignature ? _self.showSignature : showSignature // ignore: cast_nullable_to_non_nullable
as bool,showPageNumbers: null == showPageNumbers ? _self.showPageNumbers : showPageNumbers // ignore: cast_nullable_to_non_nullable
as bool,showDiscountColumn: null == showDiscountColumn ? _self.showDiscountColumn : showDiscountColumn // ignore: cast_nullable_to_non_nullable
as bool,showUnitColumn: null == showUnitColumn ? _self.showUnitColumn : showUnitColumn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentLayoutOptions].
extension DocumentLayoutOptionsPatterns on DocumentLayoutOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentLayoutOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentLayoutOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentLayoutOptions value)  $default,){
final _that = this;
switch (_that) {
case _DocumentLayoutOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentLayoutOptions value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentLayoutOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool showLogo,  bool showCompanyRegistration,  bool showCustomerReference,  bool showNotes,  bool showTermsAndConditions,  bool showFooterNote,  bool showSignature,  bool showPageNumbers,  bool showDiscountColumn,  bool showUnitColumn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentLayoutOptions() when $default != null:
return $default(_that.showLogo,_that.showCompanyRegistration,_that.showCustomerReference,_that.showNotes,_that.showTermsAndConditions,_that.showFooterNote,_that.showSignature,_that.showPageNumbers,_that.showDiscountColumn,_that.showUnitColumn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool showLogo,  bool showCompanyRegistration,  bool showCustomerReference,  bool showNotes,  bool showTermsAndConditions,  bool showFooterNote,  bool showSignature,  bool showPageNumbers,  bool showDiscountColumn,  bool showUnitColumn)  $default,) {final _that = this;
switch (_that) {
case _DocumentLayoutOptions():
return $default(_that.showLogo,_that.showCompanyRegistration,_that.showCustomerReference,_that.showNotes,_that.showTermsAndConditions,_that.showFooterNote,_that.showSignature,_that.showPageNumbers,_that.showDiscountColumn,_that.showUnitColumn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool showLogo,  bool showCompanyRegistration,  bool showCustomerReference,  bool showNotes,  bool showTermsAndConditions,  bool showFooterNote,  bool showSignature,  bool showPageNumbers,  bool showDiscountColumn,  bool showUnitColumn)?  $default,) {final _that = this;
switch (_that) {
case _DocumentLayoutOptions() when $default != null:
return $default(_that.showLogo,_that.showCompanyRegistration,_that.showCustomerReference,_that.showNotes,_that.showTermsAndConditions,_that.showFooterNote,_that.showSignature,_that.showPageNumbers,_that.showDiscountColumn,_that.showUnitColumn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentLayoutOptions implements DocumentLayoutOptions {
  const _DocumentLayoutOptions({this.showLogo = true, this.showCompanyRegistration = true, this.showCustomerReference = true, this.showNotes = true, this.showTermsAndConditions = true, this.showFooterNote = true, this.showSignature = true, this.showPageNumbers = true, this.showDiscountColumn = false, this.showUnitColumn = true});
  factory _DocumentLayoutOptions.fromJson(Map<String, dynamic> json) => _$DocumentLayoutOptionsFromJson(json);

@override@JsonKey() final  bool showLogo;
@override@JsonKey() final  bool showCompanyRegistration;
@override@JsonKey() final  bool showCustomerReference;
@override@JsonKey() final  bool showNotes;
@override@JsonKey() final  bool showTermsAndConditions;
@override@JsonKey() final  bool showFooterNote;
@override@JsonKey() final  bool showSignature;
@override@JsonKey() final  bool showPageNumbers;
@override@JsonKey() final  bool showDiscountColumn;
@override@JsonKey() final  bool showUnitColumn;

/// Create a copy of DocumentLayoutOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentLayoutOptionsCopyWith<_DocumentLayoutOptions> get copyWith => __$DocumentLayoutOptionsCopyWithImpl<_DocumentLayoutOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentLayoutOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentLayoutOptions&&(identical(other.showLogo, showLogo) || other.showLogo == showLogo)&&(identical(other.showCompanyRegistration, showCompanyRegistration) || other.showCompanyRegistration == showCompanyRegistration)&&(identical(other.showCustomerReference, showCustomerReference) || other.showCustomerReference == showCustomerReference)&&(identical(other.showNotes, showNotes) || other.showNotes == showNotes)&&(identical(other.showTermsAndConditions, showTermsAndConditions) || other.showTermsAndConditions == showTermsAndConditions)&&(identical(other.showFooterNote, showFooterNote) || other.showFooterNote == showFooterNote)&&(identical(other.showSignature, showSignature) || other.showSignature == showSignature)&&(identical(other.showPageNumbers, showPageNumbers) || other.showPageNumbers == showPageNumbers)&&(identical(other.showDiscountColumn, showDiscountColumn) || other.showDiscountColumn == showDiscountColumn)&&(identical(other.showUnitColumn, showUnitColumn) || other.showUnitColumn == showUnitColumn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,showLogo,showCompanyRegistration,showCustomerReference,showNotes,showTermsAndConditions,showFooterNote,showSignature,showPageNumbers,showDiscountColumn,showUnitColumn);
}

@override
String toString() {
    return 'DocumentLayoutOptions(showLogo: $showLogo, showCompanyRegistration: $showCompanyRegistration, showCustomerReference: $showCustomerReference, showNotes: $showNotes, showTermsAndConditions: $showTermsAndConditions, showFooterNote: $showFooterNote, showSignature: $showSignature, showPageNumbers: $showPageNumbers, showDiscountColumn: $showDiscountColumn, showUnitColumn: $showUnitColumn)';
}


}

/// @nodoc
abstract mixin class _$DocumentLayoutOptionsCopyWith<$Res> implements $DocumentLayoutOptionsCopyWith<$Res> {
  factory _$DocumentLayoutOptionsCopyWith(_DocumentLayoutOptions value, $Res Function(_DocumentLayoutOptions) _then) = __$DocumentLayoutOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool showLogo, bool showCompanyRegistration, bool showCustomerReference, bool showNotes, bool showTermsAndConditions, bool showFooterNote, bool showSignature, bool showPageNumbers, bool showDiscountColumn, bool showUnitColumn
});




}
/// @nodoc
class __$DocumentLayoutOptionsCopyWithImpl<$Res>
    implements _$DocumentLayoutOptionsCopyWith<$Res> {
  __$DocumentLayoutOptionsCopyWithImpl(this._self, this._then);

  final _DocumentLayoutOptions _self;
  final $Res Function(_DocumentLayoutOptions) _then;

/// Create a copy of DocumentLayoutOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? showLogo = null,Object? showCompanyRegistration = null,Object? showCustomerReference = null,Object? showNotes = null,Object? showTermsAndConditions = null,Object? showFooterNote = null,Object? showSignature = null,Object? showPageNumbers = null,Object? showDiscountColumn = null,Object? showUnitColumn = null,}) {
  return _then(_DocumentLayoutOptions(
showLogo: null == showLogo ? _self.showLogo : showLogo // ignore: cast_nullable_to_non_nullable
as bool,showCompanyRegistration: null == showCompanyRegistration ? _self.showCompanyRegistration : showCompanyRegistration // ignore: cast_nullable_to_non_nullable
as bool,showCustomerReference: null == showCustomerReference ? _self.showCustomerReference : showCustomerReference // ignore: cast_nullable_to_non_nullable
as bool,showNotes: null == showNotes ? _self.showNotes : showNotes // ignore: cast_nullable_to_non_nullable
as bool,showTermsAndConditions: null == showTermsAndConditions ? _self.showTermsAndConditions : showTermsAndConditions // ignore: cast_nullable_to_non_nullable
as bool,showFooterNote: null == showFooterNote ? _self.showFooterNote : showFooterNote // ignore: cast_nullable_to_non_nullable
as bool,showSignature: null == showSignature ? _self.showSignature : showSignature // ignore: cast_nullable_to_non_nullable
as bool,showPageNumbers: null == showPageNumbers ? _self.showPageNumbers : showPageNumbers // ignore: cast_nullable_to_non_nullable
as bool,showDiscountColumn: null == showDiscountColumn ? _self.showDiscountColumn : showDiscountColumn // ignore: cast_nullable_to_non_nullable
as bool,showUnitColumn: null == showUnitColumn ? _self.showUnitColumn : showUnitColumn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
