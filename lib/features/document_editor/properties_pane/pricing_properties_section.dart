import 'package:flutter/material.dart';

import '../../../domain/models/business_document.dart';
import '../../../domain/models/currency_format.dart';
import '../../../domain/models/pricing_terms.dart';
import '../../../shared/formatting/money_formatter.dart';
import '../../../shared/formatting/number_input_parser.dart';
import '../../../shared/formatting/percent_formatter.dart';
import '../../settings/settings_fields.dart';
import '../document_editor_controller.dart';
import 'properties_pane_section.dart';

const int _maximumDecimalPlaces = 3;
const int _maximumTaxRatePercentScaled = 10000;

/// Currency format and tax of the document.
class PricingPropertiesSection extends StatelessWidget {
  const PricingPropertiesSection({
    required this.document,
    required this.controller,
    required this.isLocked,
    required this.resetGeneration,
    required this.onReset,
    super.key,
  });

  final BusinessDocument document;
  final DocumentEditorController controller;
  final bool isLocked;
  final int resetGeneration;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final pricing = document.pricingTerms;
    final currency = pricing.currencyFormat;
    final isEnabled = !isLocked;
    String keyed(String name) => 'pane-$name-$resetGeneration';
    void editPricing(PricingTerms changed) =>
        controller.updatePricingTerms(changed);
    void editCurrency(CurrencyFormat changed) =>
        controller.updateCurrencyFormat(changed);

    return PropertiesPaneSection(
      title: 'Pricing & currency',
      resetSectionName: 'pricing',
      onReset: isLocked ? null : onReset,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SettingsTextField(
                key: ValueKey(keyed('currencyCode')),
                label: 'Currency code',
                value: currency.currencyCode,
                isEnabled: isEnabled,
                onChanged: (value) =>
                    editCurrency(currency.copyWith(currencyCode: value)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SettingsTextField(
                key: ValueKey(keyed('currencySymbol')),
                label: 'Symbol',
                value: currency.symbol,
                isEnabled: isEnabled,
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
              child: SettingsTextField(
                key: ValueKey(keyed('thousandsSeparator')),
                label: 'Thousands',
                value: currency.thousandsSeparator,
                isEnabled: isEnabled,
                onChanged: (value) =>
                    editCurrency(currency.copyWith(thousandsSeparator: value)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SettingsParsedField<String>(
                key: ValueKey(keyed('decimalSeparator')),
                label: 'Decimal',
                initialText: currency.decimalSeparator,
                errorText: 'Enter a separator',
                isEnabled: isEnabled,
                parse: (text) =>
                    text.isEmpty || text == currency.thousandsSeparator
                    ? null
                    : text,
                onParsed: (value) =>
                    editCurrency(currency.copyWith(decimalSeparator: value)),
              ),
            ),
          ],
        ),
        SettingsParsedField<int>(
          key: ValueKey(keyed('decimalPlaces')),
          label: 'Decimal places',
          initialText: currency.decimalPlaces.toString(),
          errorText: 'Enter a number from 0 to $_maximumDecimalPlaces',
          isEnabled: isEnabled,
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
              label: Text('Before'),
            ),
            ButtonSegment(
              value: CurrencySymbolPosition.after,
              label: Text('After'),
            ),
          ],
          selected: {currency.symbolPosition},
          onSelectionChanged: isEnabled
              ? (selection) => editCurrency(
                  currency.copyWith(symbolPosition: selection.single),
                )
              : null,
        ),
        Text('Example: ${formatMoney(123456, currency)}'),
        SettingsToggleRow(
          label: 'Charge tax',
          value: pricing.isTaxEnabled,
          isEnabled: isEnabled,
          onChanged: (value) =>
              editPricing(pricing.copyWith(isTaxEnabled: value)),
        ),
        SettingsTextField(
          key: ValueKey(keyed('taxLabel')),
          label: 'Tax label',
          value: pricing.taxLabel,
          isEnabled: isEnabled,
          onChanged: (value) => editPricing(pricing.copyWith(taxLabel: value)),
        ),
        SettingsParsedField<int>(
          key: ValueKey(keyed('taxRate')),
          label: 'Tax rate (%)',
          initialText: formatPercentScaled(
            pricing.taxRatePercentScaled,
            decimalSeparator: currency.decimalSeparator,
          ),
          isEnabled: isEnabled,
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
