import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../document_editor_controller.dart';
import 'document_page_styles.dart';
import 'watched_document.dart';
import 'inline_text_field.dart';
import 'page_image.dart';

/// Notes and terms on the left, the signature block on the right.
class DocumentPageNotesAndSignature extends ConsumerWidget {
  const DocumentPageNotesAndSignature({required this.documentId, super.key});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = watchEditedDocument(ref, documentId);
    final isLocked = document.isLocked;
    final controller = ref.read(
      documentEditorControllerProvider(documentId).notifier,
    );
    final layout = document.layoutOptions;
    final signature = document.signatureBlock;
    final signatureAssetId = signature.signatureAssetId;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (layout.showNotes) ...[
                Text('Notes', style: DocumentPageStyles.caption),
                InlineTextField(
                  key: const ValueKey('notes'),
                  value: document.notes,
                  placeholder: 'Add notes',
                  readOnly: isLocked,
                  maxLines: null,
                  onCommitted: controller.updateNotes,
                ),
                const SizedBox(height: 12),
              ],
              if (layout.showTermsAndConditions) ...[
                Text('Terms and conditions', style: DocumentPageStyles.caption),
                InlineTextField(
                  key: const ValueKey('termsAndConditions'),
                  value: document.termsAndConditions,
                  placeholder: 'Add terms and conditions',
                  readOnly: isLocked,
                  maxLines: null,
                  style: DocumentPageStyles.body.copyWith(fontSize: 12),
                  onCommitted: controller.updateTermsAndConditions,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 2,
          child: layout.showSignature
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 56,
                      child: signatureAssetId == null
                          ? null
                          : PageImage(assetId: signatureAssetId, maxHeight: 56),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: DocumentPageStyles.tokens.ink),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InlineTextField(
                            key: const ValueKey('signatoryName'),
                            value: signature.signatoryName,
                            placeholder: 'Name',
                            readOnly: isLocked,
                            style: DocumentPageStyles.emphasis,
                            onCommitted: (value) =>
                                controller.updateSignatureBlock(
                                  signature.copyWith(signatoryName: value),
                                ),
                          ),
                          InlineTextField(
                            key: const ValueKey('signatoryTitle'),
                            value: signature.signatoryTitle,
                            placeholder: 'Title',
                            readOnly: isLocked,
                            onCommitted: (value) =>
                                controller.updateSignatureBlock(
                                  signature.copyWith(signatoryTitle: value),
                                ),
                          ),
                          InlineTextField(
                            key: const ValueKey('signatureCaption'),
                            value: signature.signatureCaption,
                            placeholder: 'Caption',
                            readOnly: isLocked,
                            style: DocumentPageStyles.caption,
                            onCommitted: (value) =>
                                controller.updateSignatureBlock(
                                  signature.copyWith(signatureCaption: value),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
