import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/features/document_editor/line_item_grid/grid_cell_address.dart';
import 'package:pacim_invoicer/features/document_editor/line_item_grid/grid_focus_controller.dart';
import 'package:pacim_invoicer/shared/document_page_metrics.dart';

const _controller = GridFocusController();
const _lines = ['a', 'b'];
const _columns = [
  LineItemColumn.description,
  LineItemColumn.unit,
  LineItemColumn.quantity,
];

GridCellAddress _at(String line, LineItemColumn column) =>
    GridCellAddress(lineItemId: line, column: column);

void main() {
  test('Tab order wraps to next row', () {
    expect(
      _controller.next(_at('a', LineItemColumn.unit), _lines, _columns),
      _at('a', LineItemColumn.quantity),
    );
    expect(
      _controller.next(_at('a', LineItemColumn.quantity), _lines, _columns),
      _at('b', LineItemColumn.description),
    );
    expect(
      _controller.previous(
        _at('b', LineItemColumn.description),
        _lines,
        _columns,
      ),
      _at('a', LineItemColumn.quantity),
    );
  });

  test('next on the last cell returns null', () {
    expect(
      _controller.next(_at('b', LineItemColumn.quantity), _lines, _columns),
      isNull,
    );
    expect(
      _controller.previous(
        _at('a', LineItemColumn.description),
        _lines,
        _columns,
      ),
      isNull,
    );
  });

  test('below on the last row returns null', () {
    expect(
      _controller.below(_at('a', LineItemColumn.unit), _lines, _columns),
      _at('b', LineItemColumn.unit),
    );
    expect(
      _controller.below(_at('b', LineItemColumn.unit), _lines, _columns),
      isNull,
    );
  });

  test('unknown rows and columns return null', () {
    expect(
      _controller.next(_at('gone', LineItemColumn.unit), _lines, _columns),
      isNull,
    );
    expect(
      _controller.next(_at('a', LineItemColumn.discount), _lines, _columns),
      isNull,
    );
  });

  test('after removing a row focus goes below, or above on the last row', () {
    expect(
      _controller.afterRowRemoved(_at('a', LineItemColumn.unit), _lines),
      _at('b', LineItemColumn.unit),
    );
    expect(
      _controller.afterRowRemoved(_at('b', LineItemColumn.unit), _lines),
      _at('a', LineItemColumn.unit),
    );
    expect(
      _controller.afterRowRemoved(_at('a', LineItemColumn.unit), ['a']),
      isNull,
    );
  });
}
