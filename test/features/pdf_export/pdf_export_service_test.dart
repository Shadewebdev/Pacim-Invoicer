import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/domain/models/customer_details.dart';
import 'package:pacim_invoicer/features/pdf_export/document_pdf_builder.dart';
import 'package:pacim_invoicer/features/pdf_export/pdf_export_service.dart';
import 'package:pacim_invoicer/features/pdf_export/pdf_fonts.dart';

import '../../support/document_builders.dart';
import '../../support/fake_pdf_output_target.dart';
import '../../support/fake_repositories.dart';

PdfExportService _service(
  FakePdfOutputTarget target, {
  bool sharesInsteadOfSaving = false,
  PdfDocumentBuilder? buildPdf,
}) => PdfExportService(
  target: target,
  assets: FakeAssetRepository(),
  buildPdf: buildPdf ?? fakePdfBuilder,
  sharesInsteadOfSaving: sharesInsteadOfSaving,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final service = _service(FakePdfOutputTarget());

  test('suggestedFileName sanitises', () {
    final document = buildTestDocument().copyWith(
      customerDetails: const CustomerDetails(customerName: 'A/B: "Co"'),
    );
    expect(service.suggestedFileName(document), 'QT-2026-0001 A-B- -Co-.pdf');
  });

  test('control characters, trailing dots and spaces are removed', () {
    final document = buildTestDocument().copyWith(
      customerDetails: const CustomerDetails(customerName: 'Co\u0085x. . '),
    );
    expect(service.suggestedFileName(document), 'QT-2026-0001 Co-x.pdf');
  });

  test('the cap counts characters, not UTF-16 units', () {
    final document = buildTestDocument().copyWith(
      customerDetails: CustomerDetails(customerName: '\u{1F600}' * 300),
    );
    final name = service.suggestedFileName(document);
    expect(name.runes.length, 120);
    expect(
      name.codeUnits.where((unit) => unit >= 0xD800 && unit < 0xDC00),
      hasLength(103),
    );
  });

  test('a name cut at a dot does not end in dots', () {
    final document = buildTestDocument().copyWith(
      customerDetails: CustomerDetails(customerName: '${'x' * 102}.....more'),
    );
    expect(service.suggestedFileName(document), endsWith('x.pdf'));
  });

  test('empty customer uses number only', () {
    final document = buildTestDocument().copyWith(
      customerDetails: const CustomerDetails(customerName: '  '),
    );
    expect(service.suggestedFileName(document), 'QT-2026-0001.pdf');
  });

  test('long names are capped at 120 chars ending in .pdf', () {
    final document = buildTestDocument().copyWith(
      customerDetails: CustomerDetails(customerName: 'x' * 300),
    );
    final name = service.suggestedFileName(document);
    expect(name.length, 120);
    expect(name, endsWith('.pdf'));
  });

  test('the real builder produces a PDF with the bundled fonts', () async {
    final fonts = await PdfFontSet.load();
    final target = FakePdfOutputTarget();
    final realService = _service(
      target,
      buildPdf: (document, images) =>
          DocumentPdfBuilder(fonts: fonts)
              .build(document, imagesByAssetId: images),
    );

    await realService.exportDocument(buildTestDocument());

    expect(target.outputs.single.take(4), '%PDF'.codeUnits);
    expect(target.outputs.single.length, greaterThan(1000));
  });

  test('saving exports and reports the file name', () async {
    final target = FakePdfOutputTarget();
    final outcome = await _service(target).exportDocument(buildTestDocument());
    expect(outcome, PdfExportOutcome.exported);
    expect(target.savedNames, ['QT-2026-0001 Acme Trading.pdf']);
    expect(target.outputs.single.take(4), '%PDF'.codeUnits);
  });

  test('a cancelled save dialog is reported as cancelled', () async {
    final target = FakePdfOutputTarget()..saveSucceeds = false;
    final outcome = await _service(target).exportDocument(buildTestDocument());
    expect(outcome, PdfExportOutcome.cancelled);
  });

  test('sharing platforms share instead of saving', () async {
    final target = FakePdfOutputTarget();
    final outcome = await _service(
      target,
      sharesInsteadOfSaving: true,
    ).exportDocument(buildTestDocument());
    expect(outcome, PdfExportOutcome.exported);
    expect(target.sharedNames, ['QT-2026-0001 Acme Trading.pdf']);
    expect(target.savedNames, isEmpty);
  });

  test('printDocument sends the PDF to the print target', () async {
    final target = FakePdfOutputTarget();
    await _service(target).printDocument(buildTestDocument());
    expect(target.printedNames, ['QT-2026-0001 Acme Trading.pdf']);
  });
}
