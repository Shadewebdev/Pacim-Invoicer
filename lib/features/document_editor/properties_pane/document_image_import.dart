import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repository_providers.dart';

/// Shrinks [originalBytes] for storage and stores them, returning the new
/// asset id. Throws `ImageImportException` when the bytes are not an image.
Future<String> storeDocumentImage(
  WidgetRef ref,
  Uint8List originalBytes,
) async {
  final prepared = await ref
      .read(imageImportServiceProvider)
      .prepareImageForStorage(originalBytes);
  return ref.read(assetRepositoryProvider).storeImage(prepared);
}
