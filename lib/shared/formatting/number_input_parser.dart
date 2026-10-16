import '../../domain/models/currency_format.dart';

/// Parses typed money into minor units, or `null` when it is not a number.
///
/// Extra decimals are rounded half up to the currency's decimal places.
int? parseMoneyInput(String input, CurrencyFormat format) {
  final normalized = _normalizeDecimalText(
    input.replaceAll(format.symbol, ''),
    thousandsSeparator: format.thousandsSeparator,
    decimalSeparator: format.decimalSeparator,
  );
  if (normalized == null) return null;
  return _scaleDecimalHalfUp(normalized, format.decimalPlaces);
}

/// Parses a typed quantity into a value scaled by 1000, or `null`.
///
/// Uses the separators of [format]; extra decimals round half up.
int? parseQuantityInput(String input, CurrencyFormat format) {
  final normalized = _normalizeDecimalText(
    input,
    thousandsSeparator: format.thousandsSeparator,
    decimalSeparator: format.decimalSeparator,
  );
  if (normalized == null) return null;
  return _scaleDecimalHalfUp(normalized, 3);
}

/// Parses `8`, `8.5` or `8.5%` into a percent scaled by 100, or `null`.
///
/// Uses the separators of [format], so `8,5` reads as 8.5% when the decimal
/// separator is a comma.
int? parsePercentInput(
  String input, {
  CurrencyFormat format = CurrencyFormat.defaultFormat,
}) {
  final normalized = _normalizeDecimalText(
    input.replaceAll('%', ''),
    thousandsSeparator: format.thousandsSeparator,
    decimalSeparator: format.decimalSeparator,
  );
  if (normalized == null) return null;
  return _scaleDecimalHalfUp(normalized, 2);
}

final RegExp _plainDecimalPattern = RegExp(r'^-?(\d+\.?\d*|\.\d+)$');

/// Returns text using `.` as the decimal point, or `null` if it is not a
/// plain decimal number after stripping whitespace and thousands separators.
String? _normalizeDecimalText(
  String input, {
  required String thousandsSeparator,
  required String decimalSeparator,
}) {
  var text = input.replaceAll(RegExp(r'\s'), '');
  if (thousandsSeparator.isNotEmpty) {
    text = text.replaceAll(thousandsSeparator, '');
  }
  if (decimalSeparator != '.') {
    text = text.replaceAll(decimalSeparator, '.');
  }
  return _plainDecimalPattern.hasMatch(text) ? text : null;
}

/// Integers are exact on web up to 15 digits.
const int _maxExactDigits = 15;

/// Scales a plain decimal string by 10^[decimalPlaces], rounding half away
/// from zero using digit arithmetic (never `double`). Returns `null` when the
/// result would exceed 15 digits, and never returns negative zero.
int? _scaleDecimalHalfUp(String plainDecimal, int decimalPlaces) {
  final isNegative = plainDecimal.startsWith('-');
  final unsigned = isNegative ? plainDecimal.substring(1) : plainDecimal;
  final parts = unsigned.split('.');
  final wholeDigits = parts[0].isEmpty ? '0' : parts[0];
  final fractionDigits = parts.length > 1 ? parts[1] : '';

  final keptFraction = fractionDigits
      .padRight(decimalPlaces, '0')
      .substring(0, decimalPlaces);
  final shouldRoundUp =
      fractionDigits.length > decimalPlaces &&
      fractionDigits.codeUnitAt(decimalPlaces) >= 0x35; // '5'

  final scaled = int.tryParse('$wholeDigits$keptFraction');
  if (scaled == null) return null;
  final rounded = shouldRoundUp ? scaled + 1 : scaled;
  if (rounded.toString().length > _maxExactDigits) return null;
  if (rounded == 0) return 0;
  return isNegative ? -rounded : rounded;
}
