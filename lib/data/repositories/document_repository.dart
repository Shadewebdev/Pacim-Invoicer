import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/document_chain.dart';
import 'package:pacim_invoicer/domain/models/document_list_query.dart';
import 'package:pacim_invoicer/domain/models/document_summary.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';

abstract interface class DocumentRepository {
  Stream<List<DocumentSummary>> watchDocumentSummaries(DocumentListQuery query);

  /// How many documents match [query]'s type, search and date filters. Ignores
  /// the sort and the `limit`.
  Stream<int> watchDocumentCount(DocumentListQuery query);

  Future<BusinessDocument> getDocument(String documentId);
  Stream<BusinessDocument> watchDocument(String documentId);
  Stream<DocumentChain> watchDocumentChain(String chainId);
  Future<List<BusinessDocument>> getDocumentsInChain(String chainId);

  /// Whether a document of [type] already has [documentNumber]. Numbers are
  /// unique per type; saving a second document with one fails.
  Future<bool> documentNumberExists(DocumentType type, String documentNumber);

  /// Throws `DocumentLockedException` when the stored document is locked.
  Future<void> saveDocument(BusinessDocument document);

  /// Writes the new document and locks the source in one transaction.
  Future<void> saveUpgrade({
    required BusinessDocument lockedSource,
    required BusinessDocument createdDocument,
  });

  /// Unlocked documents only.
  Future<void> deleteDocument(String documentId);
}
