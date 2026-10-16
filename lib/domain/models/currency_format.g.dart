// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_format.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurrencyFormat _$CurrencyFormatFromJson(Map<String, dynamic> json) =>
    _CurrencyFormat(
      currencyCode: json['currencyCode'] as String,
      symbol: json['symbol'] as String,
      decimalPlaces: (json['decimalPlaces'] as num).toInt(),
      symbolPosition: $enumDecode(
        _$CurrencySymbolPositionEnumMap,
        json['symbolPosition'],
      ),
      thousandsSeparator: json['thousandsSeparator'] as String? ?? ',',
      decimalSeparator: json['decimalSeparator'] as String? ?? '.',
    );

Map<String, dynamic> _$CurrencyFormatToJson(
  _CurrencyFormat instance,
) => <String, dynamic>{
  'currencyCode': instance.currencyCode,
  'symbol': instance.symbol,
  'decimalPlaces': instance.decimalPlaces,
  'symbolPosition': _$CurrencySymbolPositionEnumMap[instance.symbolPosition]!,
  'thousandsSeparator': instance.thousandsSeparator,
  'decimalSeparator': instance.decimalSeparator,
};

const _$CurrencySymbolPositionEnumMap = {
  CurrencySymbolPosition.before: 'before',
  CurrencySymbolPosition.after: 'after',
};
