// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_list_query.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentListQuery _$DocumentListQueryFromJson(Map<String, dynamic> json) =>
    _DocumentListQuery(
      documentType: $enumDecode(_$DocumentTypeEnumMap, json['documentType']),
      searchText: json['searchText'] as String? ?? '',
      issuedFrom: json['issuedFrom'] == null
          ? null
          : DateTime.parse(json['issuedFrom'] as String),
      issuedTo: json['issuedTo'] == null
          ? null
          : DateTime.parse(json['issuedTo'] as String),
      sortField:
          $enumDecodeNullable(_$DocumentSortFieldEnumMap, json['sortField']) ??
          DocumentSortField.issueDate,
      sortDescending: json['sortDescending'] as bool? ?? true,
      limit: (json['limit'] as num?)?.toInt() ?? 50,
    );

Map<String, dynamic> _$DocumentListQueryToJson(_DocumentListQuery instance) =>
    <String, dynamic>{
      'documentType': _$DocumentTypeEnumMap[instance.documentType]!,
      'searchText': instance.searchText,
      'issuedFrom': instance.issuedFrom?.toIso8601String(),
      'issuedTo': instance.issuedTo?.toIso8601String(),
      'sortField': _$DocumentSortFieldEnumMap[instance.sortField]!,
      'sortDescending': instance.sortDescending,
      'limit': instance.limit,
    };

const _$DocumentTypeEnumMap = {
  DocumentType.quotation: 'quotation',
  DocumentType.salesOrder: 'salesOrder',
  DocumentType.deliveryOrder: 'deliveryOrder',
};

const _$DocumentSortFieldEnumMap = {
  DocumentSortField.documentNumber: 'documentNumber',
  DocumentSortField.customerName: 'customerName',
  DocumentSortField.issueDate: 'issueDate',
  DocumentSortField.grandTotal: 'grandTotal',
  DocumentSortField.updatedAt: 'updatedAt',
};
