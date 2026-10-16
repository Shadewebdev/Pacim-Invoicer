import 'package:flutter/material.dart';

import '../../../app/theme/app_color_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/document_type_colors.dart';
import '../../../domain/models/document_type.dart';

/// Tabs for choosing which document type a settings section edits, tinted
/// with that type's copy-paper colour.
class DocumentTypeTabs extends StatelessWidget {
  const DocumentTypeTabs({
    required this.selectedType,
    required this.onSelected,
    super.key,
  });

  final DocumentType selectedType;
  final ValueChanged<DocumentType> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorTokens>()!;
    final colors = theme.extension<DocumentTypeColors>()!;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.rule)),
      ),
      child: Row(
        children: [
          for (final type in DocumentType.values)
            Expanded(
              child: _DocumentTypeTab(
                label: type.displayName,
                isSelected: type == selectedType,
                tint: colors.tintFor(type),
                ink: colors.inkFor(type),
                onTap: () => onSelected(type),
              ),
            ),
        ],
      ),
    );
  }
}

class _DocumentTypeTab extends StatelessWidget {
  const _DocumentTypeTab({
    required this.label,
    required this.isSelected,
    required this.tint,
    required this.ink,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color tint;
  final Color ink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? tint : null,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? ink : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppTypography.body,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? ink : null,
            ),
          ),
        ),
      ),
    );
  }
}
