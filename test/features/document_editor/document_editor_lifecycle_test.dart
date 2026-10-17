import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_controller.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_page.dart';

import '../../support/document_builders.dart';
import '../../support/fake_repositories.dart';
import '../../support/test_provider_overrides.dart';

const _documentId = 'doc-1';

class _Harness {
  final documents = WatchCountingDocumentRepository()
    ..seed(buildTestDocument());
  final showsEditor = ValueNotifier<bool>(true);
  late final ProviderContainer container;

  bool get controllerExists =>
      container.exists(documentEditorControllerProvider(_documentId));

  DocumentEditorController get controller =>
      container.read(documentEditorControllerProvider(_documentId).notifier);

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        ...fakeStorageOverrides(documents: documents),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 18)),
      ],
    );
    addTearDown(container.dispose);
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
              valueListenable: showsEditor,
              builder: (context, showsEditor, _) => showsEditor
                  ? const DocumentEditorPage(documentId: _documentId)
                  : const Text('elsewhere'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> leave(WidgetTester tester) async {
    showsEditor.value = false;
    await tester.pumpAndSettle();
  }

  Future<void> comeBack(WidgetTester tester) async {
    showsEditor.value = true;
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('leaving the editor disposes its controller and stops watching', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.pump(tester);
    expect(harness.controllerExists, isTrue);
    expect(harness.documents.openDocumentWatches, 1);

    await harness.leave(tester);

    expect(harness.controllerExists, isFalse);
    expect(harness.documents.openDocumentWatches, 0);
    expect(harness.documents.openChainWatches, 0);
  });

  testWidgets('a pending edit is saved when the editor unmounts', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.pump(tester);

    harness.controller.updateNotes('typed just before leaving');
    await harness.leave(tester);

    expect(
      (await harness.documents.getDocument(_documentId)).notes,
      'typed just before leaving',
    );
  });

  testWidgets('a document deleted while open shows that it no longer exists', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.pump(tester);

    await harness.documents.deleteDocument(_documentId);
    await tester.pumpAndSettle();

    expect(find.text('This document no longer exists'), findsOneWidget);
  });

  testWidgets('returning to a document deleted meanwhile shows it is gone', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.pump(tester);
    await harness.leave(tester);

    await harness.documents.deleteDocument(_documentId);
    await harness.comeBack(tester);

    expect(find.text('This document no longer exists'), findsOneWidget);
  });
}
