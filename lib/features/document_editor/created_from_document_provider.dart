import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository_providers.dart';
import '../../domain/models/business_document.dart';
import '../../domain/models/document_summary.dart';

/// The first document in the chain whose source is [documentId], or null when
/// nothing was created from it. Task 20 replaces this with the chain provider.
final createdFromDocumentProvider = FutureProvider.autoDispose
    .family<DocumentSummary?, ({String documentId, String chainId})>((
      ref,
      key,
    ) async {
      final repository = ref.watch(documentRepositoryProvider);
      final chain = await repository.getDocumentsInChain(key.chainId);
      for (final candidate in chain) {
        if (candidate.sourceDocumentId == key.documentId) {
          return _summaryOf(ref, candidate);
        }
      }
      return null;
    });

DocumentSummary _summaryOf(Ref ref, BusinessDocument document) =>
    DocumentSummary(
      documentId: document.documentId,
      documentType: document.documentType,
      documentNumber: document.documentNumber,
      chainId: document.chainId,
      sourceDocumentId: document.sourceDocumentId,
      customerName: document.customerDetails.customerName,
      issueDate: document.issueDate,
      grandTotalMinor: ref
          .read(documentTotalsCalculatorProvider)
          .calculate(document)
          .grandTotalMinor,
      currencyCode: document.pricingTerms.currencyFormat.currencyCode,
      isLocked: document.isLocked,
      updatedAt: document.updatedAt,
    );
