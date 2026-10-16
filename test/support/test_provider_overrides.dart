import 'package:drift/native.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:pacim_invoicer/data/repositories/asset_repository.dart';
import 'package:pacim_invoicer/data/repositories/document_repository.dart';
import 'package:pacim_invoicer/data/repositories/number_sequence_repository.dart';
import 'package:pacim_invoicer/data/repositories/settings_repository.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';

import 'fake_repositories.dart';

/// Overrides every storage provider, using fresh fakes for the ones not given,
/// and the raw connection with an in-memory database as a backstop, so no test
/// can open the on-device database. A provider can only be overridden once per
/// container, so tests pass the repositories they inspect here instead of
/// overriding them again.
List<Override> fakeStorageOverrides({
  DocumentRepository? documents,
  NumberSequenceRepository? numberSequences,
  SettingsRepository? settings,
  AssetRepository? assets,
}) => [
  databaseConnectionProvider.overrideWithValue(NativeDatabase.memory()),
  documentRepositoryProvider.overrideWithValue(
    documents ?? FakeDocumentRepository(),
  ),
  numberSequenceRepositoryProvider.overrideWithValue(
    numberSequences ?? FakeNumberSequenceRepository(),
  ),
  settingsRepositoryProvider.overrideWithValue(
    settings ?? FakeSettingsRepository(),
  ),
  assetRepositoryProvider.overrideWithValue(assets ?? FakeAssetRepository()),
];
