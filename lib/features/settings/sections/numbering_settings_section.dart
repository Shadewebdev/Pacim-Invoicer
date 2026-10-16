import 'package:flutter/material.dart';

import '../../../app/theme/app_color_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../domain/models/document_numbering_rule.dart';
import '../../../domain/models/document_settings.dart';
import '../../../domain/models/document_type.dart';
import '../../../domain/services/document_number_formatter.dart';
import '../settings_controller.dart';
import '../settings_fields.dart';
import 'document_type_tabs.dart';

class NumberingSettingsSection extends StatefulWidget {
  const NumberingSettingsSection({
    required this.settings,
    required this.controller,
    required this.selectedType,
    required this.onTypeSelected,
    required this.previewDate,
    super.key,
  });

  final DocumentSettings settings;
  final SettingsController controller;
  final DocumentType selectedType;
  final ValueChanged<DocumentType> onTypeSelected;

  /// The date the next-number preview is rendered for.
  final DateTime previewDate;

  @override
  State<NumberingSettingsSection> createState() =>
      _NumberingSettingsSectionState();
}

class _NumberingSettingsSectionState extends State<NumberingSettingsSection> {
  static const _formatter = DocumentNumberFormatter();

  /// What is typed in the pattern field per type, including invalid text that
  /// was not saved.
  final Map<DocumentType, String> _typedPatternByType = {};

  DocumentNumberingRule get _savedRule =>
      widget.settings.numberingRuleByType[widget.selectedType]!;

  String get _shownPattern =>
      _typedPatternByType[widget.selectedType] ?? _savedRule.pattern;

  void _handlePatternChanged(String pattern) {
    setState(() => _typedPatternByType[widget.selectedType] = pattern);
    widget.controller.updateNumberingRule(
      widget.selectedType,
      _savedRule.copyWith(pattern: pattern),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    final problems = widget.controller.findNumberingPatternProblems(
      _shownPattern,
    );
    final nextNumber = _formatter.format(
      problems.isEmpty ? _shownPattern : _savedRule.pattern,
      sequence: 1,
      date: widget.previewDate,
    );

    return SettingsSectionLayout(
      title: 'Numbering',
      leading: DocumentTypeTabs(
        selectedType: widget.selectedType,
        onSelected: widget.onTypeSelected,
      ),
      children: [
        SettingsTextField(
          key: ValueKey('pattern-${widget.selectedType}'),
          label: 'Number pattern',
          value: _shownPattern,
          errorText: problems.isEmpty ? null : problems.join('\n'),
          onChanged: _handlePatternChanged,
        ),
        Text(
          'Use {yyyy}, {yy}, {mm} and {seq:N}. For example, QT-{yyyy}-{seq:4}.',
          style: TextStyle(
            fontSize: AppTypography.caption,
            color: tokens.ink.withValues(alpha: 0.7),
          ),
        ),
        SettingsToggleRow(
          label: 'Restart numbering each year',
          value: _savedRule.resetsYearly,
          onChanged: (value) => widget.controller.updateNumberingRule(
            widget.selectedType,
            _savedRule.copyWith(resetsYearly: value),
          ),
        ),
        Row(
          children: [
            const Text(
              'Next number',
              style: TextStyle(fontSize: AppTypography.body),
            ),
            const SizedBox(width: 12),
            Text(
              nextNumber,
              style: const TextStyle(
                fontSize: AppTypography.field,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
