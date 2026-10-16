import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/business_document.dart';
import '../../../domain/models/signature_block.dart';
import '../../settings/image_picker_field.dart';
import '../../settings/settings_fields.dart';
import '../document_editor_controller.dart';
import 'document_image_import.dart';
import 'properties_pane_section.dart';

/// Signatory name, title, caption and signature image.
class SignaturePropertiesSection extends ConsumerWidget {
  const SignaturePropertiesSection({
    required this.document,
    required this.controller,
    required this.isLocked,
    required this.resetGeneration,
    required this.onReset,
    super.key,
  });

  final BusinessDocument document;
  final DocumentEditorController controller;
  final bool isLocked;
  final int resetGeneration;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final block = document.signatureBlock;
    final isEnabled = !isLocked;
    String keyed(String name) => 'pane-$name-$resetGeneration';
    void edit(SignatureBlock changed) =>
        controller.updateSignatureBlock(changed);

    return PropertiesPaneSection(
      title: 'Signature',
      resetSectionName: 'signature',
      onReset: isLocked ? null : onReset,
      children: [
        SettingsTextField(
          key: ValueKey(keyed('signatoryName')),
          label: 'Signatory name',
          value: block.signatoryName,
          isEnabled: isEnabled,
          onChanged: (value) => edit(block.copyWith(signatoryName: value)),
        ),
        SettingsTextField(
          key: ValueKey(keyed('signatoryTitle')),
          label: 'Signatory title',
          value: block.signatoryTitle,
          isEnabled: isEnabled,
          onChanged: (value) => edit(block.copyWith(signatoryTitle: value)),
        ),
        SettingsTextField(
          key: ValueKey(keyed('signatureCaption')),
          label: 'Caption under the signature',
          value: block.signatureCaption,
          isEnabled: isEnabled,
          onChanged: (value) => edit(block.copyWith(signatureCaption: value)),
        ),
        ImagePickerField(
          key: ValueKey(keyed('signatureImage')),
          label: 'Signature image',
          assetId: block.signatureAssetId,
          isEnabled: isEnabled,
          onImagePicked: (bytes) async {
            final assetId = await storeDocumentImage(ref, bytes);
            final latest = ref
                .read(documentEditorControllerProvider(document.documentId))
                .value
                ?.document;
            edit(
              (latest ?? document).signatureBlock.copyWith(
                signatureAssetId: assetId,
              ),
            );
          },
          onRemove: () => edit(block.copyWith(signatureAssetId: null)),
        ),
      ],
    );
  }
}
