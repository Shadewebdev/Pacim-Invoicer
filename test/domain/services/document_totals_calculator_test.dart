import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/domain/services/document_totals_calculator.dart';

import '../../support/document_builders.dart';

void main() {
  const calculator = DocumentTotalsCalculator();

  test('2.5 × 10.00 at 10% discount = 22.50', () {
    final line = buildTestLine(
      quantityScaled: 2500,
      unitPriceMinor: 1000,
      discountPercentScaled: 1000,
    );
    final totals = calculator.calculate(buildTestDocument(lineItems: [line]));
    expect(calculator.lineAmountMinor(line), 2250);
    expect(calculator.lineGrossMinor(line), 2500);
    expect(totals.lineAmountMinorById['line-1'], 2250);
    expect(totals.subtotalBeforeDiscountMinor, 2500);
    expect(totals.discountTotalMinor, 250);
    expect(totals.subtotalMinor, 2250);
  });

  test('tax 8% on 22.50 rounds half up to 1.80', () {
    final line = buildTestLine(
      quantityScaled: 2500,
      unitPriceMinor: 1000,
      discountPercentScaled: 1000,
    );
    final totals = calculator.calculate(buildTestDocument(lineItems: [line]));
    expect(totals.taxMinor, 180);
    expect(totals.grandTotalMinor, 2430);
  });

  test('tax disabled yields zero tax', () {
    final base = buildTestDocument(lineItems: [buildTestLine()]);
    final document = base.copyWith(
      pricingTerms: base.pricingTerms.copyWith(isTaxEnabled: false),
    );
    final totals = calculator.calculate(document);
    expect(totals.taxMinor, 0);
    expect(totals.grandTotalMinor, totals.subtotalMinor);
  });

  test('half-up rounding: 0.333 × 0.15 = 0.05', () {
    final line = buildTestLine(quantityScaled: 333, unitPriceMinor: 15);
    expect(calculator.lineAmountMinor(line), 5);
  });

  test('huge values stay exact on web', () {
    final line = buildTestLine(
      quantityScaled: 1000000000,
      unitPriceMinor: 999999999,
    );
    expect(calculator.lineAmountMinor(line), 999999999000000);
  });

  test('empty document totals are zero', () {
    final totals = calculator.calculate(buildTestDocument(lineItems: []));
    expect(totals.lineAmountMinorById, isEmpty);
    expect(totals.subtotalMinor, 0);
    expect(totals.taxMinor, 0);
    expect(totals.grandTotalMinor, 0);
  });

  test('lineAmountMinorById has every line id', () {
    final totals = calculator.calculate(buildTestDocument());
    expect(totals.lineAmountMinorById.keys, ['line-1', 'line-2']);
  });

  test('roundHalfUpDivide rounds half away from zero', () {
    expect(roundHalfUpDivide(BigInt.from(5), BigInt.from(2)), 3);
    expect(roundHalfUpDivide(BigInt.from(-5), BigInt.from(2)), -3);
    expect(roundHalfUpDivide(BigInt.from(4), BigInt.from(3)), 1);
    expect(roundHalfUpDivide(BigInt.from(-4), BigInt.from(3)), -1);
  });
}
