import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pacim_invoicer/data/local/pacim_database.dart';
import 'package:pacim_invoicer/data/payload/document_payload_migrator.dart';
import 'package:pacim_invoicer/data/repositories/document_repository.dart';
import 'package:pacim_invoicer/domain/exceptions/document_exceptions.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/document_chain.dart';
import 'package:pacim_invoicer/domain/models/document_list_query.dart';
import 'package:pacim_invoicer/domain/models/document_summary.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/services/document_totals_calculator.dart';

const String _searchSeparator = '\u001F';
const String _likeEscapeCharacter = '\\';

class DriftDocumentRepository implements DocumentRepository {
  DriftDocumentRepository(
    this._database, {
    this._totalsCalculator = const DocumentTotalsCalculator(),
    this._payloadMigrator = const DocumentPayloadMigrator(),
  });

  final PacimDatabase _database;
  final DocumentTotalsCalculator _totalsCalculator;
  final DocumentPayloadMigrator _payloadMigrator;

  @override
  Stream<List<DocumentSummary>> watchDocumentSummaries(
    DocumentListQuery query,
  ) {
    final statement = _database.select(_database.documentRows)
      ..where((row) => _matchesQuery(row, query))
      ..orderBy([
        (row) => _orderingTerm(row, query),
        (row) => OrderingTerm.asc(row.documentId),
      ])
      ..limit(query.limit);
    return statement.watch().map(
      (rows) => rows.map(_summaryFromRow).toList(growable: false),
    );
  }

  Expression<bool> _matchesQuery(
    $DocumentRowsTable row,
    DocumentListQuery query,
  ) {
    var condition = row.documentType.equals(query.documentType.name);
    final searchText = query.searchText.trim().toLowerCase();
    if (searchText.isNotEmpty) {
      final pattern = '%${_escapeLikePattern(searchText)}%';
      condition =
          condition &
          row.searchText.like(pattern, escapeChar: _likeEscapeCharacter);
    }
    final issuedFrom = query.issuedFrom;
    if (issuedFrom != null) {
      condition =
          condition &
          row.issueDate.isBiggerOrEqualValue(_startOfDay(issuedFrom));
    }
    final issuedTo = query.issuedTo;
    if (issuedTo != null) {
      condition =
          condition &
          row.issueDate.isSmallerThanValue(_startOfNextDay(issuedTo));
    }
    return condition;
  }

  OrderingTerm _orderingTerm($DocumentRowsTable row, DocumentListQuery query) {
    final Expression<Object> column = switch (query.sortField) {
      DocumentSortField.documentNumber => row.documentNumber,
      DocumentSortField.customerName => row.customerName.lower(),
      DocumentSortField.issueDate => row.issueDate,
      DocumentSortField.grandTotal => row.grandTotalMinor,
      DocumentSortField.updatedAt => row.updatedAt,
    };
    return OrderingTerm(
      expression: column,
      mode: query.sortDescending ? OrderingMode.desc : OrderingMode.asc,
    );
  }

  String _escapeLikePattern(String text) => text
      .replaceAll(
        _likeEscapeCharacter,
        '$_likeEscapeCharacter$_likeEscapeCharacter',
      )
      .replaceAll('%', '$_likeEscapeCharacter%')
      .replaceAll('_', '${_likeEscapeCharacter}_');

  DateTime _startOfDay(DateTime value) => value.isUtc
      ? DateTime.utc(value.year, value.month, value.day)
      : DateTime(value.year, value.month, value.day);

  DateTime _startOfNextDay(DateTime value) => value.isUtc
      ? DateTime.utc(value.year, value.month, value.day + 1)
      : DateTime(value.year, value.month, value.day + 1);

  @override
  Future<BusinessDocument> getDocument(String documentId) async {
    final row = await _selectDocumentRow(documentId).getSingleOrNull();
    if (row == null) throw DocumentNotFoundException(documentId);
    return _documentFromRow(row);
  }

  @override
  Stream<BusinessDocument> watchDocument(String documentId) {
    return _selectDocumentRow(documentId).watchSingleOrNull().map((row) {
      if (row == null) throw DocumentNotFoundException(documentId);
      return _documentFromRow(row);
    });
  }

