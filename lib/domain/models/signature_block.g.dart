// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signature_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SignatureBlock _$SignatureBlockFromJson(Map<String, dynamic> json) =>
    _SignatureBlock(
      signatoryName: json['signatoryName'] as String? ?? '',
      signatoryTitle: json['signatoryTitle'] as String? ?? '',
      signatureAssetId: json['signatureAssetId'] as String?,
      signatureCaption: json['signatureCaption'] as String? ?? '',
    );

Map<String, dynamic> _$SignatureBlockToJson(_SignatureBlock instance) =>
    <String, dynamic>{
      'signatoryName': instance.signatoryName,
      'signatoryTitle': instance.signatoryTitle,
      'signatureAssetId': instance.signatureAssetId,
      'signatureCaption': instance.signatureCaption,
    };
