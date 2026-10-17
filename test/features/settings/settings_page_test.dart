import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/data/images/image_import_service.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/features/settings/header_preview.dart';
import 'package:pacim_invoicer/features/settings/image_picker_field.dart';
import 'package:pacim_invoicer/features/settings/settings_controller.dart';
import 'package:pacim_invoicer/features/settings/settings_page.dart';

import '../../support/fake_repositories.dart';

Future<FakeSettingsRepository> pumpSettingsPage(
  WidgetTester tester, {
  Size size = const Size(1200, 800),
  FakeNumberSequenceRepository? sequences,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final settingsRepository = FakeSettingsRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
        assetRepositoryProvider.overrideWithValue(FakeAssetRepository()),
        numberSequenceRepositoryProvider.overrideWithValue(
          sequences ?? FakeNumberSequenceRepository(),
        ),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 17)),
      ],
      child: MaterialApp(
        theme: buildAppTheme(
          brightness: Brightness.light,
          platform: TargetPlatform.windows,
        ),
        home: const Scaffold(body: SettingsPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return settingsRepository;
}

void main() {
  _imageImportTests();
  testWidgets('settings page shows the existing-documents note', (
    tester,
  ) async {
    await pumpSettingsPage(tester);
    expect(
      find.text(
        'Changes apply to new documents. Existing documents keep their own copy.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('numbering preview shows QT-2026-0001', (tester) async {
    await pumpSettingsPage(tester);
    await tester.tap(find.text('Numbering'));
    await tester.pumpAndSettle();
    expect(find.text('QT-2026-0001'), findsOneWidget);
  });

  testWidgets('numbering preview continues from the current counter', (
    tester,
  ) async {
    final sequences = FakeNumberSequenceRepository();
    for (var i = 0; i < 2; i++) {
      await sequences.allocateNextSequence(
        DocumentType.quotation,
        year: 2026,
        resetsYearly: false,
      );
    }
    await pumpSettingsPage(tester, sequences: sequences);
    await tester.tap(find.text('Numbering'));
    await tester.pumpAndSettle();
    expect(find.text('QT-2026-0003'), findsOneWidget);
  });

  testWidgets('an invalid numbering pattern shows its problem inline', (
    tester,
  ) async {
    final repository = await pumpSettingsPage(tester);
    await tester.tap(find.text('Numbering'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'QT-{yyyy}');
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Add {seq:N} so each number is unique'), findsOneWidget);
    expect(repository.saveCount, 0);
  });

  testWidgets('a yearly reset without a year token shows its problem', (
    tester,
  ) async {
    final repository = await pumpSettingsPage(tester);
    await tester.tap(find.text('Numbering'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'QT-{seq:4}');
    await tester.pump(const Duration(milliseconds: 700));
    final savesBeforeToggle = repository.saveCount;
    await tester.tap(find.text('Restart numbering each year'));
    await tester.pump(const Duration(milliseconds: 700));

    expect(
      find.text('Add {yyyy} or {yy} so yearly numbers stay unique'),
      findsOneWidget,
    );
    expect(repository.saveCount, savesBeforeToggle);
    expect(
      repository.currentSettings.numberingRuleByType.values.any(
        (rule) => rule.resetsYearly,
      ),
      isFalse,
    );

    // Adding a year token saves the pattern and the reset together.
    await tester.enterText(find.byType(TextField).first, 'QT-{yy}-{seq:4}');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    final saved = repository.currentSettings.numberingRuleByType.values.first;
    expect(saved.pattern, 'QT-{yy}-{seq:4}');
    expect(saved.resetsYearly, isTrue);
  });

  testWidgets('typing a company name saves after the debounce', (tester) async {
    final repository = await pumpSettingsPage(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Company name'),
      'Pacim Sdn Bhd',
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(
      repository.currentSettings.companyDetails.companyName,
      'Pacim Sdn Bhd',
    );
  });

  testWidgets(
    'hiding the app saves settings without waiting for the debounce',
    (tester) async {
      final repository = await pumpSettingsPage(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Company name'),
        'Pacim Sdn Bhd',
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(repository.saveCount, 0);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();
      await tester.pump();

      expect(
        repository.currentSettings.companyDetails.companyName,
        'Pacim Sdn Bhd',
      );
      expect(repository.saveCount, 1);
      await tester.pump(const Duration(seconds: 1));
      expect(repository.saveCount, 1);
    },
  );

  testWidgets('matching separators are refused both ways', (tester) async {
    final repository = await pumpSettingsPage(tester);
    await tester.tap(find.text('Pricing & currency'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Thousands separator'),
      '.',
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(
      find.text('Use a different separator from the decimal one'),
      findsOneWidget,
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Thousands separator'),
      ',',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Decimal separator'),
      ',',
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(
      find.text('Use a different separator from the thousands one'),
      findsOneWidget,
    );
    expect(repository.saveCount, 0);
  });

  testWidgets('a non-numeric tax rate shows an error and is not saved', (
    tester,
  ) async {
    final repository = await pumpSettingsPage(tester);
    await tester.tap(find.text('Pricing & currency'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Tax rate (%)'),
      'abc',
    );
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Enter a number'), findsOneWidget);
    expect(repository.saveCount, 0);
  });

  testWidgets('the header preview is hidden below 900px', (tester) async {
    await pumpSettingsPage(tester);
    expect(find.byType(HeaderPreview), findsOneWidget);

    await pumpSettingsPage(tester, size: const Size(800, 800));
    expect(find.byType(HeaderPreview), findsNothing);
  });
}

/// Passes bytes through, or throws [ImageImportException] when [rejects].
class _FakeImageImportService extends ImageImportService {
  _FakeImageImportService({this.rejects = false});

  bool rejects;

  @override
  Future<Uint8List> prepareImageForStorage(Uint8List originalBytes) async {
    if (rejects) throw const ImageImportException();
    return originalBytes;
  }
}

Future<void> _pumpImagePickerField(
  WidgetTester tester, {
  required FakeAssetRepository assetRepository,
  required _FakeImageImportService importService,
}) async {
  final container = ProviderContainer(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      assetRepositoryProvider.overrideWithValue(assetRepository),
      imageImportServiceProvider.overrideWithValue(importService),
    ],
  );
  addTearDown(container.dispose);
  await container.read(settingsControllerProvider.future);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildAppTheme(
          brightness: Brightness.light,
          platform: TargetPlatform.windows,
        ),
        home: Scaffold(
          body: ImagePickerField(
            label: 'Company logo',
            assetId: null,
            pickImageBytes: () async => Uint8List.fromList([1, 2, 3]),
            onImagePicked: container
                .read(settingsControllerProvider.notifier)
                .importCompanyLogo,
            onRemove: () {},
          ),
        ),
      ),
    ),
  );
}

void _imageImportTests() {
  testWidgets('a storage failure while importing shows an inline error', (
    tester,
  ) async {
    await _pumpImagePickerField(
      tester,
      assetRepository: FakeAssetRepository()..failNextStore = true,
      importService: _FakeImageImportService(),
    );

    await tester.tap(find.text('Choose image'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't import that image"), findsOneWidget);
  });

  testWidgets('an unsupported image shows its import error message', (
    tester,
  ) async {
    await _pumpImagePickerField(
      tester,
      assetRepository: FakeAssetRepository(),
      importService: _FakeImageImportService(rejects: true),
    );

    await tester.tap(find.text('Choose image'));
    await tester.pumpAndSettle();

    expect(find.text("This file isn't a supported image"), findsOneWidget);
  });

  testWidgets('a successful import clears a previous error', (tester) async {
    final importService = _FakeImageImportService(rejects: true);
    await _pumpImagePickerField(
      tester,
      assetRepository: FakeAssetRepository(),
      importService: importService,
    );
    await tester.tap(find.text('Choose image'));
    await tester.pumpAndSettle();
    expect(find.text("This file isn't a supported image"), findsOneWidget);

    importService.rejects = false;
    await tester.tap(find.text('Choose image'));
    await tester.pumpAndSettle();

    expect(find.text("This file isn't a supported image"), findsNothing);

    // Let the debounced settings save finish.
    await tester.pump(const Duration(seconds: 1));
  });
}
