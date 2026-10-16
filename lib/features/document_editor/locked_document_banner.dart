import 'package:flutter/material.dart';

import '../../app/theme/app_color_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/models/business_document.dart';
import '../../domain/models/document_summary.dart';

/// Tells the person why a document is read-only and offers the two ways on:
/// copy it into a new draft, or open the document that locked it.
class LockedDocumentBanner extends StatelessWidget {
  const LockedDocumentBanner({
    required this.document,
    required this.createdFrom,
    this.onDuplicateAsNewDraft,
    this.onOpenCreatedDocument,
    super.key,
  });

  final BusinessDocument document;

  /// The document created from [document], or null while it is unknown.
  final DocumentSummary? createdFrom;

  /// Null disables the button.
  final VoidCallback? onDuplicateAsNewDraft;
  final ValueChanged<DocumentSummary>? onOpenCreatedDocument;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    final typeName = document.documentType.displayName.toLowerCase();
    final created = createdFrom;
    final message = created == null
        ? 'This $typeName is locked'
        : 'This $typeName is locked because ${created.documentNumber} '
              'was created from it';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(bottom: BorderSide(color: tokens.rule)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(Icons.lock_outline, size: 16, color: tokens.ink),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(
                    message,
                    style: const TextStyle(fontSize: AppTypography.body),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: onDuplicateAsNewDraft,
                        child: const Text('Duplicate as new draft'),
                      ),
                      if (created != null)
                        OutlinedButton(
                          onPressed: onOpenCreatedDocument == null
                              ? null
                              : () => onOpenCreatedDocument!(created),
                          child: Text('Open ${created.documentNumber}'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
