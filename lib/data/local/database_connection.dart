import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Opens the on-device database. Web options are added with the web setup.
QueryExecutor openPacimDatabaseConnection() {
  return driftDatabase(name: 'pacim_invoicer');
}
