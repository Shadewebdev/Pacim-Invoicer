// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_numbering_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentNumberingRule _$DocumentNumberingRuleFromJson(
  Map<String, dynamic> json,
) => _DocumentNumberingRule(
  pattern: json['pattern'] as String,
  resetsYearly: json['resetsYearly'] as bool? ?? false,
);

Map<String, dynamic> _$DocumentNumberingRuleToJson(
  _DocumentNumberingRule instance,
) => <String, dynamic>{
  'pattern': instance.pattern,
  'resetsYearly': instance.resetsYearly,
};
