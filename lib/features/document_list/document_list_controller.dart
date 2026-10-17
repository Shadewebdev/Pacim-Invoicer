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

  /// Grows the limit by one page, but only when [loadedCount] rows fill the
  /// current limit, so repeated scroll events while a page is loading (or a
  /// list that is already complete) change nothing.
  void loadMore({required int loadedCount}) {
    if (loadedCount < state.limit) return;
    state = state.copyWith(limit: state.limit + _pageSize);
  }
}

final documentListControllerProvider =
    NotifierProvider.family<
      DocumentListController,
      DocumentListQuery,
      DocumentType
    >(DocumentListController.new);

final documentSummariesProvider = StreamProvider.autoDispose
    .family<List<DocumentSummary>, DocumentType>((ref, type) {
      final query = ref.watch(documentListControllerProvider(type));
      return ref
          .watch(documentRepositoryProvider)
          .watchDocumentSummaries(query);
    });

/// How many documents match the listing's filters, whatever the page size.
final documentCountProvider = StreamProvider.autoDispose
    .family<int, DocumentType>((ref, type) {
      final query = ref.watch(documentListControllerProvider(type));
      return ref.watch(documentRepositoryProvider).watchDocumentCount(query);
    });

/// The documents linked to a listed row, shown as chips in the chain column.
final listedDocumentChainProvider = StreamProvider.autoDispose
    .family<DocumentChain, String>(
      (ref, chainId) =>
          ref.watch(documentRepositoryProvider).watchDocumentChain(chainId),
    );
