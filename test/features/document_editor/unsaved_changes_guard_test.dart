import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_provider_overrides.dart';

import 'package:pacim_invoicer/app/app_router.dart';
import 'package:pacim_invoicer/app/pacim_invoicer_app.dart';
import 'package:pacim_invoicer/app/shell/navigation_leave_guard.dart';
import 'package:pacim_invoicer/app/shell/status_bar_message_provider.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_controller.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_state.dart';
import 'package:pacim_invoicer/features/document_editor/unsaved_changes_guard.dart';

import '../../support/document_builders.dart';
import '../../support/fake_repositories.dart';

const _documentId = 'doc-1';

class _FakeWindowCloseInterceptor implements WindowCloseInterceptor {
  Future<void> Function()? onCloseRequested;
  bool isIntercepting = false;
  int closeWindowCalls = 0;

  @override
  Future<void> startIntercepting(
    Future<void> Function() onCloseRequested,
  ) async {
    this.onCloseRequested = onCloseRequested;
    isIntercepting = true;
  }

  @override
  Future<void> stopIntercepting(
    Future<void> Function() onCloseRequested,
  ) async {
    this.onCloseRequested = null;
    isIntercepting = false;
  }

  @override
  Future<void> closeWindow() async => closeWindowCalls++;
}

late ProviderContainer _container;
late FakeDocumentRepository _documents;
late _FakeWindowCloseInterceptor _window;

/// Opens the guarded editor on top of a home page, so it can be popped.
Future<void> _pumpGuardedEditor(
  WidgetTester tester, {
  FakeDocumentRepository? repository,
}) async {
  _documents = repository ?? FakeDocumentRepository();
  _documents.seed(buildTestDocument());
  _window = _FakeWindowCloseInterceptor();
  _container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      ...fakeStorageOverrides(documents: _documents),
      clockProvider.overrideWithValue(() => DateTime(2026, 10, 17)),
      windowCloseInterceptorProvider.overrideWithValue(_window),
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
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const UnsavedChangesGuard(
                      documentId: _documentId,
                      child: Scaffold(body: Text('editor body')),
                    ),
                  ),
                ),
                child: const Text('open editor'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open editor'));
  await tester.pumpAndSettle();
}

DocumentEditorController get _controller =>
    _container.read(documentEditorControllerProvider(_documentId).notifier);

SaveStatus get _saveStatus => _container
    .read(documentEditorControllerProvider(_documentId))
    .requireValue
    .saveStatus;

Future<void> _tryToLeave(WidgetTester tester) async {
  await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
  await tester.pumpAndSettle();
}

/// Makes an edit whose autosave fails, leaving the status `failed`.
Future<void> _makeEditWithFailedSave(WidgetTester tester) async {
  _documents.failNextSave = true;
  _controller.updateNotes('edited');
  await tester.pump(const Duration(seconds: 3));
  await tester.pump();
  expect(_saveStatus, SaveStatus.failed);
}

/// Every save is followed by another edit, so the editor never settles.
class _EditsAfterEverySaveRepository extends FakeDocumentRepository {
  int editCount = 0;

  @override
  Future<void> saveDocument(BusinessDocument document) async {
    await super.saveDocument(document);
    _controller.updateNotes('edit ${editCount++}');
  }
}

