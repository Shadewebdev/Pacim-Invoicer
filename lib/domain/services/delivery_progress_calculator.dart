import '../models/business_document.dart';

/// Works out how much of each sales order line is still to be delivered.
class DeliveryProgressCalculator {
  const DeliveryProgressCalculator();

  /// Remaining scaled quantity per sales order line id. Negative values mean
  /// the line was over-delivered. Delivery lines map to sales order lines by
  /// `sourceLineItemId`; lines without one are ignored.
  Map<String, int> remainingQuantityBySalesOrderLine({
    required BusinessDocument salesOrder,
    required List<BusinessDocument> deliveryOrders,
    String? excludeDeliveryOrderId,
  }) {
    final remainingById = <String, int>{
      for (final line in salesOrder.lineItems)
        line.lineItemId: line.quantityScaled,
    };
    for (final deliveryOrder in deliveryOrders) {
      if (deliveryOrder.documentId == excludeDeliveryOrderId) continue;
      for (final line in deliveryOrder.lineItems) {
        final sourceId = line.sourceLineItemId;
        if (sourceId == null || !remainingById.containsKey(sourceId)) continue;
        remainingById[sourceId] =
            remainingById[sourceId]! - line.quantityScaled;
      }
    }
    return remainingById;
  }

  /// Remaining scaled quantity for one sales order line (0 if it is unknown).
  int remainingQuantityForLine({
    required BusinessDocument salesOrder,
    required List<BusinessDocument> deliveryOrders,
    String? excludeDeliveryOrderId,
    required String salesOrderLineItemId,
  }) {
    return remainingQuantityBySalesOrderLine(
          salesOrder: salesOrder,
          deliveryOrders: deliveryOrders,
          excludeDeliveryOrderId: excludeDeliveryOrderId,
        )[salesOrderLineItemId] ??
        0;
  }
}
