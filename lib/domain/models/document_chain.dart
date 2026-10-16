import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pacim_invoicer/domain/models/document_summary.dart';

part 'document_chain.freezed.dart';
part 'document_chain.g.dart';

/// The documents linked by upgrades, used for the breadcrumb.
@freezed
abstract class DocumentChain with _$DocumentChain {
  const factory DocumentChain({
    required String chainId,
    DocumentSummary? quotation,
    DocumentSummary? salesOrder,

    /// Ordered by document number.
    @Default(<DocumentSummary>[]) List<DocumentSummary> deliveryOrders,
  }) = _DocumentChain;

  factory DocumentChain.fromJson(Map<String, dynamic> json) =>
      _$DocumentChainFromJson(json);
}
