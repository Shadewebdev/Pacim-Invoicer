import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/data/repositories/asset_repository.dart';

/// Behaviour every [AssetRepository] implementation must satisfy.
///
/// Every call to [createRepository] must return a fresh, empty repository.
/// [countStoredAssets] reports how many distinct assets that repository holds.
void runAssetRepositoryContract(
  Future<AssetRepository> Function() createRepository,
  Future<int> Function() countStoredAssets,
) {
  group('AssetRepository contract', () {
    late AssetRepository repository;

    setUp(() async {
      repository = await createRepository();
    });

    final pngBytes = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 1, 2, 3, //
    ]);

    test(
      'storing the same image twice returns the same id and one row',
      () async {
        final firstId = await repository.storeImage(pngBytes);
        final secondId = await repository.storeImage(
          Uint8List.fromList(pngBytes),
        );

        expect(secondId, firstId);
        expect(await countStoredAssets(), 1);
        expect(await repository.loadImage(firstId), pngBytes);
      },
    );

    test('different images get different ids', () async {
      final firstId = await repository.storeImage(pngBytes);
      final secondId = await repository.storeImage(
        Uint8List.fromList([...pngBytes, 4]),
      );

      expect(secondId, isNot(firstId));
      expect(await countStoredAssets(), 2);
    });

    test('loadImage unknown id returns null', () async {
      expect(await repository.loadImage('missing'), isNull);
    });
  });
}
