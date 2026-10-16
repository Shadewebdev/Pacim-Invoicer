// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_chain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentChain _$DocumentChainFromJson(Map<String, dynamic> json) =>
    _DocumentChain(
      chainId: json['chainId'] as String,
      quotation: json['quotation'] == null
          ? null
          : DocumentSummary.fromJson(json['quotation'] as Map<String, dynamic>),
      salesOrder: json['salesOrder'] == null
          ? null
          : DocumentSummary.fromJson(
              json['salesOrder'] as Map<String, dynamic>,
            ),
      deliveryOrders:
          (json['deliveryOrders'] as List<dynamic>?)
              ?.map((e) => DocumentSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DocumentSummary>[],
    );

Map<String, dynamic> _$DocumentChainToJson(_DocumentChain instance) =>
    <String, dynamic>{
      'chainId': instance.chainId,
      'quotation': instance.quotation?.toJson(),
      'salesOrder': instance.salesOrder?.toJson(),
      'deliveryOrders': instance.deliveryOrders.map((e) => e.toJson()).toList(),
    };
