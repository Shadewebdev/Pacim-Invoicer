import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

const int _maxLongestEdgePixels = 600;
const int _maxEncodedBytes = 250 * 1024;
const int _initialJpegQuality = 85;
const int _minimumJpegQuality = 45;
const int _jpegQualityStep = 10;

class ImageImportException implements Exception {
  const ImageImportException();

  String get message => "This file isn't a supported image";

  @override
  String toString() => 'ImageImportException: $message';
}

/// Downscales logo and signature images before they are stored, so they stay
/// well under backend document size limits.
class ImageImportService {
  const ImageImportService();

  /// Resizes to a longest edge of at most 600 px (never upscaling) and
  /// re-encodes as PNG when the image has alpha, otherwise as JPEG with the
  /// quality lowered until the result is at most 250 KB.
  ///
  /// Throws [ImageImportException] when [originalBytes] is not a decodable
  /// image.
  Future<Uint8List> prepareImageForStorage(Uint8List originalBytes) async {
    final prepared = await compute(_prepareImageBytes, originalBytes);
    if (prepared == null) throw const ImageImportException();
    return prepared;
  }
}

/// Top-level so it can run in an isolate. Returns null when the bytes cannot
/// be decoded.
Uint8List? _prepareImageBytes(Uint8List originalBytes) {
  final decoded = _tryDecode(originalBytes);
  if (decoded == null) return null;

  final upright = img.bakeOrientation(decoded);
  final longestEdge = max(upright.width, upright.height);
  final resized = longestEdge > _maxLongestEdgePixels
      ? img.copyResize(
          upright,
          width: upright.width >= upright.height ? _maxLongestEdgePixels : null,
          height: upright.height > upright.width ? _maxLongestEdgePixels : null,
          interpolation: img.Interpolation.average,
        )
      : upright;

  if (resized.hasAlpha) return img.encodePng(resized);

  var quality = _initialJpegQuality;
  var encoded = img.encodeJpg(resized, quality: quality);
  while (encoded.lengthInBytes > _maxEncodedBytes &&
      quality > _minimumJpegQuality) {
    quality -= _jpegQualityStep;
    encoded = img.encodeJpg(resized, quality: quality);
  }
  return encoded;
}

img.Image? _tryDecode(Uint8List bytes) {
  try {
    return img.decodeImage(bytes);
  } on Object {
    return null;
  }
}
