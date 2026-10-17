import '../domain/models/currency_format.dart';
import '../domain/models/line_item.dart';
import 'document_page_metrics.dart';
import 'formatting/money_formatter.dart';
import 'formatting/percent_formatter.dart';
import 'formatting/quantity_formatter.dart';

/// Cell copy shared by the on-screen item grid and the PDF, so the two can
/// never print a line differently.
bool isNumericColumn(LineItemColumn column) =>
    column == LineItemColumn.quantity ||
    column == LineItemColumn.unitPrice ||
    column == LineItemColumn.discount ||
    column == LineItemColumn.amount;

String lineItemColumnLabel(LineItemColumn column) => switch (column) {
  LineItemColumn.rowNumber => '#',
  LineItemColumn.description => 'Description',
  LineItemColumn.unit => 'Unit',
  LineItemColumn.quantity => 'Qty',
  LineItemColumn.unitPrice => 'Unit price',
  LineItemColumn.discount => 'Discount',
  LineItemColumn.amount => 'Amount',
};

/// The text an editable cell shows when it is not focused, and prints.
String cellDisplayText(
  LineItemColumn column,
  LineItem line,
  CurrencyFormat format,
) => switch (column) {
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
        ? ''
        : '${formatPercentText(line.discountPercentScaled, format)}%',
  _ => cellEditText(column, line, format),
};

/// The raw text an editable cell shows while focused.
String cellEditText(
  LineItemColumn column,
  LineItem line,
  CurrencyFormat format,
) => switch (column) {
  LineItemColumn.description => line.description,
  LineItemColumn.unit => line.unit,
  LineItemColumn.quantity => formatQuantity(
    line.quantityScaled,
    format: format,
  ),
  LineItemColumn.unitPrice => formatMoney(
    line.unitPriceMinor,
    format.copyWith(thousandsSeparator: ''),
    includeSymbol: false,
  ),
  LineItemColumn.discount =>
    line.discountPercentScaled == 0
        ? ''
        : formatPercentText(line.discountPercentScaled, format),
  LineItemColumn.rowNumber || LineItemColumn.amount => '',
};
