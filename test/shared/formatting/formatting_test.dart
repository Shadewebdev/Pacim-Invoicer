import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/domain/models/currency_format.dart';
import 'package:pacim_invoicer/shared/formatting/date_formatter.dart';
import 'package:pacim_invoicer/shared/formatting/money_formatter.dart';
import 'package:pacim_invoicer/shared/formatting/number_input_parser.dart';
import 'package:pacim_invoicer/shared/formatting/quantity_formatter.dart';

void main() {
  const myr = CurrencyFormat.defaultFormat;
  final eur = myr.copyWith(
    currencyCode: 'EUR',
    symbol: '€',
    symbolPosition: CurrencySymbolPosition.after,
    thousandsSeparator: '.',
    decimalSeparator: ',',
  );
  final jpy = myr.copyWith(currencyCode: 'JPY', symbol: '¥', decimalPlaces: 0);

  group('formatMoney', () {
    test('default format', () {
      expect(myr.currencyCode, 'MYR');
      expect(formatMoney(123456, myr), 'RM1,234.56');
    });
    test('negative amounts lead with the minus sign', () {
      expect(formatMoney(-5, myr), '-RM0.05');
    });
    test('symbol after with swapped separators', () {
      expect(formatMoney(123456, eur), '1.234,56 €');
    });
    test('zero decimal places', () {
      expect(formatMoney(1234, jpy), '¥1,234');
    });
    test('symbol can be omitted', () {
      expect(formatMoney(123456, myr, includeSymbol: false), '1,234.56');
      expect(formatMoney(123456, eur, includeSymbol: false), '1.234,56');
    });
  });

  group('parseMoneyInput', () {
    test('accepts grouped input', () {
      expect(parseMoneyInput('1,234.50', myr), 123450);
    });
    test('strips symbol and whitespace', () {
      expect(parseMoneyInput('RM 12 ', myr), 1200);
    });
    test('uses the format separators', () {
      expect(parseMoneyInput('1.234,50', eur), 123450);
    });
    test('rejects garbage and empty input', () {
      expect(parseMoneyInput('abc', myr), isNull);
      expect(parseMoneyInput('', myr), isNull);
    });
    test('rounds half up to the currency decimals', () {
      expect(parseMoneyInput('1.005', myr), 101);
    });
  });

  group('quantity', () {
    test('parseQuantityInput', () {
      expect(parseQuantityInput('2.5', myr), 2500);
      expect(parseQuantityInput('0.0005', myr), 1);
    });
    test('formatQuantity trims trailing zeros', () {
      expect(formatQuantity(2500), '2.5');
      expect(formatQuantity(3000), '3');
      expect(formatQuantity(1), '0.001');
    });
  });

  test('parsePercentInput', () {
    expect(parsePercentInput('8.5%'), 850);
    expect(parsePercentInput('8'), 800);
    expect(parsePercentInput('8.5'), 850);
    expect(parsePercentInput('x'), isNull);
  });

  test('formatDocumentDate', () {
    expect(formatDocumentDate(DateTime(2026, 10, 17)), '17 Oct 2026');
  });
}
