import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pacim_invoicer/domain/models/company_details.dart';
import 'package:pacim_invoicer/domain/models/currency_format.dart';
import 'package:pacim_invoicer/domain/models/document_layout_options.dart';
import 'package:pacim_invoicer/domain/models/document_numbering_rule.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/models/pricing_terms.dart';
import 'package:pacim_invoicer/domain/models/signature_block.dart';

part 'document_settings.freezed.dart';
part 'document_settings.g.dart';

/// The single global settings record. Documents copy from it at creation.
@freezed
abstract class DocumentSettings with _$DocumentSettings {
  const factory DocumentSettings({
    required CompanyDetails companyDetails,
    required Map<DocumentType, DocumentLayoutOptions> layoutOptionsByType,
    required PricingTerms pricingTerms,
    required Map<DocumentType, String> defaultTermsByType,
    required String defaultFooterNote,
    required Map<DocumentType, SignatureBlock> signatureBlockByType,
    required Map<DocumentType, DocumentNumberingRule> numberingRuleByType,
    @Default(30) int quotationValidityDays,

    /// One of `system`, `light` or `dark`.
    @Default('system') String appearance,
  }) = _DocumentSettings;

  /// Factory defaults, with every per-type map filled for all document types.
  factory DocumentSettings.initial() {
    const numberingPrefixByType = {
      DocumentType.quotation: 'QT',
      DocumentType.salesOrder: 'SO',
      DocumentType.deliveryOrder: 'DO',
    };
    return DocumentSettings(
      companyDetails: const CompanyDetails(),
      layoutOptionsByType: {
        for (final type in DocumentType.values)
          type: const DocumentLayoutOptions(),
      },
      pricingTerms: const PricingTerms(
        currencyFormat: CurrencyFormat.defaultFormat,
      ),
      defaultTermsByType: {for (final type in DocumentType.values) type: ''},
      defaultFooterNote: '',
      signatureBlockByType: {
        for (final type in DocumentType.values)
          type: SignatureBlock(
            signatureCaption: type == DocumentType.deliveryOrder
                ? 'Received by'
                : 'Authorised signature',
          ),
      },
      numberingRuleByType: {
        for (final type in DocumentType.values)
          type: DocumentNumberingRule(
            pattern: '${numberingPrefixByType[type]}-{yyyy}-{seq:4}',
          ),
      },
    );
  }

  factory DocumentSettings.fromJson(Map<String, dynamic> json) =>
      _$DocumentSettingsFromJson(json);
}
