import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository_providers.dart';
import '../../domain/models/document_chain.dart';
import '../../domain/models/document_list_query.dart';
import '../../domain/models/document_summary.dart';
import '../../domain/models/document_type.dart';

const int _pageSize = 50;

/// Holds the search, date filter, sort and page size of one type's listing.
class DocumentListController extends Notifier<DocumentListQuery> {
  DocumentListController(this.documentType);

  final DocumentType documentType;

  @override
  DocumentListQuery build() => DocumentListQuery(documentType: documentType);

  void setSearchText(String searchText) =>
      state = state.copyWith(searchText: searchText, limit: _pageSize);

  void setIssuedRange(DateTime? issuedFrom, DateTime? issuedTo) => state = state
      .copyWith(issuedFrom: issuedFrom, issuedTo: issuedTo, limit: _pageSize);

  /// Sorts by [field]; choosing the current field again flips the direction.
  void setSort(DocumentSortField field) {
    final isSameField = state.sortField == field;
    state = state.copyWith(
      sortField: field,
      sortDescending: isSameField ? !state.sortDescending : false,
      limit: _pageSize,
    );
  }

  void loadMore() => state = state.copyWith(limit: state.limit + _pageSize);
}

final documentListControllerProvider =
    NotifierProvider.family<
      DocumentListController,
      DocumentListQuery,
      DocumentType
    >(DocumentListController.new);

final documentSummariesProvider =
    StreamProvider.family<List<DocumentSummary>, DocumentType>((ref, type) {
      final query = ref.watch(documentListControllerProvider(type));
      return ref
          .watch(documentRepositoryProvider)
          .watchDocumentSummaries(query);
    });

/// The documents linked to a listed row, shown as chips in the chain column.
final listedDocumentChainProvider =
    StreamProvider.family<DocumentChain, String>(
      (ref, chainId) =>
          ref.watch(documentRepositoryProvider).watchDocumentChain(chainId),
    );
