import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../app/theme/app_color_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/document_type_colors.dart';
import '../../domain/models/business_document.dart';
import '../../domain/models/document_type.dart';
import '../../domain/services/document_totals_calculator.dart';
import '../../shared/document_page_metrics.dart';
import '../../shared/formatting/date_formatter.dart';
import '../../shared/formatting/money_formatter.dart';
import '../../shared/formatting/percent_formatter.dart';
import '../../shared/line_item_cell_text.dart';
import 'pdf_fonts.dart';
import 'pdf_text_chunks.dart';

/// Points per logical pixel of the on-screen page at 100% zoom (72 / 96), so
/// every on-screen size maps to the same physical size on paper.
final double _pointsPerPixel =
    DocumentPageMetrics.pointsPerMm / DocumentPageMetrics.mmToLogicalPixels(1);

double _pt(double logicalPixels) => logicalPixels * _pointsPerPixel;

/// Plex's natural line box is 1.3 em; the page uses a 1.4 line height.
const double _extraLineHeightEm = 0.1;

/// Average glyph width used to estimate where text wraps. Plex body text
/// averages a little under half an em; chunks are bounded far below a page,
/// so wider text only makes a chunk taller, never too tall for a page.
const double _averageGlyphWidthEm = 0.5;

/// Width of the type-coloured band down the left edge of every page.
final double stageBandWidthPoints = _pt(
  DocumentPageMetrics.stageBandWidthPx.toDouble(),
);

/// Turns a [BusinessDocument] into a paginated A4 PDF that mirrors the
/// on-screen page: same geometry, sections, copy, typography and visibility
/// rules. Pure: images arrive as bytes, and nothing reads providers.
class DocumentPdfBuilder {
  DocumentPdfBuilder({
    required this.fonts,
    this.totalsCalculator = const DocumentTotalsCalculator(),
  });

  final PdfFontSet fonts;
  final DocumentTotalsCalculator totalsCalculator;

  static const _tokens = AppColorTokens.light;
  static const _maxPages = 200;

  /// The footer prints on every page, so a long note is cut to this many
  /// lines rather than crowding out the body.
  static const footerNoteMaxLines = 3;

  /// Header and customer blocks cannot split across pages, so each field is
  /// capped: a page-tall address would otherwise fail the export.
  static const addressMaxLines = 8;
  static const shortFieldMaxLines = 2;

  static final double _margin =
      DocumentPageMetrics.marginMm * DocumentPageMetrics.pointsPerMm;
  static final double _contentWidth =
      DocumentPageMetrics.pageWidthMm * DocumentPageMetrics.pointsPerMm -
      2 * _margin;

  /// Text inside an on-screen field sits 1 px outline + 3 px padding in, and
  /// 1 px + 2 px down.
  static final _fieldInset = pw.EdgeInsets.symmetric(
    horizontal: _pt(4),
    vertical: _pt(3),
  );

  /// A table cell's text: 1 px cell gap + the field inset across, and the
  /// 4 px row padding + 3 px down.
  static final double _cellHorizontalInset = _pt(5);
  static final double _cellVerticalInset = _pt(7);

  Future<Uint8List> build(
    BusinessDocument document, {
    required Map<String, Uint8List> imagesByAssetId,
  }) {
    final pdf = pw.Document(
      title: '${document.documentType.displayName} ${document.documentNumber}',
      theme: pw.ThemeData.withFont(
        base: fonts.regular,
        bold: fonts.semiBold,
        italic: fonts.regular,
        boldItalic: fonts.semiBold,
      ),
    );
    pdf.addPage(
      pw.MultiPage(
        pageTheme: buildPageTheme(document),
        maxPages: _maxPages,
        footer: (context) => buildFooter(
          document,
          pageNumber: context.pageNumber,
          pageCount: context.pagesCount,
        ),
        build: (_) => buildContent(document, imagesByAssetId: imagesByAssetId),
      ),
    );
    return pdf.save();
  }

