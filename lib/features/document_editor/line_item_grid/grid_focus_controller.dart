import '../../../shared/document_page_metrics.dart';
import 'grid_cell_address.dart';

/// Works out which cell keyboard navigation lands on. Pure Dart: it knows the
/// row order and the editable columns, nothing about widgets or focus.
///
/// Every method returns `null` at the edge of the grid (or for an address
/// that is not in it), so the caller decides whether to add a row or let
/// focus leave the grid.
class GridFocusController {
  const GridFocusController();

  /// The cell after [from] in reading order, wrapping to the next row.
  GridCellAddress? next(
    GridCellAddress from,
    List<String> lineIds,
    List<LineItemColumn> editableColumns,
  ) => _step(from, lineIds, editableColumns, 1);

  /// The cell before [from] in reading order, wrapping to the previous row.
  GridCellAddress? previous(
    GridCellAddress from,
    List<String> lineIds,
    List<LineItemColumn> editableColumns,
  ) => _step(from, lineIds, editableColumns, -1);

  /// The same column on the row below [from].
  GridCellAddress? below(
    GridCellAddress from,
    List<String> lineIds,
    List<LineItemColumn> editableColumns,
  ) {
    final row = lineIds.indexOf(from.lineItemId);
    if (row < 0 || !editableColumns.contains(from.column)) return null;
    if (row + 1 >= lineIds.length) return null;
    return GridCellAddress(lineItemId: lineIds[row + 1], column: from.column);
  }

  /// Where focus goes when the row of [from] is removed: the same column on
  /// the row below, or on the row above when it was the last row.
  GridCellAddress? afterRowRemoved(GridCellAddress from, List<String> lineIds) {
    final row = lineIds.indexOf(from.lineItemId);
    if (row < 0) return null;
    final neighbour = row + 1 < lineIds.length ? row + 1 : row - 1;
    if (neighbour < 0) return null;
    return GridCellAddress(lineItemId: lineIds[neighbour], column: from.column);
  }

  GridCellAddress? _step(
    GridCellAddress from,
    List<String> lineIds,
    List<LineItemColumn> editableColumns,
    int direction,
  ) {
    final row = lineIds.indexOf(from.lineItemId);
    final column = editableColumns.indexOf(from.column);
    if (row < 0 || column < 0) return null;
    final position = row * editableColumns.length + column + direction;
    if (position < 0 || position >= lineIds.length * editableColumns.length) {
      return null;
    }
    return GridCellAddress(
      lineItemId: lineIds[position ~/ editableColumns.length],
      column: editableColumns[position % editableColumns.length],
    );
  }
}
