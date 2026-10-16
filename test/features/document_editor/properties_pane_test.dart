import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/currency_format.dart';
import 'package:pacim_invoicer/domain/models/document_settings.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/models/pricing_terms.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_controller.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_page.dart';
import 'package:pacim_invoicer/features/document_editor/properties_pane/properties_pane.dart';

import '../../support/document_builders.dart';
import '../../support/fake_repositories.dart';

late ProviderContainer _container;
late FakeDocumentRepository _documents;
late FakeSettingsRepository _settings;

Future<void> _pump(
  WidgetTester tester,
  BusinessDocument document, {
  Size size = const Size(1400, 1400),
  bool pageInsteadOfPane = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  _documents = FakeDocumentRepository()..seed(document);
  _settings = FakeSettingsRepository();
  _container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      documentRepositoryProvider.overrideWithValue(_documents),
      settingsRepositoryProvider.overrideWithValue(_settings),
      assetRepositoryProvider.overrideWithValue(FakeAssetRepository()),
      clockProvider.overrideWithValue(() => DateTime(2026, 10, 17)),
    ],
  );
  addTearDown(_container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: _container,
      child: MaterialApp(
        theme: buildAppTheme(
          brightness: Brightness.light,
          platform: TargetPlatform.windows,
        ),
        home: Scaffold(
          body: pageInsteadOfPane
              ? DocumentEditorPage(documentId: document.documentId)
              : Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 300,
                    child: PropertiesPane(documentId: document.documentId),
                  ),
                ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

BusinessDocument _stateDocument(String id) =>
    _container.read(documentEditorControllerProvider(id)).requireValue.document;

Future<void> _tapReset(WidgetTester tester, String section) async {
  final button = find.byKey(ValueKey('resetSection-$section'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> _saveEdits(String documentId) => _container
    .read(documentEditorControllerProvider(documentId).notifier)
    .saveNow();

void main() {
  testWidgets('shows the four sections', (tester) async {
    await _pump(tester, buildTestDocument());
    expect(find.text('Document'), findsOneWidget);
    expect(find.text('Header & footer'), findsOneWidget);
    expect(find.text('Pricing & currency'), findsOneWidget);
    expect(find.text('Signature'), findsOneWidget);
  });

  testWidgets('Reset to defaults on pricing restores settings pricing', (
    tester,
  ) async {
    final document = buildTestDocument();
    await _pump(tester, document);
    final defaults = DocumentSettings.initial().pricingTerms;
    expect(_stateDocument(document.documentId).pricingTerms, isNot(defaults));

    await _tapReset(tester, 'pricing');

    expect(_stateDocument(document.documentId).pricingTerms, defaults);
    await _saveEdits(document.documentId);
  });

  testWidgets('Reset to defaults on header and footer resets three parts', (
    tester,
  ) async {
    final document = buildTestDocument();
    await _pump(tester, document);

    await _tapReset(tester, 'headerAndFooter');

    final reset = _stateDocument(document.documentId);
    final defaults = DocumentSettings.initial();
    expect(reset.companyDetails, defaults.companyDetails);
    expect(reset.footerNote, defaults.defaultFooterNote);
    expect(reset.termsAndConditions, '');
    // Pricing was not part of this reset.
    expect(reset.pricingTerms, document.pricingTerms);
    await _saveEdits(document.documentId);
  });

  testWidgets('delivery orders have no pricing section', (tester) async {
    await _pump(tester, buildTestDocument(type: DocumentType.deliveryOrder));
    expect(find.text('Pricing & currency'), findsNothing);
    expect(find.text('Header & footer'), findsOneWidget);
    expect(find.text('Reset to defaults'), findsNWidgets(2));
  });

  testWidgets('Document section has no reset button', (tester) async {
    await _pump(tester, buildTestDocument());
    expect(find.byKey(const ValueKey('resetSection-document')), findsNothing);
    expect(find.text('Reset to defaults'), findsNWidgets(3));
  });

  testWidgets('tax rate reads the document decimal separator and validates', (
    tester,
  ) async {
    const commaFormat = CurrencyFormat(
      currencyCode: 'EUR',
      symbol: 'EUR',
      decimalPlaces: 2,
      symbolPosition: CurrencySymbolPosition.after,
      thousandsSeparator: '.',
      decimalSeparator: ',',
    );
    final document = buildTestDocument().copyWith(
      pricingTerms: const PricingTerms(
        currencyFormat: commaFormat,
        taxRatePercentScaled: 600,
        isTaxEnabled: true,
      ),
    );
    await _pump(tester, document);
    final taxField = find.widgetWithText(TextField, 'Tax rate (%)');
    await tester.ensureVisible(taxField);

    await tester.enterText(taxField, '8,5');
    await tester.pump();
    expect(
      _stateDocument(document.documentId).pricingTerms.taxRatePercentScaled,
      850,
    );

    await tester.enterText(taxField, 'abc');
    await tester.pump();
    expect(find.text('Enter a number'), findsOneWidget);
    expect(
      _stateDocument(document.documentId).pricingTerms.taxRatePercentScaled,
      850,
    );
    await _saveEdits(document.documentId);
  });

  testWidgets('a locked document disables the pane', (tester) async {
    final document = buildTestDocument(lockedAt: DateTime.utc(2026, 10, 18));
    await _pump(tester, document);
    final reset = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('resetSection-pricing')),
    );
    expect(reset.onPressed, isNull);
    final nameField = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Company name'),
    );
    expect(nameField.enabled, isFalse);
  });

  testWidgets('below 900px properties open in a bottom sheet', (tester) async {
    await _pump(
      tester,
      buildTestDocument(),
      size: const Size(800, 900),
      pageInsteadOfPane: true,
    );
    expect(find.text('Pricing & currency'), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);

    await tester.tap(find.text('Properties'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Pricing & currency'), findsOneWidget);
  });

  testWidgets('wide windows show the pane and the toggle collapses it', (
    tester,
  ) async {
    await _pump(tester, buildTestDocument(), pageInsteadOfPane: true);
    expect(find.text('Pricing & currency'), findsOneWidget);

    await tester.tap(find.text('Hide properties'));
    await tester.pumpAndSettle();
    expect(find.text('Pricing & currency'), findsNothing);

    await tester.tap(find.text('Show properties'));
    await tester.pumpAndSettle();
    expect(find.text('Pricing & currency'), findsOneWidget);
  });
}
