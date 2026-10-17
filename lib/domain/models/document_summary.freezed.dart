// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentSummary {

 String get documentId; DocumentType get documentType; String get documentNumber; String get chainId; String? get sourceDocumentId; String get customerName; DateTime get issueDate; int get grandTotalMinor;/// The document's own format, so a listed total never depends on the
/// current settings.
 CurrencyFormat get currencyFormat; bool get isLocked; DateTime get updatedAt;
/// Create a copy of DocumentSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentSummaryCopyWith<DocumentSummary> get copyWith => _$DocumentSummaryCopyWithImpl<DocumentSummary>(this as DocumentSummary, _$identity);

  /// Serializes this DocumentSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DocumentSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentSummary&&(identical(other.documentId, _this.documentId) || other.documentId == _this.documentId)&&(identical(other.documentType, _this.documentType) || other.documentType == _this.documentType)&&(identical(other.documentNumber, _this.documentNumber) || other.documentNumber == _this.documentNumber)&&(identical(other.chainId, _this.chainId) || other.chainId == _this.chainId)&&(identical(other.sourceDocumentId, _this.sourceDocumentId) || other.sourceDocumentId == _this.sourceDocumentId)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.issueDate, _this.issueDate) || other.issueDate == _this.issueDate)&&(identical(other.grandTotalMinor, _this.grandTotalMinor) || other.grandTotalMinor == _this.grandTotalMinor)&&(identical(other.currencyFormat, _this.currencyFormat) || other.currencyFormat == _this.currencyFormat)&&(identical(other.isLocked, _this.isLocked) || other.isLocked == _this.isLocked)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DocumentSummary;
  return Object.hash(runtimeType,_this.documentId,_this.documentType,_this.documentNumber,_this.chainId,_this.sourceDocumentId,_this.customerName,_this.issueDate,_this.grandTotalMinor,_this.currencyFormat,_this.isLocked,_this.updatedAt);
}

