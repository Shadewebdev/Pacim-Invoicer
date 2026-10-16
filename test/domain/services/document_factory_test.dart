import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/domain/models/company_details.dart';
import 'package:pacim_invoicer/domain/models/currency_format.dart';
import 'package:pacim_invoicer/domain/models/document_layout_options.dart';
import 'package:pacim_invoicer/domain/models/document_settings.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/models/pricing_terms.dart';
import 'package:pacim_invoicer/domain/services/document_factory.dart';

import '../../support/document_builders.dart';
import '../../support/sequential_id_generator.dart';

void main() {
  final now = DateTime.utc(2026, 10, 17, 10);
  final settings = DocumentSettings.initial().copyWith(
    companyDetails: const CompanyDetails(companyName: 'Settings Co'),
    defaultFooterNote: 'Settings footer',
    defaultTermsByType: {
      for (final type in DocumentType.values) type: 'Terms for ${type.name}',
    },
    pricingTerms: const PricingTerms(
      currencyFormat: CurrencyFormat.defaultFormat,
      taxLabel: 'GST',
      taxRatePercentScaled: 600,
      isTaxEnabled: true,
    ),
  );

  DocumentFactory buildFactory() =>
      DocumentFactory(idGenerator: SequentialIdGenerator());

  test('createStandalone copies settings snapshot and allocates new chain', () {
    final document = buildFactory().createStandalone(
      documentType: DocumentType.salesOrder,
      documentNumber: 'SO-2026-0001',
      settings: settings,
      now: now,
    );

    expect(document.documentId, 'id-1');
    expect(document.chainId, 'id-2');
    expect(document.documentNumber, 'SO-2026-0001');
    expect(document.documentType, DocumentType.salesOrder);
    expect(document.sourceDocumentId, isNull);
    expect(document.lockedAt, isNull);
    expect(document.schemaVersion, 1);
    expect(document.companyDetails.companyName, 'Settings Co');
    expect(document.pricingTerms.taxLabel, 'GST');
    expect(document.termsAndConditions, 'Terms for salesOrder');
    expect(document.footerNote, 'Settings footer');
    expect(
      document.signatureBlock,
      settings.signatureBlockByType[DocumentType.salesOrder],
    );
    expect(
      document.layoutOptions,
      settings.layoutOptionsByType[DocumentType.salesOrder],
    );
    expect(document.lineItems, hasLength(1));
    expect(document.lineItems.single.lineItemId, 'id-3');
    expect(document.lineItems.single.sourceLineItemId, isNull);
    expect(document.validUntilDate, isNull);
    expect(document.deliveryDate, isNull);
    expect(document.issueDate, now);
    expect(document.createdAt, now);
    expect(document.updatedAt, now);
  });

  test('quotation validity is 30 days by default', () {
    final document = buildFactory().createStandalone(
      documentType: DocumentType.quotation,
      documentNumber: 'QT-2026-0001',
      settings: settings,
      now: now,
    );
    expect(document.validUntilDate, DateTime.utc(2026, 11, 16, 10));
  });

  test('delivery order starts with delivery date today', () {
    final document = buildFactory().createStandalone(
      documentType: DocumentType.deliveryOrder,
      documentNumber: 'DO-2026-0001',
      settings: settings,
      now: now,
    );
    expect(document.deliveryDate, now);
    expect(document.validUntilDate, isNull);
  });

  test('duplicateAsDraft unlinks from chain and source', () {
    final source = buildTestDocument(
      type: DocumentType.salesOrder,
      sourceDocumentId: 'quote-1',
      lockedAt: DateTime.utc(2026, 10, 18),
    );
    final copy = buildFactory().duplicateAsDraft(
      source: source,
      documentNumber: 'SO-2026-0009',
      now: now,
    );

    expect(copy.documentId, isNot(source.documentId));
    expect(copy.chainId, isNot(source.chainId));
    expect(copy.documentType, DocumentType.salesOrder);
    expect(copy.documentNumber, 'SO-2026-0009');
    expect(copy.sourceDocumentId, isNull);
    expect(copy.lockedAt, isNull);
    expect(copy.createdAt, now);
    expect(copy.updatedAt, now);
    expect(copy.customerDetails, source.customerDetails);
    expect(copy.lineItems, hasLength(source.lineItems.length));
    for (var index = 0; index < copy.lineItems.length; index++) {
      final line = copy.lineItems[index];
      final original = source.lineItems[index];
      expect(line.lineItemId, isNot(original.lineItemId));
      expect(line.sourceLineItemId, isNull);
      expect(line.description, original.description);
      expect(line.quantityScaled, original.quantityScaled);
    }
  });

  test('duplicating an old quotation keeps its validity span from today', () {
    final source = buildTestDocument().copyWith(
      issueDate: DateTime.utc(2026, 1, 1),
      validUntilDate: DateTime.utc(2026, 1, 15),
    );
    final copy = buildFactory().duplicateAsDraft(
      source: source,
      documentNumber: 'QT-2026-0009',
      now: DateTime.utc(2026, 10, 17),
    );
    expect(copy.validUntilDate, DateTime.utc(2026, 10, 31));
  });

  test('duplicating a delivery order sets delivery date to now', () {
    final source = buildTestDocument(type: DocumentType.deliveryOrder);
    final copy = buildFactory().duplicateAsDraft(
      source: source,
      documentNumber: 'DO-2026-0009',
      now: now,
    );
    expect(copy.deliveryDate, now);
  });

  test('resetSectionToDefaults(pricing) replaces only pricingTerms', () {
    final document = buildTestDocument();
    final reset = buildFactory().resetSectionToDefaults(
      document,
      DocumentSection.pricing,
      settings,
    );
    expect(reset.pricingTerms, settings.pricingTerms);
    expect(reset.copyWith(pricingTerms: document.pricingTerms), document);
  });

  test('resetSectionToDefaults replaces only the named section', () {
    final factory = buildFactory();
    final document = buildTestDocument(type: DocumentType.deliveryOrder);

    final company = factory.resetSectionToDefaults(
      document,
      DocumentSection.company,
      settings,
    );
    expect(company.companyDetails, settings.companyDetails);
    expect(company.copyWith(companyDetails: document.companyDetails), document);

    final headerAndFooter = factory.resetSectionToDefaults(
      document,
      DocumentSection.headerAndFooter,
      settings,
    );
    expect(
      headerAndFooter.layoutOptions,
      settings.layoutOptionsByType[DocumentType.deliveryOrder],
    );
    expect(headerAndFooter.footerNote, 'Settings footer');
    expect(
      headerAndFooter.copyWith(
        layoutOptions: const DocumentLayoutOptions(),
        footerNote: document.footerNote,
      ),
      document,
    );

    final signature = factory.resetSectionToDefaults(
      document,
      DocumentSection.signature,
      settings,
    );
    expect(signature.signatureBlock.signatureCaption, 'Received by');
    expect(
      signature.copyWith(signatureBlock: document.signatureBlock),
      document,
    );

    final terms = factory.resetSectionToDefaults(
      document,
      DocumentSection.terms,
      settings,
    );
    expect(terms.termsAndConditions, 'Terms for deliveryOrder');
    expect(
      terms.copyWith(termsAndConditions: document.termsAndConditions),
      document,
    );
  });
}
