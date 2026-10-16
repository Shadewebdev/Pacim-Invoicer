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
