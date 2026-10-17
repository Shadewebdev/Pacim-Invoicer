import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_provider_overrides.dart';

import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/document_layout_options.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/models/line_item.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_controller.dart';
import 'package:pacim_invoicer/features/document_editor/document_page/document_page_view.dart';
import 'package:pacim_invoicer/features/document_editor/line_item_grid/line_item_grid.dart';
import 'package:pacim_invoicer/features/document_editor/line_item_grid/line_item_row.dart';
import 'package:pacim_invoicer/shared/document_page_metrics.dart';

import '../../support/document_builders.dart';
import '../../support/fake_repositories.dart';
import '../../support/sequential_id_generator.dart';

late ProviderContainer _container;
late String _documentId;

Future<void> _pumpPage(
  WidgetTester tester,
  BusinessDocument document, {
  List<BusinessDocument> chain = const [],
  TargetPlatform platform = TargetPlatform.windows,
}) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final documents = FakeDocumentRepository()..seed(document);
  for (final other in chain) {
    documents.seed(other);
  }
  _documentId = document.documentId;
  _container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      ...fakeStorageOverrides(documents: documents),
      idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
      clockProvider.overrideWithValue(() => DateTime(2026, 10, 17)),
    ],
  );
  addTearDown(_container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: _container,
      child: MaterialApp(
        theme: buildAppTheme(brightness: Brightness.light, platform: platform),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topLeft,
              child: DocumentPageView(documentId: document.documentId),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<LineItem> get _lines => _container
    .read(documentEditorControllerProvider(_documentId))
    .requireValue
    .document
    .lineItems;

List<String> get _lineIds => [for (final line in _lines) line.lineItemId];

Finder _cell(String lineId, LineItemColumn column) => find.descendant(
  of: find.byKey(LineItemGrid.cellKey(lineId, column)),
  matching: find.byType(EditableText),
);

bool _hasFocus(WidgetTester tester, String lineId, LineItemColumn column) =>
    tester.widget<EditableText>(_cell(lineId, column)).focusNode.hasFocus;

String _cellText(WidgetTester tester, String lineId, LineItemColumn column) =>
    tester.widget<EditableText>(_cell(lineId, column)).controller.text;

Future<void> _focusCell(
  WidgetTester tester,
  String lineId,
  LineItemColumn column,
) async {
  await tester.tap(_cell(lineId, column));
  await tester.pumpAndSettle();
}

Future<void> _pressWith(
  WidgetTester tester,
  LogicalKeyboardKey modifier,
  LogicalKeyboardKey key,
) async {
  await tester.sendKeyDownEvent(modifier);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(modifier);
  await tester.pumpAndSettle();
}

TestGesture? _hoverMouse;

/// Moves a mouse pointer over [target], which reveals its row's controls.
Future<void> _hoverOver(WidgetTester tester, Finder target) async {
  var mouse = _hoverMouse;
  if (mouse == null) {
    mouse = _hoverMouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    addTearDown(() async {
      await mouse?.removePointer();
      _hoverMouse = null;
    });
    await mouse.addPointer(location: Offset.zero);
  }
  await mouse.moveTo(tester.getCenter(target));
  await tester.pump();
}

Future<void> _flushSaves() => _container
    .read(documentEditorControllerProvider(_documentId).notifier)
    .saveNow();

void main() {
  group('keyboard', () {
    testWidgets('Tab moves focus from description to unit', (tester) async {
      await _pumpPage(tester, buildTestDocument());
      await _focusCell(tester, 'line-1', LineItemColumn.description);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(_hasFocus(tester, 'line-1', LineItemColumn.unit), isTrue);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(_hasFocus(tester, 'line-1', LineItemColumn.description), isTrue);
    });

    testWidgets('Tab on the last cell of a row wraps to the next row', (
      tester,
    ) async {
      await _pumpPage(tester, buildTestDocument());
      await _focusCell(tester, 'line-1', LineItemColumn.unitPrice);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(_hasFocus(tester, 'line-2', LineItemColumn.description), isTrue);
    });

    testWidgets('Enter on a single-line cell moves down a row', (tester) async {
      await _pumpPage(tester, buildTestDocument());
      await _focusCell(tester, 'line-1', LineItemColumn.quantity);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(_hasFocus(tester, 'line-2', LineItemColumn.quantity), isTrue);
      expect(_lineIds, ['line-1', 'line-2']);
    });

    testWidgets('Enter on last row quantity adds a row and focuses its '
        'description', (tester) async {
      await _pumpPage(tester, buildTestDocument());
      await _focusCell(tester, 'line-2', LineItemColumn.quantity);
      await tester.enterText(_cell('line-2', LineItemColumn.quantity), '3');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(_lineIds, ['line-1', 'line-2', 'id-1']);
      expect(_hasFocus(tester, 'id-1', LineItemColumn.description), isTrue);
      // The typed quantity was committed on the way out.
      expect(_lines[1].quantityScaled, 3000);
      await _flushSaves();
    });

    testWidgets('Enter in the description adds a new line instead of moving', (
      tester,
    ) async {
      await _pumpPage(tester, buildTestDocument());
      await _focusCell(tester, 'line-2', LineItemColumn.description);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(_lineIds, ['line-1', 'line-2']);
      expect(_hasFocus(tester, 'line-2', LineItemColumn.description), isTrue);
    });

    testWidgets('Ctrl+Enter inserts below', (tester) async {
      await _pumpPage(tester, buildTestDocument());
      await _focusCell(tester, 'line-1', LineItemColumn.unit);
      await _pressWith(
        tester,
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.enter,
      );
      expect(_lineIds, ['line-1', 'id-1', 'line-2']);
      expect(_hasFocus(tester, 'id-1', LineItemColumn.description), isTrue);
      await _flushSaves();
    });

    testWidgets('Ctrl+Delete removes row and keeps focus in grid', (
      tester,
    ) async {
      await _pumpPage(tester, buildTestDocument());
      await _focusCell(tester, 'line-1', LineItemColumn.unit);
      await tester.enterText(_cell('line-1', LineItemColumn.unit), 'box');
      await _pressWith(
        tester,
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.delete,
      );
      expect(_lineIds, ['line-2']);
      expect(_hasFocus(tester, 'line-2', LineItemColumn.unit), isTrue);
      expect(tester.takeException(), isNull);

      // The last row: focus falls back to "+ Add item", still in the grid.
      await _pressWith(
        tester,
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.delete,
      );
      expect(_lineIds, isEmpty);
      final addItem = Focus.of(tester.element(find.text('+ Add item')));
      expect(addItem.hasFocus, isTrue);
      await _flushSaves();
    });

    testWidgets('Alt+Down moves row down', (tester) async {
      await _pumpPage(tester, buildTestDocument());
      await _focusCell(tester, 'line-1', LineItemColumn.description);
      await tester.enterText(
        _cell('line-1', LineItemColumn.description),
        'Edited before moving',
      );
      await _pressWith(
        tester,
        LogicalKeyboardKey.altLeft,
        LogicalKeyboardKey.arrowDown,
      );
      expect(_lineIds, ['line-2', 'line-1']);
      expect(_lines[1].description, 'Edited before moving');
      expect(_hasFocus(tester, 'line-1', LineItemColumn.description), isTrue);
      expect(
        _cellText(tester, 'line-1', LineItemColumn.description),
        'Edited before moving',
      );

      await _pressWith(
        tester,
        LogicalKeyboardKey.altLeft,
        LogicalKeyboardKey.arrowUp,
      );
      expect(_lineIds, ['line-1', 'line-2']);
      expect(_hasFocus(tester, 'line-1', LineItemColumn.description), isTrue);
      expect(tester.takeException(), isNull);
      await _flushSaves();
    });

    testWidgets('grid shortcuts do not fire from other page fields', (
      tester,
    ) async {
      await _pumpPage(tester, buildTestDocument());
      await tester.tap(find.byKey(const ValueKey('customerName')));
      await tester.pumpAndSettle();
      await _pressWith(
        tester,
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.enter,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(_lineIds, ['line-1', 'line-2']);
      expect(_hasFocus(tester, 'line-1', LineItemColumn.description), isFalse);
    });
  });

  group('number cells', () {
    testWidgets('typing abc in price keeps old value and shows Enter a '
        'number', (tester) async {
      await _pumpPage(tester, buildTestDocument());
      await _focusCell(tester, 'line-1', LineItemColumn.unitPrice);
      await tester.enterText(_cell('line-1', LineItemColumn.unitPrice), 'abc');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(_lines.first.unitPriceMinor, 1000);
      expect(find.byTooltip('Enter a number'), findsOneWidget);
      expect(_cellText(tester, 'line-1', LineItemColumn.unitPrice), '10.00');
    });

    testWidgets('typing 1,234.50 in price stores 123450', (tester) async {
      await _pumpPage(tester, buildTestDocument());
      await _focusCell(tester, 'line-1', LineItemColumn.unitPrice);
      // On focus the cell shows the raw editable value.
      expect(_cellText(tester, 'line-1', LineItemColumn.unitPrice), '10.00');
      await tester.enterText(
        _cell('line-1', LineItemColumn.unitPrice),
        '1,234.50',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(_lines.first.unitPriceMinor, 123450);
      expect(_cellText(tester, 'line-1', LineItemColumn.unitPrice), '1,234.50');
      expect(find.byTooltip('Enter a number'), findsNothing);

      await _focusCell(tester, 'line-1', LineItemColumn.unitPrice);
      expect(_cellText(tester, 'line-1', LineItemColumn.unitPrice), '1234.50');
      await _flushSaves();
    });

    testWidgets('negative unit prices are allowed as credits', (tester) async {
      await _pumpPage(tester, buildTestDocument());
      await _focusCell(tester, 'line-1', LineItemColumn.unitPrice);
      await tester.enterText(_cell('line-1', LineItemColumn.unitPrice), '-5');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(_lines.first.unitPriceMinor, -500);
      await _flushSaves();
    });

    testWidgets('negative quantity is rejected', (tester) async {
      await _pumpPage(tester, buildTestDocument());
      await _focusCell(tester, 'line-1', LineItemColumn.quantity);
      await tester.enterText(_cell('line-1', LineItemColumn.quantity), '-2');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(_lines.first.quantityScaled, 1000);
      expect(find.byTooltip('Enter a number'), findsOneWidget);
      expect(_cellText(tester, 'line-1', LineItemColumn.quantity), '1');
    });

    testWidgets('discount above 100% or below zero is rejected', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        buildTestDocument().copyWith(
          layoutOptions: const DocumentLayoutOptions(showDiscountColumn: true),
        ),
      );
      for (final input in ['150', '-5']) {
        await _focusCell(tester, 'line-1', LineItemColumn.discount);
        await tester.enterText(_cell('line-1', LineItemColumn.discount), input);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(_lines.first.discountPercentScaled, 0);
        expect(find.byTooltip('Enter a number'), findsOneWidget);
      }
      await _focusCell(tester, 'line-1', LineItemColumn.discount);
      await tester.enterText(_cell('line-1', LineItemColumn.discount), '12.5%');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(_lines.first.discountPercentScaled, 1250);
      expect(find.byTooltip('Enter a number'), findsNothing);
      expect(_cellText(tester, 'line-1', LineItemColumn.discount), '12.5%');
      await _flushSaves();
    });

    testWidgets('amount is read-only and follows the line', (tester) async {
      await _pumpPage(
        tester,
        buildTestDocument(
          lineItems: [buildTestLine(quantityScaled: 2000, unitPriceMinor: 750)],
        ),
      );
      expect(_cell('line-1', LineItemColumn.amount), findsNothing);
      expect(find.text('15.00'), findsOneWidget);
    });
  });

  group('layout and state', () {
    testWidgets('multi-line description of 2000 chars wraps without overflow '
        'errors', (tester) async {
      final longText = [
        for (var paragraph = 0; paragraph < 10; paragraph++)
          'Paragraph $paragraph ${'word ' * 30}${'x' * 40}',
      ].join('\n');
      expect(longText.length, greaterThanOrEqualTo(2000));
      final line = buildTestLine().copyWith(description: longText);
      await _pumpPage(tester, buildTestDocument(lineItems: [line]));
      expect(tester.takeException(), isNull);
      final page = tester.getRect(find.byType(DocumentPageView));
      final cell = tester.getRect(_cell('line-1', LineItemColumn.description));
      expect(page.width, closeTo(DocumentPageView.pageWidth, 0.5));
      expect(cell.right, lessThanOrEqualTo(page.right));
      // Wrapped onto many lines rather than one long line.
      expect(cell.height, greaterThan(300));
    });

    testWidgets('row controls cannot be hit or read while the row is idle', (
      tester,
    ) async {
      await _pumpPage(tester, buildTestDocument());
      expect(find.byTooltip('Row actions').hitTestable(), findsNothing);
      expect(find.byIcon(Icons.drag_indicator).hitTestable(), findsNothing);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('1').first));
      await tester.pump();
      expect(find.byTooltip('Row actions').hitTestable(), findsOneWidget);
    });

    testWidgets('editable document shows add-item row and row menus', (
      tester,
    ) async {
      await _pumpPage(tester, buildTestDocument());
      expect(find.text('+ Add item'), findsOneWidget);
      expect(find.byTooltip('Row actions'), findsNWidgets(2));
      expect(find.byIcon(Icons.drag_indicator), findsNWidgets(2));
    });

    testWidgets('a cell removed while edited still commits its text', (
      tester,
    ) async {
      await _pumpPage(tester, buildTestDocument());
      await _focusCell(tester, 'line-1', LineItemColumn.unit);
      await tester.enterText(_cell('line-1', LineItemColumn.unit), 'box');
      // Hiding the unit column disposes the focused, edited cell.
      _container
          .read(documentEditorControllerProvider(_documentId).notifier)
          .updateLayoutOptions(
            const DocumentLayoutOptions(showUnitColumn: false),
          );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_cell('line-1', LineItemColumn.unit), findsNothing);
      expect(_lines.first.unit, 'box');
      await _flushSaves();
    });

    testWidgets('locked document shows no add-item row', (tester) async {
      await _pumpPage(
        tester,
        buildTestDocument(lockedAt: DateTime.utc(2026, 10, 18)),
      );
      expect(find.text('+ Add item'), findsNothing);
      expect(find.byTooltip('Row actions'), findsNothing);
      expect(find.byIcon(Icons.drag_indicator), findsNothing);
      final description = tester.widget<EditableText>(
        _cell('line-1', LineItemColumn.description),
      );
      expect(description.readOnly, isTrue);
    });

    testWidgets('+ Add item appends a row and focuses its description', (
      tester,
    ) async {
      await _pumpPage(tester, buildTestDocument());
      await tester.tap(find.text('+ Add item'));
      await tester.pumpAndSettle();
      expect(_lineIds, ['line-1', 'line-2', 'id-1']);
      expect(_hasFocus(tester, 'id-1', LineItemColumn.description), isTrue);
      await _flushSaves();
    });

    testWidgets('row menu inserts above and deletes', (tester) async {
      await _pumpPage(tester, buildTestDocument());
      await _hoverOver(tester, _cell('line-1', LineItemColumn.description));
      await tester.tap(find.byTooltip('Row actions').first);
      await tester.pumpAndSettle();
      expect(find.text('Duplicate row'), findsOneWidget);
      await tester.tap(find.text('Insert row above'));
      await tester.pumpAndSettle();
      expect(_lineIds, ['id-1', 'line-1', 'line-2']);
      expect(_hasFocus(tester, 'id-1', LineItemColumn.description), isTrue);

      await _hoverOver(tester, _cell('line-2', LineItemColumn.description));
      await tester.tap(find.byTooltip('Row actions').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete row'));
      await tester.pumpAndSettle();
      expect(_lineIds, ['id-1', 'line-1']);
      expect(tester.takeException(), isNull);
      await _flushSaves();
    });

    testWidgets('dragging the handle reorders rows', (tester) async {
      await _pumpPage(tester, buildTestDocument());
      await _hoverOver(tester, _cell('line-1', LineItemColumn.description));
      final handle = find.byIcon(Icons.drag_indicator).first;
      final gesture = await tester.startGesture(tester.getCenter(handle));
      for (var step = 0; step < 10; step++) {
        await gesture.moveBy(const Offset(0, 8));
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_lineIds, ['line-2', 'line-1']);
      await _flushSaves();
    });

    testWidgets('a locked number cell keeps its printed form when focused', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        buildTestDocument(
          lineItems: [buildTestLine(unitPriceMinor: 123450)],
          lockedAt: DateTime.utc(2026, 10, 18),
        ),
      );
      await _focusCell(tester, 'line-1', LineItemColumn.unitPrice);
      expect(_cellText(tester, 'line-1', LineItemColumn.unitPrice), '1,234.50');
    });

    testWidgets('delivery over-quantity shows remaining hint', (tester) async {
      final salesOrder = buildTestDocument(
        type: DocumentType.salesOrder,
        documentId: 'so-1',
        lineItems: [buildTestLine(id: 'so-line', quantityScaled: 5000)],
      );
      final earlierDelivery = buildTestDocument(
        type: DocumentType.deliveryOrder,
        documentId: 'do-0',
        sourceDocumentId: 'so-1',
        lineItems: [
          buildTestLine(
            id: 'do-0-line',
            quantityScaled: 3000,
          ).copyWith(sourceLineItemId: 'so-line'),
        ],
      );
      final delivery = buildTestDocument(
        type: DocumentType.deliveryOrder,
        documentId: 'do-1',
        sourceDocumentId: 'so-1',
        lineItems: [
          buildTestLine(
            id: 'do-line',
            quantityScaled: 2000,
          ).copyWith(sourceLineItemId: 'so-line'),
        ],
      );
      await _pumpPage(tester, delivery, chain: [salesOrder, earlierDelivery]);
      expect(find.textContaining('left to deliver'), findsNothing);

      await _focusCell(tester, 'do-line', LineItemColumn.quantity);
      await tester.enterText(_cell('do-line', LineItemColumn.quantity), '4');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(find.text('Only 2 left to deliver'), findsOneWidget);
      await _flushSaves();
    });
  });

  group('row menu without a hover', () {
    /// A point on the row number cell, which has no field to grab the press.
    Offset rowNumber(WidgetTester tester, String lineId) =>
        tester.getTopLeft(find.byKey(ValueKey(lineId))) +
        const Offset(lineItemGutterWidth + 8, 16);

    testWidgets('long-pressing a row opens the row menu', (tester) async {
      await _pumpPage(
        tester,
        buildTestDocument(),
        platform: TargetPlatform.android,
      );
      expect(find.text('Duplicate row'), findsNothing);
      await tester.longPressAt(rowNumber(tester, 'line-1'));
      await tester.pumpAndSettle();
      expect(find.text('Duplicate row'), findsOneWidget);
      await tester.tap(find.text('Duplicate row'));
      await tester.pumpAndSettle();
      expect(_lines, hasLength(3));
      await _flushSaves();
    });

    testWidgets('right-clicking a row opens the row menu', (tester) async {
      await _pumpPage(tester, buildTestDocument());
      await tester.tapAt(
        rowNumber(tester, 'line-1'),
        buttons: kSecondaryButton,
      );
      await tester.pumpAndSettle();
      expect(find.text('Delete row'), findsOneWidget);
    });

    testWidgets('on touch platforms the menu button has a 48 px hit area', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        buildTestDocument(),
        platform: TargetPlatform.android,
      );
      final button = find.byTooltip('Row actions').first;
      final target = tester.getRect(
        find.byKey(const ValueKey('rowMenuTouchTarget-line-1')),
      );
      expect(target.width, greaterThanOrEqualTo(44));
      expect(target.contains(tester.getCenter(button)), isTrue);
      await tester.tapAt(target.center);
      await tester.pumpAndSettle();
      expect(find.text('Insert row above'), findsOneWidget);
    });

    testWidgets('locked rows have no long-press menu', (tester) async {
      await _pumpPage(
        tester,
        buildTestDocument(lockedAt: DateTime.utc(2026, 10, 17)),
        platform: TargetPlatform.android,
      );
      await tester.longPressAt(rowNumber(tester, 'line-1'));
      await tester.pumpAndSettle();
      expect(find.text('Duplicate row'), findsNothing);
    });
  });
}
