import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/domain/exceptions/document_exceptions.dart';
import 'package:pacim_invoicer/domain/models/document_settings.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/services/document_upgrade_service.dart';

import '../../support/document_builders.dart';
import '../../support/sequential_id_generator.dart';

void main() {
  final now = DateTime.utc(2026, 10, 20, 9);
  final settings = DocumentSettings.initial();

  DocumentUpgradeService buildService() =>
      DocumentUpgradeService(idGenerator: SequentialIdGenerator());

  test('quotation to sales order copies lines with sourceLineItemId and locks source', () {
    final quotation = buildTestDocument();
    final result = buildService().createNextStage(
      source: quotation,
      chainDocuments: [quotation],
      documentNumber: 'SO-2026-0001',
      settings: settings,
      now: now,
    );

    final created = result.createdDocument;
    expect(created.documentType, DocumentType.salesOrder);
    expect(created.documentNumber, 'SO-2026-0001');
    expect(created.chainId, quotation.chainId);
    expect(created.sourceDocumentId, quotation.documentId);
    expect(created.documentId, isNot(quotation.documentId));
    expect(created.lockedAt, isNull);
    expect(created.issueDate, now);
    expect(created.validUntilDate, isNull);
    expect(created.deliveryDate, isNull);
    expect(created.createdAt, now);
    expect(created.updatedAt, now);
    expect(created.companyDetails, quotation.companyDetails);
    expect(created.customerDetails, quotation.customerDetails);
    expect(created.pricingTerms, quotation.pricingTerms);
    expect(created.termsAndConditions, quotation.termsAndConditions);
    expect(created.notes, quotation.notes);
    expect(created.footerNote, quotation.footerNote);
    expect(created.customerReference, quotation.customerReference);
    expect(
      created.signatureBlock,
      settings.signatureBlockByType[DocumentType.salesOrder],
    );
    expect(created.lineItems, hasLength(2));
    for (var index = 0; index < 2; index++) {
      final line = created.lineItems[index];
      final original = quotation.lineItems[index];
      expect(line.lineItemId, isNot(original.lineItemId));
      expect(line.sourceLineItemId, original.lineItemId);
      expect(line.quantityScaled, original.quantityScaled);
      expect(line.description, original.description);
    }
    expect(result.lockedSource.lockedAt, now);
    expect(result.lockedSource.updatedAt, now);
    expect(result.lockedSource.documentId, quotation.documentId);
  });

  test('second sales order in a chain is rejected', () {
    final quotation = buildTestDocument();
    final salesOrder = buildTestDocument(
      type: DocumentType.salesOrder,
      documentId: 'so-1',
    );
    final service = buildService();
    expect(
      service.findUpgradeBlocker(
        source: quotation,
        chainDocuments: [quotation, salesOrder],
      ),
      'This chain already has a sales order',
    );
    expect(
      () => service.createNextStage(
        source: quotation,
        chainDocuments: [quotation, salesOrder],
        documentNumber: 'SO-2026-0002',
        settings: settings,
        now: now,
      ),
      throwsA(isA<InvalidUpgradeException>()),
    );
  });

  group('delivery orders', () {
    final salesOrder = buildTestDocument(
      type: DocumentType.salesOrder,
      documentId: 'so-1',
      lineItems: [
        buildTestLine(id: 'A', quantityScaled: 10000),
        buildTestLine(id: 'B', quantityScaled: 5000),
      ],
    );
    final existingDelivery = buildTestDocument(
      type: DocumentType.deliveryOrder,
      documentId: 'do-1',
      sourceDocumentId: 'so-1',
      lineItems: [
        buildTestLine(
          id: 'dA',
          quantityScaled: 4000,
        ).copyWith(sourceLineItemId: 'A'),
        buildTestLine(
          id: 'dB',
          quantityScaled: 5000,
        ).copyWith(sourceLineItemId: 'B'),
      ],
    );

    test('delivery order defaults to remaining quantities and omits fully delivered lines', () {
      final result = buildService().createNextStage(
        source: salesOrder,
        chainDocuments: [salesOrder, existingDelivery],
        documentNumber: 'DO-2026-0002',
        settings: settings,
        now: now,
      );
      final created = result.createdDocument;
      expect(created.documentType, DocumentType.deliveryOrder);
      expect(created.lineItems, hasLength(1));
      expect(created.lineItems.single.sourceLineItemId, 'A');
      expect(created.lineItems.single.quantityScaled, 6000);
      expect(created.deliveryDate, now);
      expect(created.signatureBlock.signatureCaption, 'Received by');
    });

    test('already locked sales order keeps original lockedAt', () {
      final originalLockedAt = DateTime.utc(2026, 10, 18);
      final locked = salesOrder.copyWith(lockedAt: originalLockedAt);
      final result = buildService().createNextStage(
        source: locked,
        chainDocuments: [locked, existingDelivery],
        documentNumber: 'DO-2026-0002',
        settings: settings,
        now: now,
      );
      expect(result.lockedSource.lockedAt, originalLockedAt);
      expect(result.lockedSource.updatedAt, locked.updatedAt);
    });

    test('fully delivered sales order is blocked', () {
      final secondDelivery = existingDelivery.copyWith(
        documentId: 'do-2',
        lineItems: [
          buildTestLine(
            id: 'x',
            quantityScaled: 6000,
          ).copyWith(sourceLineItemId: 'A'),
        ],
      );
      expect(
        buildService().findUpgradeBlocker(
          source: salesOrder,
          chainDocuments: [salesOrder, existingDelivery, secondDelivery],
        ),
        'Every item on this sales order has been delivered',
      );
    });

    test('delivery order upgrade is blocked', () {
      expect(
        buildService().findUpgradeBlocker(
          source: existingDelivery,
          chainDocuments: [salesOrder, existingDelivery],
        ),
        'Delivery orders are the last stage',
      );
      expect(
        () => buildService().createNextStage(
          source: existingDelivery,
          chainDocuments: [salesOrder, existingDelivery],
          documentNumber: 'DO-2026-0003',
          settings: settings,
          now: now,
        ),
        throwsA(isA<InvalidUpgradeException>()),
      );
    });

    test('allowed upgrade has no blocker', () {
      expect(
        buildService().findUpgradeBlocker(
          source: salesOrder,
          chainDocuments: [salesOrder, existingDelivery],
        ),
        isNull,
      );
    });
  });
}
