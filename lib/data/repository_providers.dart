import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pacim_invoicer/data/images/image_import_service.dart';
import 'package:pacim_invoicer/data/local/database_connection.dart';
import 'package:pacim_invoicer/data/local/drift_asset_repository.dart';
import 'package:pacim_invoicer/data/local/drift_document_repository.dart';
import 'package:pacim_invoicer/data/local/drift_number_sequence_repository.dart';
import 'package:pacim_invoicer/data/local/drift_settings_repository.dart';
import 'package:pacim_invoicer/data/local/pacim_database.dart';
import 'package:pacim_invoicer/data/repositories/asset_repository.dart';
import 'package:pacim_invoicer/data/repositories/document_repository.dart';
import 'package:pacim_invoicer/data/repositories/number_sequence_repository.dart';
import 'package:pacim_invoicer/data/repositories/settings_repository.dart';
import 'package:pacim_invoicer/data/uuid_id_generator.dart';
import 'package:pacim_invoicer/domain/services/document_factory.dart';
import 'package:pacim_invoicer/domain/services/document_totals_calculator.dart';
import 'package:pacim_invoicer/domain/services/document_upgrade_service.dart';
import 'package:pacim_invoicer/domain/services/document_validator.dart';
import 'package:pacim_invoicer/domain/services/id_generator.dart';

// The single place where storage implementations are chosen. Switching to
// Firestore means changing only the repository providers below.

/// The raw storage connection. Tests override it with an in-memory database.
final databaseConnectionProvider = Provider<QueryExecutor>(
  (ref) => openPacimDatabaseConnection(),
);

/// The app database, closed when the provider is disposed.
final pacimDatabaseProvider = Provider<PacimDatabase>((ref) {
  final database = PacimDatabase(ref.watch(databaseConnectionProvider));
  ref.onDispose(database.close);
  return database;
});

final documentTotalsCalculatorProvider = Provider<DocumentTotalsCalculator>(
  (ref) => const DocumentTotalsCalculator(),
);

final documentRepositoryProvider = Provider<DocumentRepository>(
  (ref) => DriftDocumentRepository(
    ref.watch(pacimDatabaseProvider),
    totalsCalculator: ref.watch(documentTotalsCalculatorProvider),
  ),
);

final numberSequenceRepositoryProvider = Provider<NumberSequenceRepository>(
  (ref) => DriftNumberSequenceRepository(ref.watch(pacimDatabaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => DriftSettingsRepository(ref.watch(pacimDatabaseProvider)),
);

final assetRepositoryProvider = Provider<AssetRepository>(
  (ref) => DriftAssetRepository(ref.watch(pacimDatabaseProvider)),
);

final idGeneratorProvider = Provider<IdGenerator>((ref) => UuidIdGenerator());

/// The current time. Tests override it with a fixed clock.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final documentFactoryProvider = Provider<DocumentFactory>(
  (ref) => DocumentFactory(idGenerator: ref.watch(idGeneratorProvider)),
);

final documentUpgradeServiceProvider = Provider<DocumentUpgradeService>(
  (ref) => DocumentUpgradeService(idGenerator: ref.watch(idGeneratorProvider)),
);

final documentValidatorProvider = Provider<DocumentValidator>(
  (ref) => const DocumentValidator(),
);

final imageImportServiceProvider = Provider<ImageImportService>(
  (ref) => const ImageImportService(),
);
