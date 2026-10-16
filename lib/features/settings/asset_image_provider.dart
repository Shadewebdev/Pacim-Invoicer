import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository_providers.dart';

/// The stored image bytes for an asset id, or null when the asset is missing.
final assetImageBytesProvider = FutureProvider.family<Uint8List?, String>(
  (ref, assetId) => ref.watch(assetRepositoryProvider).loadImage(assetId),
);
