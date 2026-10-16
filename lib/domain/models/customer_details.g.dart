// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomerDetails _$CustomerDetailsFromJson(Map<String, dynamic> json) =>
    _CustomerDetails(
      customerName: json['customerName'] as String? ?? '',
      attentionTo: json['attentionTo'] as String? ?? '',
      addressLines:
          (json['addressLines'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      deliveryAddressLines:
          (json['deliveryAddressLines'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$CustomerDetailsToJson(_CustomerDetails instance) =>
    <String, dynamic>{
      'customerName': instance.customerName,
      'attentionTo': instance.attentionTo,
      'addressLines': instance.addressLines,
      'phone': instance.phone,
      'email': instance.email,
      'deliveryAddressLines': instance.deliveryAddressLines,
    };
