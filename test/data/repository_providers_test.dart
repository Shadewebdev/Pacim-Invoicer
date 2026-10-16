import 'dart:typed_data';

import 'package:drift/drift.dart'
    show ApplyInterceptor, QueryExecutor, QueryInterceptor;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/data/images/image_import_service.dart';
import 'package:pacim_invoicer/data/local/database_connection.dart';
import 'package:pacim_invoicer/data/local/pacim_database.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/data/uuid_id_generator.dart';
import 'package:pacim_invoicer/domain/models/document_settings.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/services/document_totals_calculator.dart';
import 'package:pacim_invoicer/domain/services/document_validator.dart';

import '../support/document_builders.dart';
import '../support/sequential_id_generator.dart';

/// Records whether drift closed the wrapped executor.
class _CloseRecordingInterceptor extends QueryInterceptor {
  bool wasClosed = false;

  @override
  Future<void> close(QueryExecutor inner) {
    wasClosed = true;
    return super.close(inner);
  }
}

void main() {
  test('providers can be overridden with in-memory database', () async {
    final database = PacimDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final container = ProviderContainer(
      overrides: [pacimDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);

    final repository = container.read(documentRepositoryProvider);
    final document = buildTestDocument();
    await repository.saveDocument(document);

    expect(await repository.getDocument(document.documentId), document);
  });

  test('every repository shares the overridden database', () async {
    final database = PacimDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final container = ProviderContainer(
      overrides: [pacimDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);

    final sequence = await container
        .read(numberSequenceRepositoryProvider)
        .allocateNextSequence(
          DocumentType.quotation,
          year: 2026,
          resetsYearly: true,
        );
    final settingsRepository = container.read(settingsRepositoryProvider);
    final settings = DocumentSettings.initial().copyWith(
      quotationValidityDays: 14,
    );
    await settingsRepository.saveSettings(settings);
    final assetRepository = container.read(assetRepositoryProvider);
    final assetId = await assetRepository.storeImage(
      Uint8List.fromList([1, 2, 3]),
    );

    expect(sequence, 1);
    expect(await settingsRepository.watchSettings().first, settings);
    expect(await assetRepository.loadImage(assetId), [1, 2, 3]);
    final storedRows = await database
        .customSelect('SELECT COUNT(*) AS c FROM assets')
        .getSingle();
    expect(storedRows.read<int>('c'), 1);
  });

  test('disposing the container closes the database', () async {
    final interceptor = _CloseRecordingInterceptor();
    final container = ProviderContainer(
      overrides: [
        databaseConnectionProvider.overrideWithValue(
          NativeDatabase.memory().interceptWith(interceptor),
        ),
      ],
    );
    final database = container.read(pacimDatabaseProvider);
    await database.customSelect('SELECT 1').get();

    container.dispose();
    await pumpEventQueue();

    expect(interceptor.wasClosed, isTrue);
  });

  test('domain services use the provided id generator', () {
    final idGenerator = SequentialIdGenerator();
    final container = ProviderContainer(
      overrides: [idGeneratorProvider.overrideWithValue(idGenerator)],
    );
    addTearDown(container.dispose);

    expect(container.read(documentFactoryProvider).idGenerator, idGenerator);
    expect(
      container.read(documentUpgradeServiceProvider).idGenerator,
      idGenerator,
    );
  });

  test('defaults are a uuid id generator and the system clock', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(idGeneratorProvider), isA<UuidIdGenerator>());
    final before = DateTime.now();
    final now = container.read(clockProvider)();
    expect(now.isBefore(before), isFalse);
    expect(now.difference(before).inSeconds, lessThan(5));
    expect(container.read(documentValidatorProvider), isA<DocumentValidator>());
    expect(
      container.read(documentTotalsCalculatorProvider),
      isA<DocumentTotalsCalculator>(),
    );
    expect(
      container.read(imageImportServiceProvider),
      isA<ImageImportService>(),
    );
  });

  test('web options point at the bundled sqlite3 and drift worker', () {
    final options = pacimDatabaseWebOptions();

    expect(options.sqlite3Wasm, Uri.parse('sqlite3.wasm'));
    expect(options.driftWorker, Uri.parse('drift_worker.js'));
  });
}
