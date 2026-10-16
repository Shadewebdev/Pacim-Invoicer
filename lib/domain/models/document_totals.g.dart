// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_totals.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentTotals _$DocumentTotalsFromJson(Map<String, dynamic> json) =>
    _DocumentTotals(
      lineAmountMinorById: Map<String, int>.from(
        json['lineAmountMinorById'] as Map,
      ),
      subtotalBeforeDiscountMinor: (json['subtotalBeforeDiscountMinor'] as num)
          .toInt(),
      discountTotalMinor: (json['discountTotalMinor'] as num).toInt(),
      subtotalMinor: (json['subtotalMinor'] as num).toInt(),
      taxMinor: (json['taxMinor'] as num).toInt(),
      grandTotalMinor: (json['grandTotalMinor'] as num).toInt(),
    );

Map<String, dynamic> _$DocumentTotalsToJson(_DocumentTotals instance) =>
    <String, dynamic>{
      'lineAmountMinorById': instance.lineAmountMinorById,
      'subtotalBeforeDiscountMinor': instance.subtotalBeforeDiscountMinor,
      'discountTotalMinor': instance.discountTotalMinor,
      'subtotalMinor': instance.subtotalMinor,
      'taxMinor': instance.taxMinor,
      'grandTotalMinor': instance.grandTotalMinor,
    };
