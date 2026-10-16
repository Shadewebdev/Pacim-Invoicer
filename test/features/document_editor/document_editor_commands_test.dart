import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_controller.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_page.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_state.dart';

import '../../support/document_builders.dart';
import '../../support/fake_repositories.dart';
import '../../support/sequential_id_generator.dart';

late ProviderContainer _container;
late FakeDocumentRepository _documents;
late GoRouter _router;

String get _location => _router.routerDelegate.currentConfiguration.uri.path;

Future<void> _pump(
  WidgetTester tester,
  List<BusinessDocument> seeded, {
  String openId = 'doc-1',
}) async {
  tester.view.physicalSize = const Size(1400, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  _documents = FakeDocumentRepository();
  seeded.forEach(_documents.seed);
  _container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      documentRepositoryProvider.overrideWithValue(_documents),
      numberSequenceRepositoryProvider.overrideWithValue(
        FakeNumberSequenceRepository(),
      ),
      settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      assetRepositoryProvider.overrideWithValue(FakeAssetRepository()),
      idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
      clockProvider.overrideWithValue(() => DateTime(2026, 10, 17)),
    ],
  );
  addTearDown(_container.dispose);
  _router = GoRouter(
    initialLocation: '/documents/$openId',
    routes: [
      GoRoute(
        path: '/documents/:documentId',
        builder: (context, state) => Scaffold(
          body: DocumentEditorPage(
            documentId: state.pathParameters['documentId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/:typeSegment',
        builder: (context, state) =>
            Scaffold(body: Text('list ${state.pathParameters['typeSegment']}')),
      ),
    ],
  );
  addTearDown(_router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: _container,
      child: MaterialApp.router(
        routerConfig: _router,
        theme: buildAppTheme(
          brightness: Brightness.light,
          platform: TargetPlatform.windows,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

DocumentEditorController _controllerFor(String id) =>
    _container.read(documentEditorControllerProvider(id).notifier);

SaveStatus _saveStatusOf(String id) => _container
    .read(documentEditorControllerProvider(id))
    .requireValue
    .saveStatus;

Future<void> _pressChord(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool shift = false,
}) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

BusinessDocument _lockedQuotation() =>
    buildTestDocument(lockedAt: DateTime.utc(2026, 10, 17, 10));

BusinessDocument _salesOrder() => buildTestDocument(
  type: DocumentType.salesOrder,
  documentId: 'so-1',
  sourceDocumentId: 'doc-1',
);

void main() {
  testWidgets('tapping + Sales order upgrades and navigates to new document', (
    tester,
  ) async {
    await _pump(tester, [buildTestDocument()]);

    await tester.tap(find.text('+ Sales order'));
    await tester.pumpAndSettle();

    final created = _documents.storedDocuments.singleWhere(
      (document) => document.documentType == DocumentType.salesOrder,
    );
    expect(created.documentNumber, 'SO-2026-0001');
    expect(_location, '/documents/${created.documentId}');
    expect(
      _documents.storedDocuments
          .singleWhere((document) => document.documentId == 'doc-1')
          .isLocked,
      isTrue,
    );
  });

  testWidgets('upgrading saves pending edits first', (tester) async {
    await _pump(tester, [buildTestDocument()]);
    _controllerFor('doc-1').updateNotes('typed just now');

    await tester.tap(find.text('Upgrade to sales order'));
    await tester.pumpAndSettle();

    final created = _documents.storedDocuments.singleWhere(
      (document) => document.documentType == DocumentType.salesOrder,
    );
    expect(created.notes, 'typed just now');
    expect(_location, '/documents/${created.documentId}');
  });

  testWidgets('a failed save stops the upgrade and says why', (tester) async {
    await _pump(tester, [buildTestDocument()]);
    _controllerFor('doc-1').updateNotes('typed just now');
    _documents.failNextSave = true;

    await tester.tap(find.text('Upgrade to sales order'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't save — fix this before upgrading"),
      findsOneWidget,
    );
    expect(_location, '/documents/doc-1');
    expect(
      _documents.storedDocuments.any(
        (document) => document.documentType == DocumentType.salesOrder,
      ),
      isFalse,
    );
    _controllerFor('doc-1').discardPendingChanges();
  });

  testWidgets(
    'Upgrade button disabled with blocker tooltip when chain has SO',
    (tester) async {
      await _pump(tester, [_lockedQuotation(), _salesOrder()]);

      final button = find.widgetWithText(TextButton, 'Upgrade to sales order');
      expect(tester.widget<TextButton>(button).onPressed, isNull);
      expect(
        find.byTooltip('This chain already has a sales order'),
        findsOneWidget,
      );
      expect(find.text('+ Sales order'), findsNothing);
    },
  );

  testWidgets('delivery orders have no Upgrade button', (tester) async {
    await _pump(tester, [
      _lockedQuotation(),
      _salesOrder(),
      buildTestDocument(
        type: DocumentType.deliveryOrder,
        documentId: 'do-1',
        sourceDocumentId: 'so-1',
      ),
    ], openId: 'do-1');
    expect(find.textContaining('Upgrade to'), findsNothing);
  });

  testWidgets('Ctrl+S calls saveNow', (tester) async {
    await _pump(tester, [buildTestDocument()]);
    _controllerFor('doc-1').updateNotes('edited');
    expect(_saveStatusOf('doc-1'), SaveStatus.pending);

    await _pressChord(tester, LogicalKeyboardKey.keyS);

    expect(_saveStatusOf('doc-1'), SaveStatus.saved);
    expect(_documents.storedDocuments.single.notes, 'edited');
  });

  testWidgets('Ctrl+S works while a page field is focused', (tester) async {
    await _pump(tester, [buildTestDocument()]);
    final field = find.byType(EditableText).first;
    await tester.tap(field);
    await tester.pump();
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<EditableText>(),
      isNotNull,
    );
    await tester.enterText(field, 'Typed in a field');

    await _pressChord(tester, LogicalKeyboardKey.keyS);

    expect(_saveStatusOf('doc-1'), SaveStatus.saved);
    expect(_documents.saveCount, 1);
  });

  testWidgets('Ctrl+Shift+U upgrades the document', (tester) async {
    await _pump(tester, [buildTestDocument()]);

    await _pressChord(tester, LogicalKeyboardKey.keyU, shift: true);

    expect(
      _documents.storedDocuments.any(
        (document) => document.documentType == DocumentType.salesOrder,
      ),
      isTrue,
    );
    expect(_location, isNot('/documents/doc-1'));
  });

  testWidgets('Ctrl+N creates a document of the same type and opens it', (
    tester,
  ) async {
    await _pump(tester, [buildTestDocument()]);

    await _pressChord(tester, LogicalKeyboardKey.keyN);

    final created = _documents.storedDocuments.singleWhere(
      (document) => document.documentId != 'doc-1',
    );
    expect(created.documentType, DocumentType.quotation);
    expect(_location, '/documents/${created.documentId}');
  });

  testWidgets('Duplicate saves, copies and opens the new draft', (
    tester,
  ) async {
    await _pump(tester, [buildTestDocument()]);

    await tester.tap(find.widgetWithText(TextButton, 'Duplicate'));
    await tester.pumpAndSettle();

    final copy = _documents.storedDocuments.singleWhere(
      (document) => document.documentId != 'doc-1',
    );
    expect(copy.chainId, isNot('chain-1'));
    expect(_location, '/documents/${copy.documentId}');
  });

  testWidgets('the locked banner duplicates as a new draft', (tester) async {
    await _pump(tester, [_lockedQuotation(), _salesOrder()]);

    await tester.tap(find.text('Duplicate as new draft'));
    await tester.pumpAndSettle();

    expect(_documents.storedDocuments, hasLength(3));
    expect(_location, isNot('/documents/doc-1'));
  });

  testWidgets('Delete confirms, deletes the draft and returns to the list', (
    tester,
  ) async {
    await _pump(tester, [buildTestDocument()]);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(
      find.text("Delete QT-2026-0001? This can't be undone."),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(_documents.storedDocuments, isEmpty);
    expect(_location, '/quotations');
  });

  testWidgets('cancelling the delete dialog keeps the document', (
    tester,
  ) async {
    await _pump(tester, [buildTestDocument()]);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(_documents.storedDocuments, hasLength(1));
    expect(_location, '/documents/doc-1');
  });

  testWidgets('locked documents have no Delete button', (tester) async {
    await _pump(tester, [_lockedQuotation(), _salesOrder()]);
    expect(find.widgetWithText(TextButton, 'Delete'), findsNothing);
  });

  testWidgets('command tooltips show their shortcuts', (tester) async {
    await _pump(tester, [buildTestDocument()]);
    expect(find.byTooltip('Save (Ctrl+S)'), findsOneWidget);
    expect(
      find.byTooltip('Upgrade to sales order (Ctrl+Shift+U)'),
      findsOneWidget,
    );
  });
}
