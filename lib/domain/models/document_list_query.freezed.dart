// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_list_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentListQuery {

 DocumentType get documentType; String get searchText; DateTime? get issuedFrom; DateTime? get issuedTo; DocumentSortField get sortField; bool get sortDescending; int get limit;
/// Create a copy of DocumentListQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentListQueryCopyWith<DocumentListQuery> get copyWith => _$DocumentListQueryCopyWithImpl<DocumentListQuery>(this as DocumentListQuery, _$identity);

  /// Serializes this DocumentListQuery to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DocumentListQuery;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentListQuery&&(identical(other.documentType, _this.documentType) || other.documentType == _this.documentType)&&(identical(other.searchText, _this.searchText) || other.searchText == _this.searchText)&&(identical(other.issuedFrom, _this.issuedFrom) || other.issuedFrom == _this.issuedFrom)&&(identical(other.issuedTo, _this.issuedTo) || other.issuedTo == _this.issuedTo)&&(identical(other.sortField, _this.sortField) || other.sortField == _this.sortField)&&(identical(other.sortDescending, _this.sortDescending) || other.sortDescending == _this.sortDescending)&&(identical(other.limit, _this.limit) || other.limit == _this.limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DocumentListQuery;
  return Object.hash(runtimeType,_this.documentType,_this.searchText,_this.issuedFrom,_this.issuedTo,_this.sortField,_this.sortDescending,_this.limit);
}

@override
String toString() {
  final _this = this as DocumentListQuery;
  return 'DocumentListQuery(documentType: ${_this.documentType}, searchText: ${_this.searchText}, issuedFrom: ${_this.issuedFrom}, issuedTo: ${_this.issuedTo}, sortField: ${_this.sortField}, sortDescending: ${_this.sortDescending}, limit: ${_this.limit})';
}


}

