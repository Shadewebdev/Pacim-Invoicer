import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pacim_invoicer/domain/models/currency_format.dart';

part 'pricing_terms.freezed.dart';
part 'pricing_terms.g.dart';

/// Currency and tax settings of a document.
@freezed
abstract class PricingTerms with _$PricingTerms {
  const factory PricingTerms({
    required CurrencyFormat currencyFormat,
    @Default('Tax') String taxLabel,

    /// Tax rate times 100, so 800 means 8%.
    @Default(0) int taxRatePercentScaled,
    @Default(false) bool isTaxEnabled,
  }) = _PricingTerms;

  factory PricingTerms.fromJson(Map<String, dynamic> json) =>
      _$PricingTermsFromJson(json);
}
