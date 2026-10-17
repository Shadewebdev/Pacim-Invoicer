import 'dart:typed_data';

import 'package:pacim_invoicer/features/pdf_export/pdf_export_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pacim_invoicer/features/pdf_export/pdf_fonts.dart';

/// Records what would have been printed, saved or shared, so no test touches
/// a platform dialog.
class FakePdfOutputTarget implements PdfOutputTarget {
  /// What [savePdf] reports; false behaves like the user cancelling.
  bool saveSucceeds = true;

  /// Makes [savePdf] throw, like a disk error.
  bool failSave = false;

  final List<String> printedNames = [];
  final List<String> savedNames = [];
  final List<String> sharedNames = [];
  final List<Uint8List> outputs = [];

  @override
  Future<void> printPdf(Uint8List bytes, String name) async {
    outputs.add(bytes);
    printedNames.add(name);
  }

  @override
  Future<bool> savePdf(Uint8List bytes, String suggestedName) async {
    if (failSave) throw StateError('fake save failure');
    if (!saveSucceeds) return false;
    outputs.add(bytes);
    savedNames.add(suggestedName);
    return true;
  }

  @override
  Future<void> sharePdf(Uint8List bytes, String name) async {
    outputs.add(bytes);
    sharedNames.add(name);
  }
}

/// Built-in PDF fonts, so tests never load the bundled font files.
PdfFontSet fakePdfFontSet() => PdfFontSet(
  regular: pw.Font.helvetica(),
  medium: pw.Font.helvetica(),
  semiBold: pw.Font.helveticaBold(),
  bold: pw.Font.helveticaBold(),
);
