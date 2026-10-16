// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CompanyDetails _$CompanyDetailsFromJson(Map<String, dynamic> json) =>
    _CompanyDetails(
      companyName: json['companyName'] as String? ?? '',
      registrationNumber: json['registrationNumber'] as String? ?? '',
      addressLines:
          (json['addressLines'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      website: json['website'] as String? ?? '',
      logoAssetId: json['logoAssetId'] as String?,
    );

Map<String, dynamic> _$CompanyDetailsToJson(_CompanyDetails instance) =>
    <String, dynamic>{
      'companyName': instance.companyName,
      'registrationNumber': instance.registrationNumber,
      'addressLines': instance.addressLines,
      'phone': instance.phone,
      'email': instance.email,
      'website': instance.website,
      'logoAssetId': instance.logoAssetId,
    };