void main() {
  testWidgets('hitting the save attempt cap reports it in the status bar', (
    tester,
  ) async {
    await _pumpGuardedEditor(
      tester,
      repository: _EditsAfterEverySaveRepository(),
    );
    _controller.updateNotes('edited');

    await _tryToLeave(tester);

    expect(find.text('editor body'), findsOneWidget);
    expect(
      _container.read(statusBarMessageProvider),
      "Couldn't save. Your changes are still here.",
    );
    // Stops the autosave timer the last edit started.
    _controller.discardPendingChanges();
  });

  testWidgets('a second leave request while one is open shares its dialog', (
    tester,
  ) async {
    await _pumpGuardedEditor(tester);
    await _makeEditWithFailedSave(tester);
    final registry = _container.read(navigationLeaveGuardProvider);

    final first = registry.confirmLeaving();
    final second = registry.confirmLeaving();
    await tester.pumpAndSettle();
    expect(find.text('Save changes before leaving?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await first, isFalse);
    expect(await second, isFalse);
    expect(find.text('Save changes before leaving?'), findsNothing);
  });

  testWidgets('leaving with pending edits saves before navigating', (
    tester,
  ) async {
    await _pumpGuardedEditor(tester);
    _controller.updateNotes('edited');
    expect(_saveStatus, SaveStatus.pending);

    await _tryToLeave(tester);

    expect(find.text('editor body'), findsNothing);
    expect(find.text('open editor'), findsOneWidget);
    expect(_documents.saveCount, 1);
    expect(_documents.storedDocuments.single.notes, 'edited');
  });

  testWidgets('leaving with nothing to save navigates straight away', (
    tester,
  ) async {
    await _pumpGuardedEditor(tester);
    await _tryToLeave(tester);
    expect(find.text('editor body'), findsNothing);
    expect(_documents.saveCount, 0);
  });

  testWidgets('leaving with failed save shows dialog', (tester) async {
    await _pumpGuardedEditor(tester);
    await _makeEditWithFailedSave(tester);

    await _tryToLeave(tester);

    expect(find.text('Save changes before leaving?'), findsOneWidget);
    expect(find.text('Retry save'), findsOneWidget);
    expect(find.text('Leave without saving'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('editor body'), findsOneWidget);
  });

  testWidgets('Cancel keeps the editor open', (tester) async {
    await _pumpGuardedEditor(tester);
    await _makeEditWithFailedSave(tester);
    await _tryToLeave(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Save changes before leaving?'), findsNothing);
    expect(find.text('editor body'), findsOneWidget);
  });

  testWidgets('Retry save saves and then leaves', (tester) async {
    await _pumpGuardedEditor(tester);
    await _makeEditWithFailedSave(tester);
    await _tryToLeave(tester);

    await tester.tap(find.text('Retry save'));
    await tester.pumpAndSettle();

    expect(_documents.storedDocuments.single.notes, 'edited');
    expect(find.text('editor body'), findsNothing);
  });

  testWidgets('Leave without saving discards the edits for good', (
    tester,
  ) async {
    await _pumpGuardedEditor(tester);
    await _makeEditWithFailedSave(tester);
    await _tryToLeave(tester);

    await tester.tap(find.text('Leave without saving'));
    await tester.pumpAndSettle();
    expect(find.text('editor body'), findsNothing);

    // Disposing the controller must not save the discarded edits either.
    _container.dispose();
    await tester.pump();
    await tester.pump();
    expect(_documents.storedDocuments.single.notes, 'Thank you.');
    expect(_documents.saveCount, 0);
  });

  testWidgets('a retry that fails again asks again', (tester) async {
    await _pumpGuardedEditor(tester);
    await _makeEditWithFailedSave(tester);
    await _tryToLeave(tester);

    _documents.failNextSave = true;
    await tester.tap(find.text('Retry save'));
    await tester.pumpAndSettle();

    expect(find.text('Save changes before leaving?'), findsOneWidget);
    expect(find.text('editor body'), findsOneWidget);
  });

  testWidgets('closing the window with pending edits saves then closes', (
    tester,
  ) async {
    await _pumpGuardedEditor(tester);
    expect(_window.isIntercepting, isTrue);
    _controller.updateNotes('edited');

    unawaited(_window.onCloseRequested!());
    await tester.pumpAndSettle();

    expect(_documents.storedDocuments.single.notes, 'edited');
    expect(_window.closeWindowCalls, 1);
  });

  testWidgets('closing the window after a failed save asks first', (
    tester,
  ) async {
    await _pumpGuardedEditor(tester);
    await _makeEditWithFailedSave(tester);

    unawaited(_window.onCloseRequested!());
    await tester.pumpAndSettle();
    expect(find.text('Save changes before leaving?'), findsOneWidget);
    expect(_window.closeWindowCalls, 0);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(_window.closeWindowCalls, 0);
  });

  testWidgets('leaving the editor stops intercepting window close', (
    tester,
  ) async {
    await _pumpGuardedEditor(tester);
    await _tryToLeave(tester);
    expect(_window.isIntercepting, isFalse);
  });

  testWidgets('hiding the app flushes pending edits', (tester) async {
    await _pumpGuardedEditor(tester);
    _controller.updateNotes('edited');
    expect(_documents.saveCount, 0);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pumpAndSettle();

    expect(_documents.saveCount, 1);
    expect(_documents.storedDocuments.single.notes, 'edited');
  });

  testWidgets('a second editor taking over keeps close prevention on', (
    tester,
  ) async {
    final preventCloseCalls = <bool>[];
    var isWindowDestroyed = false;
    final documents = FakeDocumentRepository()
      ..seed(buildTestDocument())
      ..seed(buildTestDocument(documentId: 'doc-2'));
    final interceptor = StackedWindowCloseInterceptor(
      setPreventClose: ({required isPrevented}) async =>
          preventCloseCalls.add(isPrevented),
      destroyWindow: () async => isWindowDestroyed = true,
    );
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        ...fakeStorageOverrides(documents: documents),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 17)),
        windowCloseInterceptorProvider.overrideWithValue(interceptor),
      ],
    );
    addTearDown(container.dispose);
    final shownId = ValueNotifier('doc-1');
    addTearDown(shownId.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: ValueListenableBuilder<String>(
            valueListenable: shownId,
            builder: (context, id, _) => UnsavedChangesGuard(
              key: ValueKey(id),
              documentId: id,
              child: Text('editor $id'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(preventCloseCalls, [true]);

    shownId.value = 'doc-2';
    await tester.pumpAndSettle();

    expect(find.text('editor doc-2'), findsOneWidget);
    // The old editor leaving must not have switched prevention off.
    expect(preventCloseCalls, [true]);

    // Close requests reach the newest editor, which is clean and so closes.
    unawaited(interceptor.handleCloseRequested());
    await tester.pumpAndSettle();
    expect(isWindowDestroyed, isTrue);
  });

  testWidgets('choosing a sidebar destination with a failed save asks first', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final documents = FakeDocumentRepository()..seed(buildTestDocument());
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        ...fakeStorageOverrides(documents: documents),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 17)),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const PacimInvoicerApp(),
      ),
    );
    final router = container.read(appRouterProvider)..go('/documents/doc-1');
    await tester.pumpAndSettle();
    String path() => router.routeInformationProvider.value.uri.path;
    expect(path(), '/documents/doc-1');

    documents.failNextSave = true;
    container
        .read(documentEditorControllerProvider('doc-1').notifier)
        .updateNotes('edited');
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    await tester.tap(find.text('Sales orders'));
    await tester.pumpAndSettle();
    expect(find.text('Save changes before leaving?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(path(), '/documents/doc-1');

    await tester.tap(find.text('Sales orders'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry save'));
    await tester.pumpAndSettle();
    expect(path(), '/sales-orders');
    expect(documents.storedDocuments.single.notes, 'edited');
  });
}
