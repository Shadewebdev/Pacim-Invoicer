import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/document_type.dart';
import '../document_editor_controller.dart';
import 'document_page_header.dart' show splitAddressLines;
import 'document_page_styles.dart';
import 'inline_text_field.dart';

/// The customer block: who the document is for, and where a delivery goes.
class DocumentPageCustomer extends ConsumerWidget {
  const DocumentPageCustomer({required this.documentId, super.key});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref
        .watch(documentEditorControllerProvider(documentId))
        .requireValue;
    final document = editorState.document;
    final isLocked = editorState.isLocked;
    final controller = ref.read(
      documentEditorControllerProvider(documentId).notifier,
    );
    final customer = document.customerDetails;
    final isDeliveryOrder = document.documentType == DocumentType.deliveryOrder;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isDeliveryOrder ? 'Customer' : 'Bill to',
                style: DocumentPageStyles.caption,
              ),
              InlineTextField(
                key: const ValueKey('customerName'),
                value: customer.customerName,
                placeholder: 'Customer name',
                readOnly: isLocked,
                style: DocumentPageStyles.emphasis,
                onCommitted: (value) => controller.updateCustomerDetails(
                  customer.copyWith(customerName: value),
                ),
              ),
              InlineTextField(
                key: const ValueKey('customerAttention'),
                value: customer.attentionTo,
                placeholder: 'Attention',
                readOnly: isLocked,
                onCommitted: (value) => controller.updateCustomerDetails(
                  customer.copyWith(attentionTo: value),
                ),
              ),
              InlineTextField(
                key: const ValueKey('customerAddress'),
                value: customer.addressLines.join('\n'),
                placeholder: 'Address',
                readOnly: isLocked,
                maxLines: null,
                onCommitted: (value) => controller.updateCustomerDetails(
                  customer.copyWith(addressLines: splitAddressLines(value)),
                ),
              ),
              InlineTextField(
                key: const ValueKey('customerPhone'),
                value: customer.phone,
                placeholder: 'Phone',
                readOnly: isLocked,
                style: DocumentPageStyles.caption,
                onCommitted: (value) => controller.updateCustomerDetails(
                  customer.copyWith(phone: value),
                ),
              ),
              InlineTextField(
                key: const ValueKey('customerEmail'),
                value: customer.email,
                placeholder: 'Email',
                readOnly: isLocked,
                style: DocumentPageStyles.caption,
                onCommitted: (value) => controller.updateCustomerDetails(
                  customer.copyWith(email: value),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: isDeliveryOrder
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deliver to', style: DocumentPageStyles.caption),
                    InlineTextField(
                      key: const ValueKey('deliveryAddress'),
                      value: customer.deliveryAddressLines.join('\n'),
                      placeholder: 'Delivery address',
                      readOnly: isLocked,
                      maxLines: null,
                      onCommitted: (value) => controller.updateCustomerDetails(
                        customer.copyWith(
                          deliveryAddressLines: splitAddressLines(value),
                        ),
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
