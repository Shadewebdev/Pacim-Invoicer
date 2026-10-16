import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_totals.freezed.dart';
part 'document_totals.g.dart';

/// Computed totals of a document, in minor units. Never the stored truth.
@freezed
abstract class DocumentTotals with _$DocumentTotals {
  const factory DocumentTotals({
    required Map<String, int> lineAmountMinorById,
    required int subtotalBeforeDiscountMinor,
    required int discountTotalMinor,
    required int subtotalMinor,
    required int taxMinor,
    required int grandTotalMinor,
  }) = _DocumentTotals;

  factory DocumentTotals.fromJson(Map<String, dynamic> json) =>
      _$DocumentTotalsFromJson(json);
}
