import '../../domain/models/currency_format.dart';

/// Renders [amountMinor] using the separators, symbol and decimals of [format].
///
/// A negative amount leads with the minus sign, before the symbol.
String formatMoney(
  int amountMinor,
  CurrencyFormat format, {
  bool includeSymbol = true,
}) {
  final isNegative = amountMinor < 0;
  final absoluteDigits = amountMinor.abs().toString().padLeft(
    format.decimalPlaces + 1,
    '0',
  );
  final splitIndex = absoluteDigits.length - format.decimalPlaces;
  final wholeDigits = absoluteDigits.substring(0, splitIndex);
  final fractionDigits = absoluteDigits.substring(splitIndex);

  final groupedWhole = _groupThousands(wholeDigits, format.thousandsSeparator);
  final number = format.decimalPlaces == 0
      ? groupedWhole
      : '$groupedWhole${format.decimalSeparator}$fractionDigits';

  final sign = isNegative ? '-' : '';
  if (!includeSymbol) return '$sign$number';
  return switch (format.symbolPosition) {
    CurrencySymbolPosition.before => '$sign${format.symbol}$number',
    CurrencySymbolPosition.after => '$sign$number ${format.symbol}',
  };
}

String _groupThousands(String digits, String separator) {
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    final digitsRemaining = digits.length - index;
    if (index > 0 && digitsRemaining % 3 == 0) buffer.write(separator);
    buffer.write(digits[index]);
  }
  return buffer.toString();
}
