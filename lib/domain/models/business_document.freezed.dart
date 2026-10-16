// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BusinessDocument {

 String get documentId; DocumentType get documentType; String get documentNumber; String get chainId; String? get sourceDocumentId; DateTime? get lockedAt; int get schemaVersion; DateTime get issueDate; DateTime? get validUntilDate; DateTime? get deliveryDate; String? get customerReference; CompanyDetails get companyDetails; CustomerDetails get customerDetails; DocumentLayoutOptions get layoutOptions; PricingTerms get pricingTerms; List<LineItem> get lineItems; String get notes; String get termsAndConditions; String get footerNote; SignatureBlock get signatureBlock; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of BusinessDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BusinessDocumentCopyWith<BusinessDocument> get copyWith => _$BusinessDocumentCopyWithImpl<BusinessDocument>(this as BusinessDocument, _$identity);

  /// Serializes this BusinessDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BusinessDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BusinessDocument&&(identical(other.documentId, _this.documentId) || other.documentId == _this.documentId)&&(identical(other.documentType, _this.documentType) || other.documentType == _this.documentType)&&(identical(other.documentNumber, _this.documentNumber) || other.documentNumber == _this.documentNumber)&&(identical(other.chainId, _this.chainId) || other.chainId == _this.chainId)&&(identical(other.sourceDocumentId, _this.sourceDocumentId) || other.sourceDocumentId == _this.sourceDocumentId)&&(identical(other.lockedAt, _this.lockedAt) || other.lockedAt == _this.lockedAt)&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.issueDate, _this.issueDate) || other.issueDate == _this.issueDate)&&(identical(other.validUntilDate, _this.validUntilDate) || other.validUntilDate == _this.validUntilDate)&&(identical(other.deliveryDate, _this.deliveryDate) || other.deliveryDate == _this.deliveryDate)&&(identical(other.customerReference, _this.customerReference) || other.customerReference == _this.customerReference)&&(identical(other.companyDetails, _this.companyDetails) || other.companyDetails == _this.companyDetails)&&(identical(other.customerDetails, _this.customerDetails) || other.customerDetails == _this.customerDetails)&&(identical(other.layoutOptions, _this.layoutOptions) || other.layoutOptions == _this.layoutOptions)&&(identical(other.pricingTerms, _this.pricingTerms) || other.pricingTerms == _this.pricingTerms)&&const DeepCollectionEquality().equals(other.lineItems, _this.lineItems)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.termsAndConditions, _this.termsAndConditions) || other.termsAndConditions == _this.termsAndConditions)&&(identical(other.footerNote, _this.footerNote) || other.footerNote == _this.footerNote)&&(identical(other.signatureBlock, _this.signatureBlock) || other.signatureBlock == _this.signatureBlock)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BusinessDocument;
  return Object.hashAll([runtimeType,_this.documentId,_this.documentType,_this.documentNumber,_this.chainId,_this.sourceDocumentId,_this.lockedAt,_this.schemaVersion,_this.issueDate,_this.validUntilDate,_this.deliveryDate,_this.customerReference,_this.companyDetails,_this.customerDetails,_this.layoutOptions,_this.pricingTerms,const DeepCollectionEquality().hash(_this.lineItems),_this.notes,_this.termsAndConditions,_this.footerNote,_this.signatureBlock,_this.createdAt,_this.updatedAt]);
}

