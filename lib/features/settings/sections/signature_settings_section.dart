import 'package:flutter/material.dart';

import '../../../domain/models/document_settings.dart';
import '../../../domain/models/document_type.dart';
import '../../../domain/models/signature_block.dart';
import '../image_picker_field.dart';
import '../settings_controller.dart';
import '../settings_fields.dart';
import 'document_type_tabs.dart';

class SignatureSettingsSection extends StatelessWidget {
  const SignatureSettingsSection({
    required this.settings,
    required this.controller,
    required this.selectedType,
    required this.onTypeSelected,
    super.key,
  });

  final DocumentSettings settings;
  final SettingsController controller;
  final DocumentType selectedType;
  final ValueChanged<DocumentType> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    final block = settings.signatureBlockByType[selectedType]!;
    void edit(SignatureBlock changed) =>
        controller.updateSignatureBlock(selectedType, changed);

    return SettingsSectionLayout(
      title: 'Signature',
      leading: DocumentTypeTabs(
        selectedType: selectedType,
        onSelected: onTypeSelected,
      ),
      children: [
        SettingsTextField(
          key: ValueKey('signatory-name-$selectedType'),
          label: 'Signatory name',
          value: block.signatoryName,
          onChanged: (value) => edit(block.copyWith(signatoryName: value)),
        ),
        SettingsTextField(
          key: ValueKey('signatory-title-$selectedType'),
          label: 'Signatory title',
          value: block.signatoryTitle,
          onChanged: (value) => edit(block.copyWith(signatoryTitle: value)),
        ),
        SettingsTextField(
          key: ValueKey('signature-caption-$selectedType'),
          label: 'Caption under the signature',
          value: block.signatureCaption,
          onChanged: (value) => edit(block.copyWith(signatureCaption: value)),
        ),
        ImagePickerField(
          key: ValueKey('signature-image-$selectedType'),
          label: 'Signature image',
          assetId: block.signatureAssetId,
          onImagePicked: (bytes) =>
              controller.importSignatureImage(selectedType, bytes),
          onRemove: () => edit(block.copyWith(signatureAssetId: null)),
        ),
      ],
    );
  }
}
