import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/app/app_router.dart';
import 'package:pacim_invoicer/app/pacim_invoicer_app.dart';
import 'package:pacim_invoicer/app/theme/app_color_tokens.dart';
import 'package:pacim_invoicer/app/theme/theme_mode_provider.dart';
import 'package:pacim_invoicer/domain/models/customer_details.dart';
import 'package:pacim_invoicer/features/document_editor/document_editor_page.dart';
import 'package:pacim_invoicer/features/document_editor/document_page/document_page_view.dart';
import 'package:pacim_invoicer/features/document_editor/document_page/document_page_styles.dart';

import '../support/document_builders.dart';
import '../support/fake_repositories.dart';
import '../support/test_provider_overrides.dart';

const _widths = [1280.0, 1000.0, 800.0, 400.0];
const _themes = [ThemeMode.light, ThemeMode.dark];

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required double width,
  required ThemeMode themeMode,
  required String location,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final documents = FakeDocumentRepository()
    ..seed(
      buildTestDocument().copyWith(
        customerDetails: const CustomerDetails(customerName: 'Acme Trading'),
      ),
    );
  final container = ProviderContainer(
    overrides: [...fakeStorageOverrides(documents: documents)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const PacimInvoicerApp(),
    ),
  );
  await tester.pumpAndSettle();
  container.read(themeModeProvider.notifier).setThemeMode(themeMode);
  container.read(appRouterProvider).go(location);
  await tester.pumpAndSettle();
  return container;
}

void _expectThemeApplied(WidgetTester tester, ThemeMode mode) {
  final context = tester.element(find.byType(Scaffold).first);
  final expected = mode == ThemeMode.dark
      ? AppColorTokens.dark
      : AppColorTokens.light;
  expect(
    Theme.of(context).extension<AppColorTokens>()!.surface,
    expected.surface,
  );
}

void main() {
  for (final width in _widths) {
    for (final mode in _themes) {
      final label = '${width.toInt()}px ${mode.name}';

      testWidgets('quotations list fits at $label', (tester) async {
        await _pump(
          tester,
          width: width,
          themeMode: mode,
          location: '/quotations',
        );
        expect(tester.takeException(), isNull);
        expect(find.text('QT-2026-0001'), findsOneWidget);
        expect(find.text('Acme Trading'), findsOneWidget);
        _expectThemeApplied(tester, mode);
      });

      testWidgets('editor fits at $label', (tester) async {
        await _pump(
          tester,
          width: width,
          themeMode: mode,
          location: '/documents/doc-1',
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Export PDF'), findsOneWidget);
        expect(find.text('Fit width'), findsOneWidget);
        _expectThemeApplied(tester, mode);
      });

      testWidgets('settings fits at $label', (tester) async {
        await _pump(
          tester,
          width: width,
          themeMode: mode,
          location: '/settings',
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Appearance'), findsWidgets);
        _expectThemeApplied(tester, mode);
      });
    }
  }

  // The status and view controls drop to a second row rather than pushing
  // commands out of reach; below 760 px the commands scroll in one row, which
  // caps the bar at two rows (80 px).
  for (final width in [1700.0, 1400.0, 1000.0, 800.0, 700.0, 650.0]) {
    testWidgets('every editor command is reachable at ${width.toInt()}px', (
      tester,
    ) async {
      await _pump(
        tester,
        width: width,
        themeMode: ThemeMode.light,
        location: '/documents/doc-1',
      );
      final barHeight =
          tester.getTopLeft(find.byKey(const ValueKey('breadcrumbSlot'))).dy -
          tester.getTopLeft(find.byType(DocumentEditorPage)).dy;
      if (width < 760) {
        expect(barHeight, lessThanOrEqualTo(80), reason: 'bar height');
      }
      for (final label in [
        'Save',
        'Duplicate',
        'Export PDF',
        'Print',
        'Fit width',
      ]) {
        await tester.ensureVisible(find.text(label));
        await tester.pumpAndSettle();
        expect(
          find.text(label).hitTestable(),
          findsOneWidget,
          reason: '$label unreachable at ${width.toInt()}px',
        );
      }
    });
  }

  testWidgets('narrow list drops the issue date column', (tester) async {
    await _pump(
      tester,
      width: 400,
      themeMode: ThemeMode.light,
      location: '/quotations',
    );
    expect(find.text('Issue date'), findsNothing);
    expect(find.text('Number'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
  });

  testWidgets('wide list keeps the issue date column', (tester) async {
    await _pump(
      tester,
      width: 1280,
      themeMode: ThemeMode.light,
      location: '/quotations',
    );
    expect(find.text('Issue date'), findsOneWidget);
    expect(find.text('Chain'), findsOneWidget);
  });

  for (final mode in _themes) {
    testWidgets('narrow editor scales the white page to the screen in $mode', (
      tester,
    ) async {
      await _pump(
        tester,
        width: 400,
        themeMode: mode,
        location: '/documents/doc-1',
      );
      final pageRect = tester.getRect(find.byType(DocumentPageView));
      expect(pageRect.left, greaterThanOrEqualTo(0));
      expect(pageRect.right, lessThanOrEqualTo(400.5));
      final pageDecoration = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(DocumentPageView),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((box) => (box.decoration as BoxDecoration).color);
      expect(pageDecoration, contains(DocumentPageStyles.tokens.paper));
    });
  }
}
