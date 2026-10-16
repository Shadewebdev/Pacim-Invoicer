// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_chain.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentChain {

 String get chainId; DocumentSummary? get quotation; DocumentSummary? get salesOrder;/// Ordered by document number.
 List<DocumentSummary> get deliveryOrders;
/// Create a copy of DocumentChain
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentChainCopyWith<DocumentChain> get copyWith => _$DocumentChainCopyWithImpl<DocumentChain>(this as DocumentChain, _$identity);

  /// Serializes this DocumentChain to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DocumentChain;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentChain&&(identical(other.chainId, _this.chainId) || other.chainId == _this.chainId)&&(identical(other.quotation, _this.quotation) || other.quotation == _this.quotation)&&(identical(other.salesOrder, _this.salesOrder) || other.salesOrder == _this.salesOrder)&&const DeepCollectionEquality().equals(other.deliveryOrders, _this.deliveryOrders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DocumentChain;
  return Object.hash(runtimeType,_this.chainId,_this.quotation,_this.salesOrder,const DeepCollectionEquality().hash(_this.deliveryOrders));
}

@override
String toString() {
  final _this = this as DocumentChain;
  return 'DocumentChain(chainId: ${_this.chainId}, quotation: ${_this.quotation}, salesOrder: ${_this.salesOrder}, deliveryOrders: ${_this.deliveryOrders})';
}


}

/// @nodoc
abstract mixin class $DocumentChainCopyWith<$Res>  {
  factory $DocumentChainCopyWith(DocumentChain value, $Res Function(DocumentChain) _then) = _$DocumentChainCopyWithImpl;
@useResult
$Res call({
 String chainId, DocumentSummary? quotation, DocumentSummary? salesOrder, List<DocumentSummary> deliveryOrders
});


$DocumentSummaryCopyWith<$Res>? get quotation;$DocumentSummaryCopyWith<$Res>? get salesOrder;

}
/// @nodoc
class _$DocumentChainCopyWithImpl<$Res>
    implements $DocumentChainCopyWith<$Res> {
  _$DocumentChainCopyWithImpl(this._self, this._then);

  final DocumentChain _self;
  final $Res Function(DocumentChain) _then;

/// Create a copy of DocumentChain
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chainId = null,Object? quotation = freezed,Object? salesOrder = freezed,Object? deliveryOrders = null,}) {
  return _then(DocumentChain(
chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as String,quotation: freezed == quotation ? _self.quotation : quotation // ignore: cast_nullable_to_non_nullable
as DocumentSummary?,salesOrder: freezed == salesOrder ? _self.salesOrder : salesOrder // ignore: cast_nullable_to_non_nullable
as DocumentSummary?,deliveryOrders: null == deliveryOrders ? _self.deliveryOrders : deliveryOrders // ignore: cast_nullable_to_non_nullable
as List<DocumentSummary>,
  ));
}
/// Create a copy of DocumentChain
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentSummaryCopyWith<$Res>? get quotation {
    if (_self.quotation == null) {
    return null;
  }

  return $DocumentSummaryCopyWith<$Res>(_self.quotation!, (value) {
    return _then(_self.copyWith(quotation: value));
  });
}/// Create a copy of DocumentChain
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentSummaryCopyWith<$Res>? get salesOrder {
    if (_self.salesOrder == null) {
    return null;
  }

  return $DocumentSummaryCopyWith<$Res>(_self.salesOrder!, (value) {
    return _then(_self.copyWith(salesOrder: value));
  });
}
}


