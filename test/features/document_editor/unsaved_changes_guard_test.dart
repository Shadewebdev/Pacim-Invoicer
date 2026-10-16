import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
  Future<void> stopIntercepting() async {
    onCloseRequested = null;
    isIntercepting = false;
  }

  @override
  Future<void> closeWindow() async => closeWindowCalls++;
}

late ProviderContainer _container;
late FakeDocumentRepository _documents;
late _FakeWindowCloseInterceptor _window;

/// Opens the guarded editor on top of a home page, so it can be popped.
Future<void> _pumpGuardedEditor(WidgetTester tester) async {
  _documents = FakeDocumentRepository()..seed(buildTestDocument());
  _window = _FakeWindowCloseInterceptor();
  _container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      documentRepositoryProvider.overrideWithValue(_documents),
      settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
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

void main() {
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

  testWidgets('Leave without saving leaves with the failed status', (
    tester,
  ) async {
    await _pumpGuardedEditor(tester);
    await _makeEditWithFailedSave(tester);
    await _tryToLeave(tester);

    await tester.tap(find.text('Leave without saving'));
    await tester.pumpAndSettle();

    expect(find.text('editor body'), findsNothing);
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
}
