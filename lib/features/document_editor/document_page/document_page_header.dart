import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/document_type_colors.dart';
import '../../../domain/models/business_document.dart';
import '../../../domain/models/document_type.dart';
import '../../../shared/formatting/date_formatter.dart';
import '../../../data/repository_providers.dart';
import '../document_editor_controller.dart';
import 'document_page_styles.dart';
import 'watched_document.dart';
import 'inline_text_field.dart';
import 'page_image.dart';

/// Logo and company on the left; type title, number and dates on the right.
class DocumentPageHeader extends ConsumerWidget {
  const DocumentPageHeader({required this.documentId, super.key});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = watchEditedDocument(ref, documentId);
    final isLocked = document.isLocked;
    final controller = ref.read(
      documentEditorControllerProvider(documentId).notifier,
    );
    final company = document.companyDetails;
    final layout = document.layoutOptions;
    final logoAssetId = company.logoAssetId;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (layout.showLogo && logoAssetId != null) ...[
                PageImage(assetId: logoAssetId, maxHeight: 56),
                const SizedBox(height: 8),
              ],
              InlineTextField(
                key: const ValueKey('companyName'),
                value: company.companyName,
                placeholder: 'Company name',
                readOnly: isLocked,
                style: DocumentPageStyles.companyName,
                onCommitted: (value) => controller.updateCompanyDetails(
                  company.copyWith(companyName: value),
                ),
              ),
              InlineTextField(
                key: const ValueKey('companyAddress'),
                value: company.addressLines.join('\n'),
                placeholder: 'Address',
                readOnly: isLocked,
                maxLines: null,
                onCommitted: (value) => controller.updateCompanyDetails(
                  company.copyWith(addressLines: splitAddressLines(value)),
                ),
              ),
              if (layout.showCompanyRegistration)
                InlineTextField(
                  key: const ValueKey('companyRegistration'),
                  value: company.registrationNumber,
                  placeholder: 'Registration number',
                  readOnly: isLocked,
                  style: DocumentPageStyles.caption,
                  onCommitted: (value) => controller.updateCompanyDetails(
                    company.copyWith(registrationNumber: value),
                  ),
                ),
              InlineTextField(
                key: const ValueKey('companyPhone'),
                value: company.phone,
                placeholder: 'Phone',
                readOnly: isLocked,
                style: DocumentPageStyles.caption,
                onCommitted: (value) => controller.updateCompanyDetails(
                  company.copyWith(phone: value),
                ),
              ),
              InlineTextField(
                key: const ValueKey('companyEmail'),
                value: company.email,
                placeholder: 'Email',
                readOnly: isLocked,
                style: DocumentPageStyles.caption,
                onCommitted: (value) => controller.updateCompanyDetails(
                  company.copyWith(email: value),
                ),
              ),
              InlineTextField(
                key: const ValueKey('companyWebsite'),
                value: company.website,
                placeholder: 'Website',
                readOnly: isLocked,
                style: DocumentPageStyles.caption,
                onCommitted: (value) => controller.updateCompanyDetails(
                  company.copyWith(website: value),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 9,
          child: _TitleAndDates(
            document: document,
            isLocked: isLocked,
            controller: controller,
          ),
        ),
      ],
    );
  }
}

List<String> splitAddressLines(String text) => text
    .split('\n')
    .map((line) => line.trim())
    .where((line) => line.isNotEmpty)
    .toList();

class _TitleAndDates extends StatelessWidget {
  const _TitleAndDates({
    required this.document,
    required this.isLocked,
    required this.controller,
  });

  final BusinessDocument document;
  final bool isLocked;
  final DocumentEditorController controller;

  @override
  Widget build(BuildContext context) {
    final typeInk = Theme.of(context)
        .extension<DocumentTypeColors>()!
        .inkFor(document.documentType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          document.documentType.displayName,
          style: DocumentPageStyles.pageTitle.copyWith(color: typeInk),
        ),
        const SizedBox(height: 4),
        Text(document.documentNumber, style: DocumentPageStyles.documentNumber),
        const SizedBox(height: 14),
        _LabelledRow(
          label: 'Date',
          child: _DateField(
            key: const ValueKey('issueDate'),
            date: document.issueDate,
            isLocked: isLocked,
            onChanged: controller.updateIssueDate,
          ),
        ),
        if (document.documentType == DocumentType.quotation)
          _LabelledRow(
            label: 'Valid until',
            child: _DateField(
              key: const ValueKey('validUntilDate'),
              date: document.validUntilDate,
              isLocked: isLocked,
              onChanged: controller.updateValidUntilDate,
            ),
          ),
        if (document.documentType == DocumentType.deliveryOrder)
          _LabelledRow(
            label: 'Delivery date',
            child: _DateField(
              key: const ValueKey('deliveryDate'),
              date: document.deliveryDate,
              isLocked: isLocked,
              onChanged: controller.updateDeliveryDate,
            ),
          ),
        if (document.layoutOptions.showCustomerReference)
          _LabelledRow(
            label: 'Your reference',
            child: InlineTextField(
              key: const ValueKey('customerReference'),
              value: document.customerReference ?? '',
              placeholder: 'Reference',
              readOnly: isLocked,
              textAlign: TextAlign.end,
              onCommitted: (value) => controller.updateCustomerReference(
                value.isEmpty ? null : value,
              ),
            ),
          ),
      ],
    );
  }
}

class _LabelledRow extends StatelessWidget {
  const _LabelledRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          const SizedBox(width: 100),
          Expanded(
            flex: 5,
            child: Text(label, style: DocumentPageStyles.caption),
          ),
          Expanded(flex: 6, child: child),
        ],
      ),
    );
  }
}

class _DateField extends ConsumerWidget {
  const _DateField({
    required this.date,
    required this.isLocked,
    required this.onChanged,
    super.key,
  });

  final DateTime? date;
  final bool isLocked;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context, DateTime now) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          date == null ? 'Set date' : formatDocumentDate(date!),
          style: date == null
              ? DocumentPageStyles.caption
              : DocumentPageStyles.body,
        ),
      ),
    );
    if (isLocked) return label;
    return InkWell(
      onTap: () => _pick(context, ref.read(clockProvider)()),
      borderRadius: BorderRadius.circular(2),
      child: label,
    );
  }
}
