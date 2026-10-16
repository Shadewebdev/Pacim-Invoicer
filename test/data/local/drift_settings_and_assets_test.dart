import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/data/local/drift_asset_repository.dart';
import 'package:pacim_invoicer/data/local/drift_settings_repository.dart';
import 'package:pacim_invoicer/data/local/pacim_database.dart';
import 'package:pacim_invoicer/domain/exceptions/document_exceptions.dart';
import 'package:pacim_invoicer/domain/models/document_settings.dart';

import '../contract/asset_repository_contract.dart';
import '../contract/settings_repository_contract.dart';

void main() {
  late PacimDatabase database;

  PacimDatabase openDatabase() =>
      database = PacimDatabase.forTesting(NativeDatabase.memory());

  tearDown(() async {
    await database.close();
  });

  runSettingsRepositoryContract(() async {
    return DriftSettingsRepository(openDatabase());
  });

  runAssetRepositoryContract(
    () async => DriftAssetRepository(openDatabase()),
    () async => (await database.select(database.assetRows).get()).length,
  );

  test('stored image mime type is detected from magic numbers', () async {
    final repository = DriftAssetRepository(openDatabase());
    final pngId = await repository.storeImage(
      Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 1]),
    );
    final jpegId = await repository.storeImage(
      Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 1]),
    );

    final rows = await database.select(database.assetRows).get();
    final mimeTypeById = {for (final row in rows) row.assetId: row.mimeType};
    expect(mimeTypeById[pngId], 'image/png');
    expect(mimeTypeById[jpegId], 'image/jpeg');
  });

  test('a failed settings write is wrapped in StorageWriteException', () async {
    final repository = DriftSettingsRepository(openDatabase());
    await database.customStatement('DROP TABLE settings');
    await expectLater(
      repository.saveSettings(DocumentSettings.initial()),
      throwsA(isA<StorageWriteException>()),
    );
  });

  test('a failed asset write is wrapped in StorageWriteException', () async {
    final repository = DriftAssetRepository(openDatabase());
    await database.customStatement('DROP TABLE assets');
    await expectLater(
      repository.storeImage(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<StorageWriteException>()),
    );
  });
}
