import '../../domain/models/currency_format.dart';
import '../../domain/models/pricing_terms.dart';
import 'quantity_formatter.dart';

/// Renders a percent scaled by 100 for editing: 800 becomes `8` and 850
/// becomes `8.5` (`8,5` with a comma [decimalSeparator]).
String formatPercentScaled(
  int percentScaled, {
  required String decimalSeparator,
}) {
  final whole = percentScaled ~/ 100;
  final fraction = percentScaled % 100;
  if (fraction == 0) return '$whole';
  final fractionText = fraction.toString().padLeft(2, '0');
  final trimmedFraction = fractionText.replaceFirst(RegExp(r'0$'), '');
  return '$whole$decimalSeparator$trimmedFraction';
}

/// Renders a percent scaled by 100 for display with up to 2 decimals, using
/// the decimal separator of [format]: 800 is `8`, 825 is `8.25`.
///
/// Percentages are scaled by 100 and quantities by 1000, so multiplying by
/// 10 lets the quantity formatter print them.
String formatPercentText(int percentScaled, CurrencyFormat format) =>
    formatQuantity(percentScaled * 10, format: format);

/// The tax rate as printed beside the tax line, such as `8%`.
String formatTaxRate(PricingTerms terms) =>
    '${formatPercentText(terms.taxRatePercentScaled, terms.currencyFormat)}%';
