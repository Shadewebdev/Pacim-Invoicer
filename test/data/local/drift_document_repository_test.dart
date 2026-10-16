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

  group('storage failures', () {
    late DriftDocumentRepository repository;

    setUp(() async {
      database = PacimDatabase.forTesting(NativeDatabase.memory());
      repository = DriftDocumentRepository(database);
    });

    Future<StackTrace> stackTraceOfStorageFailure(Future<void> write) async {
      try {
        await write;
      } on StorageWriteException catch (_, stackTrace) {
        return stackTrace;
      }
      fail('expected a StorageWriteException');
    }

    test(
      'saveDocument keeps the stack trace of the underlying failure',
      () async {
        await database.customStatement('DROP TABLE documents');
        final stackTrace = await stackTraceOfStorageFailure(
          repository.saveDocument(buildTestDocument()),
        );
        expect(stackTrace.toString(), contains('package:sqlite3/'));
      },
    );

    test('saveUpgrade wraps a failed write in StorageWriteException', () async {
      await repository.saveDocument(buildTestDocument(documentId: 'qt'));
      await database.customStatement('DROP TABLE documents');
      final stackTrace = await stackTraceOfStorageFailure(
        repository.saveUpgrade(
          lockedSource: buildTestDocument(
            documentId: 'qt',
            lockedAt: DateTime.utc(2026, 10, 18),
          ),
          createdDocument: buildTestDocument(
            documentId: 'so',
            sourceDocumentId: 'qt',
          ),
        ),
      );
      expect(stackTrace.toString(), contains('package:sqlite3/'));
    });

    test(
      'deleteDocument wraps a failed write in StorageWriteException',
      () async {
        await database.customStatement('DROP TABLE documents');
        final stackTrace = await stackTraceOfStorageFailure(
          repository.deleteDocument('qt'),
        );
        expect(stackTrace.toString(), contains('package:sqlite3/'));
      },
    );
  });
}
