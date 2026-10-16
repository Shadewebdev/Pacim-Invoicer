import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/document_type_colors.dart';
import '../../../shared/document_page_metrics.dart';
import '../document_editor_controller.dart';
import '../line_item_grid/line_item_grid.dart';
import 'document_page_customer.dart';
import 'document_page_footer.dart';
import 'document_page_header.dart';
import 'document_page_notes_and_signature.dart';
import 'document_page_styles.dart';
import 'document_page_totals.dart';

/// The document as a real A4 page at 100% zoom: white paper, a single soft
/// shadow, and the type's ink as a band down the left edge. Zoom is applied
/// by the canvas around this widget.
class DocumentPageView extends ConsumerWidget {
  const DocumentPageView({required this.documentId, super.key});

  final String documentId;

  static double get pageWidth => DocumentPageMetrics.mmToLogicalPixels(
    DocumentPageMetrics.pageWidthMm.toDouble(),
  );

  static double get pageHeight => DocumentPageMetrics.mmToLogicalPixels(
    DocumentPageMetrics.pageHeightMm.toDouble(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = ref.watch(
      documentEditorControllerProvider(documentId)
          .select((state) => state.value?.document),
    );
    // Until the document loads, hold the page's footprint so nothing jumps.
    if (document == null) {
      return SizedBox(width: pageWidth, height: pageHeight);
    }
    final bandColor = Theme.of(context)
        .extension<DocumentTypeColors>()!
        .inkFor(document.documentType);
    final margin = DocumentPageMetrics.mmToLogicalPixels(
      DocumentPageMetrics.marginMm.toDouble(),
    );

    return DefaultTextStyle(
      style: DocumentPageStyles.body,
      child: SizedBox(
        width: pageWidth,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: DocumentPageStyles.tokens.paper,
            boxShadow: const [
              BoxShadow(
                color: Color(0x29000000),
                blurRadius: 18,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: pageHeight),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: DocumentPageMetrics.stageBandWidthPx.toDouble(),
                  child: ColoredBox(
                    key: const ValueKey('stageBand'),
                    color: bandColor,
                  ),
                ),
                Padding(
                  // The item grid reaches into the left margin for its row
                  // controls; every other section is inset back to the margin.
                  padding: EdgeInsets.fromLTRB(
                    margin - LineItemGrid.gutterWidth,
                    margin,
                    margin,
                    margin,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: pageHeight - 2 * margin,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _InsetFromGutter(
                              child: DocumentPageHeader(documentId: documentId),
                            ),
                            const SizedBox(height: 28),
                            _InsetFromGutter(
                              child: DocumentPageCustomer(
                                documentId: documentId,
                              ),
                            ),
                            const SizedBox(height: 24),
                            LineItemGrid(documentId: documentId),
                            if (document.documentType.showsPricing) ...[
                              const SizedBox(height: 16),
                              _InsetFromGutter(
                                child: DocumentPageTotals(
                                  documentId: documentId,
                                ),
                              ),
                            ],
                            const SizedBox(height: 28),
                            _InsetFromGutter(
                              child: DocumentPageNotesAndSignature(
                                documentId: documentId,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 24,
                            left: LineItemGrid.gutterWidth,
                          ),
                          child: DocumentPageFooter(documentId: documentId),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Puts a page section back on the left margin, past the grid's gutter.
class _InsetFromGutter extends StatelessWidget {
  const _InsetFromGutter({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: LineItemGrid.gutterWidth),
    child: child,
  );
}
