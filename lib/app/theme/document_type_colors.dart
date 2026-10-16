import 'package:flutter/material.dart';

import '../../domain/models/document_type.dart';

/// Copy-paper tint and ink per document type (spec section 7.1).
@immutable
class DocumentTypeColors extends ThemeExtension<DocumentTypeColors> {
  const DocumentTypeColors({
    required this.quotationTint,
    required this.quotationInk,
    required this.salesOrderTint,
    required this.salesOrderInk,
    required this.deliveryOrderTint,
    required this.deliveryOrderInk,
  });

  final Color quotationTint;
  final Color quotationInk;
  final Color salesOrderTint;
  final Color salesOrderInk;
  final Color deliveryOrderTint;
  final Color deliveryOrderInk;

  static const light = DocumentTypeColors(
    quotationTint: Color(0xFFDCE6FA),
    quotationInk: Color(0xFF2E56B8),
    salesOrderTint: Color(0xFFFBEFB8),
    salesOrderInk: Color(0xFF7C6100),
    deliveryOrderTint: Color(0xFFF7D9E0),
    deliveryOrderInk: Color(0xFFA23B5A),
  );

  /// Tints at 30% opacity; inks are the light inks lightened by 45%.
  static final dark = DocumentTypeColors(
    quotationTint: light.quotationTint.withValues(alpha: 0.3),
    quotationInk: _lightened(light.quotationInk),
    salesOrderTint: light.salesOrderTint.withValues(alpha: 0.3),
    salesOrderInk: _lightened(light.salesOrderInk),
    deliveryOrderTint: light.deliveryOrderTint.withValues(alpha: 0.3),
    deliveryOrderInk: _lightened(light.deliveryOrderInk),
  );

  static Color _lightened(Color ink) => Color.lerp(ink, Colors.white, 0.45)!;

  Color tintFor(DocumentType type) => switch (type) {
    DocumentType.quotation => quotationTint,
    DocumentType.salesOrder => salesOrderTint,
    DocumentType.deliveryOrder => deliveryOrderTint,
  };

  Color inkFor(DocumentType type) => switch (type) {
    DocumentType.quotation => quotationInk,
    DocumentType.salesOrder => salesOrderInk,
    DocumentType.deliveryOrder => deliveryOrderInk,
  };

  @override
  DocumentTypeColors copyWith({
    Color? quotationTint,
    Color? quotationInk,
    Color? salesOrderTint,
    Color? salesOrderInk,
    Color? deliveryOrderTint,
    Color? deliveryOrderInk,
  }) {
    return DocumentTypeColors(
      quotationTint: quotationTint ?? this.quotationTint,
      quotationInk: quotationInk ?? this.quotationInk,
      salesOrderTint: salesOrderTint ?? this.salesOrderTint,
      salesOrderInk: salesOrderInk ?? this.salesOrderInk,
      deliveryOrderTint: deliveryOrderTint ?? this.deliveryOrderTint,
      deliveryOrderInk: deliveryOrderInk ?? this.deliveryOrderInk,
    );
  }

  @override
  DocumentTypeColors lerp(ThemeExtension<DocumentTypeColors>? other, double t) {
    if (other is! DocumentTypeColors) return this;
    return DocumentTypeColors(
      quotationTint: Color.lerp(quotationTint, other.quotationTint, t)!,
      quotationInk: Color.lerp(quotationInk, other.quotationInk, t)!,
      salesOrderTint: Color.lerp(salesOrderTint, other.salesOrderTint, t)!,
      salesOrderInk: Color.lerp(salesOrderInk, other.salesOrderInk, t)!,
      deliveryOrderTint: Color.lerp(
        deliveryOrderTint,
        other.deliveryOrderTint,
        t,
      )!,
      deliveryOrderInk: Color.lerp(
        deliveryOrderInk,
        other.deliveryOrderInk,
        t,
      )!,
    );
  }
}
