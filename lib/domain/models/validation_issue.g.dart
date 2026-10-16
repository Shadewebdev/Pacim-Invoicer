// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validation_issue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ValidationIssue _$ValidationIssueFromJson(Map<String, dynamic> json) =>
    _ValidationIssue(
      kind: $enumDecode(_$ValidationIssueKindEnumMap, json['kind']),
      lineItemId: json['lineItemId'] as String?,
    );

Map<String, dynamic> _$ValidationIssueToJson(_ValidationIssue instance) =>
    <String, dynamic>{
      'kind': _$ValidationIssueKindEnumMap[instance.kind]!,
      'lineItemId': instance.lineItemId,
    };

const _$ValidationIssueKindEnumMap = {
  ValidationIssueKind.missingCustomerName: 'missingCustomerName',
  ValidationIssueKind.noLineItems: 'noLineItems',
  ValidationIssueKind.zeroQuantity: 'zeroQuantity',
  ValidationIssueKind.deliveryExceedsRemaining: 'deliveryExceedsRemaining',
};
