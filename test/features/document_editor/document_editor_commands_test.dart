import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/test_provider_overrides.dart';

import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/domain/exceptions/document_exceptions.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_controller.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_page.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_state.dart';
import 'package:pacim_invoicer/features/pdf_export/pdf_export_service.dart';
import 'package:pacim_invoicer/app/shell/status_bar_message_provider.dart';
import 'package:pacim_invoicer/domain/models/customer_details.dart';

import '../../support/document_builders.dart';
import '../../support/fake_pdf_output_target.dart';
import '../../support/fake_repositories.dart';
import '../../support/sequential_id_generator.dart';

late ProviderContainer _container;
late FakeDocumentRepository _documents;
late GoRouter _router;
late FakePdfOutputTarget _pdfTarget;

String get _location => _router.routerDelegate.currentConfiguration.uri.path;

Future<void> _pump(
  WidgetTester tester,
  List<BusinessDocument> seeded, {
  String openId = 'doc-1',
  FakeDocumentRepository? repository,
}) async {
  tester.view.physicalSize = const Size(1400, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  _documents = repository ?? FakeDocumentRepository();
  seeded.forEach(_documents.seed);
  _pdfTarget = FakePdfOutputTarget();
  _container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      ...fakeStorageOverrides(documents: _documents),
      pdfOutputTargetProvider.overrideWithValue(_pdfTarget),
      sharesPdfInsteadOfSavingProvider.overrideWithValue(false),
      pdfFontSetProvider.overrideWith((ref) async => fakePdfFontSet()),
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

/// Lets a PDF export finish. Building the PDF takes real time, which
/// pumpAndSettle does not wait for.
Future<void> _settleExport(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 1500)),
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

class _FailingUpgradeRepository extends FakeDocumentRepository {
  @override
  Future<void> saveUpgrade({
    required BusinessDocument lockedSource,
    required BusinessDocument createdDocument,
  }) => throw const StorageWriteException('fake upgrade failure');
}

class _FailingDeleteRepository extends FakeDocumentRepository {
  @override
  Future<void> deleteDocument(String documentId) =>
      throw const StorageWriteException('fake delete failure');
}

/// Makes an edit during each of the first [editedSaves] saves, so the editor
/// is still unsaved when the save returns.
class _EditsDuringSaveRepository extends FakeDocumentRepository {
  _EditsDuringSaveRepository({required this.editedSaves});

  final int editedSaves;
  int _saves = 0;

  @override
  Future<void> saveDocument(BusinessDocument document) async {
    await super.saveDocument(document);
    if (_saves++ < editedSaves) {
      _controllerFor(document.documentId)
          .updateNotes('edit during save $_saves');
    }
  }
}

class _GatedSaveRepository extends FakeDocumentRepository {
  final gate = Completer<void>();

  @override
  Future<void> saveDocument(BusinessDocument document) async {
    await gate.future;
    await super.saveDocument(document);
  }
}

class _GatedDeleteRepository extends FakeDocumentRepository {
  final gate = Completer<void>();

  @override
  Future<void> deleteDocument(String documentId) async {
    await gate.future;
    await super.deleteDocument(documentId);
  }
}

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

  testWidgets('Ctrl+S keeps working after the first flush moved focus', (
    tester,
  ) async {
    await _pump(tester, [buildTestDocument()]);
    await tester.tap(find.byType(EditableText).first);
    await tester.pump();
    await tester.enterText(find.byType(EditableText).first, 'First');

    await _pressChord(tester, LogicalKeyboardKey.keyS);
    expect(_documents.saveCount, 1);

    _controllerFor('doc-1').updateNotes('Second');
    await _pressChord(tester, LogicalKeyboardKey.keyS);
    expect(_documents.saveCount, 2);
    expect(_documents.storedDocuments.single.notes, 'Second');
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

  testWidgets('a failed upgrade names the document being upgraded', (
    tester,
  ) async {
    await _pump(tester, [
      _lockedQuotation(),
      _salesOrder().copyWith(documentNumber: 'SO-2026-0002'),
    ], repository: _FailingUpgradeRepository());

    await tester.tap(find.text('+ Delivery order'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't upgrade SO-2026-0002. Try again."),
      findsOneWidget,
    );
  });

  testWidgets('an edit landing during the save is flushed before upgrading', (
    tester,
  ) async {
    await _pump(tester, [
      buildTestDocument(),
    ], repository: _EditsDuringSaveRepository(editedSaves: 1));
    _controllerFor('doc-1').updateNotes('first');

    await tester.tap(find.text('Upgrade to sales order'));
    await tester.pumpAndSettle();

    final created = _documents.storedDocuments.singleWhere(
      (document) => document.documentType == DocumentType.salesOrder,
    );
    expect(created.notes, 'edit during save 1');
  });

  testWidgets('a save that never settles refuses the upgrade', (tester) async {
    await _pump(tester, [
      buildTestDocument(),
    ], repository: _EditsDuringSaveRepository(editedSaves: 100));
    _controllerFor('doc-1').updateNotes('first');

    await tester.tap(find.text('Upgrade to sales order'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't save — fix this before upgrading"),
      findsOneWidget,
    );
    expect(
      _documents.storedDocuments.any(
        (document) => document.documentType == DocumentType.salesOrder,
      ),
      isFalse,
    );
    _controllerFor('doc-1').discardPendingChanges();
  });

  testWidgets('a failed delete keeps the edits and says so', (tester) async {
    await _pump(tester, [
      buildTestDocument(),
    ], repository: _FailingDeleteRepository());
    _controllerFor('doc-1').updateNotes('keep me');

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't delete QT-2026-0001. Try again."),
      findsOneWidget,
    );
    expect(
      _container
          .read(documentEditorControllerProvider('doc-1'))
          .requireValue
          .document
          .notes,
      'keep me',
    );
    expect(_location, '/documents/doc-1');
    _controllerFor('doc-1').discardPendingChanges();
  });

  testWidgets('Ctrl+Shift+U does nothing while Upgrade is blocked', (
    tester,
  ) async {
    await _pump(tester, [_lockedQuotation(), _salesOrder()]);

    await _pressChord(tester, LogicalKeyboardKey.keyU, shift: true);

    expect(find.byType(SnackBar), findsNothing);
    expect(_documents.storedDocuments, hasLength(2));
    expect(_location, '/documents/doc-1');
  });

  testWidgets('deleting a draft with a pending edit never re-creates it', (
    tester,
  ) async {
    final repository = _GatedDeleteRepository();
    await _pump(tester, [buildTestDocument()], repository: repository);
    _controllerFor('doc-1').updateNotes('pending edit');

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pump();
    // The autosave delay passes while the delete is still in flight.
    await tester.pump(const Duration(seconds: 3));
    repository.gate.complete();
    await tester.pumpAndSettle();

    expect(repository.storedDocuments, isEmpty);
    expect(repository.saveCount, 0);
    expect(_location, '/quotations');
  });

  testWidgets('a save already in flight cannot bring a deleted draft back', (
    tester,
  ) async {
    final repository = _GatedSaveRepository();
    await _pump(tester, [buildTestDocument()], repository: repository);
    _controllerFor('doc-1').updateNotes('pending edit');
    unawaited(_controllerFor('doc-1').saveNow());
    await tester.pump();

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pump();
    repository.gate.complete();
    await tester.pumpAndSettle();

    expect(repository.storedDocuments, isEmpty);
    expect(_location, '/quotations');
  });

  group('PDF export', () {
    BusinessDocument noCustomer() =>
        buildTestDocument().copyWith(customerDetails: const CustomerDetails());

    String? statusMessage() => _container.read(statusBarMessageProvider);

    testWidgets('export with issues shows dialog listing messages', (
      tester,
    ) async {
      await _pump(tester, [noCustomer()]);

      await tester.tap(find.widgetWithText(TextButton, 'Export PDF'));
      await _settleExport(tester);

      expect(find.text('Export with issues?'), findsOneWidget);
      expect(find.text('Customer name is empty'), findsOneWidget);
      expect(_pdfTarget.savedNames, isEmpty);

      await tester.tap(find.widgetWithText(FilledButton, 'Export anyway'));
      await _settleExport(tester);

      expect(_pdfTarget.savedNames, ['QT-2026-0001.pdf']);
      expect(statusMessage(), 'Exported QT-2026-0001.pdf');
    });

    testWidgets('cancelling the issues dialog exports nothing', (tester) async {
      await _pump(tester, [noCustomer()]);

      await tester.tap(find.widgetWithText(TextButton, 'Export PDF'));
      await _settleExport(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(_pdfTarget.outputs, isEmpty);
      expect(statusMessage(), isNull);
    });

    testWidgets('a clean document exports without asking', (tester) async {
      await _pump(tester, [buildTestDocument()]);

      await tester.tap(find.widgetWithText(TextButton, 'Export PDF'));
      await _settleExport(tester);

      expect(find.text('Export with issues?'), findsNothing);
      expect(_pdfTarget.savedNames, ['QT-2026-0001 Acme Trading.pdf']);
      expect(statusMessage(), 'Exported QT-2026-0001 Acme Trading.pdf');
    });

    testWidgets('Ctrl+P exports and saves just-typed edits first', (
      tester,
    ) async {
      await _pump(tester, [buildTestDocument()]);
      _controllerFor('doc-1').updateNotes('typed just now');

      await _pressChord(tester, LogicalKeyboardKey.keyP);
      await _settleExport(tester);

      expect(_pdfTarget.savedNames, hasLength(1));
      expect(_documents.storedDocuments.single.notes, 'typed just now');
    });

    testWidgets('cancelling the save dialog shows nothing', (tester) async {
      await _pump(tester, [buildTestDocument()]);
      _pdfTarget.saveSucceeds = false;

      await tester.tap(find.widgetWithText(TextButton, 'Export PDF'));
      await _settleExport(tester);

      expect(statusMessage(), isNull);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a failed export says so', (tester) async {
      await _pump(tester, [buildTestDocument()]);
      _pdfTarget.failSave = true;

      await tester.tap(find.widgetWithText(TextButton, 'Export PDF'));
      await _settleExport(tester);

      expect(find.text("Couldn't export QT-2026-0001"), findsOneWidget);
      expect(statusMessage(), isNull);
    });

    testWidgets('Print sends the PDF to the printer and shows no message', (
      tester,
    ) async {
      await _pump(tester, [buildTestDocument()]);

      await tester.tap(find.widgetWithText(TextButton, 'Print'));
      await _settleExport(tester);

      expect(_pdfTarget.printedNames, ['QT-2026-0001 Acme Trading.pdf']);
      expect(statusMessage(), isNull);
    });
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
    expect(find.byTooltip('Export PDF (Ctrl+P)'), findsOneWidget);
    expect(
      find.byTooltip('Upgrade to sales order (Ctrl+Shift+U)'),
      findsOneWidget,
    );
  });
}
