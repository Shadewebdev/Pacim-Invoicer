import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../document_editor_controller.dart';
import 'document_page_styles.dart';
import 'inline_text_field.dart';

/// The footer note and the page number, ruled off at the foot of the page.
class DocumentPageFooter extends ConsumerWidget {
  const DocumentPageFooter({required this.documentId, super.key});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref
        .watch(documentEditorControllerProvider(documentId))
        .requireValue;
    final document = editorState.document;
    final layout = document.layoutOptions;
    if (!layout.showFooterNote && !layout.showPageNumbers) {
      return const SizedBox.shrink();
    }
    final controller = ref.read(
      documentEditorControllerProvider(documentId).notifier,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: DocumentPageStyles.tokens.rule)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: layout.showFooterNote
                  ? InlineTextField(
                      key: const ValueKey('footerNote'),
                      value: document.footerNote,
                      placeholder: 'Footer note',
                      readOnly: editorState.isLocked,
                      maxLines: null,
                      style: DocumentPageStyles.caption,
                      onCommitted: controller.updateFooterNote,
                    )
                  : const SizedBox.shrink(),
            ),
            if (layout.showPageNumbers) ...[
              const SizedBox(width: 24),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text('Page 1 of 1', style: DocumentPageStyles.caption),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