/// @nodoc
abstract mixin class $DocumentListQueryCopyWith<$Res>  {
  factory $DocumentListQueryCopyWith(DocumentListQuery value, $Res Function(DocumentListQuery) _then) = _$DocumentListQueryCopyWithImpl;
@useResult
$Res call({
 DocumentType documentType, String searchText, DateTime? issuedFrom, DateTime? issuedTo, DocumentSortField sortField, bool sortDescending, int limit
});




}
/// @nodoc
class _$DocumentListQueryCopyWithImpl<$Res>
    implements $DocumentListQueryCopyWith<$Res> {
  _$DocumentListQueryCopyWithImpl(this._self, this._then);

  final DocumentListQuery _self;
  final $Res Function(DocumentListQuery) _then;

/// Create a copy of DocumentListQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentType = null,Object? searchText = null,Object? issuedFrom = freezed,Object? issuedTo = freezed,Object? sortField = null,Object? sortDescending = null,Object? limit = null,}) {
  return _then(DocumentListQuery(
documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as DocumentType,searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,issuedFrom: freezed == issuedFrom ? _self.issuedFrom : issuedFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,issuedTo: freezed == issuedTo ? _self.issuedTo : issuedTo // ignore: cast_nullable_to_non_nullable
as DateTime?,sortField: null == sortField ? _self.sortField : sortField // ignore: cast_nullable_to_non_nullable
as DocumentSortField,sortDescending: null == sortDescending ? _self.sortDescending : sortDescending // ignore: cast_nullable_to_non_nullable
as bool,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentListQuery].
extension DocumentListQueryPatterns on DocumentListQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentListQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentListQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentListQuery value)  $default,){
final _that = this;
switch (_that) {
case _DocumentListQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentListQuery value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentListQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DocumentType documentType,  String searchText,  DateTime? issuedFrom,  DateTime? issuedTo,  DocumentSortField sortField,  bool sortDescending,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentListQuery() when $default != null:
return $default(_that.documentType,_that.searchText,_that.issuedFrom,_that.issuedTo,_that.sortField,_that.sortDescending,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DocumentType documentType,  String searchText,  DateTime? issuedFrom,  DateTime? issuedTo,  DocumentSortField sortField,  bool sortDescending,  int limit)  $default,) {final _that = this;
switch (_that) {
case _DocumentListQuery():
return $default(_that.documentType,_that.searchText,_that.issuedFrom,_that.issuedTo,_that.sortField,_that.sortDescending,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DocumentType documentType,  String searchText,  DateTime? issuedFrom,  DateTime? issuedTo,  DocumentSortField sortField,  bool sortDescending,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _DocumentListQuery() when $default != null:
return $default(_that.documentType,_that.searchText,_that.issuedFrom,_that.issuedTo,_that.sortField,_that.sortDescending,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentListQuery implements DocumentListQuery {
  const _DocumentListQuery({required this.documentType, this.searchText = '', this.issuedFrom, this.issuedTo, this.sortField = DocumentSortField.issueDate, this.sortDescending = true, this.limit = 50});
  factory _DocumentListQuery.fromJson(Map<String, dynamic> json) => _$DocumentListQueryFromJson(json);

@override final  DocumentType documentType;
@override@JsonKey() final  String searchText;
@override final  DateTime? issuedFrom;
@override final  DateTime? issuedTo;
@override@JsonKey() final  DocumentSortField sortField;
@override@JsonKey() final  bool sortDescending;
@override@JsonKey() final  int limit;

/// Create a copy of DocumentListQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentListQueryCopyWith<_DocumentListQuery> get copyWith => __$DocumentListQueryCopyWithImpl<_DocumentListQuery>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentListQueryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentListQuery&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.searchText, searchText) || other.searchText == searchText)&&(identical(other.issuedFrom, issuedFrom) || other.issuedFrom == issuedFrom)&&(identical(other.issuedTo, issuedTo) || other.issuedTo == issuedTo)&&(identical(other.sortField, sortField) || other.sortField == sortField)&&(identical(other.sortDescending, sortDescending) || other.sortDescending == sortDescending)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,documentType,searchText,issuedFrom,issuedTo,sortField,sortDescending,limit);
}

@override
String toString() {
    return 'DocumentListQuery(documentType: $documentType, searchText: $searchText, issuedFrom: $issuedFrom, issuedTo: $issuedTo, sortField: $sortField, sortDescending: $sortDescending, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$DocumentListQueryCopyWith<$Res> implements $DocumentListQueryCopyWith<$Res> {
  factory _$DocumentListQueryCopyWith(_DocumentListQuery value, $Res Function(_DocumentListQuery) _then) = __$DocumentListQueryCopyWithImpl;
@override @useResult
$Res call({
 DocumentType documentType, String searchText, DateTime? issuedFrom, DateTime? issuedTo, DocumentSortField sortField, bool sortDescending, int limit
});




}
/// @nodoc
class __$DocumentListQueryCopyWithImpl<$Res>
    implements _$DocumentListQueryCopyWith<$Res> {
  __$DocumentListQueryCopyWithImpl(this._self, this._then);

  final _DocumentListQuery _self;
  final $Res Function(_DocumentListQuery) _then;

/// Create a copy of DocumentListQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentType = null,Object? searchText = null,Object? issuedFrom = freezed,Object? issuedTo = freezed,Object? sortField = null,Object? sortDescending = null,Object? limit = null,}) {
  return _then(_DocumentListQuery(
documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as DocumentType,searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,issuedFrom: freezed == issuedFrom ? _self.issuedFrom : issuedFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,issuedTo: freezed == issuedTo ? _self.issuedTo : issuedTo // ignore: cast_nullable_to_non_nullable
as DateTime?,sortField: null == sortField ? _self.sortField : sortField // ignore: cast_nullable_to_non_nullable
as DocumentSortField,sortDescending: null == sortDescending ? _self.sortDescending : sortDescending // ignore: cast_nullable_to_non_nullable
as bool,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
