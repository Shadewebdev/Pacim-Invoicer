import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/data/local/drift_document_repository.dart';
import 'package:pacim_invoicer/data/local/pacim_database.dart';
import 'package:pacim_invoicer/domain/exceptions/document_exceptions.dart';

import '../../support/document_builders.dart';

import '../contract/document_repository_contract.dart';

void main() {
  late PacimDatabase database;

  tearDown(() async {
    await database.close();
  });

  runDocumentRepositoryContract(() async {
    database = PacimDatabase.forTesting(NativeDatabase.memory());
    return DriftDocumentRepository(database);
  });

  test('a failed write is wrapped in StorageWriteException', () async {
    database = PacimDatabase.forTesting(NativeDatabase.memory());
    final repository = DriftDocumentRepository(database);
    await database.customStatement('DROP TABLE documents');
    await expectLater(
      repository.saveDocument(buildTestDocument()),
      throwsA(isA<StorageWriteException>()),
    );
  });
}
