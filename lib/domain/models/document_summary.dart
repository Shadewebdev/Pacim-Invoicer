import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';

part 'document_summary.freezed.dart';
part 'document_summary.g.dart';

/// Listing row projection of a document.
@freezed
abstract class DocumentSummary with _$DocumentSummary {
  const factory DocumentSummary({
    required String documentId,
    required DocumentType documentType,
    required String documentNumber,
    required String chainId,
    String? sourceDocumentId,
    required String customerName,
    required DateTime issueDate,
    required int grandTotalMinor,
    required String currencyCode,
    required bool isLocked,
    required DateTime updatedAt,
  }) = _DocumentSummary;

  factory DocumentSummary.fromJson(Map<String, dynamic> json) =>
      _$DocumentSummaryFromJson(json);
}
