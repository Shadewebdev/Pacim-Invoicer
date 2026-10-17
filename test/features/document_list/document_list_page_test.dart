import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_provider_overrides.dart';

import 'package:pacim_invoicer/app/shell/status_bar_count_provider.dart';
import 'package:pacim_invoicer/app/shell/status_bar_message_provider.dart';
import 'package:pacim_invoicer/features/pdf_export/pdf_export_service.dart';
import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/currency_format.dart';
import 'package:pacim_invoicer/domain/models/customer_details.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/features/document_list/document_list_controller.dart';
import 'package:pacim_invoicer/features/document_list/document_list_page.dart';

import '../../support/document_builders.dart';
import '../../support/fake_pdf_output_target.dart';
import '../../support/fake_repositories.dart';

BusinessDocument _document({
  required String id,
  required String number,
  required String customer,
  DocumentType type = DocumentType.quotation,
  DateTime? lockedAt,
  DateTime? issueDate,
}) {
  return buildTestDocument(
    type: type,
    documentId: id,
    chainId: 'chain-$id',
    lockedAt: lockedAt,
  ).copyWith(
    documentNumber: number,
    customerDetails: CustomerDetails(customerName: customer),
    issueDate: issueDate ?? DateTime.utc(2026, 10, 17),
  );
}

