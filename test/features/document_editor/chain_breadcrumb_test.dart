import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/app/theme/document_type_colors.dart';
import 'package:pacim_invoicer/domain/models/document_chain.dart';
import 'package:pacim_invoicer/domain/models/document_summary.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/features/document_editor/chain_breadcrumb/chain_breadcrumb.dart';

DocumentSummary _summary(String id, DocumentType type, String number) =>
    DocumentSummary(
      documentId: id,
      documentType: type,
      documentNumber: number,
      chainId: 'chain-1',
      customerName: 'Acme Trading',
      issueDate: DateTime(2026, 10, 17),
      grandTotalMinor: 0,
      currencyCode: 'MYR',
      isLocked: false,
      updatedAt: DateTime(2026, 10, 17),
    );

final _quotation = _summary('qt', DocumentType.quotation, 'QT-2026-0004');
final _salesOrder = _summary('so', DocumentType.salesOrder, 'SO-2026-0002');
final _deliveryOne = _summary(
  'do1',
  DocumentType.deliveryOrder,
  'DO-2026-0002',
);
final _deliveryTwo = _summary(
  'do2',
  DocumentType.deliveryOrder,
  'DO-2026-0003',
);

Future<void> _pump(
  WidgetTester tester, {
  required DocumentChain chain,
  required String currentDocumentId,
  ValueChanged<String>? onOpenDocument,
  ValueChanged<String>? onUpgrade,
}) => tester.pumpWidget(
  MaterialApp(
    theme: buildAppTheme(
      brightness: Brightness.light,
      platform: TargetPlatform.windows,
    ),
    home: Scaffold(
      body: ChainBreadcrumb(
        chain: chain,
        currentDocumentId: currentDocumentId,
        onOpenDocument: onOpenDocument ?? (_) {},
        onUpgrade: onUpgrade,
      ),
    ),
  ),
);

BoxDecoration _chipDecoration(WidgetTester tester, String text) {
  final chip = find.ancestor(
    of: find.text(text),
    matching: find.byType(DecoratedBox),
  );
  return tester.widget<DecoratedBox>(chip.first).decoration as BoxDecoration;
}

void main() {
  testWidgets('breadcrumb shows QT > SO > DO dropdown with two DOs', (
    tester,
  ) async {
    await _pump(
      tester,
      chain: DocumentChain(
        chainId: 'chain-1',
        quotation: _quotation,
        salesOrder: _salesOrder,
        deliveryOrders: [_deliveryOne, _deliveryTwo],
      ),
      currentDocumentId: 'qt',
    );

    expect(find.text('QT-2026-0004'), findsOneWidget);
    expect(find.text('SO-2026-0002'), findsOneWidget);
    expect(find.text('›'), findsNWidgets(2));
    // The dropdown chip names the latest delivery order.
    expect(find.text('DO-2026-0003 ▾'), findsOneWidget);
    expect(find.text('DO-2026-0002'), findsNothing);

    await tester.tap(find.text('DO-2026-0003 ▾'));
    await tester.pumpAndSettle();

    expect(find.text('DO-2026-0002'), findsOneWidget);
    expect(find.text('DO-2026-0003'), findsOneWidget);
  });

  testWidgets('the dropdown chip names the current delivery order', (
    tester,
  ) async {
    await _pump(
      tester,
      chain: DocumentChain(
        chainId: 'chain-1',
        salesOrder: _salesOrder,
        deliveryOrders: [_deliveryOne, _deliveryTwo],
      ),
      currentDocumentId: 'do1',
    );
    expect(find.text('DO-2026-0002 ▾'), findsOneWidget);
  });

  testWidgets('choosing a delivery order from the dropdown opens it', (
    tester,
  ) async {
    String? opened;
    await _pump(
      tester,
      chain: DocumentChain(
        chainId: 'chain-1',
        salesOrder: _salesOrder,
        deliveryOrders: [_deliveryOne, _deliveryTwo],
      ),
      currentDocumentId: 'so',
      onOpenDocument: (id) => opened = id,
    );

    await tester.tap(find.text('DO-2026-0003 ▾'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DO-2026-0002'));
    await tester.pumpAndSettle();

    expect(opened, 'do1');
  });

  testWidgets('current chip is emphasised', (tester) async {
    await _pump(
      tester,
      chain: DocumentChain(
        chainId: 'chain-1',
        quotation: _quotation,
        salesOrder: _salesOrder,
      ),
      currentDocumentId: 'so',
    );
    const colors = DocumentTypeColors.light;

    final current = _chipDecoration(tester, 'SO-2026-0002');
    final other = _chipDecoration(tester, 'QT-2026-0004');
    expect(current.color, colors.salesOrderTint);
    expect(other.color, colors.quotationTint);
    expect(
      (current.border! as Border).top.width,
      greaterThan((other.border! as Border).top.width),
    );
    final currentText = tester.widget<Text>(find.text('SO-2026-0002'));
    final otherText = tester.widget<Text>(find.text('QT-2026-0004'));
    expect(currentText.style!.fontWeight, FontWeight.w600);
    expect(otherText.style!.fontWeight, isNot(FontWeight.w600));
  });

  testWidgets('standalone quotation shows + Sales order chip', (tester) async {
    String? upgradedFrom;
    await _pump(
      tester,
      chain: DocumentChain(chainId: 'chain-1', quotation: _quotation),
      currentDocumentId: 'qt',
      onUpgrade: (id) => upgradedFrom = id,
    );

    await tester.tap(find.text('+ Sales order'));
    expect(upgradedFrom, 'qt');
  });

  testWidgets('no + chip when upgrading is not offered', (tester) async {
    await _pump(
      tester,
      chain: DocumentChain(chainId: 'chain-1', quotation: _quotation),
      currentDocumentId: 'qt',
    );
    expect(find.text('+ Sales order'), findsNothing);
  });

  testWidgets('+ Delivery order stays after existing delivery orders', (
    tester,
  ) async {
    String? upgradedFrom;
    await _pump(
      tester,
      chain: DocumentChain(
        chainId: 'chain-1',
        quotation: _quotation,
        salesOrder: _salesOrder,
        deliveryOrders: [_deliveryOne],
      ),
      currentDocumentId: 'do1',
      onUpgrade: (id) => upgradedFrom = id,
    );

    await tester.tap(find.text('+ Delivery order'));
    expect(upgradedFrom, 'so');
  });
}
