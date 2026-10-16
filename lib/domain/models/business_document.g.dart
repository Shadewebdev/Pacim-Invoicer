// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BusinessDocument _$BusinessDocumentFromJson(Map<String, dynamic> json) =>
    _BusinessDocument(
      documentId: json['documentId'] as String,
      documentType: $enumDecode(_$DocumentTypeEnumMap, json['documentType']),
      documentNumber: json['documentNumber'] as String,
      chainId: json['chainId'] as String,
      sourceDocumentId: json['sourceDocumentId'] as String?,
      lockedAt: json['lockedAt'] == null
          ? null
          : DateTime.parse(json['lockedAt'] as String),
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      issueDate: DateTime.parse(json['issueDate'] as String),
      validUntilDate: json['validUntilDate'] == null
          ? null
          : DateTime.parse(json['validUntilDate'] as String),
      deliveryDate: json['deliveryDate'] == null
          ? null
          : DateTime.parse(json['deliveryDate'] as String),
      customerReference: json['customerReference'] as String?,
      companyDetails: CompanyDetails.fromJson(
        json['companyDetails'] as Map<String, dynamic>,
      ),
      customerDetails: CustomerDetails.fromJson(
        json['customerDetails'] as Map<String, dynamic>,
      ),
      layoutOptions: DocumentLayoutOptions.fromJson(
        json['layoutOptions'] as Map<String, dynamic>,
      ),
      pricingTerms: PricingTerms.fromJson(
        json['pricingTerms'] as Map<String, dynamic>,
      ),
      lineItems: (json['lineItems'] as List<dynamic>)
          .map((e) => LineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String? ?? '',
      termsAndConditions: json['termsAndConditions'] as String? ?? '',
      footerNote: json['footerNote'] as String? ?? '',
      signatureBlock: SignatureBlock.fromJson(
        json['signatureBlock'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BusinessDocumentToJson(_BusinessDocument instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'documentType': _$DocumentTypeEnumMap[instance.documentType]!,
      'documentNumber': instance.documentNumber,
      'chainId': instance.chainId,
      'sourceDocumentId': instance.sourceDocumentId,
      'lockedAt': instance.lockedAt?.toIso8601String(),
      'schemaVersion': instance.schemaVersion,
      'issueDate': instance.issueDate.toIso8601String(),
      'validUntilDate': instance.validUntilDate?.toIso8601String(),
      'deliveryDate': instance.deliveryDate?.toIso8601String(),
      'customerReference': instance.customerReference,
      'companyDetails': instance.companyDetails.toJson(),
      'customerDetails': instance.customerDetails.toJson(),
      'layoutOptions': instance.layoutOptions.toJson(),
      'pricingTerms': instance.pricingTerms.toJson(),
      'lineItems': instance.lineItems.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
      'termsAndConditions': instance.termsAndConditions,
      'footerNote': instance.footerNote,
      'signatureBlock': instance.signatureBlock.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$DocumentTypeEnumMap = {
  DocumentType.quotation: 'quotation',
  DocumentType.salesOrder: 'salesOrder',
  DocumentType.deliveryOrder: 'deliveryOrder',
};
