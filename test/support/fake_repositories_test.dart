import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/domain/models/document_list_query.dart';
import 'package:pacim_invoicer/domain/models/document_settings.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';

import '../data/contract/number_sequence_repository_contract.dart';
import 'document_builders.dart';
import 'fake_repositories.dart';

void main() {
  runNumberSequenceRepositoryContract(
    () async => FakeNumberSequenceRepository(),
  );

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

  test(
    'summaries tie-break by document id and start issuedFrom at day start',
    () async {
      final repository = FakeDocumentRepository()
        ..seed(buildTestDocument(documentId: 'b'))
        ..seed(buildTestDocument(documentId: 'a'));
      final query = DocumentListQuery(
        documentType: DocumentType.quotation,
        sortField: DocumentSortField.documentNumber,
        sortDescending: true,
        issuedFrom: DateTime.utc(2026, 10, 17, 15),
      );

      final summaries = await repository.watchDocumentSummaries(query).first;

      expect(summaries.map((summary) => summary.documentId), ['a', 'b']);
    },
  );
}
