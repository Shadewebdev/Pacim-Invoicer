import 'package:drift/drift.dart';
import 'package:pacim_invoicer/data/local/pacim_database.dart';
import 'package:pacim_invoicer/data/repositories/number_sequence_repository.dart';
import 'package:pacim_invoicer/domain/exceptions/document_exceptions.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';

/// The counter year used by types whose numbering does not reset yearly.
const int _nonResettingYear = 0;

class DriftNumberSequenceRepository implements NumberSequenceRepository {
  DriftNumberSequenceRepository(this._database);

  final PacimDatabase _database;

  /// One upsert that increments the counter row and returns the new value,
  /// inside a transaction so concurrent callers are serialised.
  @override
  Future<int> allocateNextSequence(
    DocumentType type, {
    required int year,
    required bool resetsYearly,
  }) async {
    final firstRow = NumberSequenceRowsCompanion.insert(
      documentType: type.name,
      year: resetsYearly ? year : _nonResettingYear,
      lastSequence: 1,
    );
    try {
      return await _database.transaction(() async {
        final row = await _database
            .into(_database.numberSequenceRows)
            .insertReturning(
              firstRow,
              onConflict: DoUpdate(
                (stored) => NumberSequenceRowsCompanion.custom(
                  lastSequence: stored.lastSequence + const Constant(1),
                ),
              ),
            );
        return row.lastSequence;
      });
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(StorageWriteException(error), stackTrace);
    }
  }
}
