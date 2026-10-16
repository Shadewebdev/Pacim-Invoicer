import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/app/shell/status_bar_message_provider.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/currency_format.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/models/validation_issue.dart';
import 'package:pacim_invoicer/domain/services/document_factory.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_controller.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_state.dart';

import '../../support/document_builders.dart';
import '../../support/fake_repositories.dart';
import '../../support/sequential_id_generator.dart';

final _now = DateTime(2026, 10, 17, 12);

class _Harness {
  _Harness(
    BusinessDocument document, {
    List<BusinessDocument> others = const [],
  }) : documentId = document.documentId {
    repository.seed(document);
    others.forEach(repository.seed);
    container = ProviderContainer(
      overrides: [
        documentRepositoryProvider.overrideWithValue(repository),
        settingsRepositoryProvider.overrideWithValue(settings),
        idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
        clockProvider.overrideWithValue(() => _now),
      ],
    );
    container.listen(
      documentEditorControllerProvider(document.documentId),
      (_, _) {},
    );
  }

  final repository = FakeDocumentRepository();
  final settings = FakeSettingsRepository();
  late final ProviderContainer container;
  final String documentId;

  DocumentEditorController get controller =>
      container.read(documentEditorControllerProvider(documentId).notifier);

  DocumentEditorState get state =>
      container.read(documentEditorControllerProvider(documentId)).requireValue;
}

/// Runs [body] with fake timers after the controller has loaded.
void _withHarness(
  BusinessDocument document,
  void Function(FakeAsync async, _Harness harness) body, {
  List<BusinessDocument> others = const [],
}) {
  fakeAsync((async) {
    final harness = _Harness(document, others: others);
    async.flushMicrotasks();
    body(async, harness);
    harness.container.dispose();
    async.flushMicrotasks();
  });
}

