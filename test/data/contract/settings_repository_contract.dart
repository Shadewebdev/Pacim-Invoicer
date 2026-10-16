import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/data/repositories/settings_repository.dart';
import 'package:pacim_invoicer/domain/models/document_settings.dart';

/// Behaviour every [SettingsRepository] implementation must satisfy.
///
/// Every call to [createRepository] must return a fresh, empty repository.
void runSettingsRepositoryContract(
  Future<SettingsRepository> Function() createRepository,
) {
  group('SettingsRepository contract', () {
    late SettingsRepository repository;

    setUp(() async {
      repository = await createRepository();
    });

    test('settings default to initial when empty', () async {
      expect(
        await repository.watchSettings().first,
        DocumentSettings.initial(),
      );
    });

    test('saveSettings then watchSettings emits saved value', () async {
      final saved = DocumentSettings.initial().copyWith(
        defaultFooterNote: 'Pay within 14 days',
      );

      await repository.saveSettings(saved);

      expect(await repository.watchSettings().first, saved);
    });
  });
}
