/// The three stages of a sales document, in the order they are upgraded.
enum DocumentType {
  quotation,
  salesOrder,
  deliveryOrder;

  String get displayName => switch (this) {
    DocumentType.quotation => 'Quotation',
    DocumentType.salesOrder => 'Sales order',
    DocumentType.deliveryOrder => 'Delivery order',
  };

  String get pluralDisplayName => switch (this) {
    DocumentType.quotation => 'Quotations',
    DocumentType.salesOrder => 'Sales orders',
    DocumentType.deliveryOrder => 'Delivery orders',
  };

  String get routeSegment => switch (this) {
    DocumentType.quotation => 'quotations',
    DocumentType.salesOrder => 'sales-orders',
    DocumentType.deliveryOrder => 'delivery-orders',
  };

  /// The stage a document of this type is upgraded to, or null at the last stage.
  DocumentType? get nextStage => switch (this) {
    DocumentType.quotation => DocumentType.salesOrder,
    DocumentType.salesOrder => DocumentType.deliveryOrder,
    DocumentType.deliveryOrder => null,
  };

  bool get showsPricing => this != DocumentType.deliveryOrder;

  static DocumentType fromRouteSegment(String segment) {
    for (final type in DocumentType.values) {
      if (type.routeSegment == segment) return type;
    }
    throw ArgumentError.value(segment, 'segment', 'Unknown route segment');
  }
}
