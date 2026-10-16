import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pacim_invoicer/data/local/pacim_database.dart';
import 'package:pacim_invoicer/data/repositories/settings_repository.dart';
import 'package:pacim_invoicer/domain/exceptions/document_exceptions.dart';
import 'package:pacim_invoicer/domain/models/document_settings.dart';

/// The settings table holds a single row with this id.
const int _settingsRowId = 1;

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._database);

  final PacimDatabase _database;

  @override
  Stream<DocumentSettings> watchSettings() {
    final statement = _database.select(_database.settingsRows)
      ..where((row) => row.id.equals(_settingsRowId));
    return statement.watchSingleOrNull().map((row) {
      if (row == null) return DocumentSettings.initial();
      return DocumentSettings.fromJson(
        jsonDecode(row.payloadJson) as Map<String, dynamic>,
      );
    });
  }

  @override
  Future<void> saveSettings(DocumentSettings settings) async {
    try {
      await _database
          .into(_database.settingsRows)
          .insertOnConflictUpdate(
            SettingsRowsCompanion.insert(
              id: const Value(_settingsRowId),
              payloadJson: jsonEncode(settings.toJson()),
            ),
          );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(StorageWriteException(error), stackTrace);
    }
  }
}
