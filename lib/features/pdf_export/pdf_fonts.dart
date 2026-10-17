import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// The bundled IBM Plex Sans faces embedded in every PDF, the same font the
/// on-screen page uses, so the page matches the PDF.
class PdfFontSet {
  const PdfFontSet({
    required this.regular,
    required this.medium,
    required this.semiBold,
    required this.bold,
  });

  final pw.Font regular;
  final pw.Font medium;
  final pw.Font semiBold;
  final pw.Font bold;

  static const _fontDirectory = 'assets/fonts';

  static Future<PdfFontSet> load({AssetBundle? bundle}) async {
    final assets = bundle ?? rootBundle;
    Future<pw.Font> face(String name) async =>
        pw.Font.ttf(await assets.load('$_fontDirectory/IBMPlexSans-$name.ttf'));

    final faces = await Future.wait([
      face('Regular'),
      face('Medium'),
      face('SemiBold'),
      face('Bold'),
    ]);
    return PdfFontSet(
      regular: faces[0],
      medium: faces[1],
      semiBold: faces[2],
      bold: faces[3],
    );
  }
}
