import '../exceptions/document_exceptions.dart';
import '../models/business_document.dart';
import '../models/document_settings.dart';
import '../models/document_type.dart';
import '../models/line_item.dart';
import 'delivery_progress_calculator.dart';
import 'id_generator.dart';

/// The two documents an upgrade produces; both are saved in one transaction.
class UpgradeResult {
  const UpgradeResult({
    required this.lockedSource,
    required this.createdDocument,
  });

  final BusinessDocument lockedSource;
  final BusinessDocument createdDocument;
}

/// Creates the next-stage document in a chain (spec section 3.4).
class DocumentUpgradeService {
  const DocumentUpgradeService({
    required this.idGenerator,
    this.deliveryProgressCalculator = const DeliveryProgressCalculator(),
  });

  final IdGenerator idGenerator;
  final DeliveryProgressCalculator deliveryProgressCalculator;

  /// The reason [source] cannot be upgraded, or `null` when it can.
  String? findUpgradeBlocker({
    required BusinessDocument source,
    required List<BusinessDocument> chainDocuments,
  }) {
    switch (source.documentType) {
      case DocumentType.deliveryOrder:
        return 'Delivery orders are the last stage';
      case DocumentType.quotation:
        final hasSalesOrder = chainDocuments.any(
          (document) => document.documentType == DocumentType.salesOrder,
        );
        return hasSalesOrder ? 'This chain already has a sales order' : null;
      case DocumentType.salesOrder:
        final remainingByLine = _remainingByLine(source, chainDocuments);
        final hasUndeliveredLine = remainingByLine.values.any(
          (remaining) => remaining > 0,
        );
        return hasUndeliveredLine
            ? null
            : 'Every item on this sales order has been delivered';
    }
  }

  /// Builds the next-stage document and the locked source.
  ///
  /// Throws [InvalidUpgradeException] when [findUpgradeBlocker] gives a reason.
  UpgradeResult createNextStage({
    required BusinessDocument source,
    required List<BusinessDocument> chainDocuments,
    required String documentNumber,
    required DocumentSettings settings,
    required DateTime now,
  }) {
    final blocker = findUpgradeBlocker(
      source: source,
      chainDocuments: chainDocuments,
    );
    if (blocker != null) throw InvalidUpgradeException(blocker);

    final targetType = source.documentType.nextStage!;
    final lineItems = targetType == DocumentType.deliveryOrder
        ? _deliveryLines(source, chainDocuments)
        : [
            for (final line in source.lineItems)
              line.copyWith(
                lineItemId: idGenerator.generateId(),
                sourceLineItemId: line.lineItemId,
              ),
          ];

    final createdDocument = BusinessDocument(
      documentId: idGenerator.generateId(),
      documentType: targetType,
      documentNumber: documentNumber,
      chainId: source.chainId,
      sourceDocumentId: source.documentId,
      schemaVersion: BusinessDocument.currentSchemaVersion,
      issueDate: now,
      deliveryDate: targetType == DocumentType.deliveryOrder ? now : null,
      customerReference: source.customerReference,
      companyDetails: source.companyDetails,
      customerDetails: source.customerDetails,
      layoutOptions: settings.layoutOptionsByType[targetType]!,
      pricingTerms: source.pricingTerms,
      lineItems: lineItems,
      notes: source.notes,
      termsAndConditions: source.termsAndConditions,
      footerNote: source.footerNote,
      signatureBlock: settings.signatureBlockByType[targetType]!,
      createdAt: now,
      updatedAt: now,
    );
    return UpgradeResult(
      lockedSource: source.copyWith(lockedAt: source.lockedAt ?? now),
      createdDocument: createdDocument,
    );
  }

  List<LineItem> _deliveryLines(
    BusinessDocument salesOrder,
    List<BusinessDocument> chainDocuments,
  ) {
    final remainingByLine = _remainingByLine(salesOrder, chainDocuments);
    return [
      for (final line in salesOrder.lineItems)
        if ((remainingByLine[line.lineItemId] ?? 0) > 0)
          line.copyWith(
            lineItemId: idGenerator.generateId(),
            sourceLineItemId: line.lineItemId,
            quantityScaled: remainingByLine[line.lineItemId]!,
          ),
    ];
  }

  Map<String, int> _remainingByLine(
    BusinessDocument salesOrder,
    List<BusinessDocument> chainDocuments,
  ) {
    return deliveryProgressCalculator.remainingQuantityBySalesOrderLine(
      salesOrder: salesOrder,
      deliveryOrders: [
        for (final document in chainDocuments)
          if (document.documentType == DocumentType.deliveryOrder) document,
      ],
    );
  }
}
