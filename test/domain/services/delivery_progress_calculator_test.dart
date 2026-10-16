import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/services/delivery_progress_calculator.dart';

import '../../support/document_builders.dart';

void main() {
  const calculator = DeliveryProgressCalculator();
  final salesOrder = buildTestDocument(
    type: DocumentType.salesOrder,
    documentId: 'so-1',
    lineItems: [buildTestLine(id: 'so-line', quantityScaled: 10000)],
  );

  BusinessDocument deliveryOf(
    String documentId,
    int quantityScaled, {
    String? sourceLineItemId,
  }) {
    return buildTestDocument(
      type: DocumentType.deliveryOrder,
      documentId: documentId,
      lineItems: [
        buildTestLine(
          id: '$documentId-line',
          quantityScaled: quantityScaled,
        ).copyWith(sourceLineItemId: sourceLineItemId),
      ],
    );
  }

  test('no deliveries → remaining equals ordered', () {
    final remaining = calculator.remainingQuantityBySalesOrderLine(
      salesOrder: salesOrder,
      deliveryOrders: [],
    );
    expect(remaining, {'so-line': 10000});
  });

  test('two partial deliveries subtract', () {
    final remaining = calculator.remainingQuantityForLine(
      salesOrder: salesOrder,
      deliveryOrders: [
        deliveryOf('do-1', 3000, sourceLineItemId: 'so-line'),
        deliveryOf('do-2', 2500, sourceLineItemId: 'so-line'),
      ],
      salesOrderLineItemId: 'so-line',
    );
    expect(remaining, 4500);
  });

  test('excludeDeliveryOrderId ignores the order being edited', () {
    final remaining = calculator.remainingQuantityForLine(
      salesOrder: salesOrder,
      deliveryOrders: [
        deliveryOf('do-1', 3000, sourceLineItemId: 'so-line'),
        deliveryOf('do-2', 2500, sourceLineItemId: 'so-line'),
      ],
      excludeDeliveryOrderId: 'do-2',
      salesOrderLineItemId: 'so-line',
    );
    expect(remaining, 7000);
  });

  test('over-delivery yields negative remaining', () {
    final remaining = calculator.remainingQuantityForLine(
      salesOrder: salesOrder,
      deliveryOrders: [deliveryOf('do-1', 12000, sourceLineItemId: 'so-line')],
      salesOrderLineItemId: 'so-line',
    );
    expect(remaining, -2000);
  });

  test('delivery lines without sourceLineItemId are ignored', () {
    final remaining = calculator.remainingQuantityBySalesOrderLine(
      salesOrder: salesOrder,
      deliveryOrders: [deliveryOf('do-1', 3000)],
    );
    expect(remaining, {'so-line': 10000});
  });
}
