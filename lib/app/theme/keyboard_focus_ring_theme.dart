import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Rebuilds the theme with or without focus rings as the user switches between
/// keyboard and pointer, so a ring marks keyboard focus only and not the
/// button that was just clicked.
class KeyboardFocusRingTheme extends StatefulWidget {
  const KeyboardFocusRingTheme({required this.child, super.key});

  final Widget child;

  @override
  State<KeyboardFocusRingTheme> createState() => _KeyboardFocusRingThemeState();
}

class _KeyboardFocusRingThemeState extends State<KeyboardFocusRingTheme> {
  late bool _isKeyboardMode = _readsKeyboardMode();

  bool _readsKeyboardMode() =>
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_onHighlightModeChanged);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightModeChanged);
    super.dispose();
  }

  void _onHighlightModeChanged(FocusHighlightMode mode) {
    final isKeyboardMode = mode == FocusHighlightMode.traditional;
    if (isKeyboardMode != _isKeyboardMode) {
      setState(() => _isKeyboardMode = isKeyboardMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = Theme.of(context);
    return Theme(
      data: buildAppTheme(
        brightness: current.brightness,
        platform: current.platform,
        showsFocusRing: _isKeyboardMode,
      ),
      child: widget.child,
    );
  }
}
