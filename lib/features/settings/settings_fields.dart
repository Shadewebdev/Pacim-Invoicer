import 'package:flutter/material.dart';

import '../../app/theme/app_typography.dart';

const String invalidNumberMessage = 'Enter a number';

/// Scrolling form column shared by every settings section.
class SettingsSectionLayout extends StatelessWidget {
  const SettingsSectionLayout({
    required this.title,
    required this.children,
    this.leading,
    super.key,
  });

  final String title;

  /// Shown above the fields, for example the document type tabs.
  final Widget? leading;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                if (leading != null) ...[const SizedBox(height: 12), leading!],
                const SizedBox(height: 16),
                for (final child in children) ...[
                  child,
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A text field that reports each edit. It keeps its own cursor and text, so
/// give it a key that changes when it must show a different record.
class SettingsTextField extends StatefulWidget {
  const SettingsTextField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.maxLines = 1,
    this.errorText,
    super.key,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final String? errorText;

  @override
  State<SettingsTextField> createState() => _SettingsTextFieldState();
}

class _SettingsTextFieldState extends State<SettingsTextField> {
  late final TextEditingController _textController = TextEditingController(
    text: widget.value,
  );

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      onChanged: widget.onChanged,
      minLines: widget.maxLines > 1 ? 3 : 1,
      maxLines: widget.maxLines,
      style: const TextStyle(fontSize: AppTypography.field),
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        errorMaxLines: 3,
        alignLabelWithHint: widget.maxLines > 1,
      ),
    );
  }
}

/// A text field for a typed value. Valid input is reported through
/// [onParsed]; anything else shows [errorText] and is not reported.
class SettingsParsedField<T> extends StatefulWidget {
  const SettingsParsedField({
    required this.label,
    required this.initialText,
    required this.parse,
    required this.onParsed,
    this.errorText = invalidNumberMessage,
    super.key,
  });

  final String label;
  final String initialText;
  final T? Function(String text) parse;
  final ValueChanged<T> onParsed;
  final String errorText;

  @override
  State<SettingsParsedField<T>> createState() => _SettingsParsedFieldState<T>();
}

class _SettingsParsedFieldState<T> extends State<SettingsParsedField<T>> {
  late final TextEditingController _textController = TextEditingController(
    text: widget.initialText,
  );
  bool _isInvalid = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleChanged(String text) {
    final parsed = widget.parse(text);
    setState(() => _isInvalid = parsed == null);
    if (parsed != null) widget.onParsed(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      onChanged: _handleChanged,
      style: const TextStyle(fontSize: AppTypography.field),
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: _isInvalid ? widget.errorText : null,
      ),
    );
  }
}

class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text(label, style: const TextStyle(fontSize: AppTypography.body)),
      value: value,
      onChanged: onChanged,
    );
  }
}
