import 'package:flutter/foundation.dart';

import '../../../shared/document_page_metrics.dart';

/// One editable cell of the line item grid: a line and a column.
@immutable
class GridCellAddress {
  const GridCellAddress({required this.lineItemId, required this.column});

  final String lineItemId;
  final LineItemColumn column;

  @override
  bool operator ==(Object other) =>
      other is GridCellAddress &&
      other.lineItemId == lineItemId &&
      other.column == column;

  @override
  int get hashCode => Object.hash(lineItemId, column);

  @override
  String toString() => 'GridCellAddress($lineItemId, ${column.name})';
}
