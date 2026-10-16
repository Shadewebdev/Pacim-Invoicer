import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_color_tokens.dart';
import '../../../app/theme/app_typography.dart';

/// Text that looks printed until hovered or focused, then shows an outline.
///
/// Commits on blur and, for single-line fields, on Enter.
class InlineTextField extends StatefulWidget {
  const InlineTextField({
    required this.value,
    required this.onCommitted,
    this.readOnly = false,
    this.style,
    this.maxLines = 1,
    this.placeholder,
    this.textAlign = TextAlign.start,
    super.key,
  });

  final String value;
  final ValueChanged<String> onCommitted;
  final bool readOnly;
  final TextStyle? style;

  /// One line by default; null lets the field grow with its text.
  final int? maxLines;
  final String? placeholder;
  final TextAlign textAlign;

  @override
  State<InlineTextField> createState() => _InlineTextFieldState();
}

class _InlineTextFieldState extends State<InlineTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(InlineTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) _commit();
    setState(() {});
  }

  void _commit() {
    if (widget.readOnly) return;
    if (_controller.text != widget.value) {
      widget.onCommitted(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    // The page stays white in dark mode, so it uses the light tokens.
    const tokens = AppColorTokens.light;
    final isEditable = !widget.readOnly;
    final outlineColor = !isEditable
        ? Colors.transparent
        : _focusNode.hasFocus
        ? tokens.action
        : _isHovered
        ? tokens.rule
        : Colors.transparent;
    final pageInk = tokens.ink;
    final baseStyle = TextStyle(
      fontFamily: AppTypography.documentFontFamily,
      fontSize: AppTypography.body,
      height: 1.4,
      color: pageInk,
      fontFeatures: const [FontFeature.tabularFigures()],
    ).merge(widget.style);
    final isSingleLine = widget.maxLines == 1;

    return MouseRegion(
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
          focusNode: _focusNode,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          minLines: 1,
          style: baseStyle,
          textAlign: widget.textAlign,
          cursorColor: tokens.action,
          keyboardType: isSingleLine
              ? TextInputType.text
              : TextInputType.multiline,
          textInputAction: isSingleLine
              ? TextInputAction.done
              : TextInputAction.newline,
          onSubmitted: isSingleLine ? (_) => _commit() : null,
          inputFormatters: [if (isSingleLine) _singleLineFormatter],
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
            hintText: widget.placeholder,
            hintStyle: baseStyle.copyWith(
              color: pageInk.withValues(alpha: 0.32),
            ),
          ),
        ),
      ),
    );
  }
}

final TextInputFormatter _singleLineFormatter =
    FilteringTextInputFormatter.deny(RegExp(r'[\r\n]'));
