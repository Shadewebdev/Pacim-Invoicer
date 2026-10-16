import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Tab: the next cell, wrapping across rows.
class NextGridCellIntent extends Intent {
  const NextGridCellIntent();
}

/// Shift+Tab: the previous cell, wrapping across rows.
class PreviousGridCellIntent extends Intent {
  const PreviousGridCellIntent();
}

/// Enter on a single-line cell: the same column one row down.
class GridCellBelowIntent extends Intent {
  const GridCellBelowIntent();
}

/// Ctrl+Enter: a new row below the focused one.
class InsertGridRowBelowIntent extends Intent {
  const InsertGridRowBelowIntent();
}

/// Ctrl+Delete: removes the focused row.
class RemoveGridRowIntent extends Intent {
  const RemoveGridRowIntent();
}

/// Alt+↑ / Alt+↓: moves the focused row one place.
class MoveGridRowIntent extends Intent {
  const MoveGridRowIntent(this.offset);

  /// -1 moves up, 1 moves down.
  final int offset;
}

/// The grid's key bindings. They sit on a [Shortcuts] around the grid, so
/// they only see keys while focus is inside it; an action that does not apply
/// to the focused widget is disabled and the key carries on to the page.
const Map<ShortcutActivator, Intent> lineItemGridShortcuts = {
  SingleActivator(LogicalKeyboardKey.tab): NextGridCellIntent(),
  SingleActivator(LogicalKeyboardKey.tab, shift: true):
      PreviousGridCellIntent(),
  SingleActivator(LogicalKeyboardKey.enter): GridCellBelowIntent(),
  SingleActivator(LogicalKeyboardKey.numpadEnter): GridCellBelowIntent(),
  SingleActivator(LogicalKeyboardKey.enter, control: true):
      InsertGridRowBelowIntent(),
  SingleActivator(LogicalKeyboardKey.numpadEnter, control: true):
      InsertGridRowBelowIntent(),
  SingleActivator(LogicalKeyboardKey.delete, control: true):
      RemoveGridRowIntent(),
  SingleActivator(LogicalKeyboardKey.arrowUp, alt: true): MoveGridRowIntent(-1),
  SingleActivator(LogicalKeyboardKey.arrowDown, alt: true): MoveGridRowIntent(
    1,
  ),
};

/// An action whose enabled state is decided when the key arrives. Disabled
/// actions let the key event through to the rest of the page.
class GridAction<T extends Intent> extends Action<T> {
  GridAction({required this.isEnabledFor, required this.onInvoke});

  final bool Function(T intent) isEnabledFor;
  final void Function(T intent) onInvoke;

  @override
  bool isEnabled(T intent) => isEnabledFor(intent);

  @override
  Object? invoke(T intent) {
    onInvoke(intent);
    return null;
  }
}
