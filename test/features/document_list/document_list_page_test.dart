import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/customer_details.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/features/document_list/document_list_page.dart';

import '../../support/document_builders.dart';
import '../../support/fake_repositories.dart';

BusinessDocument _document({
  required String id,
  required String number,
  required String customer,
  DocumentType type = DocumentType.quotation,
  DateTime? lockedAt,
}) {
  return buildTestDocument(
    type: type,
    documentId: id,
    chainId: 'chain-$id',
    lockedAt: lockedAt,
  ).copyWith(
    documentNumber: number,
    customerDetails: CustomerDetails(customerName: customer),
  );
}

Future<FakeDocumentRepository> pumpListPage(
  WidgetTester tester, {
  DocumentType type = DocumentType.quotation,
  List<BusinessDocument> seeded = const [],
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
        documentRepositoryProvider.overrideWithValue(documents),
        numberSequenceRepositoryProvider.overrideWithValue(
          FakeNumberSequenceRepository(),
        ),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 17)),
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
}
