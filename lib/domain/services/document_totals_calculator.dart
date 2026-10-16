import '../models/business_document.dart';
import '../models/document_totals.dart';
import '../models/line_item.dart';

/// Divides [numerator] by [denominator], rounding half away from zero.
///
/// Uses [BigInt] so results stay exact on web, where `int` is a double.
int roundHalfUpDivide(BigInt numerator, BigInt denominator) {
  final isNegative = numerator.isNegative != denominator.isNegative;
  final absoluteNumerator = numerator.abs();
  final absoluteDenominator = denominator.abs();
  final rounded =
      (absoluteNumerator * BigInt.two + absoluteDenominator) ~/
      (absoluteDenominator * BigInt.two);
  return (isNegative ? -rounded : rounded).toInt();
}

/// Computes line amounts and document totals from quantities, prices,
/// discounts and tax. Totals are always derived, never stored.
class DocumentTotalsCalculator {
  const DocumentTotalsCalculator();

  static final BigInt _quantityScale = BigInt.from(1000);
  static final BigInt _percentScale = BigInt.from(10000);

  DocumentTotals calculate(BusinessDocument document) {
    final lineAmountMinorById = <String, int>{};
    var subtotalBeforeDiscountMinor = 0;
    var subtotalMinor = 0;
    for (final line in document.lineItems) {
      final amountMinor = lineAmountMinor(line);
      lineAmountMinorById[line.lineItemId] = amountMinor;
      subtotalBeforeDiscountMinor += lineGrossMinor(line);
      subtotalMinor += amountMinor;
    }

    final terms = document.pricingTerms;
    final taxMinor = terms.isTaxEnabled
        ? roundHalfUpDivide(
            BigInt.from(subtotalMinor) *
                BigInt.from(terms.taxRatePercentScaled),
            _percentScale,
          )
        : 0;

    return DocumentTotals(
      lineAmountMinorById: lineAmountMinorById,
      subtotalBeforeDiscountMinor: subtotalBeforeDiscountMinor,
      discountTotalMinor: subtotalBeforeDiscountMinor - subtotalMinor,
      subtotalMinor: subtotalMinor,
      taxMinor: taxMinor,
      grandTotalMinor: subtotalMinor + taxMinor,
    );
  }

  /// Quantity × unit price, before any discount.
  int lineGrossMinor(LineItem line) {
    return roundHalfUpDivide(
      BigInt.from(line.quantityScaled) * BigInt.from(line.unitPriceMinor),
      _quantityScale,
    );
  }

  /// Quantity × unit price after the line's percentage discount.
  int lineAmountMinor(LineItem line) {
    final discountFactor =
        _percentScale - BigInt.from(line.discountPercentScaled);
    return roundHalfUpDivide(
      BigInt.from(line.quantityScaled) *
          BigInt.from(line.unitPriceMinor) *
          discountFactor,
      _quantityScale * _percentScale,
    );
  }
}
