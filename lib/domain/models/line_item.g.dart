// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LineItem _$LineItemFromJson(Map<String, dynamic> json) => _LineItem(
  lineItemId: json['lineItemId'] as String,
  sourceLineItemId: json['sourceLineItemId'] as String?,
  description: json['description'] as String? ?? '',
  unit: json['unit'] as String? ?? '',
  quantityScaled: (json['quantityScaled'] as num?)?.toInt() ?? 1000,
  unitPriceMinor: (json['unitPriceMinor'] as num?)?.toInt() ?? 0,
  discountPercentScaled: (json['discountPercentScaled'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$LineItemToJson(_LineItem instance) => <String, dynamic>{
  'lineItemId': instance.lineItemId,
  'sourceLineItemId': instance.sourceLineItemId,
  'description': instance.description,
  'unit': instance.unit,
  'quantityScaled': instance.quantityScaled,
  'unitPriceMinor': instance.unitPriceMinor,
  'discountPercentScaled': instance.discountPercentScaled,
};
