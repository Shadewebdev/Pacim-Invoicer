import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Where the browser loads the sqlite3 WebAssembly module and drift worker.
///
/// Both files live in `web/` and must match the resolved `sqlite3` and
/// `drift` package versions.
DriftWebOptions pacimDatabaseWebOptions() {
  return DriftWebOptions(
    sqlite3Wasm: Uri.parse('sqlite3.wasm'),
    driftWorker: Uri.parse('drift_worker.js'),
  );
}

/// Opens the on-device database: native SQLite on Windows and Android, and
/// sqlite3 WASM (OPFS or IndexedDB) on web.
QueryExecutor openPacimDatabaseConnection() {
  return driftDatabase(name: 'pacim_invoicer', web: pacimDatabaseWebOptions());
}
