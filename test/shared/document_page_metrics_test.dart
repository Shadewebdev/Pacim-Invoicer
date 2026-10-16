import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/domain/models/document_layout_options.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/shared/document_page_metrics.dart';

void main() {
  test('visibleColumns hides pricing for delivery orders', () {
    final columns = DocumentPageMetrics.visibleColumns(
      const DocumentLayoutOptions(showDiscountColumn: true),
      DocumentType.deliveryOrder,
    );
    expect(columns, [
      LineItemColumn.rowNumber,
      LineItemColumn.description,
      LineItemColumn.unit,
      LineItemColumn.quantity,
    ]);
  });

  test('visibleColumns follows the unit and discount flags', () {
    final columns = DocumentPageMetrics.visibleColumns(
      const DocumentLayoutOptions(
        showUnitColumn: false,
        showDiscountColumn: true,
      ),
      DocumentType.quotation,
    );
    expect(columns, [
      LineItemColumn.rowNumber,
      LineItemColumn.description,
      LineItemColumn.quantity,
      LineItemColumn.unitPrice,
      LineItemColumn.discount,
      LineItemColumn.amount,
    ]);
  });

  test('mmToLogicalPixels(210) ≈ 793.7', () {
    expect(DocumentPageMetrics.mmToLogicalPixels(210), closeTo(793.7, 0.1));
  });

  test('every column has a flex ratio', () {
    expect(LineItemColumn.description.flex, 5);
    expect(LineItemColumn.rowNumber.flex, 0.6);
  });
}
