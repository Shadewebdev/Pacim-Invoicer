import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';

part 'document_list_query.freezed.dart';
part 'document_list_query.g.dart';

enum DocumentSortField {
  documentNumber,
  customerName,
  issueDate,
  grandTotal,
  updatedAt,
}

/// Filter, sort and page size for a listing. Paging grows [limit].
@freezed
abstract class DocumentListQuery with _$DocumentListQuery {
  const factory DocumentListQuery({
    required DocumentType documentType,
    @Default('') String searchText,
    DateTime? issuedFrom,
    DateTime? issuedTo,
    @Default(DocumentSortField.issueDate) DocumentSortField sortField,
    @Default(true) bool sortDescending,
    @Default(50) int limit,
  }) = _DocumentListQuery;

  factory DocumentListQuery.fromJson(Map<String, dynamic> json) =>
      _$DocumentListQueryFromJson(json);
}
