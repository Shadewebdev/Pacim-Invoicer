import '../models/business_document.dart';
import '../models/customer_details.dart';
import '../models/document_settings.dart';
import '../models/document_type.dart';
import '../models/line_item.dart';
import 'id_generator.dart';

/// A part of a document that can be reset to the current Settings defaults.
enum DocumentSection { company, headerAndFooter, pricing, signature, terms }

/// Creates, duplicates and resets documents. Pure: ids and time are injected.
class DocumentFactory {
  const DocumentFactory({required this.idGenerator});

  final IdGenerator idGenerator;

  /// A new document that starts its own chain, with every settings section
  /// copied in and one empty line.
  BusinessDocument createStandalone({
    required DocumentType documentType,
    required String documentNumber,
    required DocumentSettings settings,
    required DateTime now,
  }) {
    return BusinessDocument(
      documentId: idGenerator.generateId(),
      documentType: documentType,
      documentNumber: documentNumber,
      chainId: idGenerator.generateId(),
      schemaVersion: BusinessDocument.currentSchemaVersion,
      issueDate: now,
      validUntilDate: documentType == DocumentType.quotation
          ? _addDays(now, settings.quotationValidityDays)
          : null,
      deliveryDate: documentType == DocumentType.deliveryOrder ? now : null,
      companyDetails: settings.companyDetails,
      customerDetails: const CustomerDetails(),
      layoutOptions: settings.layoutOptionsByType[documentType]!,
      pricingTerms: settings.pricingTerms,
      lineItems: [LineItem(lineItemId: idGenerator.generateId())],
      termsAndConditions: settings.defaultTermsByType[documentType] ?? '',
      footerNote: settings.defaultFooterNote,
      signatureBlock: settings.signatureBlockByType[documentType]!,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// A copy of [source] as a fresh, unlocked draft in a new chain.
  BusinessDocument duplicateAsDraft({
    required BusinessDocument source,
    required String documentNumber,
    required DateTime now,
  }) {
    return source.copyWith(
      documentId: idGenerator.generateId(),
      documentNumber: documentNumber,
      chainId: idGenerator.generateId(),
      sourceDocumentId: null,
      lockedAt: null,
      schemaVersion: BusinessDocument.currentSchemaVersion,
      issueDate: now,
      lineItems: [
        for (final line in source.lineItems)
          line.copyWith(
            lineItemId: idGenerator.generateId(),
            sourceLineItemId: null,
          ),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Re-copies the current Settings defaults into one section of [document].
  BusinessDocument resetSectionToDefaults(
    BusinessDocument document,
    DocumentSection section,
    DocumentSettings settings,
  ) {
    final type = document.documentType;
    return switch (section) {
      DocumentSection.company => document.copyWith(
        companyDetails: settings.companyDetails,
      ),
      DocumentSection.headerAndFooter => document.copyWith(
        layoutOptions: settings.layoutOptionsByType[type]!,
        footerNote: settings.defaultFooterNote,
      ),
      DocumentSection.pricing => document.copyWith(
        pricingTerms: settings.pricingTerms,
      ),
      DocumentSection.signature => document.copyWith(
        signatureBlock: settings.signatureBlockByType[type]!,
      ),
      DocumentSection.terms => document.copyWith(
        termsAndConditions: settings.defaultTermsByType[type] ?? '',
      ),
    };
  }

  /// Adds calendar days, keeping the time of day.
  static DateTime _addDays(DateTime date, int days) {
    return date.isUtc
        ? DateTime.utc(
            date.year,
            date.month,
            date.day + days,
            date.hour,
            date.minute,
            date.second,
            date.millisecond,
            date.microsecond,
          )
        : DateTime(
            date.year,
            date.month,
            date.day + days,
            date.hour,
            date.minute,
            date.second,
            date.millisecond,
            date.microsecond,
          );
  }
}
