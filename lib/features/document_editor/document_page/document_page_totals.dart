import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repository_providers.dart';
import '../../../shared/formatting/money_formatter.dart';
import '../../../shared/formatting/percent_formatter.dart';
import 'document_page_styles.dart';
import 'watched_document.dart';

/// Subtotal, discount, tax and total, right-aligned under the item table.
class DocumentPageTotals extends ConsumerWidget {
  const DocumentPageTotals({required this.documentId, super.key});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = watchEditedDocument(ref, documentId);
    final totals = ref
        .watch(documentTotalsCalculatorProvider)
        .calculate(document);
    final terms = document.pricingTerms;
    final format = terms.currencyFormat;

    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 250,
        child: Column(
          children: [
            _TotalsRow(
              label: 'Subtotal',
              amount: formatMoney(totals.subtotalBeforeDiscountMinor, format),
            ),
            if (totals.discountTotalMinor > 0)
              _TotalsRow(
                label: 'Discount',
                amount: formatMoney(-totals.discountTotalMinor, format),
              ),
            if (terms.isTaxEnabled)
              _TotalsRow(
                label: terms.taxLabel,
                note: formatTaxRate(terms),
                amount: formatMoney(totals.taxMinor, format),
              ),
            const SizedBox(height: 6),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: DocumentPageStyles.tokens.ink),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _TotalsRow(
                  label: 'Total',
                  amount: formatMoney(totals.grandTotalMinor, format),
                  isEmphasised: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({
    required this.label,
    required this.amount,
    this.note,
    this.isEmphasised = false,
  });

  final String label;
  final String? note;
  final String amount;
  final bool isEmphasised;

  @override
  Widget build(BuildContext context) {
    final style = isEmphasised
        ? DocumentPageStyles.emphasis.copyWith(fontSize: 15)
        : DocumentPageStyles.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: style),
          if (note != null) ...[
            const SizedBox(width: 6),
            Text(note!, style: DocumentPageStyles.caption),
          ],
          const Spacer(),
          Text(amount, style: style),
        ],
      ),
    );
  }
}
