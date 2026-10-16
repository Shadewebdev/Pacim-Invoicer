import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/business_document.dart';
import '../../../domain/models/company_details.dart';
import '../../../domain/models/document_layout_options.dart';
import '../../settings/image_picker_field.dart';
import '../../settings/settings_fields.dart';
import '../document_editor_controller.dart';
import 'document_image_import.dart';
import 'properties_pane_section.dart';

/// Company details, the page's block toggles, terms and the footer note.
class HeaderFooterPropertiesSection extends ConsumerWidget {
  const HeaderFooterPropertiesSection({
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
    final company = document.companyDetails;
    final options = document.layoutOptions;
    final isEnabled = !isLocked;
    String keyed(String name) => 'pane-$name-$resetGeneration';
    void editCompany(CompanyDetails changed) =>
        controller.updateCompanyDetails(changed);
    void editOptions(DocumentLayoutOptions changed) =>
        controller.updateLayoutOptions(changed);

    return PropertiesPaneSection(
      title: 'Header & footer',
      resetSectionName: 'headerAndFooter',
      onReset: isLocked ? null : onReset,
      children: [
        SettingsTextField(
          key: ValueKey(keyed('companyName')),
          label: 'Company name',
          value: company.companyName,
          isEnabled: isEnabled,
          onChanged: (value) =>
              editCompany(company.copyWith(companyName: value)),
        ),
        SettingsTextField(
          key: ValueKey(keyed('registrationNumber')),
          label: 'Registration number',
          value: company.registrationNumber,
          isEnabled: isEnabled,
          onChanged: (value) =>
              editCompany(company.copyWith(registrationNumber: value)),
        ),
        SettingsTextField(
          key: ValueKey(keyed('companyAddress')),
          label: 'Address',
          value: company.addressLines.join('\n'),
          maxLines: 4,
          isEnabled: isEnabled,
          onChanged: (value) => editCompany(
            company.copyWith(
              addressLines: value
                  .split('\n')
                  .map((line) => line.trim())
                  .where((line) => line.isNotEmpty)
                  .toList(),
            ),
          ),
        ),
        SettingsTextField(
          key: ValueKey(keyed('companyPhone')),
          label: 'Phone',
          value: company.phone,
          isEnabled: isEnabled,
          onChanged: (value) => editCompany(company.copyWith(phone: value)),
        ),
        SettingsTextField(
          key: ValueKey(keyed('companyEmail')),
          label: 'Email',
          value: company.email,
          isEnabled: isEnabled,
          onChanged: (value) => editCompany(company.copyWith(email: value)),
        ),
        SettingsTextField(
          key: ValueKey(keyed('companyWebsite')),
          label: 'Website',
          value: company.website,
          isEnabled: isEnabled,
          onChanged: (value) => editCompany(company.copyWith(website: value)),
        ),
        ImagePickerField(
          key: ValueKey(keyed('companyLogo')),
          label: 'Company logo',
          assetId: company.logoAssetId,
          isEnabled: isEnabled,
          onImagePicked: (bytes) async {
            final assetId = await storeDocumentImage(ref, bytes);
            final latest = _latestDocument(ref) ?? document;
            editCompany(latest.companyDetails.copyWith(logoAssetId: assetId));
          },
          onRemove: () {
            final latest = _latestDocument(ref) ?? document;
            editCompany(latest.companyDetails.copyWith(logoAssetId: null));
          },
        ),
        SettingsToggleRow(
          label: 'Show logo',
          value: options.showLogo,
          isEnabled: isEnabled,
          onChanged: (value) => editOptions(options.copyWith(showLogo: value)),
        ),
        SettingsToggleRow(
          label: 'Show company registration number',
          value: options.showCompanyRegistration,
          isEnabled: isEnabled,
          onChanged: (value) =>
              editOptions(options.copyWith(showCompanyRegistration: value)),
        ),
        SettingsToggleRow(
          label: 'Show customer reference',
          value: options.showCustomerReference,
          isEnabled: isEnabled,
          onChanged: (value) =>
              editOptions(options.copyWith(showCustomerReference: value)),
        ),
        SettingsToggleRow(
          label: 'Show notes',
          value: options.showNotes,
          isEnabled: isEnabled,
          onChanged: (value) => editOptions(options.copyWith(showNotes: value)),
        ),
        SettingsToggleRow(
          label: 'Show terms and conditions',
          value: options.showTermsAndConditions,
          isEnabled: isEnabled,
          onChanged: (value) =>
              editOptions(options.copyWith(showTermsAndConditions: value)),
        ),
        SettingsToggleRow(
          label: 'Show footer note',
          value: options.showFooterNote,
          isEnabled: isEnabled,
          onChanged: (value) =>
              editOptions(options.copyWith(showFooterNote: value)),
        ),
        SettingsToggleRow(
          label: 'Show signature',
          value: options.showSignature,
          isEnabled: isEnabled,
          onChanged: (value) =>
              editOptions(options.copyWith(showSignature: value)),
        ),
        SettingsToggleRow(
          label: 'Show page numbers',
          value: options.showPageNumbers,
          isEnabled: isEnabled,
          onChanged: (value) =>
              editOptions(options.copyWith(showPageNumbers: value)),
        ),
        SettingsToggleRow(
          label: 'Show discount column',
          value: options.showDiscountColumn,
          isEnabled: isEnabled,
          onChanged: (value) =>
              editOptions(options.copyWith(showDiscountColumn: value)),
        ),
        SettingsToggleRow(
          label: 'Show unit column',
          value: options.showUnitColumn,
          isEnabled: isEnabled,
          onChanged: (value) =>
              editOptions(options.copyWith(showUnitColumn: value)),
        ),
        SettingsTextField(
          key: ValueKey(keyed('terms')),
          label: 'Terms and conditions',
          value: document.termsAndConditions,
          maxLines: 6,
          isEnabled: isEnabled,
          onChanged: controller.updateTermsAndConditions,
        ),
        SettingsTextField(
          key: ValueKey(keyed('footerNote')),
          label: 'Footer note',
          value: document.footerNote,
          maxLines: 2,
          isEnabled: isEnabled,
          onChanged: controller.updateFooterNote,
        ),
      ],
    );
  }

  BusinessDocument? _latestDocument(WidgetRef ref) => ref
      .read(documentEditorControllerProvider(document.documentId))
      .value
      ?.document;
}
