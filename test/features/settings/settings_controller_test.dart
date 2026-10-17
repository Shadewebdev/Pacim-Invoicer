import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/app/shell/status_bar_message_provider.dart';
import 'package:pacim_invoicer/app/theme/theme_mode_provider.dart';
import 'package:pacim_invoicer/data/images/image_import_service.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/domain/models/document_numbering_rule.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/features/settings/settings_controller.dart';

import '../../support/fake_repositories.dart';

class _FakeImageImportService extends ImageImportService {
  const _FakeImageImportService();

  @override
  Future<Uint8List> prepareImageForStorage(Uint8List originalBytes) async =>
      Uint8List.fromList([...originalBytes, 99]);
}

typedef _Setup = ({
  ProviderContainer container,
  FakeSettingsRepository settingsRepository,
  FakeAssetRepository assetRepository,
});

/// Creates a container and loads the settings controller. Call from
/// a widget test, so timers run on the test clock.
Future<_Setup> _createLoadedContainer(WidgetTester tester) async {
  final settingsRepository = FakeSettingsRepository();
  final assetRepository = FakeAssetRepository();
  final container = ProviderContainer(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(settingsRepository),
      assetRepositoryProvider.overrideWithValue(assetRepository),
      imageImportServiceProvider.overrideWithValue(
        const _FakeImageImportService(),
      ),
    ],
  );
  container.listen(settingsControllerProvider, (_, _) {});
  container.listen(statusBarMessageProvider, (_, _) {});
  await tester.pump();
  return (
    container: container,
    settingsRepository: settingsRepository,
    assetRepository: assetRepository,
  );
}