void main() {
  test('edit sets pending then saves once after 2s of idle', () {
    _withHarness(buildTestDocument(), (async, harness) {
      for (var i = 0; i < 3; i++) {
        harness.controller.updateNotes('note $i');
        expect(harness.state.saveStatus, SaveStatus.pending);
        async.elapse(const Duration(milliseconds: 500));
      }
      expect(harness.repository.saveCount, 0);

      async.elapse(const Duration(milliseconds: 1500));
      async.flushMicrotasks();

      expect(harness.repository.saveCount, 1);
      expect(harness.state.saveStatus, SaveStatus.saved);
      final stored = harness.repository.storedDocuments.single;
      expect(stored.notes, 'note 2');
      expect(stored.updatedAt, _now);
    });
  });

  test('saveNow flushes immediately', () {
    _withHarness(buildTestDocument(), (async, harness) {
      harness.controller.updateFooterNote('Bye');

      harness.controller.saveNow();
      async.flushMicrotasks();

      expect(harness.repository.saveCount, 1);
      expect(harness.state.saveStatus, SaveStatus.saved);
      async.elapse(const Duration(seconds: 5));
      expect(harness.repository.saveCount, 1);
    });
  });

  test('disposing the provider with pending edits saves them', () {
    fakeAsync((async) {
      final harness = _Harness(buildTestDocument());
      async.flushMicrotasks();
      harness.controller.updateNotes('unsaved');

      harness.container.dispose();
      async.flushMicrotasks();

      expect(harness.repository.storedDocuments.single.notes, 'unsaved');
    });
  });

  test('edits on a locked document are ignored', () {
    _withHarness(buildTestDocument(lockedAt: DateTime.utc(2026, 10, 18)), (
      async,
      harness,
    ) {
      final before = harness.state;
      harness.controller.updateNotes('nope');
      harness.controller.removeLineItem('line-1');
      expect(harness.controller.insertLineItem(atIndex: 0), isNull);

      expect(harness.state, before);
      async.elapse(const Duration(seconds: 5));
      expect(harness.repository.saveCount, 0);
    });
  });

  test('save failure sets failed and retrySave recovers', () {
    _withHarness(buildTestDocument(), (async, harness) {
      harness.repository.failNextSave = true;
      harness.controller.updateNotes('x');
      async.elapse(const Duration(seconds: 2));
      async.flushMicrotasks();

      expect(harness.state.saveStatus, SaveStatus.failed);
      expect(
        harness.container.read(statusBarMessageProvider),
        "Couldn't save — Retry",
      );

      harness.controller.retrySave();
      async.flushMicrotasks();

      expect(harness.state.saveStatus, SaveStatus.saved);
      expect(harness.repository.storedDocuments.single.notes, 'x');
    });
  });

  test('a locked document found on save reloads as saved and locked', () {
    _withHarness(buildTestDocument(), (async, harness) {
      harness.controller.updateNotes('mine');
      harness.repository.seed(
        buildTestDocument(lockedAt: DateTime.utc(2026, 10, 18)),
      );
      async.flushMicrotasks();
      expect(harness.state.saveStatus, SaveStatus.pending);

      async.elapse(const Duration(seconds: 2));
      async.flushMicrotasks();

      expect(harness.state.saveStatus, SaveStatus.saved);
      expect(harness.state.isLocked, isTrue);
      expect(harness.state.document.notes, 'Thank you.');
    });
  });

  test('changing decimal places from 2 to 0 rounds 1050 to 11', () {
    _withHarness(
      buildTestDocument(lineItems: [buildTestLine(unitPriceMinor: 1050)]),
      (async, harness) {
        final format = harness.state.document.pricingTerms.currencyFormat;

        harness.controller.updateCurrencyFormat(
          format.copyWith(decimalPlaces: 0),
        );

        expect(harness.state.document.lineItems.single.unitPriceMinor, 11);
        expect(
          harness.state.document.pricingTerms.currencyFormat.decimalPlaces,
          0,
        );
      },
    );
  });

  test('changing decimal places from 2 to 3 multiplies prices by 10', () {
    _withHarness(
      buildTestDocument(lineItems: [buildTestLine(unitPriceMinor: 1050)]),
      (async, harness) {
        harness.controller.updateCurrencyFormat(
          CurrencyFormat.defaultFormat.copyWith(decimalPlaces: 3),
        );

        expect(harness.state.document.lineItems.single.unitPriceMinor, 10500);
      },
    );
  });

  test('moveLineItem reorders', () {
    _withHarness(
      buildTestDocument(
        lineItems: [
          buildTestLine(id: 'a'),
          buildTestLine(id: 'b'),
          buildTestLine(id: 'c'),
        ],
      ),
      (async, harness) {
        harness.controller.moveLineItem('a', toIndex: 2);

        expect(
          harness.state.document.lineItems.map((line) => line.lineItemId),
          ['b', 'c', 'a'],
        );
      },
    );
  });

  test('removeLineItem removes', () {
    _withHarness(buildTestDocument(), (async, harness) {
      harness.controller.removeLineItem('line-1');

      expect(harness.state.document.lineItems.map((line) => line.lineItemId), [
        'line-2',
      ]);
    });
  });

  test('insertLineItem returns id of empty line at index', () {
    _withHarness(buildTestDocument(), (async, harness) {
      final newId = harness.controller.insertLineItem(atIndex: 1);

      expect(newId, 'id-1');
      final lines = harness.state.document.lineItems;
      expect(lines.map((line) => line.lineItemId), [
        'line-1',
        'id-1',
        'line-2',
      ]);
      expect(lines[1].description, isEmpty);
      expect(lines[1].unitPriceMinor, 0);
    });
  });

  test('duplicateLineItem copies the line below it with a new id', () {
    _withHarness(buildTestDocument(), (async, harness) {
      harness.controller.duplicateLineItem('line-1');

      final lines = harness.state.document.lineItems;
      expect(lines.map((line) => line.lineItemId), [
        'line-1',
        'id-1',
        'line-2',
      ]);
      expect(lines[1].description, lines[0].description);
    });
  });

  test('updateLineItem changes the line and revalidates', () {
    _withHarness(buildTestDocument(), (async, harness) {
      harness.controller.updateLineItem(
        'line-1',
        (line) => line.copyWith(quantityScaled: 0),
      );

      expect(
        harness.state.validationIssues,
        contains(
          const ValidationIssue(
            kind: ValidationIssueKind.zeroQuantity,
            lineItemId: 'line-1',
          ),
        ),
      );
    });
  });

  test(
    'delivery order validation flags over-delivery against its sales order',
    () {
      final salesOrder = buildTestDocument(
        type: DocumentType.salesOrder,
        documentId: 'so-1',
        lineItems: [buildTestLine(id: 'so-line', quantityScaled: 5000)],
      );
      final deliveryOrder = buildTestDocument(
        type: DocumentType.deliveryOrder,
        documentId: 'do-1',
        sourceDocumentId: 'so-1',
        lineItems: [
          buildTestLine(
            id: 'do-line',
            quantityScaled: 3000,
          ).copyWith(sourceLineItemId: 'so-line'),
        ],
      );
      final earlierDelivery = buildTestDocument(
        type: DocumentType.deliveryOrder,
        documentId: 'do-0',
        sourceDocumentId: 'so-1',
        lineItems: [
          buildTestLine(
            id: 'earlier',
            quantityScaled: 3000,
          ).copyWith(sourceLineItemId: 'so-line'),
        ],
      );

      _withHarness(deliveryOrder, others: [salesOrder, earlierDelivery], (
        async,
        harness,
      ) {
        expect(harness.state.salesOrder?.documentId, 'so-1');
        expect(
          harness.state.otherDeliveryOrders.map((order) => order.documentId),
          ['do-0'],
        );
        expect(
          harness.state.validationIssues.map((issue) => issue.kind),
          contains(ValidationIssueKind.deliveryExceedsRemaining),
        );

        harness.controller.updateLineItem(
          'do-line',
          (line) => line.copyWith(quantityScaled: 2000),
        );

        expect(
          harness.state.validationIssues.map((issue) => issue.kind),
          isNot(contains(ValidationIssueKind.deliveryExceedsRemaining)),
        );
      });
    },
  );

  test('external lock replaces state when saved', () {
    _withHarness(buildTestDocument(), (async, harness) {
      harness.repository.seed(
        buildTestDocument(lockedAt: DateTime.utc(2026, 10, 18)),
      );
      async.flushMicrotasks();

      expect(harness.state.isLocked, isTrue);
    });
  });

  test('external updates are ignored while edits are pending', () {
    _withHarness(buildTestDocument(), (async, harness) {
      harness.controller.updateNotes('mine');
      harness.repository.seed(
        buildTestDocument(lockedAt: DateTime.utc(2026, 10, 18)),
      );
      async.flushMicrotasks();

      expect(harness.state.isLocked, isFalse);
      expect(harness.state.document.notes, 'mine');
    });
  });

  test('resetSectionToDefaults restores the section from settings', () {
    _withHarness(buildTestDocument(), (async, harness) {
      harness.controller.updateTermsAndConditions('custom');

      harness.controller.resetSectionToDefaults(DocumentSection.terms);
      async.flushMicrotasks();

      expect(
        harness.state.document.termsAndConditions,
        harness.settings.currentSettings.defaultTermsByType[DocumentType
                .quotation] ??
            '',
      );
      expect(harness.state.saveStatus, SaveStatus.pending);
    });
  });
}
