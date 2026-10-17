import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/app/shell/status_bar.dart';
import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/customer_details.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_controller.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_page.dart';
import 'package:pacim_invoicer/features/document_editor/line_item_grid/line_item_row.dart';
import 'package:pacim_invoicer/shared/document_page_metrics.dart';

import '../../support/document_builders.dart';
import '../../support/fake_repositories.dart';
import '../../support/test_provider_overrides.dart';

const _documentId = 'doc-1';
const _bothIssues =
    '2 issues: Customer name is empty; An item has a quantity of zero';

BusinessDocument _documentWithIssues() => buildTestDocument(
  lineItems: [
    buildTestLine(),
    buildTestLine(id: 'line-2', quantityScaled: 0),
  ],
).copyWith(customerDetails: const CustomerDetails(customerName: ''));

final _showsEditor = ValueNotifier<bool>(true);
late ProviderContainer _container;

Future<void> _pumpEditorWithStatusBar(
  WidgetTester tester,
  BusinessDocument document,
) async {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  _showsEditor.value = true;
  _container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      ...fakeStorageOverrides(
        documents: FakeDocumentRepository()..seed(document),
      ),
      clockProvider.overrideWithValue(() => DateTime(2026, 10, 18)),
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
          body: Column(
            children: [
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _showsEditor,
                  builder: (context, showsEditor, _) => showsEditor
                      ? const DocumentEditorPage(documentId: _documentId)
                      : const Text('elsewhere'),
                ),
              ),
              const StatusBar(),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The outline colour of the field's border box.
Color? _outlineColorWithin(WidgetTester tester, Finder field) {
  final boxes = tester.widgetList<DecoratedBox>(
    find.descendant(of: field, matching: find.byType(DecoratedBox)),
  );
  for (final box in boxes) {
    final decoration = box.decoration;
    if (decoration is BoxDecoration && decoration.border is Border) {
      return (decoration.border! as Border).top.color;
    }
  }
  return null;
}

Color _errorColor(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(StatusBar))).colorScheme.error;

void main() {
  testWidgets('the status bar lists the issues while the editor is open', (
    tester,
  ) async {
    await _pumpEditorWithStatusBar(tester, _documentWithIssues());
    expect(find.text(_bothIssues), findsOneWidget);

    final controller = _container.read(
      documentEditorControllerProvider(_documentId).notifier,
    );
    controller.updateCustomerDetails(
      const CustomerDetails(customerName: 'Acme'),
    );
    await tester.pump();
    expect(
      find.text('1 issue: An item has a quantity of zero'),
      findsOneWidget,
    );

    controller.updateLineItem(
      'line-2',
      (line) => line.copyWith(quantityScaled: 1000),
    );
    await tester.pump();
    expect(find.textContaining('issue'), findsNothing);
    await controller.saveNow();
  });

  testWidgets('leaving the editor clears its issues from the status bar', (
    tester,
  ) async {
    await _pumpEditorWithStatusBar(tester, _documentWithIssues());
    expect(find.text(_bothIssues), findsOneWidget);

    _showsEditor.value = false;
    await tester.pumpAndSettle();

    expect(find.textContaining('issue'), findsNothing);
  });

  testWidgets('an empty customer name has an error outline', (tester) async {
    await _pumpEditorWithStatusBar(tester, _documentWithIssues());

    final nameField = find.byKey(const ValueKey('customerName'));
    expect(_outlineColorWithin(tester, nameField), _errorColor(tester));
    expect(
      find.descendant(
        of: nameField,
        matching: find.byTooltip('Customer name is empty'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a zero quantity cell has an error outline and tooltip', (
    tester,
  ) async {
    await _pumpEditorWithStatusBar(tester, _documentWithIssues());

    final zeroCell = find.byKey(
      lineItemCellKey('line-2', LineItemColumn.quantity),
    );
    final filledCell = find.byKey(
      lineItemCellKey('line-1', LineItemColumn.quantity),
    );
    expect(_outlineColorWithin(tester, zeroCell), _errorColor(tester));
    expect(_outlineColorWithin(tester, filledCell), isNot(_errorColor(tester)));
    expect(find.byTooltip('An item has a quantity of zero'), findsOneWidget);
  });
}
