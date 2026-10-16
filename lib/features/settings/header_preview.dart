import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../app/theme/app_color_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/document_type_colors.dart';
import '../../domain/models/document_settings.dart';
import '../../domain/models/document_type.dart';

const double _paperInset = 16;

/// A miniature of the top and bottom of the page, redrawn as settings change.
class HeaderPreview extends StatelessWidget {
  const HeaderPreview({
    required this.settings,
    required this.documentType,
    required this.sampleDocumentNumber,
    this.logoBytes,
    super.key,
  });

  final DocumentSettings settings;
  final DocumentType documentType;
  final String sampleDocumentNumber;
  final Uint8List? logoBytes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorTokens>()!;
    final colors = theme.extension<DocumentTypeColors>()!;
    final company = settings.companyDetails;
    final options = settings.layoutOptionsByType[documentType]!;
    // The page stays white and dark-on-light in both themes.
    const pageInk = Color(0xFF1E2633);
    final pageMutedInk = pageInk.withValues(alpha: 0.7);
    final baseStyle = TextStyle(
      fontFamily: AppTypography.documentFontFamily,
      fontSize: 11,
      height: 1.35,
      color: pageInk,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final contactLines = [
      company.phone,
      company.email,
      company.website,
    ].where((line) => line.isNotEmpty);
    final hasCompanyName = company.companyName.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Page header preview', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.paper,
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: colors.tintFor(documentType)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(_paperInset),
                    child: DefaultTextStyle(
                      style: baseStyle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (options.showLogo && logoBytes != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxHeight: 44,
                                            maxWidth: 120,
                                          ),
                                          child: Image.memory(
                                            logoBytes!,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      hasCompanyName
                                          ? company.companyName
                                          : 'Your company name',
                                      style: baseStyle.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: hasCompanyName
                                            ? pageInk
                                            : pageMutedInk,
                                      ),
                                    ),
                                    if (options.showCompanyRegistration &&
                                        company.registrationNumber.isNotEmpty)
                                      Text(
                                        'Reg. ${company.registrationNumber}',
                                        style: baseStyle.copyWith(
                                          color: pageMutedInk,
                                        ),
                                      ),
                                    for (final line in company.addressLines)
                                      Text(line),
                                    for (final line in contactLines) Text(line),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    documentType.displayName,
                                    style: baseStyle.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'No. $sampleDocumentNumber',
                                    style: baseStyle.copyWith(
                                      color: pageMutedInk,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (options.showFooterNote &&
                              settings.defaultFooterNote.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Divider(color: tokens.rule, height: 1),
                            const SizedBox(height: 6),
                            Text(
                              settings.defaultFooterNote,
                              style: baseStyle.copyWith(
                                fontSize: 10,
                                color: pageMutedInk,
                              ),
                            ),
                          ],
                          if (options.showPageNumbers) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Page 1 of 1',
                                style: baseStyle.copyWith(
                                  fontSize: 10,
                                  color: pageMutedInk,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
