import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/data/repositories/document_repository.dart';
import 'package:pacim_invoicer/domain/exceptions/document_exceptions.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/document_list_query.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/services/document_totals_calculator.dart';

import '../../support/document_builders.dart';

/// Behaviour every [DocumentRepository] implementation must satisfy.
void runDocumentRepositoryContract(
  Future<DocumentRepository> Function() createRepository,
) {
  group('DocumentRepository contract', () {
    late DocumentRepository repository;

    setUp(() async {
      repository = await createRepository();
    });

    BusinessDocument documentWith({
      required String id,
      String number = 'QT-2026-0001',
      String customer = 'Acme Trading',
      DateTime? issueDate,
      DocumentType type = DocumentType.quotation,
      String chainId = 'chain-1',
      int unitPriceMinor = 1000,
      DateTime? updatedAt,
    }) {
      final base = buildTestDocument(
        documentId: id,
        type: type,
        chainId: chainId,
        lineItems: [buildTestLine(unitPriceMinor: unitPriceMinor)],
      );
      return base.copyWith(
        documentNumber: number,
        customerDetails: base.customerDetails.copyWith(customerName: customer),
        issueDate: issueDate ?? DateTime.utc(2026, 10, 17),
        updatedAt: updatedAt ?? DateTime.utc(2026, 10, 17, 9),
      );
    }

    Future<List<String>> listedIds(DocumentListQuery query) async {
      final summaries = await repository.watchDocumentSummaries(query).first;
      return summaries.map((summary) => summary.documentId).toList();
    }

    test('saveDocument then getDocument returns an equal document', () async {
      final document = buildTestDocument();
      await repository.saveDocument(document);
      expect(await repository.getDocument(document.documentId), document);
    });

    test('getDocument for unknown id throws DocumentNotFoundException', () {
      expect(
        repository.getDocument('missing'),
        throwsA(isA<DocumentNotFoundException>()),
      );
    });

    test(
      'saving over a locked stored document throws DocumentLockedException',
      () async {
        final locked = buildTestDocument(lockedAt: DateTime.utc(2026, 10, 18));
        await repository.saveDocument(locked);
        await expectLater(
          repository.saveDocument(locked.copyWith(notes: 'changed')),
          throwsA(isA<DocumentLockedException>()),
        );
        final stored = await repository.getDocument(locked.documentId);
        expect(stored.notes, locked.notes);
      },
    );

    test('watchDocumentSummaries filters by type and searchText on number or '
        'customer, case-insensitive', () async {
      await repository.saveDocument(
        documentWith(id: 'a', number: 'QT-2026-0001', customer: 'Acme'),
      );
      await repository.saveDocument(
        documentWith(id: 'b', number: 'QT-2026-0002', customer: 'Beta Corp'),
      );
      await repository.saveDocument(
        documentWith(id: 'c', number: 'QT-2026-0003', customer: '50% Off_Co'),
      );
      await repository.saveDocument(
        documentWith(
          id: 'd',
          number: 'SO-2026-0001',
          customer: 'Acme',
          type: DocumentType.salesOrder,
        ),
      );
      const quotations = DocumentListQuery(
        documentType: DocumentType.quotation,
        sortField: DocumentSortField.documentNumber,
        sortDescending: false,
      );

      expect(await listedIds(quotations), ['a', 'b', 'c']);
      expect(await listedIds(quotations.copyWith(searchText: 'acme')), ['a']);
      expect(await listedIds(quotations.copyWith(searchText: 'qt-2026-0002')), [
        'b',
      ]);
      expect(await listedIds(quotations.copyWith(searchText: 'BETA')), ['b']);
      expect(await listedIds(quotations.copyWith(searchText: '%')), ['c']);
      expect(await listedIds(quotations.copyWith(searchText: 'off_co')), ['c']);
      expect(
        await listedIds(quotations.copyWith(searchText: 'off-co')),
        isEmpty,
      );
    });

    test('watchDocumentSummaries sorts by each DocumentSortField both '
        'directions', () async {
      // Every field orders the documents a, b, c when ascending.
      await repository.saveDocument(
        documentWith(
          id: 'b',
          number: 'QT-2026-0002',
          customer: 'Beta',
          issueDate: DateTime.utc(2026, 10, 2),
          unitPriceMinor: 2000,
          updatedAt: DateTime.utc(2026, 10, 2),
        ),
      );
      await repository.saveDocument(
        documentWith(
          id: 'c',
          number: 'QT-2026-0003',
          customer: 'Gamma',
          issueDate: DateTime.utc(2026, 10, 3),
          unitPriceMinor: 3000,
          updatedAt: DateTime.utc(2026, 10, 3),
        ),
      );
      await repository.saveDocument(
        documentWith(
          id: 'a',
          number: 'QT-2026-0001',
          customer: 'Alpha',
          issueDate: DateTime.utc(2026, 10, 1),
          unitPriceMinor: 1000,
          updatedAt: DateTime.utc(2026, 10, 1),
        ),
      );

      for (final field in DocumentSortField.values) {
        final ascending = DocumentListQuery(
          documentType: DocumentType.quotation,
          sortField: field,
          sortDescending: false,
        );
        expect(await listedIds(ascending), [
          'a',
          'b',
          'c',
        ], reason: '$field ascending');
        expect(await listedIds(ascending.copyWith(sortDescending: true)), [
          'c',
          'b',
          'a',
        ], reason: '$field descending');
      }
    });

    test(
      'watchDocumentSummaries applies issued date range inclusively',
      () async {
        for (final day in [1, 2, 3, 4]) {
          await repository.saveDocument(
            documentWith(
              id: 'd$day',
              number: 'QT-2026-000$day',
              issueDate: DateTime.utc(2026, 10, day, day == 3 ? 15 : 0),
            ),
          );
        }
        final query = DocumentListQuery(
          documentType: DocumentType.quotation,
          sortField: DocumentSortField.documentNumber,
          sortDescending: false,
          issuedFrom: DateTime.utc(2026, 10, 2),
          issuedTo: DateTime.utc(2026, 10, 3),
        );
        expect(await listedIds(query), ['d2', 'd3']);
      },
    );

    test('watchDocumentSummaries respects limit', () async {
      for (final day in [1, 2, 3]) {
        await repository.saveDocument(
          documentWith(id: 'd$day', number: 'QT-2026-000$day'),
        );
      }
      final ids = await listedIds(
        const DocumentListQuery(documentType: DocumentType.quotation, limit: 2),
      );
      expect(ids, hasLength(2));
    });

    test('summary grandTotalMinor matches DocumentTotalsCalculator', () async {
      final document = documentWith(id: 'a', unitPriceMinor: 1234);
      await repository.saveDocument(document);
      final summaries = await repository
          .watchDocumentSummaries(
            const DocumentListQuery(documentType: DocumentType.quotation),
          )
          .first;
      final summary = summaries.single;
      expect(
        summary.grandTotalMinor,
        const DocumentTotalsCalculator().calculate(document).grandTotalMinor,
      );
      expect(summary.customerName, 'Acme Trading');
      expect(
        summary.currencyCode,
        document.pricingTerms.currencyFormat.currencyCode,
      );
      expect(summary.isLocked, isFalse);
    });

    test(
      'watchDocumentChain groups QT, SO and DOs ordered by number',
      () async {
        await repository.saveDocument(documentWith(id: 'qt'));
        await repository.saveDocument(
          documentWith(
            id: 'so',
            number: 'SO-2026-0001',
            type: DocumentType.salesOrder,
          ),
        );
        await repository.saveDocument(
          documentWith(
            id: 'do2',
            number: 'DO-2026-0002',
            type: DocumentType.deliveryOrder,
          ),
        );
        await repository.saveDocument(
          documentWith(
            id: 'do1',
            number: 'DO-2026-0001',
            type: DocumentType.deliveryOrder,
          ),
        );
        await repository.saveDocument(
          documentWith(id: 'other', chainId: 'chain-2'),
        );

        final chain = await repository.watchDocumentChain('chain-1').first;
        expect(chain.chainId, 'chain-1');
        expect(chain.quotation?.documentId, 'qt');
        expect(chain.salesOrder?.documentId, 'so');
        expect(chain.deliveryOrders.map((s) => s.documentId), ['do1', 'do2']);

        final empty = await repository.watchDocumentChain('nothing').first;
        expect(empty.quotation, isNull);
        expect(empty.salesOrder, isNull);
        expect(empty.deliveryOrders, isEmpty);

        expect(await repository.getDocumentsInChain('chain-1'), hasLength(4));
      },
    );

    test('watchDocumentSummaries emits again after a save', () async {
      const query = DocumentListQuery(documentType: DocumentType.quotation);
      final emissions = <int>[];
      final subscription = repository
          .watchDocumentSummaries(query)
          .listen((summaries) => emissions.add(summaries.length));
      await pumpEventQueue();
      await repository.saveDocument(documentWith(id: 'a'));
      await pumpEventQueue();
      await subscription.cancel();
      expect(emissions, [0, 1]);
    });

    group('saveUpgrade', () {
      // Filled in by Task 11.
    }, skip: 'Implemented in Task 11');

    group('deleteDocument', () {
      // Filled in by Task 11.
    }, skip: 'Implemented in Task 11');
  });
}
