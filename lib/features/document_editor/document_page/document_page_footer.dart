import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../document_editor_controller.dart';
import 'document_page_styles.dart';
import 'watched_document.dart';
import 'inline_text_field.dart';

/// The footer note, ruled off at the foot of the page. Page numbers belong to
/// the PDF, where pages exist, so the screen does not show them.
class DocumentPageFooter extends ConsumerWidget {
  const DocumentPageFooter({required this.documentId, super.key});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = watchEditedDocument(ref, documentId);
    final layout = document.layoutOptions;
    if (!layout.showFooterNote) return const SizedBox.shrink();
    final controller = ref.read(
      documentEditorControllerProvider(documentId).notifier,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: DocumentPageStyles.tokens.rule)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: InlineTextField(
          key: const ValueKey('footerNote'),
          value: document.footerNote,
          placeholder: 'Footer note',
          readOnly: document.isLocked,
          maxLines: null,
          style: DocumentPageStyles.caption,
          onCommitted: controller.updateFooterNote,
        ),
      ),
    );
  }
}
