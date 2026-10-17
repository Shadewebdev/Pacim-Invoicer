import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/document_type_colors.dart';
import '../../../domain/models/currency_format.dart';
import '../../../domain/models/line_item.dart';
import '../../../shared/document_page_metrics.dart';
import '../../../shared/line_item_cell_text.dart';
import '../../../shared/formatting/money_formatter.dart';
import '../../../shared/formatting/number_input_parser.dart';
import '../../../shared/formatting/quantity_formatter.dart';
import '../document_page/document_page_styles.dart';
import 'grid_cell_field.dart';

/// Width of the strip left of the table that holds the drag handle and row
/// menu. It sits in the page margin, so the table keeps the PDF's geometry.
const double lineItemGutterWidth = 44;

/// Width of the touch-only menu hit area.
const double _touchTargetWidth = 48;

/// Where the touch target starts: just right of the 16 px drag handle (which
/// ends 24 px before the gutter's edge, beside the 20 px menu button), so the
/// handle stays draggable and the target grows to the right, over the row
/// number cell, instead.
const double _touchTargetLeft = lineItemGutterWidth - 24;

/// Vertical padding of a table row; with one line of text a row is 32 px.
const double _rowVerticalPadding = 4;

/// Identifies the cell widget of [column] on line [lineItemId].
ValueKey<String> lineItemCellKey(String lineItemId, LineItemColumn column) =>
    ValueKey('lineCell-$lineItemId-${column.name}');

/// The columns a user can type into.
bool isEditableColumn(LineItemColumn column) =>
    column != LineItemColumn.rowNumber && column != LineItemColumn.amount;

/// The line with [text] typed into [column], or null when the text is not a
/// valid value: not a number, a negative quantity or discount, or a discount
/// above 100%. A blank number cell means zero. Unit prices may be negative,
/// for credits.
LineItem? lineWithCellInput(
  LineItem line,
  LineItemColumn column,
  String text,
  CurrencyFormat format,
) {
  final isBlank = text.trim().isEmpty;
  switch (column) {
    case LineItemColumn.description:
      return line.copyWith(description: text);
    case LineItemColumn.unit:
      return line.copyWith(unit: text.trim());
    case LineItemColumn.quantity:
      final quantity = isBlank ? 0 : parseQuantityInput(text, format);
      if (quantity == null || quantity < 0) return null;
      return line.copyWith(quantityScaled: quantity);
    case LineItemColumn.unitPrice:
      final price = isBlank ? 0 : parseMoneyInput(text, format);
      if (price == null) return null;
      return line.copyWith(unitPriceMinor: price);
    case LineItemColumn.discount:
      final percent = isBlank ? 0 : parsePercentInput(text, format: format);
      if (percent == null || percent < 0 || percent > 10000) return null;
      return line.copyWith(discountPercentScaled: percent);
    case LineItemColumn.rowNumber || LineItemColumn.amount:
      return null;
  }
}

/// Lays [cellFor] out across [columns] with the shared flex ratios.
class LineItemTableRow extends StatelessWidget {
  const LineItemTableRow({
    required this.columns,
    required this.cellFor,
    required this.bottomRule,
    super.key,
  });

  final List<LineItemColumn> columns;
  final Widget Function(LineItemColumn column) cellFor;
  final Color bottomRule;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: bottomRule)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: _rowVerticalPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final column in columns)
              Expanded(
                flex: (column.flex * 10).round(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: cellFor(column),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Printed (not editable) text in a cell, padded like an editable one so
/// baselines line up.
class StaticCellText extends StatelessWidget {
  const StaticCellText(
    this.text, {
    required this.column,
    this.style,
    super.key,
  });

  final String text;
  final LineItemColumn column;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // The 1 px matches the outline every editable cell reserves.
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Text(
        text,
        style: style ?? DocumentPageStyles.body,
        textAlign: isNumericColumn(column) ? TextAlign.end : TextAlign.start,
      ),
    );
  }
}

/// One line of the grid: the gutter with drag handle and row menu, then a
/// cell per visible column.
class LineItemRow extends StatefulWidget {
  const LineItemRow({
    required this.line,
    required this.index,
    required this.columns,
    required this.currencyFormat,
    required this.amountMinor,
    required this.isLocked,
    required this.focusNodeFor,
    required this.commitHandleFor,
    required this.onCellCommitted,
    required this.onInsertAbove,
    required this.onInsertBelow,
    required this.onDuplicate,
    required this.onDelete,
    this.remainingToDeliver,
    super.key,
  });

  final LineItem line;
  final int index;
  final List<LineItemColumn> columns;
  final CurrencyFormat currencyFormat;
  final int amountMinor;
  final bool isLocked;

  /// Set on a delivery order line whose quantity exceeds what is left to
  /// deliver on its sales order line.
  final int? remainingToDeliver;

  final FocusNode Function(LineItemColumn column) focusNodeFor;
  final GridCellCommitHandle Function(LineItemColumn column) commitHandleFor;

  /// Returns false when the text is not accepted.
  final bool Function(LineItemColumn column, String text) onCellCommitted;
  final VoidCallback onInsertAbove;
  final VoidCallback onInsertBelow;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  State<LineItemRow> createState() => _LineItemRowState();
}

class _LineItemRowState extends State<LineItemRow> {
  final _menuController = MenuController();

  /// Mouse only: every menu item also has a keyboard shortcut in the grid.
  final _menuButtonFocusNode = FocusNode(
    debugLabel: 'Row actions',
    skipTraversal: true,
  );
  bool _isHovered = false;
  bool _containsFocus = false;

