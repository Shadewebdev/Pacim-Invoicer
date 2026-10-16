// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DocumentEditorState {

 BusinessDocument get document; SaveStatus get saveStatus; List<ValidationIssue> get validationIssues;/// For a delivery order, the sales order it delivers against.
 BusinessDocument? get salesOrder;/// For a delivery order, the other delivery orders of the same chain.
 List<BusinessDocument> get otherDeliveryOrders;
/// Create a copy of DocumentEditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentEditorStateCopyWith<DocumentEditorState> get copyWith => _$DocumentEditorStateCopyWithImpl<DocumentEditorState>(this as DocumentEditorState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DocumentEditorState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentEditorState&&(identical(other.document, _this.document) || other.document == _this.document)&&(identical(other.saveStatus, _this.saveStatus) || other.saveStatus == _this.saveStatus)&&const DeepCollectionEquality().equals(other.validationIssues, _this.validationIssues)&&(identical(other.salesOrder, _this.salesOrder) || other.salesOrder == _this.salesOrder)&&const DeepCollectionEquality().equals(other.otherDeliveryOrders, _this.otherDeliveryOrders));
}


@override
int get hashCode {
  final _this = this as DocumentEditorState;
  return Object.hash(runtimeType,_this.document,_this.saveStatus,const DeepCollectionEquality().hash(_this.validationIssues),_this.salesOrder,const DeepCollectionEquality().hash(_this.otherDeliveryOrders));
}

@override
String toString() {
  final _this = this as DocumentEditorState;
  return 'DocumentEditorState(document: ${_this.document}, saveStatus: ${_this.saveStatus}, validationIssues: ${_this.validationIssues}, salesOrder: ${_this.salesOrder}, otherDeliveryOrders: ${_this.otherDeliveryOrders})';
}


}

/// @nodoc
abstract mixin class $DocumentEditorStateCopyWith<$Res>  {
  factory $DocumentEditorStateCopyWith(DocumentEditorState value, $Res Function(DocumentEditorState) _then) = _$DocumentEditorStateCopyWithImpl;
@useResult
$Res call({
 BusinessDocument document, SaveStatus saveStatus, List<ValidationIssue> validationIssues, BusinessDocument? salesOrder, List<BusinessDocument> otherDeliveryOrders
});


$BusinessDocumentCopyWith<$Res> get document;$BusinessDocumentCopyWith<$Res>? get salesOrder;

}
/// @nodoc
class _$DocumentEditorStateCopyWithImpl<$Res>
    implements $DocumentEditorStateCopyWith<$Res> {
  _$DocumentEditorStateCopyWithImpl(this._self, this._then);

  final DocumentEditorState _self;
  final $Res Function(DocumentEditorState) _then;

/// Create a copy of DocumentEditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? document = null,Object? saveStatus = null,Object? validationIssues = null,Object? salesOrder = freezed,Object? otherDeliveryOrders = null,}) {
  return _then(DocumentEditorState(
document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as BusinessDocument,saveStatus: null == saveStatus ? _self.saveStatus : saveStatus // ignore: cast_nullable_to_non_nullable
as SaveStatus,validationIssues: null == validationIssues ? _self.validationIssues : validationIssues // ignore: cast_nullable_to_non_nullable
as List<ValidationIssue>,salesOrder: freezed == salesOrder ? _self.salesOrder : salesOrder // ignore: cast_nullable_to_non_nullable
as BusinessDocument?,otherDeliveryOrders: null == otherDeliveryOrders ? _self.otherDeliveryOrders : otherDeliveryOrders // ignore: cast_nullable_to_non_nullable
as List<BusinessDocument>,
  ));
}
/// Create a copy of DocumentEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BusinessDocumentCopyWith<$Res> get document {
  
  return $BusinessDocumentCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}/// Create a copy of DocumentEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BusinessDocumentCopyWith<$Res>? get salesOrder {
    if (_self.salesOrder == null) {
    return null;
  }

  return $BusinessDocumentCopyWith<$Res>(_self.salesOrder!, (value) {
    return _then(_self.copyWith(salesOrder: value));
  });
}
}


