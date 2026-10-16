import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_layout_options.freezed.dart';
part 'document_layout_options.g.dart';

/// Which optional blocks appear on the page and in the PDF.
@freezed
abstract class DocumentLayoutOptions with _$DocumentLayoutOptions {
  const factory DocumentLayoutOptions({
    @Default(true) bool showLogo,
    @Default(true) bool showCompanyRegistration,
    @Default(true) bool showCustomerReference,
    @Default(true) bool showNotes,
    @Default(true) bool showTermsAndConditions,
    @Default(true) bool showFooterNote,
    @Default(true) bool showSignature,
    @Default(true) bool showPageNumbers,
    @Default(false) bool showDiscountColumn,
    @Default(true) bool showUnitColumn,
  }) = _DocumentLayoutOptions;

  factory DocumentLayoutOptions.fromJson(Map<String, dynamic> json) =>
      _$DocumentLayoutOptionsFromJson(json);
}
