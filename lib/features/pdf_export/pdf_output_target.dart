import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';

/// Where a finished PDF goes. Behind an interface so the export flow can be
/// tested without platform dialogs.
abstract interface class PdfOutputTarget {
  /// Opens the system print dialog.
  Future<void> printPdf(Uint8List bytes, String name);

  /// Asks where to save the file. Returns false when the person cancelled.
  Future<bool> savePdf(Uint8List bytes, String suggestedName);

  /// Hands the file to the system share sheet or starts a download.
  Future<void> sharePdf(Uint8List bytes, String name);
}

/// The real target, built on the `printing` and `file_picker` packages.
class PlatformPdfOutputTarget implements PdfOutputTarget {
  const PlatformPdfOutputTarget();

  @override
  Future<void> printPdf(Uint8List bytes, String name) async {
    await Printing.layoutPdf(onLayout: (_) async => bytes, name: name);
  }

  @override
  Future<bool> savePdf(Uint8List bytes, String suggestedName) async {
    final location = await FilePicker.saveFile(
      fileName: suggestedName,
      bytes: bytes,
      mimeType: 'application/pdf',
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    return location != null;
  }

  @override
  Future<void> sharePdf(Uint8List bytes, String name) async {
    await Printing.sharePdf(bytes: bytes, filename: name);
  }
}