  bool get _isTouchPlatform => switch (Theme.of(context).platform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    _ => false,
  };

  // Touch has no hover, so the controls are always there to find.
  bool get _showsRowControls =>
      _isTouchPlatform ||
      _isHovered ||
      _containsFocus ||
      _menuController.isOpen;

  void _toggleMenu() =>
      _menuController.isOpen ? _menuController.close() : _menuController.open();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (hasFocus) => setState(() => _containsFocus = hasFocus),
        child: GestureDetector(
          // Long-press (touch) and right-click (desktop) open the row menu
          // wherever the row is not an editable field.
          behavior: HitTestBehavior.translucent,
          onLongPress: widget.isLocked ? null : _menuController.open,
          onSecondaryTapUp: widget.isLocked
              ? null
              : (_) => _menuController.open(),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: lineItemGutterWidth,
                    child: widget.isLocked ? null : _buildGutter(),
                  ),
                  Expanded(
                    child: LineItemTableRow(
                      columns: widget.columns,
                      bottomRule: DocumentPageStyles.tokens.rule,
                      cellFor: _buildCell,
                    ),
                  ),
                ],
              ),
              // The 20 px menu button is too small for a finger, so on touch a
              // wider target overlays the gutter without moving anything.
              if (_isTouchPlatform && !widget.isLocked)
                Positioned(
                  left: _touchTargetLeft,
                  top: 0,
                  bottom: 0,
                  width: _touchTargetWidth,
                  child: GestureDetector(
                    key: ValueKey(
                      'rowMenuTouchTarget-${widget.line.lineItemId}',
                    ),
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleMenu,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGutter() {
    final iconColor = DocumentPageStyles.mutedInk;
    // Hidden controls keep their space and state but cannot be hit or read.
    return Visibility(
      visible: _showsRowControls,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, right: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ReorderableDragStartListener(
              index: widget.index,
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Semantics(
                  label: 'Drag to reorder',
                  child: Icon(Icons.drag_indicator, size: 16, color: iconColor),
                ),
              ),
            ),
            MenuAnchor(
              controller: _menuController,
              onOpen: () => setState(() {}),
              onClose: () => setState(() {}),
              menuChildren: [
                MenuItemButton(
                  onPressed: widget.onInsertAbove,
                  child: const Text('Insert row above'),
                ),
                MenuItemButton(
                  onPressed: widget.onInsertBelow,
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.enter,
                    control: true,
                  ),
                  child: const Text('Insert row below'),
                ),
                MenuItemButton(
                  onPressed: widget.onDuplicate,
                  child: const Text('Duplicate row'),
                ),
                MenuItemButton(
                  onPressed: widget.onDelete,
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.delete,
                    control: true,
                  ),
                  child: const Text('Delete row'),
                ),
              ],
              builder: (context, controller, _) => IconButton(
                tooltip: 'Row actions',
                focusNode: _menuButtonFocusNode,
                onPressed: () =>
                    controller.isOpen ? controller.close() : controller.open(),
                icon: Icon(Icons.more_vert, size: 16, color: iconColor),
                iconSize: 16,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 20,
                  height: 24,
                ),
                style: IconButton.styleFrom(
                  // Touch platforms would otherwise pad it out to 48 px and overflow.
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _menuButtonFocusNode.dispose();
    super.dispose();
  }

  Widget _buildCell(LineItemColumn column) {
    final line = widget.line;
    final format = widget.currencyFormat;
    switch (column) {
      case LineItemColumn.rowNumber:
        return StaticCellText(
          '${widget.index + 1}',
          column: column,
          style: DocumentPageStyles.body.copyWith(
            color: DocumentPageStyles.mutedInk,
          ),
        );
      case LineItemColumn.amount:
        return StaticCellText(
          formatMoney(widget.amountMinor, format, includeSymbol: false),
          column: column,
        );
      case LineItemColumn.description ||
          LineItemColumn.unit ||
          LineItemColumn.quantity ||
          LineItemColumn.unitPrice ||
          LineItemColumn.discount:
        final isNumber = isNumericColumn(column);
        final field = GridCellField(
          key: lineItemCellKey(line.lineItemId, column),
          displayText: cellDisplayText(column, line, format),
          editText: cellEditText(column, line, format),
          onCommitted: (text) => widget.onCellCommitted(column, text),
          focusNode: widget.focusNodeFor(column),
          commitHandle: widget.commitHandleFor(column),
          readOnly: widget.isLocked,
          isMultiline: column == LineItemColumn.description,
          selectAllOnFocus: isNumber,
          textAlign: isNumber ? TextAlign.end : TextAlign.start,
          placeholder: column == LineItemColumn.description
              ? 'Description'
              : null,
        );
        if (column != LineItemColumn.quantity) return field;
        // Always a column, so the hint appearing never rebuilds the field.
        final remaining = widget.remainingToDeliver;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            field,
            if (remaining != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(3, 2, 3, 0),
                child: Text(
                  'Only ${formatQuantity(remaining, format: format)} '
                  'left to deliver',
                  textAlign: TextAlign.end,
                  style: DocumentPageStyles.caption.copyWith(
                    // The page is always white, so it uses the light ink.
                    color: DocumentTypeColors.light.deliveryOrderInk,
                    height: 1.25,
                  ),
                ),
              ),
          ],
        );
    }
  }
}
