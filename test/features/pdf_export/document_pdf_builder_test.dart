import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/document_layout_options.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/models/line_item.dart';
import 'package:pacim_invoicer/features/pdf_export/document_pdf_builder.dart';
import 'package:pacim_invoicer/features/pdf_export/pdf_fonts.dart';

import '../../support/document_builders.dart';

/// Every widget in [widget]'s tree. Throws on a widget type it cannot see
/// into, so a test can never silently miss text.
Iterable<pw.Widget> _descendants(pw.Widget widget) sync* {
  yield widget;
  final children = switch (widget) {
    pw.MultiChildWidget(:final children) => children,
    pw.SingleChildWidget(:final child) => [?child],
    pw.SizedBox(:final child) => [?child],
    pw.Table(:final children) => [for (final row in children) ...row.children],
    pw.Partitions(:final children) => [
      for (final partition in children) partition.child,
    ],
    pw.RichText() || pw.Image() => const <pw.Widget>[],
    _ => throw UnsupportedError('Unknown widget ${widget.runtimeType}'),
  };
  for (final child in children) {
    yield* _descendants(child);
  }
}

String _spanText(pw.InlineSpan span) => switch (span) {
  pw.TextSpan(:final text, :final children) =>
    '${text ?? ''}${(children ?? const []).map(_spanText).join()}',
  _ => '',
};

List<String> _texts(Iterable<pw.Widget> widgets) => [
  for (final root in widgets)
    for (final widget in _descendants(root))
      if (widget is pw.RichText) _spanText(widget.text),
];

int _pageCount(Uint8List pdfBytes) =>
    RegExp(r'/Type\s*/Page(?![a-zA-Z])')
        .allMatches(latin1.decode(pdfBytes))
        .length;

Uint8List _pngBytes() =>
    Uint8List.fromList(img.encodePng(img.Image(width: 4, height: 2)));

