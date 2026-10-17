import 'package:flutter/material.dart';

import '../../../app/theme/app_typography.dart';
import '../../../domain/models/currency_format.dart';
import '../../../domain/models/document_settings.dart';
import '../../../domain/models/pricing_terms.dart';
import '../../../shared/formatting/money_formatter.dart';
import '../../../shared/formatting/number_input_parser.dart';
import '../../../shared/formatting/percent_formatter.dart';
import '../settings_controller.dart';
import '../settings_fields.dart';

const int _maximumDecimalPlaces = 3;
const int _maximumTaxRatePercentScaled = 10000;

class PricingSettingsSection extends StatelessWidget {
  const PricingSettingsSection({
    required this.settings,
    required this.controller,
    super.key,
  });

  final DocumentSettings settings;
  final SettingsController controller;

  /// The current format with one separator changed, or null when the two
  /// separators would clash.
  CurrencyFormat? _withDistinctSeparators({
    String? thousandsSeparator,
    String? decimalSeparator,
  }) {
    final changed = settings.pricingTerms.currencyFormat.copyWith(
      thousandsSeparator:
          thousandsSeparator ??
          settings.pricingTerms.currencyFormat.thousandsSeparator,
      decimalSeparator:
          decimalSeparator ??
          settings.pricingTerms.currencyFormat.decimalSeparator,
    );
    return changed.hasDistinctSeparators ? changed : null;
  }

  @override
  Widget build(BuildContext context) {
    final pricing = settings.pricingTerms;
    final currency = pricing.currencyFormat;
    void editPricing(PricingTerms changed) =>
        controller.updatePricingTerms(changed);
    void editCurrency(CurrencyFormat changed) =>
        editPricing(pricing.copyWith(currencyFormat: changed));

    return SettingsSectionLayout(
      title: 'Pricing & currency',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SettingsTextField(
                label: 'Currency code',
                value: currency.currencyCode,
                onChanged: (value) =>
                    editCurrency(currency.copyWith(currencyCode: value)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SettingsTextField(
                label: 'Symbol',
                value: currency.symbol,
                onChanged: (value) =>
                    editCurrency(currency.copyWith(symbol: value)),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SettingsParsedField<CurrencyFormat>(
                label: 'Thousands separator',
                initialText: currency.thousandsSeparator,
                errorText: 'Use a different separator from the decimal one',
                parse: (text) =>
                    _withDistinctSeparators(thousandsSeparator: text),
                onParsed: editCurrency,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SettingsParsedField<CurrencyFormat>(
                label: 'Decimal separator',
                initialText: currency.decimalSeparator,
                errorText: 'Use a different separator from the thousands one',
                parse: (text) =>
                    _withDistinctSeparators(decimalSeparator: text),
                onParsed: editCurrency,
              ),
            ),
          ],
        ),
        SettingsParsedField<int>(
          label: 'Decimal places',
          initialText: currency.decimalPlaces.toString(),
          errorText: 'Enter a number from 0 to $_maximumDecimalPlaces',
          parse: (text) {
            final places = int.tryParse(text.trim());
            if (places == null ||
                places < 0 ||
                places > _maximumDecimalPlaces) {
              return null;
            }
            return places;
          },
          onParsed: (places) =>
              editCurrency(currency.copyWith(decimalPlaces: places)),
        ),
        SegmentedButton<CurrencySymbolPosition>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: CurrencySymbolPosition.before,
              label: Text('Symbol before amount'),
            ),
            ButtonSegment(
              value: CurrencySymbolPosition.after,
              label: Text('Symbol after amount'),
            ),
          ],
          selected: {currency.symbolPosition},
          onSelectionChanged: (selection) =>
              editCurrency(currency.copyWith(symbolPosition: selection.single)),
        ),
        Text(
          'Example: ${formatMoney(123456, currency)}',
          style: const TextStyle(fontSize: AppTypography.body),
        ),
        SettingsParsedField<int>(
          label: 'Quotation validity (days)',
          initialText: settings.quotationValidityDays.toString(),
          errorText: 'Enter a number from 1 to 365',
          parse: (text) {
            final days = int.tryParse(text.trim());
            if (days == null || days < 1 || days > 365) return null;
            return days;
          },
          onParsed: controller.updateQuotationValidityDays,
        ),
        SettingsToggleRow(
          label: 'Charge tax on new documents',
          value: pricing.isTaxEnabled,
          onChanged: (value) =>
              editPricing(pricing.copyWith(isTaxEnabled: value)),
        ),
        SettingsTextField(
          label: 'Tax label',
          value: pricing.taxLabel,
          onChanged: (value) => editPricing(pricing.copyWith(taxLabel: value)),
        ),
        SettingsParsedField<int>(
          label: 'Tax rate (%)',
          initialText: formatPercentScaled(
            pricing.taxRatePercentScaled,
            decimalSeparator: currency.decimalSeparator,
          ),
          parse: (text) {
            final scaled = parsePercentInput(text, format: currency);
            if (scaled == null ||
                scaled < 0 ||
                scaled > _maximumTaxRatePercentScaled) {
              return null;
            }
            return scaled;
          },
          onParsed: (scaled) =>
              editPricing(pricing.copyWith(taxRatePercentScaled: scaled)),
        ),
      ],
    );
  }
}