  /// A4 with the page margins, and the stage band on every page.
  pw.PageTheme buildPageTheme(BusinessDocument document) {
    final bandColor = _pdfColor(
      DocumentTypeColors.light.inkFor(document.documentType),
    );
    return pw.PageTheme(
      pageFormat: PdfPageFormat(
        DocumentPageMetrics.pageWidthMm * DocumentPageMetrics.pointsPerMm,
        DocumentPageMetrics.pageHeightMm * DocumentPageMetrics.pointsPerMm,
      ),
      margin: pw.EdgeInsets.all(_margin),
      buildBackground: (_) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.SizedBox(
            width: stageBandWidthPoints,
            height: double.infinity,
            child: pw.DecoratedBox(
              decoration: pw.BoxDecoration(color: bandColor),
            ),
          ),
        ),
      ),
    );
  }

  /// The flowing page content, in the on-screen page's section order. Each
  /// top-level widget either fits on a page or splits between bounded parts.
  List<pw.Widget> buildContent(
    BusinessDocument document, {
    required Map<String, Uint8List> imagesByAssetId,
  }) {
    final notesAndSignature = _notesAndSignature(document, imagesByAssetId);
    return [
      _header(document, imagesByAssetId),
      pw.SizedBox(height: _pt(28)),
      _customer(document),
      pw.SizedBox(height: _pt(24)),
      _lineItemTable(document),
      if (document.documentType.showsPricing) ...[
        pw.SizedBox(height: _pt(16)),
        _totals(document),
      ],
      if (notesAndSignature != null) ...[
        pw.SizedBox(height: _pt(28)),
        notesAndSignature,
      ],
    ];
  }

  /// The footer note and "Page x of y", ruled off at the foot of each page.
  pw.Widget buildFooter(
    BusinessDocument document, {
    required int pageNumber,
    required int pageCount,
  }) {
    final layout = document.layoutOptions;
    if (!layout.showFooterNote && !layout.showPageNumbers) {
      return pw.SizedBox();
    }
    return pw.Padding(
      padding: pw.EdgeInsets.only(top: _pt(24)),
      child: pw.DecoratedBox(
        decoration: pw.BoxDecoration(
          border: pw.Border(top: _rule(_tokens.rule)),
        ),
        child: pw.Padding(
          padding: pw.EdgeInsets.only(top: _pt(6)),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: layout.showFooterNote && document.footerNote.isNotEmpty
                    ? _field(
                        document.footerNote,
                        _caption,
                        maxLines: footerNoteMaxLines,
                      )
                    : pw.SizedBox(),
              ),
              if (layout.showPageNumbers) ...[
                pw.SizedBox(width: _pt(24)),
                pw.Padding(
                  padding: pw.EdgeInsets.only(top: _pt(3)),
                  child: pw.Text(
                    'Page $pageNumber of $pageCount',
                    style: _caption,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Typography: DocumentPageStyles in points.

  pw.TextStyle _style({
    required pw.Font font,
    required double fontSizePx,
    PdfColor? color,
    double extraLineHeightEm = _extraLineHeightEm,
  }) {
    final fontSize = _pt(fontSizePx);
    return pw.TextStyle(
      font: font,
      fontSize: fontSize,
      lineSpacing: fontSize * extraLineHeightEm,
      color: color ?? _pdfColor(_tokens.ink),
    );
  }

  pw.TextStyle get _body =>
      _style(font: fonts.regular, fontSizePx: AppTypography.body);

  pw.TextStyle get _caption => _style(
    font: fonts.regular,
    fontSizePx: AppTypography.caption,
    color: _mutedInk,
  );

  pw.TextStyle get _emphasis =>
      _style(font: fonts.semiBold, fontSizePx: AppTypography.body);

  PdfColor get _mutedInk => _pdfColor(
    Color.alphaBlend(_tokens.ink.withValues(alpha: 0.62), _tokens.paper),
  );

  static PdfColor _pdfColor(Color color) => PdfColor.fromInt(color.toARGB32());

  pw.BorderSide _rule(Color color) =>
      pw.BorderSide(color: _pdfColor(color), width: _pt(1));

  /// Text placed where the page has an inline field; empty fields print
  /// nothing.
  pw.Widget _field(
    String text,
    pw.TextStyle style, {
    pw.TextAlign textAlign = pw.TextAlign.left,
    int maxLines = shortFieldMaxLines,
  }) => pw.Padding(
    padding: _fieldInset,
    child: pw.Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
    ),
  );

  List<pw.Widget> _fields(List<(String, pw.TextStyle)> texts) => [
    for (final (text, style) in texts)
      if (text.isNotEmpty) _field(text, style),
  ];

  List<pw.Widget> _addressField(List<String> lines) => [
    if (lines.isNotEmpty)
      _field(lines.join('\n'), _body, maxLines: addressMaxLines),
  ];

  // Sections.

  pw.Widget _header(
    BusinessDocument document,
    Map<String, Uint8List> imagesByAssetId,
  ) {
    final company = document.companyDetails;
    final layout = document.layoutOptions;
    final logo = layout.showLogo
        ? _decodeImage(company.logoAssetId, imagesByAssetId)
        : null;
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 11,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logo != null) ...[
                _imageBox(logo, height: _pt(56)),
                pw.SizedBox(height: _pt(8)),
              ],
              ..._fields([
                (
                  company.companyName,
                  _style(
                    font: fonts.semiBold,
                    fontSizePx: AppTypography.paneTitle,
                  ),
                ),
              ]),
              ..._addressField(company.addressLines),
              ..._fields([
                if (layout.showCompanyRegistration)
                  (company.registrationNumber, _caption),
                (company.phone, _caption),
                (company.email, _caption),
                (company.website, _caption),
              ]),
            ],
          ),
        ),
        pw.SizedBox(width: _pt(24)),
        pw.Expanded(flex: 9, child: _titleAndDates(document)),
      ],
    );
  }

  pw.Widget _titleAndDates(BusinessDocument document) {
    final type = document.documentType;
    final validUntil = document.validUntilDate;
    final deliveryDate = document.deliveryDate;
    final reference = document.customerReference ?? '';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          type.displayName,
          style: _style(
            font: fonts.semiBold,
            fontSizePx: AppTypography.pageTitle + 8,
            color: _pdfColor(DocumentTypeColors.light.inkFor(type)),
            extraLineHeightEm: 0,
          ),
        ),
        pw.SizedBox(height: _pt(4)),
        pw.Text(
          document.documentNumber,
          style: _style(font: fonts.medium, fontSizePx: AppTypography.field),
        ),
        pw.SizedBox(height: _pt(14)),
        _labelledRow('Date', formatDocumentDate(document.issueDate)),
        if (type == DocumentType.quotation && validUntil != null)
          _labelledRow('Valid until', formatDocumentDate(validUntil)),
        if (type == DocumentType.deliveryOrder && deliveryDate != null)
          _labelledRow('Delivery date', formatDocumentDate(deliveryDate)),
        if (document.layoutOptions.showCustomerReference &&
            reference.isNotEmpty)
          _labelledRow('Your reference', reference),
      ],
    );
  }

  pw.Widget _labelledRow(String label, String value) => pw.Padding(
    padding: pw.EdgeInsets.only(top: _pt(2)),
    child: pw.Row(
      children: [
        pw.SizedBox(width: 70),
        pw.Expanded(flex: 5, child: pw.Text(label, style: _caption)),
        pw.Expanded(
          flex: 6,
          child: _field(value, _body, textAlign: pw.TextAlign.right),
        ),
      ],
    ),
  );

  pw.Widget _customer(BusinessDocument document) {
    final customer = document.customerDetails;
    final isDeliveryOrder = document.documentType == DocumentType.deliveryOrder;
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                isDeliveryOrder ? 'Customer' : 'Bill to',
                style: _caption,
              ),
              ..._fields([
                (customer.customerName, _emphasis),
                (customer.attentionTo, _body),
              ]),
              ..._addressField(customer.addressLines),
              ..._fields([
                (customer.phone, _caption),
                (customer.email, _caption),
              ]),
            ],
          ),
        ),
        pw.SizedBox(width: _pt(24)),
        pw.Expanded(
          child: isDeliveryOrder
              ? pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Deliver to', style: _caption),
                    ..._addressField(customer.deliveryAddressLines),
                  ],
                )
              : pw.SizedBox(),
        ),
      ],
    );
  }

  /// The item table. Its header row repeats on every page. A long
  /// description is cut into bounded rows (see [splitTextIntoChunks]) so
  /// the table can break inside a line item; only the first row of a line
  /// carries its number, quantity and prices, and only the last is ruled.
  pw.Widget _lineItemTable(BusinessDocument document) {
    final columns = DocumentPageMetrics.visibleColumns(
      document.layoutOptions,
      document.documentType,
    );
    final format = document.pricingTerms.currencyFormat;
    final totalFlex = columns.fold(0.0, (sum, column) => sum + column.flex);
    final descriptionWidth =
        _contentWidth * LineItemColumn.description.flex / totalFlex -
        2 * _cellHorizontalInset;
    final body = _body;
    final charsPerLine = _charsPerLine(descriptionWidth, body);

    pw.Widget cell(
      LineItemColumn column,
      String text,
      pw.TextStyle style, {
      required double top,
      required double bottom,
    }) => pw.Padding(
      padding: pw.EdgeInsets.fromLTRB(
        _cellHorizontalInset,
        top,
        _cellHorizontalInset,
        bottom,
      ),
      child: pw.Text(
        text,
        style: style,
        textAlign: isNumericColumn(column)
            ? pw.TextAlign.right
            : pw.TextAlign.left,
      ),
    );

    final rows = <pw.TableRow>[
      pw.TableRow(
        repeat: true,
        decoration: pw.BoxDecoration(
          border: pw.Border(bottom: _rule(_tokens.ink)),
        ),
        children: [
          for (final column in columns)
            cell(
              column,
              lineItemColumnLabel(column),
              _caption,
              top: _cellVerticalInset,
              bottom: _cellVerticalInset,
            ),
        ],
      ),
    ];

    final lines = document.lineItems;
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final chunks = splitTextIntoChunks(
        line.description,
        charsPerLine: charsPerLine,
      );
      for (var part = 0; part < chunks.length; part++) {
        final isFirst = part == 0;
        final isLast = part == chunks.length - 1;
        final top = isFirst ? _cellVerticalInset : body.lineSpacing!;
        final bottom = isLast ? _cellVerticalInset : 0.0;
        String textFor(LineItemColumn column) => switch (column) {
          LineItemColumn.description => chunks[part],
          _ when !isFirst => '',
          LineItemColumn.rowNumber => '${index + 1}',
          LineItemColumn.amount => formatMoney(
            totalsCalculator.lineAmountMinor(line),
            format,
            includeSymbol: false,
          ),
          _ => cellDisplayText(column, line, format),
        };
        rows.add(
          pw.TableRow(
            decoration: isLast
                ? pw.BoxDecoration(
                    border: pw.Border(bottom: _rule(_tokens.rule)),
                  )
                : null,
            children: [
              for (final column in columns)
                cell(
                  column,
                  textFor(column),
                  column == LineItemColumn.rowNumber
                      ? body.copyWith(color: _mutedInk)
                      : body,
                  top: top,
                  bottom: bottom,
                ),
            ],
          ),
        );
      }
    }

    return pw.Table(
      columnWidths: {
        for (var index = 0; index < columns.length; index++)
          index: pw.FlexColumnWidth(columns[index].flex),
      },
      children: rows,
    );
  }

  pw.Widget _totals(BusinessDocument document) {
    final totals = totalsCalculator.calculate(document);
    final terms = document.pricingTerms;
    final format = terms.currencyFormat;
    final emphasised = _style(font: fonts.semiBold, fontSizePx: 15);

    pw.Widget row(
      String label,
      String amount, {
      String? note,
      pw.TextStyle? style,
    }) => pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: _pt(2)),
      child: pw.Row(
        children: [
          pw.Text(label, style: style ?? _body),
          if (note != null) ...[
            pw.SizedBox(width: _pt(6)),
            pw.Text(note, style: _caption),
          ],
          pw.Spacer(),
          pw.Text(amount, style: style ?? _body),
        ],
      ),
    );

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: _pt(250),
        child: pw.Column(
          children: [
            row(
              'Subtotal',
              formatMoney(totals.subtotalBeforeDiscountMinor, format),
            ),
            if (totals.discountTotalMinor > 0)
              row('Discount', formatMoney(-totals.discountTotalMinor, format)),
            if (terms.isTaxEnabled)
              row(
                terms.taxLabel,
                formatMoney(totals.taxMinor, format),
                note: formatTaxRate(terms),
              ),
            pw.SizedBox(height: _pt(6)),
            pw.DecoratedBox(
              decoration: pw.BoxDecoration(
                border: pw.Border(top: _rule(_tokens.ink)),
              ),
              child: pw.Padding(
                padding: pw.EdgeInsets.only(top: _pt(6)),
                child: row(
                  'Total',
                  formatMoney(totals.grandTotalMinor, format),
                  style: emphasised,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Notes and terms on the left, the signature on the right. Partitions let
  /// the notes column flow onto later pages; its long texts are cut into
  /// bounded pieces so every piece fits a page.
  pw.Widget? _notesAndSignature(
    BusinessDocument document,
    Map<String, Uint8List> imagesByAssetId,
  ) {
    final layout = document.layoutOptions;
    final showNotes = layout.showNotes && document.notes.isNotEmpty;
    final showTerms =
        layout.showTermsAndConditions && document.termsAndConditions.isNotEmpty;
    if (!showNotes && !showTerms && !layout.showSignature) return null;

    final gap = _pt(32);
    final notesWidth = (_contentWidth - gap) * 3 / 5;
    // Every partition must be able to span: one that cannot reports it has
    // nothing more to lay out, which ends the block after its first page and
    // drops the rest. So the gap is padding inside the signature column.
    return pw.Partitions(
      children: [
        pw.Partition(
          width: notesWidth,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (showNotes) ...[
                pw.Text('Notes', style: _caption),
                ..._flowingField(document.notes, _body, width: notesWidth),
                pw.SizedBox(height: _pt(12)),
              ],
              if (showTerms) ...[
                pw.Text('Terms and conditions', style: _caption),
                ..._flowingField(
                  document.termsAndConditions,
                  _style(font: fonts.regular, fontSizePx: 12),
                  width: notesWidth,
                ),
              ],
            ],
          ),
        ),
        pw.Partition(
          width: _contentWidth - notesWidth,
          child: pw.Padding(
            padding: pw.EdgeInsets.only(left: gap),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (layout.showSignature) _signature(document, imagesByAssetId),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// A long field as bounded pieces that read as one block of text.
  List<pw.Widget> _flowingField(
    String text,
    pw.TextStyle style, {
    required double width,
  }) {
    final chunks = splitTextIntoChunks(
      text,
      charsPerLine: _charsPerLine(width - _fieldInset.horizontal, style),
    );
    return [
      for (var index = 0; index < chunks.length; index++)
        pw.Padding(
          padding: pw.EdgeInsets.fromLTRB(
            _fieldInset.left,
            index == 0 ? _fieldInset.top : style.lineSpacing!,
            _fieldInset.right,
            index == chunks.length - 1 ? _fieldInset.bottom : 0,
          ),
          child: pw.Text(chunks[index], style: style),
        ),
    ];
  }

  pw.Widget _signature(
    BusinessDocument document,
    Map<String, Uint8List> imagesByAssetId,
  ) {
    final signature = document.signatureBlock;
    final image = _decodeImage(signature.signatureAssetId, imagesByAssetId);
    final imageHeight = _pt(56);
    // One unsplittable block: the signature never breaks across pages.
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          height: imageHeight,
          child: image == null ? null : _imageBox(image, height: imageHeight),
        ),
        pw.DecoratedBox(
          decoration: pw.BoxDecoration(
            border: pw.Border(top: _rule(_tokens.ink)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: _fields([
              (signature.signatoryName, _emphasis),
              (signature.signatoryTitle, _body),
              (signature.signatureCaption, _caption),
            ]),
          ),
        ),
      ],
    );
  }

  pw.Widget _imageBox(pw.ImageProvider image, {required double height}) =>
      pw.Align(
        alignment: pw.Alignment.centerLeft,
        child: pw.Image(image, height: height, fit: pw.BoxFit.contain),
      );

  int _charsPerLine(double width, pw.TextStyle style) =>
      (width / (style.fontSize! * _averageGlyphWidthEm)).floor().clamp(8, 400);

  /// The image for [assetId], or null when it is missing or not a readable
  /// image. The bytes are fully decoded first: `pw.MemoryImage` reads only
  /// the header, and a corrupt body would otherwise fail the whole export.
  static pw.ImageProvider? _decodeImage(
    String? assetId,
    Map<String, Uint8List> imagesByAssetId,
  ) {
    final bytes = assetId == null ? null : imagesByAssetId[assetId];
    if (bytes == null) return null;
    try {
      if (img.decodeImage(bytes) == null) return null;
      return pw.MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }
}
