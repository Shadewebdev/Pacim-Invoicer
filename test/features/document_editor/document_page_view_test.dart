import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/document_layout_options.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_controller.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_page.dart';
import 'package:pacim_invoicer/features/document_editor/document_page/document_page_view.dart';
import 'package:pacim_invoicer/features/document_editor/document_page/page_zoom_provider.dart';

import '../../support/document_builders.dart';
import '../../support/fake_repositories.dart';

late ProviderContainer _container;
late FakeDocumentRepository _documents;

Future<void> _pump(
  WidgetTester tester,
  Widget home,
  BusinessDocument? seeded, {
  Size size = const Size(1400, 1600),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final documents = _documents = FakeDocumentRepository();
  if (seeded != null) documents.seed(seeded);
  _container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      documentRepositoryProvider.overrideWithValue(documents),
      settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      assetRepositoryProvider.overrideWithValue(FakeAssetRepository()),
      clockProvider.overrideWithValue(() => DateTime(2026, 10, 17)),
    ],
  );
  addTearDown(_container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: _container,
      child: MaterialApp(
        theme: buildAppTheme(
          brightness: Brightness.light,
          platform: TargetPlatform.windows,
        ),
        home: Scaffold(
          body: Align(alignment: Alignment.topLeft, child: home),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpPage(WidgetTester tester, BusinessDocument document) =>
    _pump(tester, DocumentPageView(documentId: document.documentId), document);

void main() {
  testWidgets('page renders company name, number and customer', (tester) async {
    await _pumpPage(tester, buildTestDocument());
    expect(find.text('Pacim Sdn Bhd'), findsOneWidget);
    expect(find.text('QT-2026-0001'), findsOneWidget);
    expect(find.text('Acme Trading'), findsOneWidget);
    expect(find.text('Quotation'), findsOneWidget);
    expect(find.text('Page 1 of 1'), findsOneWidget);
  });

  testWidgets('committing customer name calls updateCustomerDetails', (
    tester,
  ) async {
    final document = buildTestDocument();
    await _pumpPage(tester, document);
    await tester.enterText(
      find.byKey(const ValueKey('customerName')),
      'Zenith Bhd',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final stored = _container
        .read(documentEditorControllerProvider(document.documentId))
        .requireValue
        .document;
    expect(stored.customerDetails.customerName, 'Zenith Bhd');
    await _container
        .read(documentEditorControllerProvider(document.documentId).notifier)
        .saveNow();
  });

  testWidgets('hidden notes block when showNotes false', (tester) async {
    final document = buildTestDocument().copyWith(
      layoutOptions: const DocumentLayoutOptions(showNotes: false),
    );
    await _pumpPage(tester, document);
    expect(find.text('Thank you.'), findsNothing);
    expect(find.text('Payment within 30 days.'), findsOneWidget);
  });

  testWidgets('locked documents are read-only', (tester) async {
    await _pumpPage(
      tester,
      buildTestDocument().copyWith(lockedAt: DateTime.utc(2026, 10, 18)),
    );
    final field = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('customerName')),
        matching: find.byType(TextField),
      ),
    );
    expect(field.readOnly, isTrue);
  });

  testWidgets('delivery order page has no totals section', (tester) async {
    await _pumpPage(
      tester,
      buildTestDocument(type: DocumentType.deliveryOrder),
    );
    expect(find.text('Total'), findsNothing);
    expect(find.text('Subtotal'), findsNothing);
    expect(find.text('Delivery order'), findsOneWidget);
  });

  testWidgets('quotation page shows subtotal and total', (tester) async {
    await _pumpPage(tester, buildTestDocument());
    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('SST'), findsOneWidget);
  });

  testWidgets('missing document shows no-longer-exists message', (
    tester,
  ) async {
    await _pump(
      tester,
      const SizedBox(
        width: 1200,
        height: 800,
        child: DocumentEditorPage(documentId: 'gone'),
      ),
      null,
    );
    expect(find.text('This document no longer exists'), findsOneWidget);
    expect(find.text('Back to quotations'), findsOneWidget);
  });

  testWidgets('editor page shows the command bar', (tester) async {
    final document = buildTestDocument();
    await _pump(
      tester,
      SizedBox(
        width: 1400,
        height: 900,
        child: DocumentEditorPage(documentId: document.documentId),
      ),
      document,
    );
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Export PDF'), findsOneWidget);
    expect(find.text('Fit width'), findsOneWidget);
  });

  testWidgets('fit width zooms the page to the canvas and zoom is clamped', (
    tester,
  ) async {
    final document = buildTestDocument();
    await _pump(
      tester,
      SizedBox(
        width: 700,
        height: 800,
        child: DocumentEditorPage(documentId: document.documentId),
      ),
      document,
      size: const Size(700, 800),
    );
    await tester.tap(find.text('Fit width'));
    await tester.pumpAndSettle();
    expect(_container.read(pageZoomProvider), lessThan(1));
    expect(_container.read(pageZoomProvider), greaterThanOrEqualTo(0.5));

    final notifier = _container.read(pageZoomProvider.notifier);
    notifier.setZoom(9);
    expect(_container.read(pageZoomProvider), 2.0);
    notifier.setZoom(0.1);
    expect(_container.read(pageZoomProvider), 0.5);
    notifier.zoomBySteps(1);
    expect(_container.read(pageZoomProvider), closeTo(0.6, 1e-9));
  });
  testWidgets('footer is pinned to the bottom of a short page', (tester) async {
    final document = buildTestDocument(lineItems: [buildTestLine()]);
    await _pumpPage(tester, document);
    final footer = tester.getBottomLeft(find.text('Page 1 of 1')).dy;
    final page = tester.getRect(find.byType(DocumentPageView));
    expect(page.height, closeTo(DocumentPageView.pageHeight, 0.5));
    // The footer sits within the bottom margin of the A4 page.
    expect(page.bottom - footer, lessThan(100));
  });

  testWidgets('Save commits the text of a focused field before saving', (
    tester,
  ) async {
    final document = buildTestDocument();
    await _pump(
      tester,
      SizedBox(
        width: 1400,
        height: 900,
        child: DocumentEditorPage(documentId: document.documentId),
      ),
      document,
    );
    await tester.enterText(
      find.byKey(const ValueKey('customerName')),
      'Typed Not Blurred',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final stored = _documents.storedDocuments.single;
    expect(stored.customerDetails.customerName, 'Typed Not Blurred');
    expect(_documents.saveCount, greaterThan(0));
  });
}
