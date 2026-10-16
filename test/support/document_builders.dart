import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/company_details.dart';
import 'package:pacim_invoicer/domain/models/currency_format.dart';
import 'package:pacim_invoicer/domain/models/customer_details.dart';
import 'package:pacim_invoicer/domain/models/document_layout_options.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/models/line_item.dart';
import 'package:pacim_invoicer/domain/models/pricing_terms.dart';
import 'package:pacim_invoicer/domain/models/signature_block.dart';

/// Builds a fully populated document for tests, with every optional field set.
BusinessDocument buildTestDocument({
  DocumentType type = DocumentType.quotation,
  List<LineItem>? lineItems,
  String chainId = 'chain-1',
  String documentId = 'doc-1',
  String? sourceDocumentId,
  DateTime? lockedAt,
}) {
  return BusinessDocument(
    documentId: documentId,
    documentType: type,
    documentNumber: 'QT-2026-0001',
    chainId: chainId,
    sourceDocumentId: sourceDocumentId,
    lockedAt: lockedAt,
    schemaVersion: BusinessDocument.currentSchemaVersion,
    issueDate: DateTime.utc(2026, 10, 17),
    validUntilDate: DateTime.utc(2026, 11, 16),
    deliveryDate: DateTime.utc(2026, 11, 20),
    customerReference: 'PO-778',
    companyDetails: const CompanyDetails(
      companyName: 'Pacim Sdn Bhd',
      registrationNumber: '202001000001',
      addressLines: ['1 Jalan Satu', '50000 Kuala Lumpur'],
      phone: '+60 3 1234 5678',
      email: 'hello@pacim.example',
      website: 'pacim.example',
      logoAssetId: 'logo-1',
    ),
    customerDetails: const CustomerDetails(
      customerName: 'Acme Trading',
      attentionTo: 'Ms Lim',
      addressLines: ['9 Jalan Dua', '40000 Shah Alam'],
      phone: '+60 3 8765 4321',
      email: 'ap@acme.example',
      deliveryAddressLines: ['Warehouse 3', '40000 Shah Alam'],
    ),
    layoutOptions: const DocumentLayoutOptions(),
    pricingTerms: const PricingTerms(
      currencyFormat: CurrencyFormat.defaultFormat,
      taxLabel: 'SST',
      taxRatePercentScaled: 800,
      isTaxEnabled: true,
    ),
    lineItems: lineItems ?? [buildTestLine(), buildTestLine(id: 'line-2')],
    notes: 'Thank you.',
    termsAndConditions: 'Payment within 30 days.',
    footerNote: 'Computer generated.',
    signatureBlock: const SignatureBlock(
      signatoryName: 'A. Tan',
      signatoryTitle: 'Director',
      signatureAssetId: 'sig-1',
      signatureCaption: 'Authorised signature',
    ),
    createdAt: DateTime.utc(2026, 10, 17, 8),
    updatedAt: DateTime.utc(2026, 10, 17, 9),
  );
}

/// Builds a line item with sensible defaults for tests.
LineItem buildTestLine({
  String id = 'line-1',
  int quantityScaled = 1000,
  int unitPriceMinor = 1000,
  int discountPercentScaled = 0,
}) {
  return LineItem(
    lineItemId: id,
    sourceLineItemId: 'source-$id',
    description: 'Item $id',
    unit: 'pcs',
    quantityScaled: quantityScaled,
    unitPriceMinor: unitPriceMinor,
    discountPercentScaled: discountPercentScaled,
  );
}
