import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_color_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/repository_providers.dart';
import '../../../domain/models/document_numbering_rule.dart';
import '../../../domain/models/document_settings.dart';
import '../../../domain/models/document_type.dart';
import '../../../domain/services/document_number_formatter.dart';
import '../settings_controller.dart';
import '../settings_fields.dart';
import 'document_type_tabs.dart';

/// Which counter a numbering preview reads.
typedef NextSequenceKey = ({DocumentType type, int year, bool resetsYearly});

/// The sequence the next document of a type would get, for the preview.
final nextSequenceProvider = FutureProvider.autoDispose
    .family<int, NextSequenceKey>(
      (ref, key) => ref
          .watch(numberSequenceRepositoryProvider)
          .peekNextSequence(
            key.type,
            year: key.year,
            resetsYearly: key.resetsYearly,
          ),
    );

class NumberingSettingsSection extends ConsumerStatefulWidget {
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
  ConsumerState<NumberingSettingsSection> createState() =>
      _NumberingSettingsSectionState();
}

class _NumberingSettingsSectionState
    extends ConsumerState<NumberingSettingsSection> {
  static const _formatter = DocumentNumberFormatter();

  /// The rule as shown per type, including an invalid pattern or reset choice
  /// that was not saved.
  final Map<DocumentType, DocumentNumberingRule> _shownRuleByType = {};

  DocumentNumberingRule get _savedRule =>
      widget.settings.numberingRuleByType[widget.selectedType]!;

  DocumentNumberingRule get _shownRule =>
      _shownRuleByType[widget.selectedType] ?? _savedRule;

  /// Saves [rule] when it has no problems; until then it is only shown.
  void _changeRule(DocumentNumberingRule rule) {
    setState(() => _shownRuleByType[widget.selectedType] = rule);
    widget.controller.updateNumberingRule(widget.selectedType, rule);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    final shownRule = _shownRule;
    final problems = widget.controller.findNumberingRuleProblems(shownRule);
    final previewRule = problems.isEmpty ? shownRule : _savedRule;
    final nextSequence =
        ref
            .watch(
              nextSequenceProvider((
                type: widget.selectedType,
                year: widget.previewDate.year,
                resetsYearly: previewRule.resetsYearly,
              )),
            )
            .value ??
        1;
    final nextNumber = _formatter.format(
      previewRule.pattern,
      sequence: nextSequence,
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
          value: shownRule.pattern,
          errorText: problems.isEmpty ? null : problems.join('\n'),
          onChanged: (pattern) =>
              _changeRule(shownRule.copyWith(pattern: pattern)),
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
          value: shownRule.resetsYearly,
          onChanged: (value) =>
              _changeRule(shownRule.copyWith(resetsYearly: value)),
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
