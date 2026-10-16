import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/document_chain.dart';
import 'package:pacim_invoicer/domain/models/document_list_query.dart';
import 'package:pacim_invoicer/domain/models/document_summary.dart';

abstract interface class DocumentRepository {
  Stream<List<DocumentSummary>> watchDocumentSummaries(DocumentListQuery query);
  Future<BusinessDocument> getDocument(String documentId);
  Stream<BusinessDocument> watchDocument(String documentId);
  Stream<DocumentChain> watchDocumentChain(String chainId);
  Future<List<BusinessDocument>> getDocumentsInChain(String chainId);

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
