import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/data/local/drift_number_sequence_repository.dart';
import 'package:pacim_invoicer/data/local/pacim_database.dart';

import '../contract/number_sequence_repository_contract.dart';

void main() {
  late PacimDatabase database;

  tearDown(() async {
    await database.close();
  });

  runNumberSequenceRepositoryContract(() async {
    database = PacimDatabase.forTesting(NativeDatabase.memory());
    return DriftNumberSequenceRepository(database);
  });
}
