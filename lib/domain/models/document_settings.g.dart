// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentSettings _$DocumentSettingsFromJson(
  Map<String, dynamic> json,
) => _DocumentSettings(
  companyDetails: CompanyDetails.fromJson(
    json['companyDetails'] as Map<String, dynamic>,
  ),
  layoutOptionsByType: (json['layoutOptionsByType'] as Map<String, dynamic>)
      .map(
        (k, e) => MapEntry(
          $enumDecode(_$DocumentTypeEnumMap, k),
          DocumentLayoutOptions.fromJson(e as Map<String, dynamic>),
        ),
      ),
  pricingTerms: PricingTerms.fromJson(
    json['pricingTerms'] as Map<String, dynamic>,
  ),
  defaultTermsByType: (json['defaultTermsByType'] as Map<String, dynamic>).map(
    (k, e) => MapEntry($enumDecode(_$DocumentTypeEnumMap, k), e as String),
  ),
  defaultFooterNote: json['defaultFooterNote'] as String,
  signatureBlockByType: (json['signatureBlockByType'] as Map<String, dynamic>)
      .map(
        (k, e) => MapEntry(
          $enumDecode(_$DocumentTypeEnumMap, k),
          SignatureBlock.fromJson(e as Map<String, dynamic>),
        ),
      ),
  numberingRuleByType: (json['numberingRuleByType'] as Map<String, dynamic>)
      .map(
        (k, e) => MapEntry(
          $enumDecode(_$DocumentTypeEnumMap, k),
          DocumentNumberingRule.fromJson(e as Map<String, dynamic>),
        ),
      ),
  quotationValidityDays: (json['quotationValidityDays'] as num?)?.toInt() ?? 30,
  appearance: json['appearance'] as String? ?? 'system',
);

Map<String, dynamic> _$DocumentSettingsToJson(_DocumentSettings instance) =>
    <String, dynamic>{
      'companyDetails': instance.companyDetails.toJson(),
      'layoutOptionsByType': instance.layoutOptionsByType.map(
        (k, e) => MapEntry(_$DocumentTypeEnumMap[k]!, e.toJson()),
      ),
      'pricingTerms': instance.pricingTerms.toJson(),
      'defaultTermsByType': instance.defaultTermsByType.map(
        (k, e) => MapEntry(_$DocumentTypeEnumMap[k]!, e),
      ),
      'defaultFooterNote': instance.defaultFooterNote,
      'signatureBlockByType': instance.signatureBlockByType.map(
        (k, e) => MapEntry(_$DocumentTypeEnumMap[k]!, e.toJson()),
      ),
      'numberingRuleByType': instance.numberingRuleByType.map(
        (k, e) => MapEntry(_$DocumentTypeEnumMap[k]!, e.toJson()),
      ),
      'quotationValidityDays': instance.quotationValidityDays,
      'appearance': instance.appearance,
    };

const _$DocumentTypeEnumMap = {
  DocumentType.quotation: 'quotation',
  DocumentType.salesOrder: 'salesOrder',
  DocumentType.deliveryOrder: 'deliveryOrder',
};
