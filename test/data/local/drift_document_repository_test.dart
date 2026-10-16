import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/data/local/drift_document_repository.dart';
import 'package:pacim_invoicer/data/local/pacim_database.dart';

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
}
