import 'package:flutter/material.dart';

import '../../../app/theme/app_color_tokens.dart';
import '../../../app/theme/app_typography.dart';

/// One collapsible group of fields in the properties pane. A section with a
/// [resetSectionName] ends with a "Reset to defaults" button.
class PropertiesPaneSection extends StatefulWidget {
  const PropertiesPaneSection({
    required this.title,
    required this.children,
    this.resetSectionName,
    this.onReset,
    super.key,
  });

  final String title;
  final List<Widget> children;

  /// Names the reset button's key, `resetSection-<name>`. Null means the
  /// section has no reset button.
  final String? resetSectionName;

  /// Null disables the reset button, for example on a locked document.
  final VoidCallback? onReset;

  @override
  State<PropertiesPaneSection> createState() => _PropertiesPaneSectionState();
}

class _PropertiesPaneSectionState extends State<PropertiesPaneSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.rule)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: _isExpanded,
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: AppTypography.field,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final child in widget.children) ...[
                    child,
                    const SizedBox(height: 12),
                  ],
                  if (widget.resetSectionName != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        key: ValueKey(
                          'resetSection-${widget.resetSectionName}',
                        ),
                        onPressed: widget.onReset,
                        child: const Text('Reset to defaults'),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
