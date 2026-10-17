import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:pacim_invoicer/data/local/pacim_database.dart';
import 'package:pacim_invoicer/data/repositories/number_sequence_repository.dart';
import 'package:pacim_invoicer/domain/exceptions/document_exceptions.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';

/// The counter year that holds the highest sequence ever issued for a type.
const int _allYears = 0;

/// Each type has two kinds of counter row: year 0 holds the highest sequence
/// ever issued, and each calendar year's row holds the highest issued in that
/// year. Every allocation raises both, whichever mode it uses, so switching
/// "Restart numbering each year" on or off never goes back to a sequence that
/// was already issued: non-resetting numbering continues from year 0, and
/// yearly numbering continues from the year's own row.
///
/// The rows are read and written in one transaction, which serialises
/// concurrent callers; a Firestore version is two document reads and two
/// writes in one `runTransaction`.
class DriftNumberSequenceRepository implements NumberSequenceRepository {
  DriftNumberSequenceRepository(this._database);

  final PacimDatabase _database;

  @override
  Future<int> allocateNextSequence(
    DocumentType type, {
    required int year,
    required bool resetsYearly,
  }) async {
    try {
      return await _database.transaction(() async {
        final highestEver = await _lastSequence(type, _allYears);
        final highestThisYear = await _lastSequence(type, year);
        final next = (resetsYearly ? highestThisYear : highestEver) + 1;
        await _storeLastSequence(type, _allYears, math.max(highestEver, next));
        await _storeLastSequence(type, year, math.max(highestThisYear, next));
        return next;
      });
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(StorageWriteException(error), stackTrace);
    }
  }

  @override
  Future<int> peekNextSequence(
    DocumentType type, {
    required int year,
    required bool resetsYearly,
  }) async => await _lastSequence(type, resetsYearly ? year : _allYears) + 1;

  Future<int> _lastSequence(DocumentType type, int year) async {
    final row =
        await (_database.select(_database.numberSequenceRows)..where(
              (row) =>
                  row.documentType.equals(type.name) & row.year.equals(year),
            ))
            .getSingleOrNull();
    return row?.lastSequence ?? 0;
  }

  Future<void> _storeLastSequence(
    DocumentType type,
    int year,
    int lastSequence,
  ) {
    return _database
        .into(_database.numberSequenceRows)
        .insertOnConflictUpdate(
          NumberSequenceRowsCompanion.insert(
            documentType: type.name,
            year: year,
            lastSequence: lastSequence,
          ),
        );
  }
}
