// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_terms.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PricingTerms _$PricingTermsFromJson(Map<String, dynamic> json) =>
    _PricingTerms(
      currencyFormat: CurrencyFormat.fromJson(
        json['currencyFormat'] as Map<String, dynamic>,
      ),
      taxLabel: json['taxLabel'] as String? ?? 'Tax',
      taxRatePercentScaled:
          (json['taxRatePercentScaled'] as num?)?.toInt() ?? 0,
      isTaxEnabled: json['isTaxEnabled'] as bool? ?? false,
    );

Map<String, dynamic> _$PricingTermsToJson(_PricingTerms instance) =>
    <String, dynamic>{
      'currencyFormat': instance.currencyFormat.toJson(),
      'taxLabel': instance.taxLabel,
      'taxRatePercentScaled': instance.taxRatePercentScaled,
      'isTaxEnabled': instance.isTaxEnabled,
    };
