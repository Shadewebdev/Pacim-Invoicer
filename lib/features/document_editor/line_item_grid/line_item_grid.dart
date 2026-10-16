import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repository_providers.dart';
import '../../../domain/models/business_document.dart';
import '../../../domain/models/document_type.dart';
import '../../../domain/services/delivery_progress_calculator.dart';
import '../../../shared/document_page_metrics.dart';
import '../document_editor_controller.dart';
import '../document_page/document_page_styles.dart';
import '../document_page/watched_document.dart';
import 'grid_cell_address.dart';
import 'grid_cell_field.dart';
import 'grid_focus_controller.dart';
import 'grid_shortcuts.dart';
import 'line_item_row.dart';

/// The focus node and commit handle of one cell, owned by the grid.
class _CellSlot {
  _CellSlot(GridCellAddress address)
    : focusNode = FocusNode(debugLabel: address.toString());

  final FocusNode focusNode;
  final GridCellCommitHandle commitHandle = GridCellCommitHandle();
}

/// The line items on the A4 page, edited like a spreadsheet.
///
/// Focus model: the grid owns one [FocusNode] per editable cell, keyed by
/// [GridCellAddress] rather than by row position, so a node always belongs to
/// the same line and column however rows are inserted, removed or moved, and
/// it survives the row's element being rebuilt (a reorder rebuilds it).
/// Nodes of rows that are gone are disposed after the frame that removed
/// them. Keyboard actions work out the focused cell from the primary focus;
/// after a structural change they ask for focus on the target address once
/// the controller's new state has been built.
class LineItemGrid extends ConsumerStatefulWidget {
  const LineItemGrid({required this.documentId, super.key});

  final String documentId;

  /// How far the grid reaches into the page's left margin for its row
  /// controls.
  static const double gutterWidth = lineItemGutterWidth;

  /// Identifies the cell widget of [column] on line [lineItemId].
  static ValueKey<String> cellKey(String lineItemId, LineItemColumn column) =>
      lineItemCellKey(lineItemId, column);

  @override
  ConsumerState<LineItemGrid> createState() => _LineItemGridState();
}

class _LineItemGridState extends ConsumerState<LineItemGrid> {
  static const _navigation = GridFocusController();
  static const _deliveryProgress = DeliveryProgressCalculator();

  final _cells = <GridCellAddress, _CellSlot>{};
  final _addItemFocusNode = FocusNode(debugLabel: 'Add item');

  /// The cells of the document as last built.
  Set<GridCellAddress> _liveAddresses = const {};
  bool _isPruneScheduled = false;

  late final Map<Type, Action<Intent>> _actions = {
    NextGridCellIntent: GridAction<NextGridCellIntent>(
      isEnabledFor: (_) => _stepTarget(forward: true) != null,
      onInvoke: (_) => _focusCell(_stepTarget(forward: true)),
    ),
    PreviousGridCellIntent: GridAction<PreviousGridCellIntent>(
      isEnabledFor: (_) => _stepTarget(forward: false) != null,
      onInvoke: (_) => _focusCell(_stepTarget(forward: false)),
    ),
    GridCellBelowIntent: GridAction<GridCellBelowIntent>(
      isEnabledFor: (_) => _canMoveBelow(),
      onInvoke: (_) => _moveBelow(),
    ),
    InsertGridRowBelowIntent: GridAction<InsertGridRowBelowIntent>(
      isEnabledFor: (_) => _focusedCellIfEditable() != null,
      onInvoke: (_) => _insertBelowFocusedRow(),
    ),
    RemoveGridRowIntent: GridAction<RemoveGridRowIntent>(
      isEnabledFor: (_) => _focusedCellIfEditable() != null,
      onInvoke: (_) => _removeFocusedRow(),
    ),
    MoveGridRowIntent: GridAction<MoveGridRowIntent>(
      isEnabledFor: (intent) => _moveTargetIndex(intent.offset) != null,
      onInvoke: (intent) => _moveFocusedRow(intent.offset),
    ),
  };

