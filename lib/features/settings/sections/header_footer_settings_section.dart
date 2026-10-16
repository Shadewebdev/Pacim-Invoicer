import 'package:flutter/material.dart';

import '../../../domain/models/document_layout_options.dart';
import '../../../domain/models/document_settings.dart';
import '../../../domain/models/document_type.dart';
import '../settings_controller.dart';
import '../settings_fields.dart';
import 'document_type_tabs.dart';

class HeaderFooterSettingsSection extends StatelessWidget {
  const HeaderFooterSettingsSection({
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
    final options = settings.layoutOptionsByType[selectedType]!;
    void edit(DocumentLayoutOptions changed) =>
        controller.updateLayoutOptions(selectedType, changed);

    return SettingsSectionLayout(
      title: 'Header & footer',
      leading: DocumentTypeTabs(
        selectedType: selectedType,
        onSelected: onTypeSelected,
      ),
      children: [
        SettingsToggleRow(
          label: 'Show logo',
          value: options.showLogo,
          onChanged: (value) => edit(options.copyWith(showLogo: value)),
        ),
        SettingsToggleRow(
          label: 'Show company registration number',
          value: options.showCompanyRegistration,
          onChanged: (value) =>
              edit(options.copyWith(showCompanyRegistration: value)),
        ),
        SettingsToggleRow(
          label: 'Show customer reference',
          value: options.showCustomerReference,
          onChanged: (value) =>
              edit(options.copyWith(showCustomerReference: value)),
        ),
        SettingsToggleRow(
          label: 'Show notes',
          value: options.showNotes,
          onChanged: (value) => edit(options.copyWith(showNotes: value)),
        ),
        SettingsToggleRow(
          label: 'Show terms and conditions',
          value: options.showTermsAndConditions,
          onChanged: (value) =>
              edit(options.copyWith(showTermsAndConditions: value)),
        ),
        SettingsToggleRow(
          label: 'Show footer note',
          value: options.showFooterNote,
          onChanged: (value) => edit(options.copyWith(showFooterNote: value)),
        ),
        SettingsToggleRow(
          label: 'Show signature',
          value: options.showSignature,
          onChanged: (value) => edit(options.copyWith(showSignature: value)),
        ),
        SettingsToggleRow(
          label: 'Show page numbers',
          value: options.showPageNumbers,
          onChanged: (value) => edit(options.copyWith(showPageNumbers: value)),
        ),
        SettingsToggleRow(
          label: 'Show discount column',
          value: options.showDiscountColumn,
          onChanged: (value) =>
              edit(options.copyWith(showDiscountColumn: value)),
        ),
        SettingsToggleRow(
          label: 'Show unit column',
          value: options.showUnitColumn,
          onChanged: (value) => edit(options.copyWith(showUnitColumn: value)),
        ),
        SettingsTextField(
          key: ValueKey('terms-$selectedType'),
          label: 'Default terms and conditions',
          value: settings.defaultTermsByType[selectedType] ?? '',
          maxLines: 6,
          onChanged: (value) =>
              controller.updateDefaultTerms(selectedType, value),
        ),
        SettingsTextField(
          label: 'Footer note (all document types)',
          value: settings.defaultFooterNote,
          maxLines: 2,
          onChanged: controller.updateFooterNote,
        ),
      ],
    );
  }
}