@override
String toString() {
  final _this = this as BusinessDocument;
  return 'BusinessDocument(documentId: ${_this.documentId}, documentType: ${_this.documentType}, documentNumber: ${_this.documentNumber}, chainId: ${_this.chainId}, sourceDocumentId: ${_this.sourceDocumentId}, lockedAt: ${_this.lockedAt}, schemaVersion: ${_this.schemaVersion}, issueDate: ${_this.issueDate}, validUntilDate: ${_this.validUntilDate}, deliveryDate: ${_this.deliveryDate}, customerReference: ${_this.customerReference}, companyDetails: ${_this.companyDetails}, customerDetails: ${_this.customerDetails}, layoutOptions: ${_this.layoutOptions}, pricingTerms: ${_this.pricingTerms}, lineItems: ${_this.lineItems}, notes: ${_this.notes}, termsAndConditions: ${_this.termsAndConditions}, footerNote: ${_this.footerNote}, signatureBlock: ${_this.signatureBlock}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $BusinessDocumentCopyWith<$Res>  {
  factory $BusinessDocumentCopyWith(BusinessDocument value, $Res Function(BusinessDocument) _then) = _$BusinessDocumentCopyWithImpl;
@useResult
$Res call({
 String documentId, DocumentType documentType, String documentNumber, String chainId, String? sourceDocumentId, DateTime? lockedAt, int schemaVersion, DateTime issueDate, DateTime? validUntilDate, DateTime? deliveryDate, String? customerReference, CompanyDetails companyDetails, CustomerDetails customerDetails, DocumentLayoutOptions layoutOptions, PricingTerms pricingTerms, List<LineItem> lineItems, String notes, String termsAndConditions, String footerNote, SignatureBlock signatureBlock, DateTime createdAt, DateTime updatedAt
});


$CompanyDetailsCopyWith<$Res> get companyDetails;$CustomerDetailsCopyWith<$Res> get customerDetails;$DocumentLayoutOptionsCopyWith<$Res> get layoutOptions;$PricingTermsCopyWith<$Res> get pricingTerms;$SignatureBlockCopyWith<$Res> get signatureBlock;

}
/// @nodoc
class _$BusinessDocumentCopyWithImpl<$Res>
    implements $BusinessDocumentCopyWith<$Res> {
  _$BusinessDocumentCopyWithImpl(this._self, this._then);

  final BusinessDocument _self;
  final $Res Function(BusinessDocument) _then;

/// Create a copy of BusinessDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? documentType = null,Object? documentNumber = null,Object? chainId = null,Object? sourceDocumentId = freezed,Object? lockedAt = freezed,Object? schemaVersion = null,Object? issueDate = null,Object? validUntilDate = freezed,Object? deliveryDate = freezed,Object? customerReference = freezed,Object? companyDetails = null,Object? customerDetails = null,Object? layoutOptions = null,Object? pricingTerms = null,Object? lineItems = null,Object? notes = null,Object? termsAndConditions = null,Object? footerNote = null,Object? signatureBlock = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(BusinessDocument(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as DocumentType,documentNumber: null == documentNumber ? _self.documentNumber : documentNumber // ignore: cast_nullable_to_non_nullable
as String,chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as String,sourceDocumentId: freezed == sourceDocumentId ? _self.sourceDocumentId : sourceDocumentId // ignore: cast_nullable_to_non_nullable
as String?,lockedAt: freezed == lockedAt ? _self.lockedAt : lockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,validUntilDate: freezed == validUntilDate ? _self.validUntilDate : validUntilDate // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveryDate: freezed == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,customerReference: freezed == customerReference ? _self.customerReference : customerReference // ignore: cast_nullable_to_non_nullable
as String?,companyDetails: null == companyDetails ? _self.companyDetails : companyDetails // ignore: cast_nullable_to_non_nullable
as CompanyDetails,customerDetails: null == customerDetails ? _self.customerDetails : customerDetails // ignore: cast_nullable_to_non_nullable
as CustomerDetails,layoutOptions: null == layoutOptions ? _self.layoutOptions : layoutOptions // ignore: cast_nullable_to_non_nullable
as DocumentLayoutOptions,pricingTerms: null == pricingTerms ? _self.pricingTerms : pricingTerms // ignore: cast_nullable_to_non_nullable
as PricingTerms,lineItems: null == lineItems ? _self.lineItems : lineItems // ignore: cast_nullable_to_non_nullable
as List<LineItem>,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,termsAndConditions: null == termsAndConditions ? _self.termsAndConditions : termsAndConditions // ignore: cast_nullable_to_non_nullable
as String,footerNote: null == footerNote ? _self.footerNote : footerNote // ignore: cast_nullable_to_non_nullable
as String,signatureBlock: null == signatureBlock ? _self.signatureBlock : signatureBlock // ignore: cast_nullable_to_non_nullable
as SignatureBlock,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of BusinessDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyDetailsCopyWith<$Res> get companyDetails {
  
  return $CompanyDetailsCopyWith<$Res>(_self.companyDetails, (value) {
    return _then(_self.copyWith(companyDetails: value));
  });
}/// Create a copy of BusinessDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerDetailsCopyWith<$Res> get customerDetails {
  
  return $CustomerDetailsCopyWith<$Res>(_self.customerDetails, (value) {
    return _then(_self.copyWith(customerDetails: value));
  });
}/// Create a copy of BusinessDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentLayoutOptionsCopyWith<$Res> get layoutOptions {
  
  return $DocumentLayoutOptionsCopyWith<$Res>(_self.layoutOptions, (value) {
    return _then(_self.copyWith(layoutOptions: value));
  });
}/// Create a copy of BusinessDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PricingTermsCopyWith<$Res> get pricingTerms {
  
  return $PricingTermsCopyWith<$Res>(_self.pricingTerms, (value) {
    return _then(_self.copyWith(pricingTerms: value));
  });
}/// Create a copy of BusinessDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SignatureBlockCopyWith<$Res> get signatureBlock {
  
  return $SignatureBlockCopyWith<$Res>(_self.signatureBlock, (value) {
    return _then(_self.copyWith(signatureBlock: value));
  });
}
}


