import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/data/repository_providers.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/features/document_editor/document_commands.dart';

import '../../support/fake_repositories.dart';
import '../../support/sequential_id_generator.dart';

class _Harness {
  _Harness() {
    container = ProviderContainer(
      overrides: [
        documentRepositoryProvider.overrideWithValue(documents),
        numberSequenceRepositoryProvider.overrideWithValue(sequences),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
        idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 17)),
      ],
    );
  }

  final documents = FakeDocumentRepository();
  final sequences = FakeNumberSequenceRepository();
  late final ProviderContainer container;

  DocumentCommands get commands => container.read(documentCommandsProvider);
}

void main() {
  test('createDocument allocates QT-2026-0001 then QT-2026-0002', () async {
    final harness = _Harness();
    addTearDown(harness.container.dispose);

    final firstId = await harness.commands.createDocument(
      DocumentType.quotation,
    );
    final secondId = await harness.commands.createDocument(
      DocumentType.quotation,
    );

    expect(
      (await harness.documents.getDocument(firstId)).documentNumber,
      'QT-2026-0001',
    );
    expect(
      (await harness.documents.getDocument(secondId)).documentNumber,
      'QT-2026-0002',
    );
  });

  test('upgradeDocument creates SO in same chain and locks QT', () async {
    final harness = _Harness();
    addTearDown(harness.container.dispose);
    final quotationId = await harness.commands.createDocument(
      DocumentType.quotation,
    );

    final salesOrderId = await harness.commands.upgradeDocument(quotationId);

    final quotation = await harness.documents.getDocument(quotationId);
    final salesOrder = await harness.documents.getDocument(salesOrderId);
    expect(salesOrder.documentType, DocumentType.salesOrder);
    expect(salesOrder.documentNumber, 'SO-2026-0001');
    expect(salesOrder.chainId, quotation.chainId);
    expect(salesOrder.sourceDocumentId, quotationId);
    expect(quotation.lockedAt, isNotNull);
  });

  test('duplicateDocument starts a new chain', () async {
    final harness = _Harness();
    addTearDown(harness.container.dispose);
    final quotationId = await harness.commands.createDocument(
      DocumentType.quotation,
    );

    final copyId = await harness.commands.duplicateDocument(quotationId);

    final original = await harness.documents.getDocument(quotationId);
    final copy = await harness.documents.getDocument(copyId);
    expect(copy.chainId, isNot(original.chainId));
    expect(copy.documentNumber, 'QT-2026-0002');
    expect(copy.lockedAt, isNull);
  });

  test('deleteDocument removes an unlocked document', () async {
    final harness = _Harness();
    addTearDown(harness.container.dispose);
    final quotationId = await harness.commands.createDocument(
      DocumentType.quotation,
    );

    await harness.commands.deleteDocument(quotationId);

    expect(harness.documents.storedDocuments, isEmpty);
  });
}