@override
String toString() {
  final _this = this as DocumentSummary;
  return 'DocumentSummary(documentId: ${_this.documentId}, documentType: ${_this.documentType}, documentNumber: ${_this.documentNumber}, chainId: ${_this.chainId}, sourceDocumentId: ${_this.sourceDocumentId}, customerName: ${_this.customerName}, issueDate: ${_this.issueDate}, grandTotalMinor: ${_this.grandTotalMinor}, currencyFormat: ${_this.currencyFormat}, isLocked: ${_this.isLocked}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $DocumentSummaryCopyWith<$Res>  {
  factory $DocumentSummaryCopyWith(DocumentSummary value, $Res Function(DocumentSummary) _then) = _$DocumentSummaryCopyWithImpl;
@useResult
$Res call({
 String documentId, DocumentType documentType, String documentNumber, String chainId, String? sourceDocumentId, String customerName, DateTime issueDate, int grandTotalMinor, CurrencyFormat currencyFormat, bool isLocked, DateTime updatedAt
});


$CurrencyFormatCopyWith<$Res> get currencyFormat;

}
/// @nodoc
class _$DocumentSummaryCopyWithImpl<$Res>
    implements $DocumentSummaryCopyWith<$Res> {
  _$DocumentSummaryCopyWithImpl(this._self, this._then);

  final DocumentSummary _self;
  final $Res Function(DocumentSummary) _then;

/// Create a copy of DocumentSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? documentType = null,Object? documentNumber = null,Object? chainId = null,Object? sourceDocumentId = freezed,Object? customerName = null,Object? issueDate = null,Object? grandTotalMinor = null,Object? currencyFormat = null,Object? isLocked = null,Object? updatedAt = null,}) {
  return _then(DocumentSummary(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as DocumentType,documentNumber: null == documentNumber ? _self.documentNumber : documentNumber // ignore: cast_nullable_to_non_nullable
as String,chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as String,sourceDocumentId: freezed == sourceDocumentId ? _self.sourceDocumentId : sourceDocumentId // ignore: cast_nullable_to_non_nullable
as String?,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,grandTotalMinor: null == grandTotalMinor ? _self.grandTotalMinor : grandTotalMinor // ignore: cast_nullable_to_non_nullable
as int,currencyFormat: null == currencyFormat ? _self.currencyFormat : currencyFormat // ignore: cast_nullable_to_non_nullable
as CurrencyFormat,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of DocumentSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurrencyFormatCopyWith<$Res> get currencyFormat {
  
  return $CurrencyFormatCopyWith<$Res>(_self.currencyFormat, (value) {
    return _then(_self.copyWith(currencyFormat: value));
  });
}
}


/// Adds pattern-matching-related methods to [DocumentSummary].
extension DocumentSummaryPatterns on DocumentSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentSummary value)  $default,){
final _that = this;
switch (_that) {
case _DocumentSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String documentId,  DocumentType documentType,  String documentNumber,  String chainId,  String? sourceDocumentId,  String customerName,  DateTime issueDate,  int grandTotalMinor,  CurrencyFormat currencyFormat,  bool isLocked,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentSummary() when $default != null:
return $default(_that.documentId,_that.documentType,_that.documentNumber,_that.chainId,_that.sourceDocumentId,_that.customerName,_that.issueDate,_that.grandTotalMinor,_that.currencyFormat,_that.isLocked,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String documentId,  DocumentType documentType,  String documentNumber,  String chainId,  String? sourceDocumentId,  String customerName,  DateTime issueDate,  int grandTotalMinor,  CurrencyFormat currencyFormat,  bool isLocked,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DocumentSummary():
return $default(_that.documentId,_that.documentType,_that.documentNumber,_that.chainId,_that.sourceDocumentId,_that.customerName,_that.issueDate,_that.grandTotalMinor,_that.currencyFormat,_that.isLocked,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String documentId,  DocumentType documentType,  String documentNumber,  String chainId,  String? sourceDocumentId,  String customerName,  DateTime issueDate,  int grandTotalMinor,  CurrencyFormat currencyFormat,  bool isLocked,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DocumentSummary() when $default != null:
return $default(_that.documentId,_that.documentType,_that.documentNumber,_that.chainId,_that.sourceDocumentId,_that.customerName,_that.issueDate,_that.grandTotalMinor,_that.currencyFormat,_that.isLocked,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentSummary extends DocumentSummary {
  const _DocumentSummary({required this.documentId, required this.documentType, required this.documentNumber, required this.chainId, this.sourceDocumentId, required this.customerName, required this.issueDate, required this.grandTotalMinor, required this.currencyFormat, required this.isLocked, required this.updatedAt}): super._();
  factory _DocumentSummary.fromJson(Map<String, dynamic> json) => _$DocumentSummaryFromJson(json);

@override final  String documentId;
@override final  DocumentType documentType;
@override final  String documentNumber;
@override final  String chainId;
@override final  String? sourceDocumentId;
@override final  String customerName;
@override final  DateTime issueDate;
@override final  int grandTotalMinor;
/// The document's own format, so a listed total never depends on the
/// current settings.
@override final  CurrencyFormat currencyFormat;
@override final  bool isLocked;
@override final  DateTime updatedAt;

/// Create a copy of DocumentSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentSummaryCopyWith<_DocumentSummary> get copyWith => __$DocumentSummaryCopyWithImpl<_DocumentSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentSummary&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.documentNumber, documentNumber) || other.documentNumber == documentNumber)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.sourceDocumentId, sourceDocumentId) || other.sourceDocumentId == sourceDocumentId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.grandTotalMinor, grandTotalMinor) || other.grandTotalMinor == grandTotalMinor)&&(identical(other.currencyFormat, currencyFormat) || other.currencyFormat == currencyFormat)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,documentId,documentType,documentNumber,chainId,sourceDocumentId,customerName,issueDate,grandTotalMinor,currencyFormat,isLocked,updatedAt);
}

@override
String toString() {
    return 'DocumentSummary(documentId: $documentId, documentType: $documentType, documentNumber: $documentNumber, chainId: $chainId, sourceDocumentId: $sourceDocumentId, customerName: $customerName, issueDate: $issueDate, grandTotalMinor: $grandTotalMinor, currencyFormat: $currencyFormat, isLocked: $isLocked, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DocumentSummaryCopyWith<$Res> implements $DocumentSummaryCopyWith<$Res> {
  factory _$DocumentSummaryCopyWith(_DocumentSummary value, $Res Function(_DocumentSummary) _then) = __$DocumentSummaryCopyWithImpl;
@override @useResult
$Res call({
 String documentId, DocumentType documentType, String documentNumber, String chainId, String? sourceDocumentId, String customerName, DateTime issueDate, int grandTotalMinor, CurrencyFormat currencyFormat, bool isLocked, DateTime updatedAt
});


@override $CurrencyFormatCopyWith<$Res> get currencyFormat;

}
/// @nodoc
class __$DocumentSummaryCopyWithImpl<$Res>
    implements _$DocumentSummaryCopyWith<$Res> {
  __$DocumentSummaryCopyWithImpl(this._self, this._then);

  final _DocumentSummary _self;
  final $Res Function(_DocumentSummary) _then;

/// Create a copy of DocumentSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? documentType = null,Object? documentNumber = null,Object? chainId = null,Object? sourceDocumentId = freezed,Object? customerName = null,Object? issueDate = null,Object? grandTotalMinor = null,Object? currencyFormat = null,Object? isLocked = null,Object? updatedAt = null,}) {
  return _then(_DocumentSummary(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as DocumentType,documentNumber: null == documentNumber ? _self.documentNumber : documentNumber // ignore: cast_nullable_to_non_nullable
as String,chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as String,sourceDocumentId: freezed == sourceDocumentId ? _self.sourceDocumentId : sourceDocumentId // ignore: cast_nullable_to_non_nullable
as String?,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,grandTotalMinor: null == grandTotalMinor ? _self.grandTotalMinor : grandTotalMinor // ignore: cast_nullable_to_non_nullable
as int,currencyFormat: null == currencyFormat ? _self.currencyFormat : currencyFormat // ignore: cast_nullable_to_non_nullable
as CurrencyFormat,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of DocumentSummary
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