/// Adds pattern-matching-related methods to [BusinessDocument].
extension BusinessDocumentPatterns on BusinessDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BusinessDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BusinessDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BusinessDocument value)  $default,){
final _that = this;
switch (_that) {
case _BusinessDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BusinessDocument value)?  $default,){
final _that = this;
switch (_that) {
case _BusinessDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String documentId,  DocumentType documentType,  String documentNumber,  String chainId,  String? sourceDocumentId,  DateTime? lockedAt,  int schemaVersion,  DateTime issueDate,  DateTime? validUntilDate,  DateTime? deliveryDate,  String? customerReference,  CompanyDetails companyDetails,  CustomerDetails customerDetails,  DocumentLayoutOptions layoutOptions,  PricingTerms pricingTerms,  List<LineItem> lineItems,  String notes,  String termsAndConditions,  String footerNote,  SignatureBlock signatureBlock,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BusinessDocument() when $default != null:
return $default(_that.documentId,_that.documentType,_that.documentNumber,_that.chainId,_that.sourceDocumentId,_that.lockedAt,_that.schemaVersion,_that.issueDate,_that.validUntilDate,_that.deliveryDate,_that.customerReference,_that.companyDetails,_that.customerDetails,_that.layoutOptions,_that.pricingTerms,_that.lineItems,_that.notes,_that.termsAndConditions,_that.footerNote,_that.signatureBlock,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String documentId,  DocumentType documentType,  String documentNumber,  String chainId,  String? sourceDocumentId,  DateTime? lockedAt,  int schemaVersion,  DateTime issueDate,  DateTime? validUntilDate,  DateTime? deliveryDate,  String? customerReference,  CompanyDetails companyDetails,  CustomerDetails customerDetails,  DocumentLayoutOptions layoutOptions,  PricingTerms pricingTerms,  List<LineItem> lineItems,  String notes,  String termsAndConditions,  String footerNote,  SignatureBlock signatureBlock,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BusinessDocument():
return $default(_that.documentId,_that.documentType,_that.documentNumber,_that.chainId,_that.sourceDocumentId,_that.lockedAt,_that.schemaVersion,_that.issueDate,_that.validUntilDate,_that.deliveryDate,_that.customerReference,_that.companyDetails,_that.customerDetails,_that.layoutOptions,_that.pricingTerms,_that.lineItems,_that.notes,_that.termsAndConditions,_that.footerNote,_that.signatureBlock,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String documentId,  DocumentType documentType,  String documentNumber,  String chainId,  String? sourceDocumentId,  DateTime? lockedAt,  int schemaVersion,  DateTime issueDate,  DateTime? validUntilDate,  DateTime? deliveryDate,  String? customerReference,  CompanyDetails companyDetails,  CustomerDetails customerDetails,  DocumentLayoutOptions layoutOptions,  PricingTerms pricingTerms,  List<LineItem> lineItems,  String notes,  String termsAndConditions,  String footerNote,  SignatureBlock signatureBlock,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BusinessDocument() when $default != null:
return $default(_that.documentId,_that.documentType,_that.documentNumber,_that.chainId,_that.sourceDocumentId,_that.lockedAt,_that.schemaVersion,_that.issueDate,_that.validUntilDate,_that.deliveryDate,_that.customerReference,_that.companyDetails,_that.customerDetails,_that.layoutOptions,_that.pricingTerms,_that.lineItems,_that.notes,_that.termsAndConditions,_that.footerNote,_that.signatureBlock,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BusinessDocument extends BusinessDocument {
  const _BusinessDocument({required this.documentId, required this.documentType, required this.documentNumber, required this.chainId, this.sourceDocumentId, this.lockedAt, required this.schemaVersion, required this.issueDate, this.validUntilDate, this.deliveryDate, this.customerReference, required this.companyDetails, required this.customerDetails, required this.layoutOptions, required this.pricingTerms, required  List<LineItem> lineItems, this.notes = '', this.termsAndConditions = '', this.footerNote = '', required this.signatureBlock, required this.createdAt, required this.updatedAt}): _lineItems = lineItems,super._();
  factory _BusinessDocument.fromJson(Map<String, dynamic> json) => _$BusinessDocumentFromJson(json);

@override final  String documentId;
@override final  DocumentType documentType;
@override final  String documentNumber;
@override final  String chainId;
@override final  String? sourceDocumentId;
@override final  DateTime? lockedAt;
@override final  int schemaVersion;
@override final  DateTime issueDate;
@override final  DateTime? validUntilDate;
@override final  DateTime? deliveryDate;
@override final  String? customerReference;
@override final  CompanyDetails companyDetails;
@override final  CustomerDetails customerDetails;
@override final  DocumentLayoutOptions layoutOptions;
@override final  PricingTerms pricingTerms;
 final  List<LineItem> _lineItems;
@override List<LineItem> get lineItems {
  if (_lineItems is EqualUnmodifiableListView) return _lineItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lineItems);
}

@override@JsonKey() final  String notes;
@override@JsonKey() final  String termsAndConditions;
@override@JsonKey() final  String footerNote;
@override final  SignatureBlock signatureBlock;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of BusinessDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BusinessDocumentCopyWith<_BusinessDocument> get copyWith => __$BusinessDocumentCopyWithImpl<_BusinessDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BusinessDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BusinessDocument&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.documentNumber, documentNumber) || other.documentNumber == documentNumber)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.sourceDocumentId, sourceDocumentId) || other.sourceDocumentId == sourceDocumentId)&&(identical(other.lockedAt, lockedAt) || other.lockedAt == lockedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.validUntilDate, validUntilDate) || other.validUntilDate == validUntilDate)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.customerReference, customerReference) || other.customerReference == customerReference)&&(identical(other.companyDetails, companyDetails) || other.companyDetails == companyDetails)&&(identical(other.customerDetails, customerDetails) || other.customerDetails == customerDetails)&&(identical(other.layoutOptions, layoutOptions) || other.layoutOptions == layoutOptions)&&(identical(other.pricingTerms, pricingTerms) || other.pricingTerms == pricingTerms)&&const DeepCollectionEquality().equals(other.lineItems, _lineItems)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.termsAndConditions, termsAndConditions) || other.termsAndConditions == termsAndConditions)&&(identical(other.footerNote, footerNote) || other.footerNote == footerNote)&&(identical(other.signatureBlock, signatureBlock) || other.signatureBlock == signatureBlock)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,documentId,documentType,documentNumber,chainId,sourceDocumentId,lockedAt,schemaVersion,issueDate,validUntilDate,deliveryDate,customerReference,companyDetails,customerDetails,layoutOptions,pricingTerms,const DeepCollectionEquality().hash(_lineItems),notes,termsAndConditions,footerNote,signatureBlock,createdAt,updatedAt]);
}

