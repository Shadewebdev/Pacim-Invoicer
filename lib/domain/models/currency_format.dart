import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency_format.freezed.dart';
part 'currency_format.g.dart';

enum CurrencySymbolPosition { before, after }

/// How amounts are rendered for one currency.
@freezed
abstract class CurrencyFormat with _$CurrencyFormat {
  const CurrencyFormat._();

  const factory CurrencyFormat({
    required String currencyCode,
    required String symbol,
    required int decimalPlaces,
    required CurrencySymbolPosition symbolPosition,
    @Default(',') String thousandsSeparator,
    @Default('.') String decimalSeparator,
  }) = _CurrencyFormat;

  /// Malaysian ringgit, rendered as `RM1,234.56`.
  static const defaultFormat = CurrencyFormat(
    currencyCode: 'MYR',
    symbol: 'RM',
    decimalPlaces: 2,
    symbolPosition: CurrencySymbolPosition.before,
  );

  factory CurrencyFormat.fromJson(Map<String, dynamic> json) =>
      _$CurrencyFormatFromJson(json);

  /// True when amounts can be read back unambiguously: there is a decimal
  /// separator and it differs from the thousands separator, which may be
  /// empty for no grouping.
  bool get hasDistinctSeparators =>
      decimalSeparator.isNotEmpty && thousandsSeparator != decimalSeparator;

  /// How many minor units make one major unit (100 for two decimal places).
  int get minorUnitsPerMajor {
    var result = 1;
    for (var i = 0; i < decimalPlaces; i++) {
      result *= 10;
    }
    return result;
  }
}
