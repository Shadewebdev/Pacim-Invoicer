import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_provider_overrides.dart';

import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/domain/models/document_summary.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_page.dart';
import 'package:pacim_invoicer/features/document_editor/locked_document_banner.dart';

import '../../support/document_builders.dart';
import '../../support/fake_repositories.dart';

final _createdFrom = DocumentSummary(
  documentId: 'so-1',
  documentType: DocumentType.salesOrder,
  documentNumber: 'SO-2026-0002',
  chainId: 'chain-1',
  sourceDocumentId: 'doc-1',
  customerName: 'Acme Trading',
  issueDate: DateTime(2026, 10, 17),
  grandTotalMinor: 0,
  currencyCode: 'MYR',
  isLocked: false,
  updatedAt: DateTime(2026, 10, 17),
);

Widget _app(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: buildAppTheme(
          brightness: Brightness.light,
          platform: TargetPlatform.windows,
        ),
        home: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('locked banner text names the created document', (tester) async {
    var duplicated = 0;
    String? openedId;
    await tester.pumpWidget(
      _app(
        LockedDocumentBanner(
          document: buildTestDocument(),
          createdFrom: _createdFrom,
          onDuplicateAsNewDraft: () => duplicated++,
          onOpenCreatedDocument: (summary) => openedId = summary.documentId,
        ),
      ),
    );
    expect(
      find.text(
        'This quotation is locked because SO-2026-0002 was created from it',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Duplicate as new draft'));
    await tester.tap(find.text('Open SO-2026-0002'));
    expect(duplicated, 1);
    expect(openedId, 'so-1');
  });

  testWidgets('without a created document the banner still says it is locked', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        LockedDocumentBanner(
          document: buildTestDocument(type: DocumentType.salesOrder),
          createdFrom: null,
        ),
      ),
    );
    expect(find.text('This sales order is locked'), findsOneWidget);
    expect(find.textContaining('Open '), findsNothing);
  });

  testWidgets('the editor page finds the document created from a locked one', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final quotation = buildTestDocument(lockedAt: DateTime.utc(2026, 10, 18));
    final salesOrder = buildTestDocument(
      type: DocumentType.salesOrder,
      documentId: 'so-1',
      sourceDocumentId: 'doc-1',
    ).copyWith(documentNumber: 'SO-2026-0002');
    final documents = FakeDocumentRepository()
      ..seed(quotation)
      ..seed(salesOrder);
    await tester.pumpWidget(
      _app(
        const DocumentEditorPage(documentId: 'doc-1'),
        overrides: [
          ...fakeStorageOverrides(documents: documents),
          clockProvider.overrideWithValue(() => DateTime(2026, 10, 18)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(
        'This quotation is locked because SO-2026-0002 was created from it',
      ),
      findsOneWidget,
    );
    expect(find.text('Open SO-2026-0002'), findsOneWidget);
  });
}
