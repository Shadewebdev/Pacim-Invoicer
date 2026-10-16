import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/domain/models/document_settings.dart';

import 'fake_repositories.dart';

void main() {
  testWidgets('a write immediately after listening is not lost', (
    tester,
  ) async {
    final repository = FakeSettingsRepository();
    final received = <String>[];
    repository.watchSettings().listen(
      (settings) => received.add(settings.defaultFooterNote),
    );
    await repository.saveSettings(
      DocumentSettings.initial().copyWith(defaultFooterNote: 'after listen'),
    );
    await tester.pump();

    expect(received, ['', 'after listen']);
  });
}
