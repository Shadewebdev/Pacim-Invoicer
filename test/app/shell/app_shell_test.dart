import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/app/app_router.dart';
import 'package:pacim_invoicer/app/pacim_invoicer_app.dart';
import 'package:pacim_invoicer/app/shell/status_bar_message_provider.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';

import '../../support/fake_repositories.dart';

Future<ProviderContainer> pumpApp(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      documentRepositoryProvider.overrideWithValue(FakeDocumentRepository()),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const PacimInvoicerApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

String currentPath(ProviderContainer container) =>
    container.read(appRouterProvider).routeInformationProvider.value.uri.path;

void main() {
  const wide = Size(1200, 800);

  testWidgets('sidebar lists the three document types and settings', (
    tester,
  ) async {
    await pumpApp(tester, wide);
    expect(find.text('Quotations'), findsWidgets);
    expect(find.text('Sales orders'), findsOneWidget);
    expect(find.text('Delivery orders'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('root redirects to quotations', (tester) async {
    final container = await pumpApp(tester, wide);
    container.read(appRouterProvider).go('/');
    await tester.pumpAndSettle();
    expect(currentPath(container), '/quotations');
  });

  testWidgets('tapping Sales orders navigates to /sales-orders', (
    tester,
  ) async {
    final container = await pumpApp(tester, wide);
    await tester.tap(find.text('Sales orders'));
    await tester.pumpAndSettle();
    expect(currentPath(container), '/sales-orders');
  });

  testWidgets('unknown type segment redirects to quotations', (tester) async {
    final container = await pumpApp(tester, wide);
    container.read(appRouterProvider).go('/nonsense');
    await tester.pumpAndSettle();
    expect(currentPath(container), '/quotations');
  });

  testWidgets('below 900px the sidebar collapses to a rail without labels', (
    tester,
  ) async {
    await pumpApp(tester, const Size(800, 700));
    expect(find.text('Sales orders'), findsNothing);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('below 600px navigation moves into a drawer', (tester) async {
    final container = await pumpApp(tester, const Size(500, 700));
    expect(find.text('Sales orders'), findsNothing);
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    expect(find.text('Sales orders'), findsOneWidget);
    await tester.tap(find.text('Sales orders'));
    await tester.pumpAndSettle();
    expect(currentPath(container), '/sales-orders');
    expect(find.text('Delivery orders'), findsNothing);
  });

  testWidgets('status bar shows the status bar message', (tester) async {
    final container = await pumpApp(tester, wide);
    container.read(statusBarMessageProvider.notifier).showMessage('Saved');
    await tester.pump();
    expect(find.text('Saved'), findsOneWidget);
  });
}
