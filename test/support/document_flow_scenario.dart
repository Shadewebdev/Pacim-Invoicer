import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/app/pacim_invoicer_app.dart';
import 'package:pacim_invoicer/features/document_editor/chain_breadcrumb/chain_breadcrumb.dart';
import 'package:pacim_invoicer/features/document_editor/line_item_grid/line_item_grid.dart';
import 'package:pacim_invoicer/features/pdf_export/pdf_export_service.dart';
import 'package:pacim_invoicer/shared/document_page_metrics.dart';

import 'fake_pdf_output_target.dart';
import 'test_provider_overrides.dart';

/// Walks the whole product flow through the real app with in-memory storage:
/// quotation, customer and items, upgrade, two partial deliveries, breadcrumb
/// navigation and a PDF export. Shared by the integration test and the
/// regular widget test, so CI runs it without a device.
Future<void> runDocumentFlowScenario(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final pdfTarget = FakePdfOutputTarget();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...fakeStorageOverrides(),
        pdfOutputTargetProvider.overrideWithValue(pdfTarget),
        sharesPdfInsteadOfSavingProvider.overrideWithValue(false),
        pdfDocumentBuilderProvider.overrideWithValue(fakePdfBuilder),
      ],
      child: const PacimInvoicerApp(),
    ),
  );
  await tester.pumpAndSettle();

  // 1. Create a quotation, set the customer and add two items.
  await tester.tap(find.text('New quotation').first);
  await tester.pumpAndSettle();
  await _typeInto(
    tester,
    find.byKey(const ValueKey('customerName')),
    'Acme Trading',
  );

  final firstLineId = _lineIdsOnPage(tester).single;
  await _fillLine(
    tester,
    firstLineId,
    description: 'Steel bracket',
    quantity: '10',
    unitPrice: '12.50',
  );
  // Enter on the last row's cells adds a row and focuses its description.
  await tester.tap(_cellField(firstLineId, LineItemColumn.unitPrice));
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
  final secondLineId = _lineIdsOnPage(tester).last;
  expect(secondLineId, isNot(firstLineId));
  await _fillLine(
    tester,
    secondLineId,
    description: 'Mounting plate',
    quantity: '5',
    unitPrice: '30',
  );
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
  expect(find.text('Saved'), findsOneWidget);

  // 2. Upgrade to a sales order; the quotation is locked.
  await tester.tap(find.text('Upgrade to sales order'));
  await tester.pumpAndSettle();
  expect(find.text('Sales order'), findsWidgets);
  final breadcrumbChips = find.descendant(
    of: find.byType(ChainBreadcrumb),
    matching: find.textContaining(RegExp(r'^(QT|SO|DO)-')),
  );
  expect(breadcrumbChips, findsNWidgets(2));
  final quotationNumber = _textOf(tester, breadcrumbChips.first);
  final salesOrderNumber = _textOf(tester, breadcrumbChips.last);

  await tester.tap(find.text('Quotations').first);
  await tester.pumpAndSettle();
  expect(find.text('Locked'), findsOneWidget);
  expect(find.text('Acme Trading'), findsOneWidget);

  // 3. Create two partial delivery orders and check what is left.
  await tester.tap(find.text('Sales orders').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Acme Trading'));
  // A single tap waits out the double-tap window before focusing the row.
  await tester.pump(const Duration(milliseconds: 400));
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
  await tester.tap(find.text('+ Delivery order'));
  await tester.pumpAndSettle();
  var lineIds = _lineIdsOnPage(tester);
  expect(_quantityText(tester, lineIds[0]), '10');
  expect(_quantityText(tester, lineIds[1]), '5');
  await _typeInto(tester, _cellField(lineIds[0], LineItemColumn.quantity), '4');
  await _typeInto(tester, _cellField(lineIds[1], LineItemColumn.quantity), '2');
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('+ Delivery order'));
  await tester.pumpAndSettle();
  lineIds = _lineIdsOnPage(tester);
  // 10 - 4 and 5 - 2 are left to deliver on the second order.
  expect(_quantityText(tester, lineIds[0]), '6');
  expect(_quantityText(tester, lineIds[1]), '3');
  await _typeInto(tester, _cellField(lineIds[0], LineItemColumn.quantity), '7');
  expect(find.text('Only 6 left to deliver'), findsOneWidget);
  await _typeInto(tester, _cellField(lineIds[0], LineItemColumn.quantity), '6');
  expect(find.textContaining('left to deliver'), findsNothing);
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
  expect(find.text('Saved'), findsOneWidget);

  // 4. Navigate through the breadcrumb.
  await tester.tap(
    find.descendant(
      of: find.byType(ChainBreadcrumb),
      matching: find.text(quotationNumber),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.textContaining('is locked because'), findsOneWidget);
  await tester.tap(
    find.descendant(
      of: find.byType(ChainBreadcrumb),
      matching: find.text(salesOrderNumber),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.textContaining('is locked because'), findsOneWidget);
  // The page header and the breadcrumb chip both show the sales order.
  expect(find.text(salesOrderNumber), findsNWidgets(2));

  // 5. Export a PDF through the fake output target.
  await tester.tap(find.text('Export PDF'));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
  if (find.text('Export anyway').evaluate().isNotEmpty) {
    await tester.tap(find.text('Export anyway'));
    await tester.pumpAndSettle();
  }
  expect(pdfTarget.outputs, hasLength(1));
}

Finder _cellField(String lineItemId, LineItemColumn column) => find.descendant(
  of: find.byKey(LineItemGrid.cellKey(lineItemId, column)),
  matching: find.byType(EditableText),
);

Future<void> _fillLine(
  WidgetTester tester,
  String lineItemId, {
  required String description,
  required String quantity,
  required String unitPrice,
}) async {
  await _typeInto(
    tester,
    _cellField(lineItemId, LineItemColumn.description),
    description,
  );
  await _typeInto(
    tester,
    _cellField(lineItemId, LineItemColumn.quantity),
    quantity,
  );
  await _typeInto(
    tester,
    _cellField(lineItemId, LineItemColumn.unitPrice),
    unitPrice,
  );
}

String _quantityText(WidgetTester tester, String lineItemId) => tester
    .widget<EditableText>(_cellField(lineItemId, LineItemColumn.quantity))
    .controller
    .text;

String _textOf(WidgetTester tester, Finder finder) =>
    tester.widget<Text>(finder).data!;

/// The line item ids on the open page, in row order.
List<String> _lineIdsOnPage(WidgetTester tester) {
  const prefix = 'lineCell-';
  const suffix = '-description';
  final keys = find
      .byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> &&
            key.value.startsWith(prefix) &&
            key.value.endsWith(suffix);
      })
      .evaluate()
      .map((element) => (element.widget.key! as ValueKey<String>).value);
  return [
    for (final key in keys)
      key.substring(prefix.length, key.length - suffix.length),
  ];
}

/// Focuses [field], types [text] and commits it with the keyboard's Done key,
/// like a person would; a field that lost focus ignores plain enterText.
Future<void> _typeInto(WidgetTester tester, Finder field, String text) async {
  await tester.tap(field);
  await tester.pump();
  await tester.enterText(field, text);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}