/// Adds pattern-matching-related methods to [DocumentChain].
extension DocumentChainPatterns on DocumentChain {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentChain value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentChain() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentChain value)  $default,){
final _that = this;
switch (_that) {
case _DocumentChain():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentChain value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentChain() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String chainId,  DocumentSummary? quotation,  DocumentSummary? salesOrder,  List<DocumentSummary> deliveryOrders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentChain() when $default != null:
return $default(_that.chainId,_that.quotation,_that.salesOrder,_that.deliveryOrders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String chainId,  DocumentSummary? quotation,  DocumentSummary? salesOrder,  List<DocumentSummary> deliveryOrders)  $default,) {final _that = this;
switch (_that) {
case _DocumentChain():
return $default(_that.chainId,_that.quotation,_that.salesOrder,_that.deliveryOrders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String chainId,  DocumentSummary? quotation,  DocumentSummary? salesOrder,  List<DocumentSummary> deliveryOrders)?  $default,) {final _that = this;
switch (_that) {
case _DocumentChain() when $default != null:
return $default(_that.chainId,_that.quotation,_that.salesOrder,_that.deliveryOrders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentChain implements DocumentChain {
  const _DocumentChain({required this.chainId, this.quotation, this.salesOrder,  List<DocumentSummary> deliveryOrders = const <DocumentSummary>[]}): _deliveryOrders = deliveryOrders;
  factory _DocumentChain.fromJson(Map<String, dynamic> json) => _$DocumentChainFromJson(json);

@override final  String chainId;
@override final  DocumentSummary? quotation;
@override final  DocumentSummary? salesOrder;
/// Ordered by document number.
 final  List<DocumentSummary> _deliveryOrders;
/// Ordered by document number.
@override@JsonKey() List<DocumentSummary> get deliveryOrders {
  if (_deliveryOrders is EqualUnmodifiableListView) return _deliveryOrders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deliveryOrders);
}


/// Create a copy of DocumentChain
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentChainCopyWith<_DocumentChain> get copyWith => __$DocumentChainCopyWithImpl<_DocumentChain>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentChainToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentChain&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.quotation, quotation) || other.quotation == quotation)&&(identical(other.salesOrder, salesOrder) || other.salesOrder == salesOrder)&&const DeepCollectionEquality().equals(other.deliveryOrders, _deliveryOrders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,chainId,quotation,salesOrder,const DeepCollectionEquality().hash(_deliveryOrders));
}

@override
String toString() {
    return 'DocumentChain(chainId: $chainId, quotation: $quotation, salesOrder: $salesOrder, deliveryOrders: $deliveryOrders)';
}


}

/// @nodoc
abstract mixin class _$DocumentChainCopyWith<$Res> implements $DocumentChainCopyWith<$Res> {
  factory _$DocumentChainCopyWith(_DocumentChain value, $Res Function(_DocumentChain) _then) = __$DocumentChainCopyWithImpl;
@override @useResult
$Res call({
 String chainId, DocumentSummary? quotation, DocumentSummary? salesOrder, List<DocumentSummary> deliveryOrders
});


@override $DocumentSummaryCopyWith<$Res>? get quotation;@override $DocumentSummaryCopyWith<$Res>? get salesOrder;

}
/// @nodoc
class __$DocumentChainCopyWithImpl<$Res>
    implements _$DocumentChainCopyWith<$Res> {
  __$DocumentChainCopyWithImpl(this._self, this._then);

  final _DocumentChain _self;
  final $Res Function(_DocumentChain) _then;

/// Create a copy of DocumentChain
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chainId = null,Object? quotation = freezed,Object? salesOrder = freezed,Object? deliveryOrders = null,}) {
  return _then(_DocumentChain(
chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as String,quotation: freezed == quotation ? _self.quotation : quotation // ignore: cast_nullable_to_non_nullable
as DocumentSummary?,salesOrder: freezed == salesOrder ? _self.salesOrder : salesOrder // ignore: cast_nullable_to_non_nullable
as DocumentSummary?,deliveryOrders: null == deliveryOrders ? _self._deliveryOrders : deliveryOrders // ignore: cast_nullable_to_non_nullable
as List<DocumentSummary>,
  ));
}

/// Create a copy of DocumentChain
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentSummaryCopyWith<$Res>? get quotation {
    if (_self.quotation == null) {
    return null;
  }

  return $DocumentSummaryCopyWith<$Res>(_self.quotation!, (value) {
    return _then(_self.copyWith(quotation: value));
  });
}/// Create a copy of DocumentChain
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentSummaryCopyWith<$Res>? get salesOrder {
    if (_self.salesOrder == null) {
    return null;
  }

  return $DocumentSummaryCopyWith<$Res>(_self.salesOrder!, (value) {
    return _then(_self.copyWith(salesOrder: value));
  });
}
}

// dart format on
