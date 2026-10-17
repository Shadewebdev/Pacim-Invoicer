import '../../data/repositories/document_repository.dart';
import '../../domain/models/business_document.dart';
import '../../domain/models/document_type.dart';

/// What a delivery order is validated against: the sales order it delivers
/// and the other delivery orders of the same chain.
class DeliveryValidationContext {
  const DeliveryValidationContext({
    this.salesOrder,
    this.otherDeliveryOrders = const [],
  });

  static const none = DeliveryValidationContext();

  final BusinessDocument? salesOrder;
  final List<BusinessDocument> otherDeliveryOrders;
}

/// Loads the validation context of [document]. Anything but a delivery order
/// created from a source has none.
Future<DeliveryValidationContext> loadDeliveryValidationContext(
  DocumentRepository repository,
  BusinessDocument document,
) async {
  if (document.documentType != DocumentType.deliveryOrder ||
      document.sourceDocumentId == null) {
    return DeliveryValidationContext.none;
  }
  final chain = await repository.getDocumentsInChain(document.chainId);
  BusinessDocument? salesOrder;
  final otherDeliveryOrders = <BusinessDocument>[];
  for (final candidate in chain) {
    if (candidate.documentType == DocumentType.salesOrder) {
      salesOrder = candidate;
    } else if (candidate.documentType == DocumentType.deliveryOrder &&
        candidate.documentId != document.documentId) {
      otherDeliveryOrders.add(candidate);
    }
  }
  return DeliveryValidationContext(
    salesOrder: salesOrder,
    otherDeliveryOrders: otherDeliveryOrders,
  );
}
