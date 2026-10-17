// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentSummary _$DocumentSummaryFromJson(Map<String, dynamic> json) =>
    _DocumentSummary(
      documentId: json['documentId'] as String,
      documentType: $enumDecode(_$DocumentTypeEnumMap, json['documentType']),
      documentNumber: json['documentNumber'] as String,
      chainId: json['chainId'] as String,
      sourceDocumentId: json['sourceDocumentId'] as String?,
      customerName: json['customerName'] as String,
      issueDate: DateTime.parse(json['issueDate'] as String),
      grandTotalMinor: (json['grandTotalMinor'] as num).toInt(),
      currencyFormat: CurrencyFormat.fromJson(
        json['currencyFormat'] as Map<String, dynamic>,
      ),
      isLocked: json['isLocked'] as bool,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DocumentSummaryToJson(_DocumentSummary instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'documentType': _$DocumentTypeEnumMap[instance.documentType]!,
      'documentNumber': instance.documentNumber,
      'chainId': instance.chainId,
      'sourceDocumentId': instance.sourceDocumentId,
      'customerName': instance.customerName,
      'issueDate': instance.issueDate.toIso8601String(),
      'grandTotalMinor': instance.grandTotalMinor,
      'currencyFormat': instance.currencyFormat.toJson(),
      'isLocked': instance.isLocked,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$DocumentTypeEnumMap = {
  DocumentType.quotation: 'quotation',
  DocumentType.salesOrder: 'salesOrder',
  DocumentType.deliveryOrder: 'deliveryOrder',
};