@override
String toString() {
    return 'BusinessDocument(documentId: $documentId, documentType: $documentType, documentNumber: $documentNumber, chainId: $chainId, sourceDocumentId: $sourceDocumentId, lockedAt: $lockedAt, schemaVersion: $schemaVersion, issueDate: $issueDate, validUntilDate: $validUntilDate, deliveryDate: $deliveryDate, customerReference: $customerReference, companyDetails: $companyDetails, customerDetails: $customerDetails, layoutOptions: $layoutOptions, pricingTerms: $pricingTerms, lineItems: $lineItems, notes: $notes, termsAndConditions: $termsAndConditions, footerNote: $footerNote, signatureBlock: $signatureBlock, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BusinessDocumentCopyWith<$Res> implements $BusinessDocumentCopyWith<$Res> {
  factory _$BusinessDocumentCopyWith(_BusinessDocument value, $Res Function(_BusinessDocument) _then) = __$BusinessDocumentCopyWithImpl;
@override @useResult
$Res call({
 String documentId, DocumentType documentType, String documentNumber, String chainId, String? sourceDocumentId, DateTime? lockedAt, int schemaVersion, DateTime issueDate, DateTime? validUntilDate, DateTime? deliveryDate, String? customerReference, CompanyDetails companyDetails, CustomerDetails customerDetails, DocumentLayoutOptions layoutOptions, PricingTerms pricingTerms, List<LineItem> lineItems, String notes, String termsAndConditions, String footerNote, SignatureBlock signatureBlock, DateTime createdAt, DateTime updatedAt
});


@override $CompanyDetailsCopyWith<$Res> get companyDetails;@override $CustomerDetailsCopyWith<$Res> get customerDetails;@override $DocumentLayoutOptionsCopyWith<$Res> get layoutOptions;@override $PricingTermsCopyWith<$Res> get pricingTerms;@override $SignatureBlockCopyWith<$Res> get signatureBlock;

}
/// @nodoc
class __$BusinessDocumentCopyWithImpl<$Res>
    implements _$BusinessDocumentCopyWith<$Res> {
  __$BusinessDocumentCopyWithImpl(this._self, this._then);

  final _BusinessDocument _self;
  final $Res Function(_BusinessDocument) _then;

/// Create a copy of BusinessDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? documentType = null,Object? documentNumber = null,Object? chainId = null,Object? sourceDocumentId = freezed,Object? lockedAt = freezed,Object? schemaVersion = null,Object? issueDate = null,Object? validUntilDate = freezed,Object? deliveryDate = freezed,Object? customerReference = freezed,Object? companyDetails = null,Object? customerDetails = null,Object? layoutOptions = null,Object? pricingTerms = null,Object? lineItems = null,Object? notes = null,Object? termsAndConditions = null,Object? footerNote = null,Object? signatureBlock = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_BusinessDocument(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as DocumentType,documentNumber: null == documentNumber ? _self.documentNumber : documentNumber // ignore: cast_nullable_to_non_nullable
as String,chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as String,sourceDocumentId: freezed == sourceDocumentId ? _self.sourceDocumentId : sourceDocumentId // ignore: cast_nullable_to_non_nullable
as String?,lockedAt: freezed == lockedAt ? _self.lockedAt : lockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,validUntilDate: freezed == validUntilDate ? _self.validUntilDate : validUntilDate // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveryDate: freezed == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,customerReference: freezed == customerReference ? _self.customerReference : customerReference // ignore: cast_nullable_to_non_nullable
as String?,companyDetails: null == companyDetails ? _self.companyDetails : companyDetails // ignore: cast_nullable_to_non_nullable
as CompanyDetails,customerDetails: null == customerDetails ? _self.customerDetails : customerDetails // ignore: cast_nullable_to_non_nullable
as CustomerDetails,layoutOptions: null == layoutOptions ? _self.layoutOptions : layoutOptions // ignore: cast_nullable_to_non_nullable
as DocumentLayoutOptions,pricingTerms: null == pricingTerms ? _self.pricingTerms : pricingTerms // ignore: cast_nullable_to_non_nullable
as PricingTerms,lineItems: null == lineItems ? _self._lineItems : lineItems // ignore: cast_nullable_to_non_nullable
as List<LineItem>,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,termsAndConditions: null == termsAndConditions ? _self.termsAndConditions : termsAndConditions // ignore: cast_nullable_to_non_nullable
as String,footerNote: null == footerNote ? _self.footerNote : footerNote // ignore: cast_nullable_to_non_nullable
as String,signatureBlock: null == signatureBlock ? _self.signatureBlock : signatureBlock // ignore: cast_nullable_to_non_nullable
as SignatureBlock,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of BusinessDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyDetailsCopyWith<$Res> get companyDetails {
  
  return $CompanyDetailsCopyWith<$Res>(_self.companyDetails, (value) {
    return _then(_self.copyWith(companyDetails: value));
  });
}/// Create a copy of BusinessDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerDetailsCopyWith<$Res> get customerDetails {
  
  return $CustomerDetailsCopyWith<$Res>(_self.customerDetails, (value) {
    return _then(_self.copyWith(customerDetails: value));
  });
}/// Create a copy of BusinessDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentLayoutOptionsCopyWith<$Res> get layoutOptions {
  
  return $DocumentLayoutOptionsCopyWith<$Res>(_self.layoutOptions, (value) {
    return _then(_self.copyWith(layoutOptions: value));
  });
}/// Create a copy of BusinessDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PricingTermsCopyWith<$Res> get pricingTerms {
  
  return $PricingTermsCopyWith<$Res>(_self.pricingTerms, (value) {
    return _then(_self.copyWith(pricingTerms: value));
  });
}/// Create a copy of BusinessDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SignatureBlockCopyWith<$Res> get signatureBlock {
  
  return $SignatureBlockCopyWith<$Res>(_self.signatureBlock, (value) {
    return _then(_self.copyWith(signatureBlock: value));
  });
}
}

// dart format on
