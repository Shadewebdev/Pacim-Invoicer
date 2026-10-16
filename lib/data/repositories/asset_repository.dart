import 'dart:typed_data';

abstract interface class AssetRepository {
  /// Returns the SHA-256 asset id; storing the same bytes twice is idempotent.
  Future<String> storeImage(Uint8List bytes);
  Future<Uint8List?> loadImage(String assetId);
}
