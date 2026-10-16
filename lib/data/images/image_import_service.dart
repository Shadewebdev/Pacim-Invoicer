import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

const int _maxLongestEdgePixels = 600;
const int _maxEncodedBytes = 250 * 1024;
const int _initialJpegQuality = 85;
const int _minimumJpegQuality = 45;
const int _jpegQualityStep = 10;
const double _downscaleFactor = 0.75;
const int _minimumEdgePixels = 64;

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

  return _encodeWithinSizeLimit(resized);
}

/// Encodes with the format's normal steps, then as a last resort shrinks the
/// image until the result fits or the longest edge reaches the minimum.
Uint8List _encodeWithinSizeLimit(img.Image image) {
  final keepsTransparency = _hasTransparentPixel(image);
  var current = image;
  while (true) {
    final encoded = keepsTransparency
        ? img.encodePng(current)
        : _encodeJpegWithinLimit(current);
    if (encoded.lengthInBytes <= _maxEncodedBytes) return encoded;
    if (max(current.width, current.height) <= _minimumEdgePixels) {
      return encoded;
    }
    current = img.copyResize(
      current,
      width: max(1, (current.width * _downscaleFactor).round()),
      height: max(1, (current.height * _downscaleFactor).round()),
      interpolation: img.Interpolation.average,
    );
  }
}

/// Lowers the JPEG quality step by step; returns the last attempt, which may
/// still be over the limit.
Uint8List _encodeJpegWithinLimit(img.Image image) {
  var quality = _initialJpegQuality;
  var encoded = img.encodeJpg(image, quality: quality);
  while (encoded.lengthInBytes > _maxEncodedBytes &&
      quality > _minimumJpegQuality) {
    quality -= _jpegQualityStep;
    encoded = img.encodeJpg(image, quality: quality);
  }
  return encoded;
}

bool _hasTransparentPixel(img.Image image) {
  if (!image.hasAlpha) return false;
  for (final pixel in image) {
    if (pixel.a < pixel.maxChannelValue) return true;
  }
  return false;
}

img.Image? _tryDecode(Uint8List bytes) {
  try {
    return img.decodeImage(bytes);
  } on Object {
    return null;
  }
}
