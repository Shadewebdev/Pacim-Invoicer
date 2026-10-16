import '../domain/models/document_layout_options.dart';
import '../domain/models/document_type.dart';

/// The columns of the line item table, in print order.
enum LineItemColumn {
  rowNumber(0.6),
  description(5),
  unit(1.2),
  quantity(1.2),
  unitPrice(1.8),
  discount(1.2),
  amount(2);

  const LineItemColumn(this.flex);

  /// Relative width of the column; shared by the on-screen page and the PDF.
  final double flex;
}

/// Page geometry shared by the on-screen A4 page and the PDF.
abstract final class DocumentPageMetrics {
  static const pageWidthMm = 210;
  static const pageHeightMm = 297;
  static const marginMm = 18;
  static const stageBandWidthPx = 4;
  static const pointsPerMm = 72 / 25.4;

  /// Converts millimetres to logical pixels at 100% zoom (96 px per inch).
  static double mmToLogicalPixels(double mm) => mm * 96 / 25.4;

  static List<LineItemColumn> visibleColumns(
    DocumentLayoutOptions options,
    DocumentType type,
  ) {
    return [
      LineItemColumn.rowNumber,
      LineItemColumn.description,
      if (options.showUnitColumn) LineItemColumn.unit,
      LineItemColumn.quantity,
      if (type.showsPricing) LineItemColumn.unitPrice,
      if (type.showsPricing && options.showDiscountColumn)
        LineItemColumn.discount,
      if (type.showsPricing) LineItemColumn.amount,
    ];
  }
}