  DocumentEditorController get _editor =>
      ref.read(documentEditorControllerProvider(widget.documentId).notifier);

  BusinessDocument? get _document => ref
      .read(documentEditorControllerProvider(widget.documentId))
      .value
      ?.document;

  @override
  void dispose() {
    for (final slot in _cells.values) {
      slot.focusNode.dispose();
    }
    _addItemFocusNode.dispose();
    super.dispose();
  }

  // Cells and focus.

  _CellSlot _slotFor(GridCellAddress address) =>
      _cells.putIfAbsent(address, () => _CellSlot(address));

  static List<String> _lineIdsOf(BusinessDocument document) => [
    for (final line in document.lineItems) line.lineItemId,
  ];

  static List<LineItemColumn> _editableColumnsOf(BusinessDocument document) => [
    for (final column in DocumentPageMetrics.visibleColumns(
      document.layoutOptions,
      document.documentType,
    ))
      if (isEditableColumn(column)) column,
  ];

  /// The cell holding primary focus, if it is one of this grid's.
  GridCellAddress? get _focusedCell {
    final primary = FocusManager.instance.primaryFocus;
    if (primary == null) return null;
    for (final entry in _cells.entries) {
      if (entry.value.focusNode == primary) return entry.key;
    }
    return null;
  }

  /// The focused cell when the document can be changed.
  GridCellAddress? _focusedCellIfEditable() {
    final document = _document;
    if (document == null || document.isLocked) return null;
    return _focusedCell;
  }

  void _focusCell(GridCellAddress? address) {
    if (address == null) return;
    _cells[address]?.focusNode.requestFocus();
  }

