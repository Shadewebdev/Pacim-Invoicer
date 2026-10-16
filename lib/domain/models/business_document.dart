import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pacim_invoicer/domain/models/company_details.dart';
import 'package:pacim_invoicer/domain/models/customer_details.dart';
import 'package:pacim_invoicer/domain/models/document_layout_options.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/models/line_item.dart';
import 'package:pacim_invoicer/domain/models/pricing_terms.dart';
import 'package:pacim_invoicer/domain/models/signature_block.dart';

part 'business_document.freezed.dart';
part 'business_document.g.dart';

/// A self-contained quotation, sales order or delivery order.
@freezed
abstract class BusinessDocument with _$BusinessDocument {
  const BusinessDocument._();

  static const currentSchemaVersion = 1;

  const factory BusinessDocument({
    required String documentId,
    required DocumentType documentType,
    required String documentNumber,
    required String chainId,
    String? sourceDocumentId,
    DateTime? lockedAt,
    required int schemaVersion,
    required DateTime issueDate,
    DateTime? validUntilDate,
    DateTime? deliveryDate,
    String? customerReference,
    required CompanyDetails companyDetails,
    required CustomerDetails customerDetails,
    required DocumentLayoutOptions layoutOptions,
    required PricingTerms pricingTerms,
    required List<LineItem> lineItems,
    @Default('') String notes,
    @Default('') String termsAndConditions,
    @Default('') String footerNote,
    required SignatureBlock signatureBlock,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BusinessDocument;

  factory BusinessDocument.fromJson(Map<String, dynamic> json) =>
      _$BusinessDocumentFromJson(json);

  bool get isLocked => lockedAt != null;
}
