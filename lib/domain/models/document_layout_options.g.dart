// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_layout_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentLayoutOptions _$DocumentLayoutOptionsFromJson(
  Map<String, dynamic> json,
) => _DocumentLayoutOptions(
  showLogo: json['showLogo'] as bool? ?? true,
  showCompanyRegistration: json['showCompanyRegistration'] as bool? ?? true,
  showCustomerReference: json['showCustomerReference'] as bool? ?? true,
  showNotes: json['showNotes'] as bool? ?? true,
  showTermsAndConditions: json['showTermsAndConditions'] as bool? ?? true,
  showFooterNote: json['showFooterNote'] as bool? ?? true,
  showSignature: json['showSignature'] as bool? ?? true,
  showPageNumbers: json['showPageNumbers'] as bool? ?? true,
  showDiscountColumn: json['showDiscountColumn'] as bool? ?? false,
  showUnitColumn: json['showUnitColumn'] as bool? ?? true,
);

Map<String, dynamic> _$DocumentLayoutOptionsToJson(
  _DocumentLayoutOptions instance,
) => <String, dynamic>{
  'showLogo': instance.showLogo,
  'showCompanyRegistration': instance.showCompanyRegistration,
  'showCustomerReference': instance.showCustomerReference,
  'showNotes': instance.showNotes,
  'showTermsAndConditions': instance.showTermsAndConditions,
  'showFooterNote': instance.showFooterNote,
  'showSignature': instance.showSignature,
  'showPageNumbers': instance.showPageNumbers,
  'showDiscountColumn': instance.showDiscountColumn,
  'showUnitColumn': instance.showUnitColumn,
};
