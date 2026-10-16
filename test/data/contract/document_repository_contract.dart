import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/data/repositories/document_repository.dart';
import 'package:pacim_invoicer/domain/exceptions/document_exceptions.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/document_list_query.dart';
import 'package:pacim_invoicer/domain/models/document_summary.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/services/document_totals_calculator.dart';

import '../../support/document_builders.dart';

/// Behaviour every [DocumentRepository] implementation must satisfy.
///
/// Every call to [createRepository] must return a fresh, empty repository.
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

    // Search is infix on number or customer. An implementation may filter on
    // the client, since stores such as Firestore have no substring query.
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

    test('watchDocumentCount counts all matches ignoring limit', () async {
      for (final day in [1, 2, 3]) {
        await repository.saveDocument(
          documentWith(id: 'd$day', number: 'QT-2026-000$day'),
        );
      }
      await repository.saveDocument(
        documentWith(
          id: 'so',
          number: 'SO-2026-0001',
          type: DocumentType.salesOrder,
        ),
      );
      const limited = DocumentListQuery(
        documentType: DocumentType.quotation,
        limit: 2,
      );
      expect(await repository.watchDocumentCount(limited).first, 3);
      expect(
        await repository
            .watchDocumentCount(limited.copyWith(searchText: '0002'))
            .first,
        1,
      );
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
      final expectation = expectLater(
        repository.watchDocumentSummaries(query),
        emitsThrough(
          predicate<List<DocumentSummary>>(
            (summaries) => summaries.any((s) => s.documentId == 'a'),
            'contains the saved document',
          ),
        ),
      );
      await pumpEventQueue();
      await repository.saveDocument(documentWith(id: 'a'));
      await expectation;
    });

    test('saving an existing unlocked document overwrites it and refreshes its '
        'summary', () async {
      await repository.saveDocument(documentWith(id: 'a'));
      final changed = documentWith(
        id: 'a',
        customer: 'Renamed Co',
        unitPriceMinor: 5000,
      );
      await repository.saveDocument(changed);

      expect(await repository.getDocument('a'), changed);
      final summaries = await repository
          .watchDocumentSummaries(
            const DocumentListQuery(documentType: DocumentType.quotation),
          )
          .first;
      expect(summaries, hasLength(1));
      expect(summaries.single.customerName, 'Renamed Co');
      expect(
        summaries.single.grandTotalMinor,
        const DocumentTotalsCalculator().calculate(changed).grandTotalMinor,
      );
    });

    test(
      'watchDocument emits the document and re-emits after a save',
      () async {
        final original = documentWith(id: 'a');
        await repository.saveDocument(original);
        final updated = original.copyWith(notes: 'updated notes');
        final expectation = expectLater(
          repository.watchDocument('a'),
          emitsThrough(updated),
        );
        await pumpEventQueue();
        await repository.saveDocument(updated);
        await expectation;
      },
    );

    test('watchDocument for an unknown id emits DocumentNotFoundException', () {
      expect(
        repository.watchDocument('missing'),
        emitsError(isA<DocumentNotFoundException>()),
      );
    });

    test('customer sort is case-insensitive', () async {
      await repository.saveDocument(
        documentWith(id: 'c', number: 'QT-2026-0003', customer: 'charlie'),
      );
      await repository.saveDocument(
        documentWith(id: 'a', number: 'QT-2026-0001', customer: 'alpha'),
      );
      await repository.saveDocument(
        documentWith(id: 'b', number: 'QT-2026-0002', customer: 'Bravo'),
      );
      final ids = await listedIds(
        const DocumentListQuery(
          documentType: DocumentType.quotation,
          sortField: DocumentSortField.customerName,
          sortDescending: false,
        ),
      );
      expect(ids, ['a', 'b', 'c']);
    });

    test('search finds non-ASCII customer names regardless of case', () async {
      await repository.saveDocument(documentWith(id: 'a', customer: 'École'));
      const query = DocumentListQuery(documentType: DocumentType.quotation);
      expect(await listedIds(query.copyWith(searchText: 'École')), ['a']);
      expect(await listedIds(query.copyWith(searchText: 'école')), ['a']);
    });

    final lockTime = DateTime.utc(2026, 10, 18, 10);

    BusinessDocument derivedFrom(
      BusinessDocument source, {
      required String id,
      required DocumentType type,
      required String number,
    }) {
      return documentWith(
        id: id,
        type: type,
        number: number,
        chainId: source.chainId,
      ).copyWith(sourceDocumentId: source.documentId);
    }

    BusinessDocument lockedCopyOf(BusinessDocument source) =>
        source.copyWith(lockedAt: lockTime, updatedAt: lockTime);

    Future<bool> isListedAsLocked(BusinessDocument document) async {
      final summaries = await repository
          .watchDocumentSummaries(
            DocumentListQuery(documentType: document.documentType),
          )
          .first;
      return summaries
          .singleWhere((summary) => summary.documentId == document.documentId)
          .isLocked;
    }

    group('saveUpgrade', () {
      test(
        'saveUpgrade writes created document and locks source atomically',
        () async {
          final quotation = documentWith(id: 'qt');
          await repository.saveDocument(quotation);
          final lockedQuotation = lockedCopyOf(quotation);
          final salesOrder = derivedFrom(
            quotation,
            id: 'so',
            type: DocumentType.salesOrder,
            number: 'SO-2026-0001',
          );

          await repository.saveUpgrade(
            lockedSource: lockedQuotation,
            createdDocument: salesOrder,
          );

          expect(await repository.getDocument('qt'), lockedQuotation);
          expect(await repository.getDocument('so'), salesOrder);
          expect(await isListedAsLocked(quotation), isTrue);
          expect(await isListedAsLocked(salesOrder), isFalse);
          await expectLater(
            repository.saveDocument(lockedQuotation.copyWith(notes: 'edit')),
            throwsA(isA<DocumentLockedException>()),
          );
        },
      );

      test('saveUpgrade failure leaves neither change', () async {
        final quotation = documentWith(id: 'qt');
        final existingLocked = documentWith(
          id: 'taken',
          number: 'SO-2026-0001',
          type: DocumentType.salesOrder,
          chainId: 'chain-2',
        ).copyWith(lockedAt: lockTime);
        await repository.saveDocument(quotation);
        await repository.saveDocument(existingLocked);
        final collidingSalesOrder = derivedFrom(
          quotation,
          id: 'taken',
          type: DocumentType.salesOrder,
          number: 'SO-2026-0002',
        );

        await expectLater(
          repository.saveUpgrade(
            lockedSource: lockedCopyOf(quotation),
            createdDocument: collidingSalesOrder,
          ),
          throwsA(isA<DocumentLockedException>()),
        );

        expect(await repository.getDocument('qt'), quotation);
        expect(await repository.getDocument('taken'), existingLocked);
      });

      test('saveUpgrade onto an existing unlocked id fails and leaves neither '
          'change', () async {
        final quotation = documentWith(id: 'qt');
        final existingDraft = documentWith(
          id: 'taken',
          number: 'SO-2026-0001',
          type: DocumentType.salesOrder,
          chainId: 'chain-2',
        );
        await repository.saveDocument(quotation);
        await repository.saveDocument(existingDraft);

        await expectLater(
          repository.saveUpgrade(
            lockedSource: lockedCopyOf(quotation),
            createdDocument: derivedFrom(
              quotation,
              id: 'taken',
              type: DocumentType.salesOrder,
              number: 'SO-2026-0002',
            ),
          ),
          throwsA(isA<StorageWriteException>()),
        );

        expect(await repository.getDocument('qt'), quotation);
        expect(await isListedAsLocked(quotation), isFalse);
        expect(await repository.getDocument('taken'), existingDraft);
      });

      test('saveUpgrade from an already locked, unchanged source is allowed '
          'and keeps the original lock', () async {
        final salesOrder = documentWith(
          id: 'so',
          number: 'SO-2026-0001',
          type: DocumentType.salesOrder,
        ).copyWith(lockedAt: lockTime);
        await repository.saveDocument(salesOrder);
        final secondDelivery = derivedFrom(
          salesOrder,
          id: 'do2',
          type: DocumentType.deliveryOrder,
          number: 'DO-2026-0002',
        );

        await repository.saveUpgrade(
          lockedSource: salesOrder,
          createdDocument: secondDelivery,
        );

        expect(await repository.getDocument('so'), salesOrder);
        expect(await repository.getDocument('do2'), secondDelivery);
      });

      test('saveUpgrade rejects a source that is not locked', () async {
        final quotation = documentWith(id: 'qt');
        await repository.saveDocument(quotation);
        final salesOrder = derivedFrom(
          quotation,
          id: 'so',
          type: DocumentType.salesOrder,
          number: 'SO-2026-0001',
        );

        await expectLater(
          repository.saveUpgrade(
            lockedSource: quotation,
            createdDocument: salesOrder,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('saveUpgrade rejects a created document whose sourceDocumentId '
          'does not match', () async {
        final quotation = documentWith(id: 'qt');
        await repository.saveDocument(quotation);
        final unrelated = documentWith(
          id: 'so',
          number: 'SO-2026-0001',
          type: DocumentType.salesOrder,
        ).copyWith(sourceDocumentId: 'other');

        await expectLater(
          repository.saveUpgrade(
            lockedSource: lockedCopyOf(quotation),
            createdDocument: unrelated,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test(
        'saveUpgrade rejects a created document that is already locked',
        () async {
          final quotation = documentWith(id: 'qt');
          await repository.saveDocument(quotation);
          final lockedSalesOrder = derivedFrom(
            quotation,
            id: 'so',
            type: DocumentType.salesOrder,
            number: 'SO-2026-0001',
          ).copyWith(lockedAt: lockTime);

          await expectLater(
            repository.saveUpgrade(
              lockedSource: lockedCopyOf(quotation),
              createdDocument: lockedSalesOrder,
            ),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test('saveUpgrade throws DocumentLockedException when the source differs '
          'from the stored one in more than the lock', () async {
        final quotation = documentWith(id: 'qt');
        await repository.saveDocument(quotation);
        final salesOrder = derivedFrom(
          quotation,
          id: 'so',
          type: DocumentType.salesOrder,
          number: 'SO-2026-0001',
        );

        await expectLater(
          repository.saveUpgrade(
            lockedSource: lockedCopyOf(quotation).copyWith(notes: 'sneaky'),
            createdDocument: salesOrder,
          ),
          throwsA(isA<DocumentLockedException>()),
        );

        expect(await repository.getDocument('qt'), quotation);
        await expectLater(
          repository.getDocument('so'),
          throwsA(isA<DocumentNotFoundException>()),
        );
      });

      test(
        'saveUpgrade with an unknown source throws DocumentNotFoundException',
        () async {
          final quotation = documentWith(id: 'qt');
          await expectLater(
            repository.saveUpgrade(
              lockedSource: lockedCopyOf(quotation),
              createdDocument: derivedFrom(
                quotation,
                id: 'so',
                type: DocumentType.salesOrder,
                number: 'SO-2026-0001',
              ),
            ),
            throwsA(isA<DocumentNotFoundException>()),
          );
          await expectLater(
            repository.getDocument('so'),
            throwsA(isA<DocumentNotFoundException>()),
          );
        },
      );
    });

    group('deleteDocument', () {
      test('deleting the only SO created from a QT unlocks the QT', () async {
        final quotation = documentWith(id: 'qt');
        await repository.saveDocument(quotation);
        await repository.saveUpgrade(
          lockedSource: lockedCopyOf(quotation),
          createdDocument: derivedFrom(
            quotation,
            id: 'so',
            type: DocumentType.salesOrder,
            number: 'SO-2026-0001',
          ),
        );

        await repository.deleteDocument('so');

        await expectLater(
          repository.getDocument('so'),
          throwsA(isA<DocumentNotFoundException>()),
        );
        final unlocked = await repository.getDocument('qt');
        expect(unlocked.lockedAt, isNull);
        // Only the lock is cleared; updatedAt keeps the value from locking.
        expect(unlocked, lockedCopyOf(quotation).copyWith(lockedAt: null));
        expect(await isListedAsLocked(quotation), isFalse);
        final edited = unlocked.copyWith(notes: 'editable again');
        await repository.saveDocument(edited);
        expect(await repository.getDocument('qt'), edited);
      });

      test('deleting one of two DOs keeps the SO locked', () async {
        final salesOrder = documentWith(
          id: 'so',
          number: 'SO-2026-0001',
          type: DocumentType.salesOrder,
        );
        await repository.saveDocument(salesOrder);
        final lockedSalesOrder = lockedCopyOf(salesOrder);
        await repository.saveUpgrade(
          lockedSource: lockedSalesOrder,
          createdDocument: derivedFrom(
            salesOrder,
            id: 'do1',
            type: DocumentType.deliveryOrder,
            number: 'DO-2026-0001',
          ),
        );
        await repository.saveUpgrade(
          lockedSource: lockedSalesOrder,
          createdDocument: derivedFrom(
            salesOrder,
            id: 'do2',
            type: DocumentType.deliveryOrder,
            number: 'DO-2026-0002',
          ),
        );

        await repository.deleteDocument('do1');

        expect(await repository.getDocument('so'), lockedSalesOrder);
        expect(await isListedAsLocked(salesOrder), isTrue);

        await repository.deleteDocument('do2');

        expect((await repository.getDocument('so')).lockedAt, isNull);
        expect(await isListedAsLocked(salesOrder), isFalse);
      });

      test('deleting a locked document throws', () async {
        final locked = documentWith(id: 'qt').copyWith(lockedAt: lockTime);
        await repository.saveDocument(locked);

        await expectLater(
          repository.deleteDocument('qt'),
          throwsA(isA<DocumentLockedException>()),
        );
        expect(await repository.getDocument('qt'), locked);
      });

      test('deleting a standalone draft removes only that document', () async {
        await repository.saveDocument(documentWith(id: 'a'));
        await repository.saveDocument(
          documentWith(id: 'b', number: 'QT-2026-0002'),
        );

        await repository.deleteDocument('a');

        expect(
          await listedIds(
            const DocumentListQuery(documentType: DocumentType.quotation),
          ),
          ['b'],
        );
      });

      test('deleting an unknown id throws DocumentNotFoundException', () async {
        await expectLater(
          repository.deleteDocument('missing'),
          throwsA(isA<DocumentNotFoundException>()),
        );
      });
    });
  });
}
