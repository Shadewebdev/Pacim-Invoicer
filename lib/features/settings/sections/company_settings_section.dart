import 'package:flutter/material.dart';

import '../../../domain/models/company_details.dart';
import '../../../domain/models/document_settings.dart';
import '../image_picker_field.dart';
import '../settings_controller.dart';
import '../settings_fields.dart';

class CompanySettingsSection extends StatelessWidget {
  const CompanySettingsSection({
    required this.settings,
    required this.controller,
    super.key,
  });

  final DocumentSettings settings;
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final company = settings.companyDetails;
    void edit(CompanyDetails Function(CompanyDetails current) change) =>
        controller.updateCompanyDetails(change(company));

    return SettingsSectionLayout(
      title: 'Company',
      children: [
        SettingsTextField(
          label: 'Company name',
          value: company.companyName,
          onChanged: (value) =>
              edit((current) => current.copyWith(companyName: value)),
        ),
        SettingsTextField(
          label: 'Registration number',
          value: company.registrationNumber,
          onChanged: (value) =>
              edit((current) => current.copyWith(registrationNumber: value)),
        ),
        SettingsTextField(
          label: 'Address',
          value: company.addressLines.join('\n'),
          maxLines: 4,
          onChanged: (value) => edit(
            (current) => current.copyWith(
              addressLines: value
                  .split('\n')
                  .map((line) => line.trim())
                  .where((line) => line.isNotEmpty)
                  .toList(),
            ),
          ),
        ),
        SettingsTextField(
          label: 'Phone',
          value: company.phone,
          onChanged: (value) =>
              edit((current) => current.copyWith(phone: value)),
        ),
        SettingsTextField(
          label: 'Email',
          value: company.email,
          onChanged: (value) =>
              edit((current) => current.copyWith(email: value)),
        ),
        SettingsTextField(
          label: 'Website',
          value: company.website,
          onChanged: (value) =>
              edit((current) => current.copyWith(website: value)),
        ),
        ImagePickerField(
          label: 'Company logo',
          assetId: company.logoAssetId,
          onImagePicked: controller.importCompanyLogo,
          onRemove: () =>
              edit((current) => current.copyWith(logoAssetId: null)),
        ),
      ],
    );
  }
}
