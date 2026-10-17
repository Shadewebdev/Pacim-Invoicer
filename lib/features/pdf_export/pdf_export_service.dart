import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/asset_repository.dart';
import '../../data/repository_providers.dart';
import '../../domain/models/business_document.dart';
import 'document_pdf_builder.dart';
import 'pdf_fonts.dart';
import 'pdf_output_target.dart';

export 'pdf_output_target.dart';

const int _maximumFileNameLength = 120;
const String _fileExtension = '.pdf';
final RegExp _forbiddenFileNameCharacters = RegExp(
  r'[<>:"/\\|?*\x00-\x1f\x7f-\x9f]',
);
final RegExp _trailingSpacesAndDots = RegExp(r'[ .]+$');
final RegExp _whitespaceRun = RegExp(r'\s+');

/// Builds the PDF bytes of a document from its images by asset id.
typedef PdfDocumentBuilder = Future<Uint8List> Function(
  BusinessDocument document,
  Map<String, Uint8List> imagesByAssetId,
);

enum PdfExportOutcome { exported, cancelled }

/// Builds a document's PDF and prints, saves or shares it.
class PdfExportService {
  PdfExportService({
    required this.target,
    required this.assets,
    required this.buildPdf,
    required this.sharesInsteadOfSaving,
  });

  final PdfOutputTarget target;
  final AssetRepository assets;
  final PdfDocumentBuilder buildPdf;

  /// True where there is no save dialog (Android and web), so the PDF is
  /// shared or downloaded instead.
  final bool sharesInsteadOfSaving;

  /// `<number> <customerName>.pdf`, safe to use as a file name on Windows.
  String suggestedFileName(BusinessDocument document) {
    final customerName = document.customerDetails.customerName.trim();
    final base = '${document.documentNumber} $customerName'
        .replaceAll(_forbiddenFileNameCharacters, '-')
        .replaceAll(_whitespaceRun, ' ')
        .trim();
    final maximumBaseLength = _maximumFileNameLength - _fileExtension.length;
    final capped = String.fromCharCodes(base.runes.take(maximumBaseLength));
    // Windows drops trailing spaces and dots from file names.
    final trimmed = capped.replaceAll(_trailingSpacesAndDots, '');
    return '$trimmed$_fileExtension';
  }

  Future<void> printDocument(BusinessDocument document) async {
    await target.printPdf(
      await _buildPdf(document),
      suggestedFileName(document),
    );
  }

  Future<PdfExportOutcome> exportDocument(BusinessDocument document) async {
    final bytes = await _buildPdf(document);
    final fileName = suggestedFileName(document);
    if (sharesInsteadOfSaving) {
      await target.sharePdf(bytes, fileName);
      return PdfExportOutcome.exported;
    }
    return await target.savePdf(bytes, fileName)
        ? PdfExportOutcome.exported
        : PdfExportOutcome.cancelled;
  }

  Future<Uint8List> _buildPdf(BusinessDocument document) async {
    final imagesByAssetId = <String, Uint8List>{};
    for (final assetId in [
      document.companyDetails.logoAssetId,
      document.signatureBlock.signatureAssetId,
    ]) {
      if (assetId == null || imagesByAssetId.containsKey(assetId)) continue;
      final image = await assets.loadImage(assetId);
      if (image != null) imagesByAssetId[assetId] = image;
    }
    return buildPdf(document, imagesByAssetId);
  }
}

/// Where PDFs go on this platform.
final pdfOutputTargetProvider = Provider<PdfOutputTarget>(
  (ref) => const PlatformPdfOutputTarget(),
);

/// The bundled fonts, loaded once and kept. A failed load is not kept, so the
/// next export tries again.
final pdfFontSetProvider = FutureProvider<PdfFontSet>((ref) async {
  try {
    return await PdfFontSet.load();
  } on Object {
    ref.invalidateSelf();
    rethrow;
  }
});

/// Turns a document into PDF bytes with the bundled fonts.
final pdfDocumentBuilderProvider = Provider<PdfDocumentBuilder>(
  (ref) => (document, imagesByAssetId) async {
    final fonts = await ref.read(pdfFontSetProvider.future);
    return DocumentPdfBuilder(fonts: fonts)
        .build(document, imagesByAssetId: imagesByAssetId);
  },
);

/// Android and web have no save dialog, so they share or download instead.
final sharesPdfInsteadOfSavingProvider = Provider<bool>(
  (ref) => kIsWeb || defaultTargetPlatform == TargetPlatform.android,
);

final pdfExportServiceProvider = Provider<PdfExportService>(
  (ref) => PdfExportService(
    target: ref.watch(pdfOutputTargetProvider),
    assets: ref.watch(assetRepositoryProvider),
    buildPdf: ref.watch(pdfDocumentBuilderProvider),
    sharesInsteadOfSaving: ref.watch(sharesPdfInsteadOfSavingProvider),
  ),
);
