import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../document_page/document_page_styles.dart';

/// Lets the grid commit a cell's typed text before it inserts, removes or
/// moves rows, so the change never depends on the cell being disposed.
class GridCellCommitHandle {
  VoidCallback? _commit;

  void commitPending() => _commit?.call();
}

/// One grid cell. It follows the inline field contract: commits on blur and,
/// for single-line cells, on submit, never on keystrokes, and at most once
/// per edit.
///
/// Number cells pass a formatted [displayText] and a raw [editText]: the cell
/// shows the raw text while focused. When [onCommitted] rejects the text the
/// stored value is kept and the cell shows an error outline with the tooltip
/// "Enter a number".
class GridCellField extends StatefulWidget {
  const GridCellField({
    required this.displayText,
    required this.editText,
    required this.onCommitted,
    required this.focusNode,
    this.commitHandle,
    this.readOnly = false,
    this.isMultiline = false,
    this.selectAllOnFocus = false,
    this.textAlign = TextAlign.start,
    this.placeholder,
    super.key,
  });

  final String displayText;
  final String editText;

  /// Returns false when the text is not accepted.
  final bool Function(String text) onCommitted;

  /// Owned by the grid, keyed by cell address, so it outlives this widget
  /// when the row's element is rebuilt.
  final FocusNode focusNode;
  final GridCellCommitHandle? commitHandle;
  final bool readOnly;
  final bool isMultiline;
  final bool selectAllOnFocus;
  final TextAlign textAlign;
  final String? placeholder;

  static const invalidNumberMessage = 'Enter a number';

  @override
  State<GridCellField> createState() => _GridCellFieldState();
}

class _GridCellFieldState extends State<GridCellField> {
  late final TextEditingController _controller;

  /// Keeps the text field's state when the error tooltip wraps it.
  final _fieldKey = GlobalKey();

  /// The edit text of the value last committed (or received), so a blur
  /// after submit commits once.
  late String _lastCommittedText;

  /// True while the controller holds edit text rather than display text.
  bool _isEditing = false;
  bool _isHovered = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _lastCommittedText = widget.editText;
    _controller = TextEditingController(text: widget.displayText);
    widget.focusNode.addListener(_onFocusChanged);
    widget.commitHandle?._commit = _commitPending;
    // A rebuilt row can receive a node that is already focused.
    if (widget.focusNode.hasFocus) _startEditing();
  }

  @override
  void didUpdateWidget(GridCellField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChanged);
      widget.focusNode.addListener(_onFocusChanged);
    }
    if (oldWidget.commitHandle != widget.commitHandle) {
      _detachHandle(oldWidget.commitHandle);
      widget.commitHandle?._commit = _commitPending;
    }
    final storedValueChanged = oldWidget.editText != widget.editText;
    if (storedValueChanged) _hasError = false;
    if (_isEditing) {
      // Follow a new stored value unless the user has typed since.
      if (storedValueChanged && _controller.text == _lastCommittedText) {
        _controller.text = widget.editText;
        _lastCommittedText = widget.editText;
      }
    } else {
      _lastCommittedText = widget.editText;
      if (_controller.text != widget.displayText) {
        _controller.text = widget.displayText;
      }
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    _detachHandle(widget.commitHandle);
    if (_isDirty) {
      // Committing changes the editor's provider, which may not happen while
      // the tree is being torn down, so it waits for the frame to finish.
      final text = _controller.text;
      final commit = widget.onCommitted;
      scheduleMicrotask(() => commit(text));
    }
    _controller.dispose();
    super.dispose();
  }

  bool get _isDirty =>
      !widget.readOnly && _isEditing && _controller.text != _lastCommittedText;

  void _detachHandle(GridCellCommitHandle? handle) {
    if (handle != null && handle._commit == _commitPending) {
      handle._commit = null;
    }
  }

  void _onFocusChanged() {
    if (widget.focusNode.hasFocus) {
      _startEditing();
    } else {
      _commitPending();
      _isEditing = false;
      _lastCommittedText = widget.editText;
      _controller.text = widget.displayText;
    }
    if (mounted) setState(() {});
  }

  void _startEditing() {
    if (_isEditing) return;
    _isEditing = true;
    _lastCommittedText = widget.editText;
    // A read-only cell keeps showing its printed form.
    if (widget.readOnly) return;
    if (_controller.text != widget.editText) {
      _controller.text = widget.editText;
    }
    if (widget.selectAllOnFocus) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    }
  }

  void _commitPending() {
    if (!_isDirty) return;
    final text = _controller.text;
    final isAccepted = widget.onCommitted(text);
    if (isAccepted) {
      _lastCommittedText = text;
      _hasError = false;
    } else {
      _hasError = true;
      _controller.text = widget.editText;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DocumentPageStyles.tokens;
    final isEditable = !widget.readOnly;
    final isFocused = widget.focusNode.hasFocus;
    final outlineColor = _hasError
        ? Theme.of(context).colorScheme.error
        : !isEditable
        ? Colors.transparent
        : isFocused
        ? tokens.action
        : _isHovered
        ? tokens.rule
        : Colors.transparent;
    final style = DocumentPageStyles.body;

    final Widget field = KeyedSubtree(
      key: _fieldKey,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: isEditable ? SystemMouseCursors.text : MouseCursor.defer,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: outlineColor),
            borderRadius: BorderRadius.circular(2),
          ),
          child: TextField(
            controller: _controller,
            focusNode: widget.focusNode,
            readOnly: widget.readOnly,
            maxLines: widget.isMultiline ? null : 1,
            minLines: 1,
            style: style,
            textAlign: widget.textAlign,
            cursorColor: tokens.action,
            keyboardType: widget.isMultiline
                ? TextInputType.multiline
                : TextInputType.text,
            textInputAction: widget.isMultiline
                ? TextInputAction.newline
                : TextInputAction.done,
            onSubmitted: widget.isMultiline ? null : (_) => _commitPending(),
            inputFormatters: [if (!widget.isMultiline) _singleLineFormatter],
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 2,
              ),
              hintText: isEditable ? widget.placeholder : null,
              hintStyle: style.copyWith(
                color: tokens.ink.withValues(alpha: 0.32),
              ),
            ),
          ),
        ),
      ),
    );

    if (!_hasError) return field;
    return Tooltip(message: GridCellField.invalidNumberMessage, child: field);
  }
}

final TextInputFormatter _singleLineFormatter =
    FilteringTextInputFormatter.deny(RegExp(r'[\r\n]'));
