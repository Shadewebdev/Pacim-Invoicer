import '../../domain/models/currency_format.dart';

/// Renders a quantity scaled by 1000 with up to 3 decimals, trimming zeros,
/// using the decimal separator of [format].
String formatQuantity(
  int quantityScaled, {
  CurrencyFormat format = CurrencyFormat.defaultFormat,
}) {
  final sign = quantityScaled < 0 ? '-' : '';
  final digits = quantityScaled.abs().toString().padLeft(4, '0');
  final whole = digits.substring(0, digits.length - 3);
  final fraction = digits
      .substring(digits.length - 3)
      .replaceFirst(RegExp(r'0+$'), '');
  return fraction.isEmpty
      ? '$sign$whole'
      : '$sign$whole${format.decimalSeparator}$fraction';
}
