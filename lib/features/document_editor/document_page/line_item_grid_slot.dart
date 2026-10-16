import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/business_document.dart';
import '../../../domain/models/line_item.dart';
import '../../../shared/document_page_metrics.dart';
import '../../../shared/formatting/money_formatter.dart';
import '../../../shared/formatting/quantity_formatter.dart';
import '../document_editor_controller.dart';
import '../../../data/repository_providers.dart';
import 'document_page_styles.dart';

/// The seam where the keyboard-editable item grid plugs in (Task 18).
/// For now it is a read-only table following [DocumentPageMetrics.visibleColumns].
class LineItemGridSlot extends ConsumerWidget {
  const LineItemGridSlot({required this.documentId, super.key});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = ref
        .watch(documentEditorControllerProvider(documentId))
        .requireValue
        .document;
    final totals = ref
        .watch(documentTotalsCalculatorProvider)
        .calculate(document);
    final columns = DocumentPageMetrics.visibleColumns(
      document.layoutOptions,
      document.documentType,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TableRow(
          columns: columns,
          cellText: (column) => _headerLabel(column),
          style: DocumentPageStyles.caption,
          bottomRule: DocumentPageStyles.tokens.ink,
        ),
        for (var index = 0; index < document.lineItems.length; index++)
          _TableRow(
            columns: columns,
            cellText: (column) => _cellText(
              column,
              document,
              document.lineItems[index],
              index,
              totals.lineAmountMinorById[document
                      .lineItems[index]
                      .lineItemId] ??
                  0,
            ),
            style: DocumentPageStyles.body,
            bottomRule: DocumentPageStyles.tokens.rule,
          ),
      ],
    );
  }
}

String _headerLabel(LineItemColumn column) => switch (column) {
  LineItemColumn.rowNumber => '#',
  LineItemColumn.description => 'Description',
  LineItemColumn.unit => 'Unit',
  LineItemColumn.quantity => 'Qty',
  LineItemColumn.unitPrice => 'Unit price',
  LineItemColumn.discount => 'Discount',
  LineItemColumn.amount => 'Amount',
};

String _cellText(
  LineItemColumn column,
  BusinessDocument document,
  LineItem line,
  int index,
  int amountMinor,
) {
  final format = document.pricingTerms.currencyFormat;
  return switch (column) {
    LineItemColumn.rowNumber => '${index + 1}',
    LineItemColumn.description => line.description,
    LineItemColumn.unit => line.unit,
    LineItemColumn.quantity => formatQuantity(
      line.quantityScaled,
      format: format,
    ),
    LineItemColumn.unitPrice => formatMoney(
      line.unitPriceMinor,
      format,
      includeSymbol: false,
    ),
    LineItemColumn.discount =>
      line.discountPercentScaled == 0
          // Percentages are scaled by 100 and quantities by 1000, so
          // multiplying by 10 lets the quantity formatter print them.
          ? ''
          : '${formatQuantity(line.discountPercentScaled * 10, format: format)}%',
    LineItemColumn.amount => formatMoney(
      amountMinor,
      format,
      includeSymbol: false,
    ),
  };
}

bool _isNumeric(LineItemColumn column) =>
    column == LineItemColumn.quantity ||
    column == LineItemColumn.unitPrice ||
    column == LineItemColumn.discount ||
    column == LineItemColumn.amount;

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.columns,
    required this.cellText,
    required this.style,
    required this.bottomRule,
  });

  final List<LineItemColumn> columns;
  final String Function(LineItemColumn column) cellText;
  final TextStyle style;
  final Color bottomRule;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: bottomRule)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final column in columns)
              Expanded(
                flex: (column.flex * 10).round(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    cellText(column),
                    style: style,
                    textAlign: _isNumeric(column)
                        ? TextAlign.end
                        : TextAlign.start,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