  SimpleSelectStatement<$DocumentRowsTable, DocumentRow> _selectDocumentRow(
    String documentId,
  ) {
    return _database.select(_database.documentRows)
      ..where((row) => row.documentId.equals(documentId));
  }

  @override
  Stream<DocumentChain> watchDocumentChain(String chainId) {
    final statement = _database.select(_database.documentRows)
      ..where((row) => row.chainId.equals(chainId))
      ..orderBy([(row) => OrderingTerm.asc(row.documentNumber)]);
    return statement.watch().map((rows) {
      final summaries = rows.map(_summaryFromRow).toList();
      DocumentSummary? firstOfType(DocumentType type) {
        for (final summary in summaries) {
          if (summary.documentType == type) return summary;
        }
        return null;
      }

      return DocumentChain(
        chainId: chainId,
        quotation: firstOfType(DocumentType.quotation),
        salesOrder: firstOfType(DocumentType.salesOrder),
        deliveryOrders: summaries
            .where(
              (summary) => summary.documentType == DocumentType.deliveryOrder,
            )
            .toList(growable: false),
      );
    });
  }

  @override
  Future<List<BusinessDocument>> getDocumentsInChain(String chainId) async {
    final statement = _database.select(_database.documentRows)
      ..where((row) => row.chainId.equals(chainId))
      ..orderBy([(row) => OrderingTerm.asc(row.documentNumber)]);
    final rows = await statement.get();
    return rows.map(_documentFromRow).toList(growable: false);
  }

  @override
  Future<void> saveDocument(BusinessDocument document) {
    final row = _rowFromDocument(document);
    return _wrapStorageFailures(
      () => _database.transaction(() async {
        final stored = await _selectDocumentRow(document.documentId)
            .getSingleOrNull();
        if (stored != null && stored.lockedAt != null) {
          throw DocumentLockedException(document.documentId);
        }
        await _database
            .into(_database.documentRows)
            .insertOnConflictUpdate(row);
      }),
    );
  }

  /// The stored source may differ from [lockedSource] only in `lockedAt` and
  /// `updatedAt`; anything else means the caller holds a stale or edited
  /// copy, which is refused as a write to a locked document. A source that is
  /// already locked keeps its original lock and is not rewritten. Any existing
  /// row with the created document's id fails the whole transaction.
  @override
  Future<void> saveUpgrade({
    required BusinessDocument lockedSource,
    required BusinessDocument createdDocument,
  }) async {
    if (lockedSource.lockedAt == null) {
      throw ArgumentError.value(
        lockedSource.documentId,
        'lockedSource',
        'must have lockedAt set',
      );
    }
    if (createdDocument.sourceDocumentId != lockedSource.documentId) {
      throw ArgumentError.value(
        createdDocument.sourceDocumentId,
        'createdDocument.sourceDocumentId',
        'must be ${lockedSource.documentId}',
      );
    }
    if (createdDocument.lockedAt != null) {
      throw ArgumentError.value(
        createdDocument.documentId,
        'createdDocument',
        'must not have lockedAt set',
      );
    }
    final sourceRow = _rowFromDocument(lockedSource);
    final createdRow = _rowFromDocument(createdDocument);
    return _wrapStorageFailures(
      () => _database.transaction(() async {
        final storedSourceRow = await _selectDocumentRow(
          lockedSource.documentId,
        ).getSingleOrNull();
        if (storedSourceRow == null) {
          throw DocumentNotFoundException(lockedSource.documentId);
        }
        final storedSource = _documentFromRow(storedSourceRow);
        final incomingWithStoredLock = lockedSource.copyWith(
          lockedAt: storedSource.lockedAt,
          updatedAt: storedSource.updatedAt,
        );
        if (incomingWithStoredLock != storedSource) {
          throw DocumentLockedException(lockedSource.documentId);
        }

        final existingCreatedRow = await _selectDocumentRow(
          createdDocument.documentId,
        ).getSingleOrNull();
        if (existingCreatedRow?.lockedAt != null) {
          throw DocumentLockedException(createdDocument.documentId);
        }

        if (storedSource.lockedAt == null) {
          await _database.update(_database.documentRows).replace(sourceRow);
        }
        // A plain insert, so an existing unlocked row with this id fails the
        // transaction and rolls back the source lock above.
        await _database
            .into(_database.documentRows)
            .insert(createdRow, mode: InsertMode.insert);
      }),
    );
  }