void main() {
  _quotationValidityTests();
  testWidgets('updateCompanyDetails persists after debounce', (tester) async {
    final setup = await _createLoadedContainer(tester);
    final container = setup.container;
    final controller = container.read(settingsControllerProvider.notifier);
    final company = container
        .read(settingsControllerProvider)
        .requireValue
        .companyDetails;

    controller.updateCompanyDetails(
      company.copyWith(companyName: 'Pacim Sdn Bhd'),
    );
    await tester.pump(const Duration(milliseconds: 599));
    expect(setup.settingsRepository.saveCount, 0);
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump();

    expect(setup.settingsRepository.saveCount, 1);
    expect(
      setup.settingsRepository.currentSettings.companyDetails.companyName,
      'Pacim Sdn Bhd',
    );
    container.dispose();
  });

  testWidgets('rapid changes collapse into one save', (tester) async {
    final setup = await _createLoadedContainer(tester);
    final controller = setup.container.read(
      settingsControllerProvider.notifier,
    );

    controller.updateFooterNote('a');
    await tester.pump(const Duration(milliseconds: 400));
    controller.updateFooterNote('ab');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(setup.settingsRepository.saveCount, 1);
    expect(setup.settingsRepository.currentSettings.defaultFooterNote, 'ab');
    setup.container.dispose();
  });

  testWidgets('invalid numbering pattern shows problem text and is not saved', (
    tester,
  ) async {
    final setup = await _createLoadedContainer(tester);
    final controller = setup.container.read(
      settingsControllerProvider.notifier,
    );

    expect(
      controller.findNumberingRuleProblems(
        const DocumentNumberingRule(pattern: 'QT-{yyyy}'),
      ),
      isNotEmpty,
    );
    controller.updateNumberingRule(
      DocumentType.quotation,
      const DocumentNumberingRule(pattern: 'QT-{yyyy}'),
    );
    controller.updateFooterNote('Thank you');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    final saved = setup.settingsRepository.currentSettings;
    expect(
      saved.numberingRuleByType[DocumentType.quotation]!.pattern,
      'QT-{yyyy}-{seq:4}',
    );
    expect(saved.defaultFooterNote, 'Thank you');
    setup.container.dispose();
  });

  testWidgets('a valid numbering pattern is saved', (tester) async {
    final setup = await _createLoadedContainer(tester);

    setup.container
        .read(settingsControllerProvider.notifier)
        .updateNumberingRule(
          DocumentType.salesOrder,
          const DocumentNumberingRule(
            pattern: 'S{yy}{mm}-{seq:3}',
            resetsYearly: true,
          ),
        );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    final rule = setup
        .settingsRepository
        .currentSettings
        .numberingRuleByType[DocumentType.salesOrder]!;
    expect(rule.pattern, 'S{yy}{mm}-{seq:3}');
    expect(rule.resetsYearly, isTrue);
    setup.container.dispose();
  });

  testWidgets('a yearly reset without a year token is not saved', (
    tester,
  ) async {
    final setup = await _createLoadedContainer(tester);

    setup.container
        .read(settingsControllerProvider.notifier)
        .updateNumberingRule(
          DocumentType.quotation,
          const DocumentNumberingRule(
            pattern: 'QT-{seq:4}',
            resetsYearly: true,
          ),
        );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(setup.settingsRepository.saveCount, 0);
    setup.container.dispose();
  });

  testWidgets('importCompanyLogo stores prepared image and sets logoAssetId', (
    tester,
  ) async {
    final setup = await _createLoadedContainer(tester);

    setup.container
        .read(settingsControllerProvider.notifier)
        .importCompanyLogo(Uint8List.fromList([1, 2, 3]));
    await tester.pump();

    final logoAssetId = setup.container
        .read(settingsControllerProvider)
        .requireValue
        .companyDetails
        .logoAssetId;
    expect(logoAssetId, isNotNull);
    expect(setup.assetRepository.storedImages[logoAssetId], [1, 2, 3, 99]);
    setup.container.dispose();
  });

  testWidgets(
    'importSignatureImage sets the signature asset for that type only',
    (tester) async {
      final setup = await _createLoadedContainer(tester);

      setup.container
          .read(settingsControllerProvider.notifier)
          .importSignatureImage(
            DocumentType.deliveryOrder,
            Uint8List.fromList([7]),
          );
      await tester.pump();

      final blocks = setup.container
          .read(settingsControllerProvider)
          .requireValue
          .signatureBlockByType;
      expect(blocks[DocumentType.deliveryOrder]!.signatureAssetId, isNotNull);
      expect(blocks[DocumentType.quotation]!.signatureAssetId, isNull);
      setup.container.dispose();
    },
  );

  testWidgets('a failed save reports to the status bar', (tester) async {
    final logged = <String?>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => logged.add(message);
    final setup = await _createLoadedContainer(tester);
    setup.settingsRepository.failNextSave = true;

    setup.container
        .read(settingsControllerProvider.notifier)
        .updateFooterNote('x');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(
      setup.container.read(statusBarMessageProvider),
      "Couldn't save settings",
    );
    debugPrint = originalDebugPrint;
    expect(logged.join(), contains('fake save failure'));
    setup.container.dispose();
  });

  testWidgets('disposing the controller flushes a pending save', (
    tester,
  ) async {
    final setup = await _createLoadedContainer(tester);

    setup.container
        .read(settingsControllerProvider.notifier)
        .updateFooterNote('pending');
    setup.container.dispose();
    await tester.pump();

    expect(
      setup.settingsRepository.currentSettings.defaultFooterNote,
      'pending',
    );
  });

  testWidgets('appearance follows loaded settings and updates', (tester) async {
    final setup = await _createLoadedContainer(tester);
    final container = setup.container;
    expect(container.read(themeModeProvider), ThemeMode.system);

    container
        .read(settingsControllerProvider.notifier)
        .updateAppearance('dark');
    expect(container.read(themeModeProvider), ThemeMode.dark);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    expect(setup.settingsRepository.currentSettings.appearance, 'dark');
    container.dispose();
  });
}

void _quotationValidityTests() {
  testWidgets('updateQuotationValidityDays accepts 1 to 365 only', (
    tester,
  ) async {
    final setup = await _createLoadedContainer(tester);
    final controller = setup.container.read(
      settingsControllerProvider.notifier,
    );

    controller.updateQuotationValidityDays(0);
    controller.updateQuotationValidityDays(366);
    await tester.pump(const Duration(milliseconds: 700));
    expect(setup.settingsRepository.saveCount, 0);

    controller.updateQuotationValidityDays(14);
    await tester.pump(const Duration(milliseconds: 700));
    expect(setup.settingsRepository.currentSettings.quotationValidityDays, 14);
    setup.container.dispose();
  });
}