/// Adds pattern-matching-related methods to [DocumentEditorState].
extension DocumentEditorStatePatterns on DocumentEditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentEditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentEditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentEditorState value)  $default,){
final _that = this;
switch (_that) {
case _DocumentEditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentEditorState value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentEditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BusinessDocument document,  SaveStatus saveStatus,  List<ValidationIssue> validationIssues,  BusinessDocument? salesOrder,  List<BusinessDocument> otherDeliveryOrders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentEditorState() when $default != null:
return $default(_that.document,_that.saveStatus,_that.validationIssues,_that.salesOrder,_that.otherDeliveryOrders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BusinessDocument document,  SaveStatus saveStatus,  List<ValidationIssue> validationIssues,  BusinessDocument? salesOrder,  List<BusinessDocument> otherDeliveryOrders)  $default,) {final _that = this;
switch (_that) {
case _DocumentEditorState():
return $default(_that.document,_that.saveStatus,_that.validationIssues,_that.salesOrder,_that.otherDeliveryOrders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BusinessDocument document,  SaveStatus saveStatus,  List<ValidationIssue> validationIssues,  BusinessDocument? salesOrder,  List<BusinessDocument> otherDeliveryOrders)?  $default,) {final _that = this;
switch (_that) {
case _DocumentEditorState() when $default != null:
return $default(_that.document,_that.saveStatus,_that.validationIssues,_that.salesOrder,_that.otherDeliveryOrders);case _:
  return null;

}
}

}

/// @nodoc


class _DocumentEditorState extends DocumentEditorState {
  const _DocumentEditorState({required this.document, this.saveStatus = SaveStatus.saved,  List<ValidationIssue> validationIssues = const [], this.salesOrder,  List<BusinessDocument> otherDeliveryOrders = const []}): _validationIssues = validationIssues,_otherDeliveryOrders = otherDeliveryOrders,super._();
  

@override final  BusinessDocument document;
@override@JsonKey() final  SaveStatus saveStatus;
 final  List<ValidationIssue> _validationIssues;
@override@JsonKey() List<ValidationIssue> get validationIssues {
  if (_validationIssues is EqualUnmodifiableListView) return _validationIssues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_validationIssues);
}

/// For a delivery order, the sales order it delivers against.
@override final  BusinessDocument? salesOrder;
/// For a delivery order, the other delivery orders of the same chain.
 final  List<BusinessDocument> _otherDeliveryOrders;
/// For a delivery order, the other delivery orders of the same chain.
@override@JsonKey() List<BusinessDocument> get otherDeliveryOrders {
  if (_otherDeliveryOrders is EqualUnmodifiableListView) return _otherDeliveryOrders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_otherDeliveryOrders);
}


/// Create a copy of DocumentEditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentEditorStateCopyWith<_DocumentEditorState> get copyWith => __$DocumentEditorStateCopyWithImpl<_DocumentEditorState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentEditorState&&(identical(other.document, document) || other.document == document)&&(identical(other.saveStatus, saveStatus) || other.saveStatus == saveStatus)&&const DeepCollectionEquality().equals(other.validationIssues, _validationIssues)&&(identical(other.salesOrder, salesOrder) || other.salesOrder == salesOrder)&&const DeepCollectionEquality().equals(other.otherDeliveryOrders, _otherDeliveryOrders));
}


@override
int get hashCode {
    return Object.hash(runtimeType,document,saveStatus,const DeepCollectionEquality().hash(_validationIssues),salesOrder,const DeepCollectionEquality().hash(_otherDeliveryOrders));
}

@override
String toString() {
    return 'DocumentEditorState(document: $document, saveStatus: $saveStatus, validationIssues: $validationIssues, salesOrder: $salesOrder, otherDeliveryOrders: $otherDeliveryOrders)';
}


}

/// @nodoc
abstract mixin class _$DocumentEditorStateCopyWith<$Res> implements $DocumentEditorStateCopyWith<$Res> {
  factory _$DocumentEditorStateCopyWith(_DocumentEditorState value, $Res Function(_DocumentEditorState) _then) = __$DocumentEditorStateCopyWithImpl;
@override @useResult
$Res call({
 BusinessDocument document, SaveStatus saveStatus, List<ValidationIssue> validationIssues, BusinessDocument? salesOrder, List<BusinessDocument> otherDeliveryOrders
});


@override $BusinessDocumentCopyWith<$Res> get document;@override $BusinessDocumentCopyWith<$Res>? get salesOrder;

}
/// @nodoc
class __$DocumentEditorStateCopyWithImpl<$Res>
    implements _$DocumentEditorStateCopyWith<$Res> {
  __$DocumentEditorStateCopyWithImpl(this._self, this._then);

  final _DocumentEditorState _self;
  final $Res Function(_DocumentEditorState) _then;

/// Create a copy of DocumentEditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? document = null,Object? saveStatus = null,Object? validationIssues = null,Object? salesOrder = freezed,Object? otherDeliveryOrders = null,}) {
  return _then(_DocumentEditorState(
document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as BusinessDocument,saveStatus: null == saveStatus ? _self.saveStatus : saveStatus // ignore: cast_nullable_to_non_nullable
as SaveStatus,validationIssues: null == validationIssues ? _self._validationIssues : validationIssues // ignore: cast_nullable_to_non_nullable
as List<ValidationIssue>,salesOrder: freezed == salesOrder ? _self.salesOrder : salesOrder // ignore: cast_nullable_to_non_nullable
as BusinessDocument?,otherDeliveryOrders: null == otherDeliveryOrders ? _self._otherDeliveryOrders : otherDeliveryOrders // ignore: cast_nullable_to_non_nullable
as List<BusinessDocument>,
  ));
}

/// Create a copy of DocumentEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BusinessDocumentCopyWith<$Res> get document {
  
  return $BusinessDocumentCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}/// Create a copy of DocumentEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BusinessDocumentCopyWith<$Res>? get salesOrder {
    if (_self.salesOrder == null) {
    return null;
  }

  return $BusinessDocumentCopyWith<$Res>(_self.salesOrder!, (value) {
    return _then(_self.copyWith(salesOrder: value));
  });
}
}

// dart format on