  /// Unlocks the source when no other document was created from it. Only the
  /// lock is cleared; `updatedAt` is left as stored.
  @override
  Future<void> deleteDocument(String documentId) {
    return _wrapStorageFailures(
      () => _database.transaction(() async {
        final storedRow = await _selectDocumentRow(documentId)
            .getSingleOrNull();
        if (storedRow == null) throw DocumentNotFoundException(documentId);
        if (storedRow.lockedAt != null) {
          throw DocumentLockedException(documentId);
        }
        await (_database.delete(
          _database.documentRows,
        )..where((row) => row.documentId.equals(documentId))).go();

        final sourceDocumentId = storedRow.sourceDocumentId;
        if (sourceDocumentId == null) return;
        final remainingDerived =
            await (_database.select(_database.documentRows)
                  ..where(
                    (row) => row.sourceDocumentId.equals(sourceDocumentId),
                  )
                  ..limit(1))
                .get();
        if (remainingDerived.isNotEmpty) return;

        final sourceRow = await _selectDocumentRow(sourceDocumentId)
            .getSingleOrNull();
        if (sourceRow == null || sourceRow.lockedAt == null) return;
        // The payload is the source of truth, so it is rewritten along with
        // the lockedAt column.
        final unlockedSource = _documentFromRow(sourceRow)
            .copyWith(lockedAt: null);
        await _database
            .update(_database.documentRows)
            .replace(_rowFromDocument(unlockedSource));
      }),
    );
  }

  /// Wraps storage failures in [StorageWriteException], keeping the original
  /// stack trace. Domain exceptions pass through unchanged.
  Future<void> _wrapStorageFailures(Future<void> Function() write) async {
    try {
      await write();
    } on DocumentLockedException {
      rethrow;
    } on DocumentNotFoundException {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(StorageWriteException(error), stackTrace);
    }
  }

  DocumentRowsCompanion _rowFromDocument(BusinessDocument document) {
    return DocumentRowsCompanion.insert(
      documentId: document.documentId,
      documentType: document.documentType.name,
      documentNumber: document.documentNumber,
      chainId: document.chainId,
      sourceDocumentId: Value(document.sourceDocumentId),
      customerName: document.customerDetails.customerName,
      issueDate: document.issueDate,
      grandTotalMinor: _totalsCalculator.calculate(document).grandTotalMinor,
      currencyCode: document.pricingTerms.currencyFormat.currencyCode,
      lockedAt: Value(document.lockedAt),
      updatedAt: document.updatedAt,
      schemaVersion: document.schemaVersion,
      searchText: _searchTextFor(document),
      payloadJson: jsonEncode(document.toJson()),
    );
  }

  /// Lowercased with Dart's Unicode-aware rules, because SQLite lower() is
  /// ASCII-only. The separator cannot appear in a number or a name.
  String _searchTextFor(BusinessDocument document) =>
      '${document.documentNumber}$_searchSeparator'
              '${document.customerDetails.customerName}'
          .toLowerCase();

  BusinessDocument _documentFromRow(DocumentRow row) {
    final payload = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    return BusinessDocument.fromJson(
      _payloadMigrator.migrateToCurrent(payload, row.schemaVersion),
    );
  }

  DocumentSummary _summaryFromRow(DocumentRow row) {
    return DocumentSummary(
      documentId: row.documentId,
      documentType: DocumentType.values.byName(row.documentType),
      documentNumber: row.documentNumber,
      chainId: row.chainId,
      sourceDocumentId: row.sourceDocumentId,
      customerName: row.customerName,
      issueDate: row.issueDate,
      grandTotalMinor: row.grandTotalMinor,
      currencyCode: row.currencyCode,
      isLocked: row.lockedAt != null,
      updatedAt: row.updatedAt,
    );
  }
}
