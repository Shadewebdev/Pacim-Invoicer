import 'package:flutter/material.dart';

import '../../app/theme/app_typography.dart';
import '../../app/theme/document_type_colors.dart';
import '../../domain/models/document_type.dart';

/// A small copy-paper chip: the type's tint behind its ink, with [label].
class DocumentTypeBadge extends StatelessWidget {
  const DocumentTypeBadge({
    required this.documentType,
    required this.label,
    super.key,
  });

  final DocumentType documentType;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<DocumentTypeColors>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.tintFor(documentType),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: AppTypography.caption,
            color: colors.inkFor(documentType),
          ),
        ),
      ),
    );
  }
}