  /// Focuses [address] once the rows of the controller's new state are
  /// built, or "+ Add item" when [address] is null.
  void _focusAfterRebuild(GridCellAddress? address) {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (address == null) {
        _addItemFocusNode.requestFocus();
      } else {
        _cells[address]?.focusNode.requestFocus();
      }
    });
  }

  /// Commits what the user typed into the focused cell, so a structural
  /// change never relies on the cell being disposed to save it.
  void _commitFocusedCell() {
    final address = _focusedCell;
    if (address != null) _cells[address]!.commitHandle.commitPending();
  }

  void _pruneDeadCells() {
    _isPruneScheduled = false;
    if (!mounted) return;
    final dead = [
      for (final address in _cells.keys)
        if (!_liveAddresses.contains(address)) address,
    ];
    for (final address in dead) {
      _cells.remove(address)!.focusNode.dispose();
    }
  }

  // Keyboard actions.

  GridCellAddress? _stepTarget({required bool forward}) {
    final from = _focusedCell;
    final document = _document;
    if (from == null || document == null) return null;
    final lineIds = _lineIdsOf(document);
    final columns = _editableColumnsOf(document);
    return forward
        ? _navigation.next(from, lineIds, columns)
        : _navigation.previous(from, lineIds, columns);
  }

  bool _canMoveBelow() {
    final from = _focusedCell;
    final document = _document;
    // Enter in the description is a new line of text.
    if (from == null ||
        document == null ||
        from.column == LineItemColumn.description) {
      return false;
    }
    final below = _navigation.below(
      from,
      _lineIdsOf(document),
      _editableColumnsOf(document),
    );
    return below != null || !document.isLocked;
  }

  void _moveBelow() {
    final from = _focusedCell;
    final document = _document;
    if (from == null || document == null) return;
    final below = _navigation.below(
      from,
      _lineIdsOf(document),
      _editableColumnsOf(document),
    );
    if (below != null) {
      _focusCell(below);
    } else {
      _insertLine(atIndex: document.lineItems.length);
    }
  }

  void _insertBelowFocusedRow() {
    final from = _focusedCell;
    final document = _document;
    if (from == null || document == null) return;
    _insertLine(atIndex: _lineIdsOf(document).indexOf(from.lineItemId) + 1);
  }

  void _removeFocusedRow() {
    final from = _focusedCell;
    final document = _document;
    if (from == null || document == null) return;
    final target = _navigation.afterRowRemoved(from, _lineIdsOf(document));
    _editor.removeLineItem(from.lineItemId);
    _focusAfterRebuild(target);
  }

  int? _moveTargetIndex(int offset) {
    final from = _focusedCellIfEditable();
    final document = _document;
    if (from == null || document == null) return null;
    final target = _lineIdsOf(document).indexOf(from.lineItemId) + offset;
    if (target < 0 || target >= document.lineItems.length) return null;
    return target;
  }

  void _moveFocusedRow(int offset) {
    final from = _focusedCell;
    final target = _moveTargetIndex(offset);
    if (from == null || target == null) return;
    _commitFocusedCell();
    _editor.moveLineItem(from.lineItemId, toIndex: target);
    _focusAfterRebuild(from);
  }

  // Row intents shared by keys, the row menu and "+ Add item".

  void _insertLine({required int atIndex}) {
    _commitFocusedCell();
    final lineItemId = _editor.insertLineItem(atIndex: atIndex);
    if (lineItemId == null) return;
    _focusAfterRebuild(
      GridCellAddress(
        lineItemId: lineItemId,
        column: LineItemColumn.description,
      ),
    );
  }

  void _insertRelativeTo(String lineItemId, {required int offset}) {
    final document = _document;
    if (document == null) return;
    final index = _lineIdsOf(document).indexOf(lineItemId);
    if (index >= 0) _insertLine(atIndex: index + offset);
  }

  void _duplicateLine(String lineItemId) {
    _commitFocusedCell();
    _editor.duplicateLineItem(lineItemId);
  }

  void _removeLine(String lineItemId) => _editor.removeLineItem(lineItemId);

  void _moveLineByDrag(int fromIndex, int toIndex) {
    final document = _document;
    if (document == null || fromIndex >= document.lineItems.length) return;
    _commitFocusedCell();
    _editor.moveLineItem(
      document.lineItems[fromIndex].lineItemId,
      toIndex: toIndex,
    );
  }

  /// Applies typed text to a cell; returns false when it is not a valid
  /// value, so the cell keeps the stored one.
  bool _commitCell(String lineItemId, LineItemColumn column, String text) {
    // A cell disposed with the grid has nowhere left to commit.
    if (!mounted) return false;
    final document = _document;
    if (document == null || document.isLocked) return true;
    final format = document.pricingTerms.currencyFormat;
    final index = _lineIdsOf(document).indexOf(lineItemId);
    // The row is gone, so there is nothing to keep.
    if (index < 0) return true;
    final isValid =
        lineWithCellInput(document.lineItems[index], column, text, format) !=
        null;
    if (!isValid) return false;
    _editor.updateLineItem(
      lineItemId,
      (line) => lineWithCellInput(line, column, text, format) ?? line,
    );
    return true;
  }

  // Building.

  /// What is left to deliver per sales order line, for a delivery order with
  /// a known sales order; otherwise null.
  Map<String, int>? _remainingToDeliver(BusinessDocument document) {
    if (document.documentType != DocumentType.deliveryOrder) return null;
    final (salesOrder, otherDeliveryOrders) = ref.watch(
      documentEditorControllerProvider(widget.documentId).select(
        (state) => (
          state.requireValue.salesOrder,
          state.requireValue.otherDeliveryOrders,
        ),
      ),
    );
    if (salesOrder == null) return null;
    return _deliveryProgress.remainingQuantityBySalesOrderLine(
      salesOrder: salesOrder,
      deliveryOrders: otherDeliveryOrders,
      excludeDeliveryOrderId: document.documentId,
    );
  }

  Widget _buildRow(
    BusinessDocument document,
    int index, {
    required List<LineItemColumn> columns,
    required int amountMinor,
    required Map<String, int>? remainingBySalesOrderLine,
  }) {
    final line = document.lineItems[index];
    final sourceId = line.sourceLineItemId;
    final remaining = sourceId == null
        ? null
        : remainingBySalesOrderLine?[sourceId];
    GridCellAddress addressOf(LineItemColumn column) =>
        GridCellAddress(lineItemId: line.lineItemId, column: column);
    return LineItemRow(
      key: ValueKey(line.lineItemId),
      line: line,
      index: index,
      columns: columns,
      currencyFormat: document.pricingTerms.currencyFormat,
      amountMinor: amountMinor,
      isLocked: document.isLocked,
      remainingToDeliver: remaining != null && line.quantityScaled > remaining
          ? math.max(0, remaining)
          : null,
      focusNodeFor: (column) => _slotFor(addressOf(column)).focusNode,
      commitHandleFor: (column) => _slotFor(addressOf(column)).commitHandle,
      onCellCommitted: (column, text) =>
          _commitCell(line.lineItemId, column, text),
      onInsertAbove: () => _insertRelativeTo(line.lineItemId, offset: 0),
      onInsertBelow: () => _insertRelativeTo(line.lineItemId, offset: 1),
      onDuplicate: () => _duplicateLine(line.lineItemId),
      onDelete: () => _removeLine(line.lineItemId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final document = watchEditedDocument(ref, widget.documentId);
    final totalsCalculator = ref.watch(documentTotalsCalculatorProvider);
    final remainingBySalesOrderLine = _remainingToDeliver(document);
    final columns = DocumentPageMetrics.visibleColumns(
      document.layoutOptions,
      document.documentType,
    );
    final editableColumns = _editableColumnsOf(document);
    final isLocked = document.isLocked;

    _liveAddresses = {
      for (final line in document.lineItems)
        for (final column in editableColumns)
          GridCellAddress(lineItemId: line.lineItemId, column: column),
    };
    if (!_isPruneScheduled &&
        _cells.keys.any((address) => !_liveAddresses.contains(address))) {
      _isPruneScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _pruneDeadCells());
    }

    final rows = [
      for (var index = 0; index < document.lineItems.length; index++)
        _buildRow(
          document,
          index,
          columns: columns,
          amountMinor: totalsCalculator.lineAmountMinor(
            document.lineItems[index],
          ),
          remainingBySalesOrderLine: remainingBySalesOrderLine,
        ),
    ];

    return Shortcuts(
      shortcuts: lineItemGridShortcuts,
      child: Actions(
        actions: _actions,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: LineItemGrid.gutterWidth),
              child: LineItemTableRow(
                columns: columns,
                bottomRule: DocumentPageStyles.tokens.ink,
                cellFor: (column) => StaticCellText(
                  lineItemColumnLabel(column),
                  column: column,
                  style: DocumentPageStyles.caption,
                ),
              ),
            ),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              proxyDecorator: _decorateDraggedRow,
              onReorderItem: _moveLineByDrag,
              children: rows,
            ),
            if (!isLocked)
              Padding(
                padding: const EdgeInsets.only(
                  left: LineItemGrid.gutterWidth,
                  top: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    focusNode: _addItemFocusNode,
                    onPressed: () =>
                        _insertLine(atIndex: document.lineItems.length),
                    style: TextButton.styleFrom(
                      foregroundColor: DocumentPageStyles.tokens.action,
                      textStyle: DocumentPageStyles.body,
                      minimumSize: const Size(0, 28),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('+ Add item'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The row being dragged: paper with an action outline, no shadow.
Widget _decorateDraggedRow(Widget child, int index, Animation<double> _) {
  final tokens = DocumentPageStyles.tokens;
  return Material(
    type: MaterialType.transparency,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.paper,
        border: Border.all(color: tokens.action),
      ),
      child: child,
    ),
  );
}
