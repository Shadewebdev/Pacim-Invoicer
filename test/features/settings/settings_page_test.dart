import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/features/settings/header_preview.dart';
import 'package:pacim_invoicer/features/settings/settings_page.dart';

import '../../support/fake_repositories.dart';

Future<FakeSettingsRepository> pumpSettingsPage(
  WidgetTester tester, {
  Size size = const Size(1200, 800),
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
