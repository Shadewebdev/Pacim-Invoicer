import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/features/settings/settings_fields.dart';

void main() {
  testWidgets('a two-line text field builds without an assertion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsTextField(
            label: 'Footer note',
            value: 'Thanks',
            maxLines: 2,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Thanks'), findsOneWidget);
  });
}
