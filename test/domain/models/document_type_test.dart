import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';

void main() {
  test('next stage follows quotation → sales order → delivery order', () {
    expect(DocumentType.quotation.nextStage, DocumentType.salesOrder);
    expect(DocumentType.salesOrder.nextStage, DocumentType.deliveryOrder);
    expect(DocumentType.deliveryOrder.nextStage, isNull);
  });
  test('route segments round-trip', () {
    for (final type in DocumentType.values) {
      expect(DocumentType.fromRouteSegment(type.routeSegment), type);
    }
  });
  test('delivery orders hide pricing', () {
    expect(DocumentType.deliveryOrder.showsPricing, isFalse);
    expect(DocumentType.quotation.showsPricing, isTrue);
  });
}
