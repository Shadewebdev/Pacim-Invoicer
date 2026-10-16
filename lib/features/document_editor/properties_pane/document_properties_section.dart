import 'package:flutter/material.dart';

import '../../../domain/models/business_document.dart';
import '../../../domain/models/document_type.dart';
import '../../settings/settings_fields.dart';
import '../document_editor_controller.dart';
import 'properties_pane_date_field.dart';
import 'properties_pane_section.dart';

/// Dates and customer reference. These have no settings defaults, so the
/// section has no reset button.
class DocumentPropertiesSection extends StatelessWidget {
  const DocumentPropertiesSection({
    required this.document,
    required this.controller,
    required this.today,
    required this.isLocked,
    required this.resetGeneration,
    super.key,
  });

  final BusinessDocument document;
  final DocumentEditorController controller;
  final DateTime today;
  final bool isLocked;
  final int resetGeneration;

  @override
  Widget build(BuildContext context) {
    return PropertiesPaneSection(
      title: 'Document',
      children: [
        PropertiesPaneDateField(
          label: 'Issue date',
          date: document.issueDate,
          fallbackPickerDate: today,
          isEnabled: !isLocked,
          onChanged: controller.updateIssueDate,
        ),
        if (document.documentType == DocumentType.quotation)
          PropertiesPaneDateField(
            label: 'Valid until',
            date: document.validUntilDate,
            fallbackPickerDate: today,
            isEnabled: !isLocked,
            onChanged: controller.updateValidUntilDate,
            onCleared: () => controller.updateValidUntilDate(null),
          ),
        if (document.documentType == DocumentType.deliveryOrder)
          PropertiesPaneDateField(
            label: 'Delivery date',
            date: document.deliveryDate,
            fallbackPickerDate: today,
            isEnabled: !isLocked,
            onChanged: controller.updateDeliveryDate,
            onCleared: () => controller.updateDeliveryDate(null),
          ),
        SettingsTextField(
          key: ValueKey('pane-customerReference-$resetGeneration'),
          label: 'Customer reference',
          value: document.customerReference ?? '',
          isEnabled: !isLocked,
          onChanged: (value) =>
              controller.updateCustomerReference(value.isEmpty ? null : value),
        ),
      ],
    );
  }
}
