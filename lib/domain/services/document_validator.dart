import '../models/business_document.dart';
import '../models/document_type.dart';
import '../models/validation_issue.dart';
import 'delivery_progress_calculator.dart';

/// Finds problems that should be surfaced before a document is exported.
class DocumentValidator {
  const DocumentValidator({
    this.deliveryProgressCalculator = const DeliveryProgressCalculator(),
  });

  final DeliveryProgressCalculator deliveryProgressCalculator;

  /// The delivery-exceeds-remaining check runs only for a delivery order when
  /// [salesOrder] is given; [otherDeliveryOrders] are the chain's other
  /// delivery orders (the document itself is ignored if listed).
  List<ValidationIssue> validate(
    BusinessDocument document, {
    BusinessDocument? salesOrder,
    List<BusinessDocument> otherDeliveryOrders = const [],
  }) {
    final issues = <ValidationIssue>[];
    if (document.customerDetails.customerName.trim().isEmpty) {
      issues.add(
        const ValidationIssue(kind: ValidationIssueKind.missingCustomerName),
      );
    }
    if (document.lineItems.isEmpty) {
      issues.add(const ValidationIssue(kind: ValidationIssueKind.noLineItems));
    }
    for (final line in document.lineItems) {
      if (line.quantityScaled == 0) {
        issues.add(
          ValidationIssue(
            kind: ValidationIssueKind.zeroQuantity,
            lineItemId: line.lineItemId,
          ),
        );
      }
    }
    if (salesOrder != null &&
        document.documentType == DocumentType.deliveryOrder) {
      final remainingBySalesOrderLine = deliveryProgressCalculator
          .remainingQuantityBySalesOrderLine(
            salesOrder: salesOrder,
            deliveryOrders: otherDeliveryOrders,
            excludeDeliveryOrderId: document.documentId,
          );
      for (final line in document.lineItems) {
        final remaining = remainingBySalesOrderLine[line.sourceLineItemId];
        if (remaining != null && line.quantityScaled > remaining) {
          issues.add(
            ValidationIssue(
              kind: ValidationIssueKind.deliveryExceedsRemaining,
              lineItemId: line.lineItemId,
            ),
          );
        }
      }
    }
    return issues;
  }
}
