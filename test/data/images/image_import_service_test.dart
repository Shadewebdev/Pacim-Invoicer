import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pacim_invoicer/data/images/image_import_service.dart';

Uint8List _noisyPng(int width, int height) {
  final random = Random(7);
  final image = img.Image(width: width, height: height);
  for (final pixel in image) {
    pixel.setRgb(random.nextInt(256), random.nextInt(256), random.nextInt(256));
  }
  return img.encodePng(image);
}

Uint8List _noisyRgbaPng(int width, int height, {required bool transparent}) {
  final random = Random(11);
  final image = img.Image(width: width, height: height, numChannels: 4);
  for (final pixel in image) {
    pixel.setRgba(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      transparent ? random.nextInt(200) : 255,
    );
  }
  return img.encodePng(image);
}

void main() {
  const service = ImageImportService();

  test('a 3000x1000 image is resized to 600x200', () async {
    final prepared = await service.prepareImageForStorage(
      _noisyPng(3000, 1000),
    );

    final decoded = img.decodeImage(prepared)!;
    expect(decoded.width, 600);
    expect(decoded.height, 200);
  });

  test('output is at most 250 KB', () async {
    final prepared = await service.prepareImageForStorage(
      _noisyPng(3000, 1000),
    );

    expect(prepared.lengthInBytes, lessThanOrEqualTo(250 * 1024));
  });

  test('small images are not upscaled', () async {
    final prepared = await service.prepareImageForStorage(_noisyPng(100, 50));

    final decoded = img.decodeImage(prepared)!;
    expect(decoded.width, 100);
    expect(decoded.height, 50);
  });

  test('images with alpha stay PNG and opaque images become JPEG', () async {
    final withAlpha = img.Image(width: 20, height: 20, numChannels: 4);
    final preparedAlpha = await service.prepareImageForStorage(
      img.encodePng(withAlpha),
    );
    final preparedOpaque = await service.prepareImageForStorage(
      _noisyPng(20, 20),
    );

    expect(preparedAlpha.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    expect(preparedOpaque.sublist(0, 2), [0xFF, 0xD8]);
  });

  test('non-image bytes throw ImageImportException', () async {
    await expectLater(
      service.prepareImageForStorage(Uint8List.fromList([1, 2, 3, 4])),
      throwsA(
        isA<ImageImportException>().having(
          (error) => error.message,
          'message',
          "This file isn't a supported image",
        ),
      ),
    );
  });

  test('a noisy transparent image is kept at most 250 KB', () async {
    final prepared = await service.prepareImageForStorage(
      _noisyRgbaPng(600, 600, transparent: true),
    );

    expect(prepared.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    expect(prepared.lengthInBytes, lessThanOrEqualTo(250 * 1024));
  });

  test('an opaque RGBA image is encoded as JPEG', () async {
    final prepared = await service.prepareImageForStorage(
      _noisyRgbaPng(100, 100, transparent: false),
    );

    expect(prepared.sublist(0, 2), [0xFF, 0xD8]);
  });
}