Future<FakeDocumentRepository> pumpListPage(
  WidgetTester tester, {
  DocumentType type = DocumentType.quotation,
  List<BusinessDocument> seeded = const [],
  FakeNumberSequenceRepository? sequences,
  FakePdfOutputTarget? pdfTarget,
  PdfDocumentBuilder? pdfBuilder,
}) async {
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final documents = FakeDocumentRepository();
  seeded.forEach(documents.seed);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...fakeStorageOverrides(
          documents: documents,
          numberSequences: sequences,
        ),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 17)),
        pdfOutputTargetProvider.overrideWithValue(
          pdfTarget ?? FakePdfOutputTarget(),
        ),
        sharesPdfInsteadOfSavingProvider.overrideWithValue(false),
        pdfDocumentBuilderProvider.overrideWithValue(
          pdfBuilder ?? fakePdfBuilder,
        ),
      ],
      child: MaterialApp(
        theme: buildAppTheme(
          brightness: Brightness.light,
          platform: TargetPlatform.windows,
        ),
        home: Scaffold(body: DocumentListPage(documentType: type)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return documents;
}

Future<void> openContextMenu(WidgetTester tester, String rowText) async {
  await tester.tap(find.text(rowText), buttons: kSecondaryButton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty state shows New quotation', (tester) async {
    await pumpListPage(tester);
    expect(find.text('No quotations yet'), findsOneWidget);
    expect(find.text('New quotation'), findsWidgets);
  });

  testWidgets('each total uses the currency format of its own document', (
    tester,
  ) async {
    final base = _document(id: 'y1', number: 'QT-2026-0001', customer: 'Acme');
    await pumpListPage(
      tester,
      seeded: [
        base.copyWith(
          lineItems: [buildTestLine(unitPriceMinor: 1500)],
          pricingTerms: base.pricingTerms.copyWith(
            isTaxEnabled: false,
            currencyFormat: const CurrencyFormat(
              currencyCode: 'JPY',
              symbol: '¥',
              decimalPlaces: 0,
              symbolPosition: CurrencySymbolPosition.before,
            ),
          ),
        ),
      ],
    );

    expect(find.text('¥1,500'), findsOneWidget);
  });

  testWidgets('leaving the list stops its chain and listing watchers', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final documents = WatchCountingDocumentRepository()
      ..seed(_document(id: 'a', number: 'QT-2026-0001', customer: 'Acme'))
      ..seed(_document(id: 'b', number: 'QT-2026-0002', customer: 'Beta'));
    final container = ProviderContainer(
      overrides: [
        ...fakeStorageOverrides(documents: documents),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 17)),
      ],
    );
    addTearDown(container.dispose);
    final showsList = ValueNotifier<bool>(true);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(
            brightness: Brightness.light,
            platform: TargetPlatform.windows,
          ),
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: showsList,
              builder: (context, showsList, _) => showsList
                  ? const DocumentListPage(documentType: DocumentType.quotation)
                  : const Text('elsewhere'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(documents.openChainWatches, 2);

    showsList.value = false;
    await tester.pumpAndSettle();

    expect(documents.openChainWatches, 0);
    expect(
      container.exists(documentSummariesProvider(DocumentType.quotation)),
      isFalse,
    );
    expect(
      container.exists(documentCountProvider(DocumentType.quotation)),
      isFalse,
    );
  });

  testWidgets('delivery order list hides the total column', (tester) async {
    await pumpListPage(
      tester,
      type: DocumentType.deliveryOrder,
      seeded: [
        _document(
          id: 'd1',
          number: 'DO-2026-0001',
          customer: 'Acme',
          type: DocumentType.deliveryOrder,
        ),
      ],
    );
    expect(find.text('DO-2026-0001'), findsOneWidget);
    expect(find.text('Total'), findsNothing);
    expect(find.text('Customer'), findsOneWidget);
  });

  testWidgets('quotation list shows the total column', (tester) async {
    await pumpListPage(
      tester,
      seeded: [_document(id: 'q1', number: 'QT-2026-0001', customer: 'Acme')],
    );
    expect(find.text('Total'), findsOneWidget);
  });

  testWidgets('locked rows show Locked and hide Delete in the menu', (
    tester,
  ) async {
    await pumpListPage(
      tester,
      seeded: [
        _document(
          id: 'q1',
          number: 'QT-2026-0001',
          customer: 'Locked Co',
          lockedAt: DateTime.utc(2026, 10, 18),
        ),
        _document(id: 'q2', number: 'QT-2026-0002', customer: 'Draft Co'),
      ],
    );
    expect(find.text('Locked'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);

    await openContextMenu(tester, 'Locked Co');
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Delete'), findsNothing);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    await openContextMenu(tester, 'Draft Co');
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Upgrade to sales order'), findsOneWidget);
  });

  testWidgets('Export PDF in the row menu exports that document', (
    tester,
  ) async {
    final pdfTarget = FakePdfOutputTarget();
    await pumpListPage(
      tester,
      pdfTarget: pdfTarget,
      seeded: [
        _document(id: 'q1', number: 'QT-2026-0003', customer: 'Export Co'),
      ],
    );
    await openContextMenu(tester, 'Export Co');
    await tester.tap(find.text('Export PDF'));
    await tester.pumpAndSettle();

    expect(pdfTarget.savedNames, ['QT-2026-0003 Export Co.pdf']);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(DocumentListPage)),
    );
    expect(
      container.read(statusBarMessageProvider),
      'Exported QT-2026-0003 Export Co.pdf',
    );
  });

  testWidgets('exporting an over-delivered delivery order lists the issue', (
    tester,
  ) async {
    final pdfTarget = FakePdfOutputTarget();
    final salesOrder = buildTestDocument(
      type: DocumentType.salesOrder,
      documentId: 'so-1',
      chainId: 'chain-x',
      lineItems: [buildTestLine(id: 'so-line', quantityScaled: 5000)],
    );
    deliveryOrderWith(String id, String number, int quantity) =>
        buildTestDocument(
          type: DocumentType.deliveryOrder,
          documentId: id,
          chainId: 'chain-x',
          sourceDocumentId: 'so-1',
          lineItems: [
            buildTestLine(
              id: '$id-line',
              quantityScaled: quantity,
            ).copyWith(sourceLineItemId: 'so-line'),
          ],
        ).copyWith(
          documentNumber: number,
          customerDetails: const CustomerDetails(customerName: 'Late Co'),
        );
    await pumpListPage(
      tester,
      type: DocumentType.deliveryOrder,
      pdfTarget: pdfTarget,
      seeded: [
        salesOrder,
        deliveryOrderWith('do-0', 'DO-2026-0001', 3000),
        deliveryOrderWith('do-1', 'DO-2026-0002', 3000),
      ],
    );
    await tester.tap(
      find.text('DO-2026-0002').first,
      buttons: kSecondaryButton,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export PDF'));
    await tester.pumpAndSettle();

    expect(find.text('Export with issues?'), findsOneWidget);
    expect(
      find.text('An item delivers more than remains on the sales order'),
      findsOneWidget,
    );
    expect(pdfTarget.savedNames, isEmpty);
  });

  testWidgets('exporting twice while one export runs exports once', (
    tester,
  ) async {
    final pdfTarget = FakePdfOutputTarget();
    final gate = Completer<void>();
    await pumpListPage(
      tester,
      pdfTarget: pdfTarget,
      pdfBuilder: (document, images) async {
        await gate.future;
        return fakePdfBuilder(document, images);
      },
      seeded: [
        _document(id: 'q1', number: 'QT-2026-0003', customer: 'Export Co'),
      ],
    );

    for (var attempt = 0; attempt < 2; attempt++) {
      await openContextMenu(tester, 'Export Co');
      await tester.tap(find.text('Export PDF'));
      await tester.pumpAndSettle();
    }
    gate.complete();
    await tester.pumpAndSettle();

    expect(pdfTarget.outputs, hasLength(1));
  });

  testWidgets('delete asks for confirmation with the document number', (
    tester,
  ) async {
    final documents = await pumpListPage(
      tester,
      seeded: [
        _document(id: 'q2', number: 'QT-2026-0004', customer: 'Delete Co'),
      ],
    );
    await openContextMenu(tester, 'Delete Co');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(
      find.text("Delete QT-2026-0004? This can't be undone."),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(documents.storedDocuments, isEmpty);
  });

  testWidgets('typing in search filters rows', (tester) async {
    await pumpListPage(
      tester,
      seeded: [
        _document(id: 'q1', number: 'QT-2026-0001', customer: 'Acme'),
        _document(id: 'q2', number: 'QT-2026-0002', customer: 'Borneo'),
      ],
    );
    expect(find.text('Acme'), findsOneWidget);
    expect(find.text('Borneo'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'borneo');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Acme'), findsNothing);
    expect(find.text('Borneo'), findsOneWidget);
  });

  group('with 60 quotations', () {
    List<BusinessDocument> sixtyQuotations() => [
      for (var day = 1; day <= 60; day++)
        _document(
          id: 'q$day',
          number: 'QT-2026-${day.toString().padLeft(4, '0')}',
          customer: 'Customer $day',
          issueDate: DateTime.utc(2026, 1, 1).add(Duration(days: day)),
        ),
    ];

    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(
          tester.element(find.byType(DocumentListPage)),
        );

    testWidgets('scrolling to the bottom loads more once and keeps position', (
      tester,
    ) async {
      await pumpListPage(tester, seeded: sixtyQuotations());
      final listFinder = find.byType(ListView);
      expect(find.text('QT-2026-0010'), findsNothing);

      for (var attempt = 0; attempt < 6; attempt++) {
        await tester.drag(listFinder, const Offset(0, -1500));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      final scrollable = tester.state<ScrollableState>(
        find.descendant(of: listFinder, matching: find.byType(Scrollable)),
      );
      expect(scrollable.position.pixels, greaterThan(0));
      final query = containerOf(tester)
          .read(documentListControllerProvider(DocumentType.quotation));
      expect(query.limit, 100);

      await tester.drag(listFinder, const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(find.text('QT-2026-0001'), findsOneWidget);
    });

    testWidgets('status bar count is the total, not the loaded rows', (
      tester,
    ) async {
      await pumpListPage(tester, seeded: sixtyQuotations());
      expect(containerOf(tester).read(statusBarCountProvider), '60 quotations');
    });
  });

  testWidgets('a double-click on New quotation creates only one document', (
    tester,
  ) async {
    final sequences = _GatedNumberSequenceRepository();
    final documents = await pumpListPage(tester, sequences: sequences);

    final button = find.widgetWithText(FilledButton, 'New quotation').first;
    await tester.tap(button);
    await tester.tap(button);
    sequences.release();
    await tester.pumpAndSettle();

    expect(documents.storedDocuments, hasLength(1));
    expect(sequences.allocationCount, 1);
  });
}

class _GatedNumberSequenceRepository extends FakeNumberSequenceRepository {
  final Completer<void> _gate = Completer<void>();
  int allocationCount = 0;

  void release() => _gate.complete();

  @override
  Future<int> allocateNextSequence(
    DocumentType type, {
    required int year,
    required bool resetsYearly,
  }) async {
    allocationCount++;
    await _gate.future;
    return super.allocateNextSequence(
      type,
      year: year,
      resetsYearly: resetsYearly,
    );
  }
}