List<LineItem> _lines(int count) => [
  for (var i = 0; i < count; i++) buildTestLine(id: 'line-$i'),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DocumentPdfBuilder builder;

  setUpAll(() async {
    builder = DocumentPdfBuilder(fonts: await PdfFontSet.load());
  });

  List<String> contentTexts(
    BusinessDocument document, {
    Map<String, Uint8List> images = const {},
  }) => _texts(builder.buildContent(document, imagesByAssetId: images));

  test('builds a non-empty PDF starting with %PDF', () async {
    final bytes = await builder.build(
      buildTestDocument(),
      imagesByAssetId: const {},
    );
    expect(bytes.length, greaterThan(1000));
    expect(latin1.decode(bytes.sublist(0, 4)), '%PDF');
    expect(_pageCount(bytes), 1);
  });

  test('60 lines produce more than one page', () async {
    final bytes = await builder.build(
      buildTestDocument(lineItems: _lines(60)),
      imagesByAssetId: const {},
    );
    expect(_pageCount(bytes), greaterThan(1));
  });

  test('content includes document number and customer name', () {
    final texts = contentTexts(buildTestDocument());
    expect(texts, contains('QT-2026-0001'));
    expect(texts, contains('Acme Trading'));
    expect(texts, contains('Pacim Sdn Bhd'));
    expect(texts, contains('Quotation'));
    expect(texts, contains('Bill to'));
    expect(texts, contains('Total'));
    expect(texts, contains('RM21.60'));
  });

  test('delivery order PDF contains no currency symbol', () {
    final document = buildTestDocument(type: DocumentType.deliveryOrder);
    final texts = [
      ...contentTexts(document),
      ..._texts([builder.buildFooter(document, pageNumber: 1, pageCount: 1)]),
    ];
    expect(texts.where((text) => text.contains('RM')), isEmpty);
    expect(texts, isNot(contains('Unit price')));
    expect(texts, isNot(contains('Amount')));
    expect(texts, isNot(contains('Total')));
    expect(texts, isNot(contains('10.00')));
    expect(texts, containsAll(['Delivery order', 'Deliver to', 'Qty']));
  });

  test(
    'a 2000-character multi-line description builds without exception',
    () async {
      final description = List.generate(
        40,
        (i) => 'Line $i of a long specification, measured and cut.',
      ).join('\n');
      expect(description.length, greaterThanOrEqualTo(2000));
      final document = buildTestDocument(
        lineItems: [
          buildTestLine().copyWith(description: description),
          buildTestLine(id: 'line-2'),
        ],
      );

      final bytes = await builder.build(document, imagesByAssetId: const {});

      // About 80 wrapped lines plus the header: it must flow onto page 2.
      expect(_pageCount(bytes), inInclusiveRange(2, 4));
      final table = builder
          .buildContent(document, imagesByAssetId: const {})
          .whereType<pw.Table>()
          .single;
      // Header, the description in several bounded rows, then line 2.
      expect(table.children.length, greaterThan(4));
      final descriptionTexts = contentTexts(document)
          .where((text) => text.startsWith('Line '));
      expect(descriptionTexts.join('\n'), description);
    },
  );

  test('a single description longer than a page splits across pages', () async {
    final description = List.filled(1500, 'galvanised').join(' ');
    final document = buildTestDocument(
      lineItems: [buildTestLine().copyWith(description: description)],
    );

    final bytes = await builder.build(document, imagesByAssetId: const {});

    // About 16,500 characters: every row must reach the PDF, not just a page.
    expect(_pageCount(bytes), greaterThanOrEqualTo(6));
  });

  test('long notes and terms split across pages without exception', () async {
    final longText = List.generate(
      300,
      (i) => 'Clause $i: goods remain ours until paid in full.',
    ).join('\n');
    final document = buildTestDocument().copyWith(
      notes: longText,
      termsAndConditions: List.filled(2000, 'terms').join(' '),
    );

    final bytes = await builder.build(document, imagesByAssetId: const {});

    // Over 26,000 characters of notes and terms; a block that stops
    // spanning after one page would silently drop the rest.
    expect(_pageCount(bytes), greaterThanOrEqualTo(8));
  });

  test('item table repeats its column header row on every page', () {
    final table = builder
        .buildContent(
          buildTestDocument(lineItems: _lines(60)),
          imagesByAssetId: const {},
        )
        .whereType<pw.Table>()
        .single;
    expect(table.children.first.repeat, isTrue);
    expect(table.children.skip(1).where((row) => row.repeat), isEmpty);
    expect(table.children, hasLength(61));
  });

  test('hidden signature is absent', () {
    final shown = buildTestDocument();
    expect(contentTexts(shown), containsAll(['A. Tan', 'Director']));

    final hidden = shown.copyWith(
      layoutOptions: const DocumentLayoutOptions(showSignature: false),
    );
    final texts = contentTexts(hidden);
    expect(texts, isNot(contains('A. Tan')));
    expect(texts, isNot(contains('Director')));
    expect(texts, isNot(contains('Authorised signature')));
  });

  test('hidden notes, terms and registration are absent', () {
    final document = buildTestDocument().copyWith(
      layoutOptions: const DocumentLayoutOptions(
        showNotes: false,
        showTermsAndConditions: false,
        showCompanyRegistration: false,
        showCustomerReference: false,
      ),
    );
    final texts = contentTexts(document);
    expect(texts, isNot(contains('Thank you.')));
    expect(texts, isNot(contains('Payment within 30 days.')));
    expect(texts, isNot(contains('202001000001')));
    expect(texts, isNot(contains('PO-778')));
  });

  test('columns follow the layout options', () {
    final withDiscount = buildTestDocument().copyWith(
      layoutOptions: const DocumentLayoutOptions(
        showDiscountColumn: true,
        showUnitColumn: false,
      ),
    );
    final texts = contentTexts(withDiscount);
    expect(texts, containsAll(['#', 'Description', 'Qty', 'Discount']));
    expect(texts, isNot(contains('Unit')));
    expect(texts, isNot(contains('pcs')));
  });

  test(
    'images are drawn when valid and skipped silently when corrupt',
    () async {
      final document = buildTestDocument();
      List<pw.Image> imagesIn(Map<String, Uint8List> images) => [
        for (final root in builder.buildContent(
          document,
          imagesByAssetId: images,
        ))
          ..._descendants(root).whereType<pw.Image>(),
      ];

      expect(
        imagesIn({'logo-1': _pngBytes(), 'sig-1': _pngBytes()}),
        hasLength(2),
      );
      expect(
        imagesIn({
          'logo-1': Uint8List.fromList([1, 2, 3]),
        }),
        isEmpty,
      );
      expect(imagesIn({'logo-1': _pngBytes().sublist(0, 40)}), isEmpty);
      expect(imagesIn(const {}), isEmpty);
      final bytes = await builder.build(
        document,
        imagesByAssetId: {
          'logo-1': Uint8List.fromList([1, 2, 3]),
        },
      );
      expect(latin1.decode(bytes.sublist(0, 4)), '%PDF');
    },
  );

  test('footer shows the footer note and page x of y', () {
    final document = buildTestDocument();
    expect(
      _texts([builder.buildFooter(document, pageNumber: 2, pageCount: 3)]),
      containsAll(['Computer generated.', 'Page 2 of 3']),
    );

    final noFooter = document.copyWith(
      layoutOptions: const DocumentLayoutOptions(
        showFooterNote: false,
        showPageNumbers: false,
      ),
    );
    expect(
      _texts([builder.buildFooter(noFooter, pageNumber: 1, pageCount: 1)]),
      isEmpty,
    );
  });

  test('pages are A4 with 18 mm margins and a stage band background', () {
    final theme = builder.buildPageTheme(buildTestDocument());
    expect(theme.pageFormat.width, closeTo(PdfPageFormat.a4.width, 0.01));
    expect(theme.pageFormat.height, closeTo(PdfPageFormat.a4.height, 0.01));
    expect(
      (theme.margin! as pw.EdgeInsets).left,
      closeTo(18 * PdfPageFormat.mm, 0.01),
    );
    expect(
      (theme.margin! as pw.EdgeInsets).top,
      closeTo(18 * PdfPageFormat.mm, 0.01),
    );
    expect(theme.buildBackground, isNotNull);
    // The 4 px screen band at 0.75 pt per pixel.
    expect(stageBandWidthPoints, closeTo(3, 1e-9));
  });

  group('worst-case text', () {
    Future<int> buildPages(BusinessDocument document) async {
      final bytes = await builder.build(document, imagesByAssetId: const {});
      expect(latin1.decode(bytes.sublist(0, 4)), '%PDF');
      return _pageCount(bytes);
    }

    BusinessDocument withDescription(String description) => buildTestDocument(
      lineItems: [buildTestLine().copyWith(description: description)],
    );

    test('3000 wide characters with no spaces paginate', () async {
      final pages = await buildPages(withDescription('W' * 3000));
      expect(pages, allOf(greaterThan(1), lessThan(200)));
    });

    test('wide words mixed with line breaks paginate', () async {
      final description = List.generate(
        250,
        (i) => i % 4 == 3 ? 'WWWWWWWWWWWWWWWW\n' : 'WWWWWWWWWWWWWWWW ',
      ).join();
      expect(description.length, greaterThanOrEqualTo(4000));
      final pages = await buildPages(withDescription(description));
      expect(pages, allOf(greaterThan(1), lessThan(200)));
    });

    test('notes of 3000 wide characters paginate', () async {
      final pages = await buildPages(
        buildTestDocument().copyWith(notes: 'W' * 3000),
      );
      expect(pages, allOf(greaterThan(1), lessThan(200)));
    });

    test('a 2000-character footer note is clamped to three lines', () async {
      final footerNote = List.filled(400, 'note').join(' ');
      final document = buildTestDocument().copyWith(footerNote: footerNote);
      final footerTexts = _descendants(
        builder.buildFooter(document, pageNumber: 1, pageCount: 1),
      ).whereType<pw.RichText>().toList();
      final noteText = footerTexts.singleWhere(
        (text) => _spanText(text.text) == footerNote,
      );
      expect(noteText.maxLines, DocumentPdfBuilder.footerNoteMaxLines);

      final short = await buildPages(buildTestDocument(lineItems: _lines(60)));
      final long = await buildPages(
        buildTestDocument(lineItems: _lines(60))
            .copyWith(footerNote: footerNote),
      );
      expect(long, lessThanOrEqualTo(short + 1));
    });

    test('a 200-line customer address builds without throwing', () async {
      final document = buildTestDocument().copyWith(
        customerDetails: buildTestDocument().customerDetails.copyWith(
          addressLines: [for (var i = 0; i < 200; i++) 'Address line $i'],
          deliveryAddressLines: [for (var i = 0; i < 200; i++) 'Dock $i'],
        ),
        companyDetails: buildTestDocument().companyDetails.copyWith(
          addressLines: [for (var i = 0; i < 200; i++) 'Company line $i'],
          companyName: List.filled(200, 'Name').join(' '),
        ),
      );
      expect(await buildPages(document), lessThan(200));
      expect(
        await buildPages(
          document.copyWith(documentType: DocumentType.deliveryOrder),
        ),
        lessThan(200),
      );
    });

    test('CJK and Tamil text builds without throwing', () async {
      final document =
          buildTestDocument(
            lineItems: [buildTestLine().copyWith(description: '陈大文 தமிழ்')],
          ).copyWith(
            customerDetails: buildTestDocument().customerDetails.copyWith(
              customerName: '陈大文',
              attentionTo: 'தமிழ்',
            ),
            notes: '陈大文 தமிழ் ' * 50,
          );
      expect(await buildPages(document), greaterThanOrEqualTo(1));
    });
  });
}
