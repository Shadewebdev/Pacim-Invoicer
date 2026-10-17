import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pacim_invoicer/data/repositories/asset_repository.dart';
import 'package:pacim_invoicer/data/repositories/document_repository.dart';
import 'package:pacim_invoicer/data/repositories/number_sequence_repository.dart';
import 'package:pacim_invoicer/data/repositories/settings_repository.dart';
import 'package:pacim_invoicer/domain/exceptions/document_exceptions.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/document_chain.dart';
import 'package:pacim_invoicer/domain/models/document_list_query.dart';
import 'package:pacim_invoicer/domain/models/document_settings.dart';
import 'package:pacim_invoicer/domain/models/document_summary.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/services/document_totals_calculator.dart';

/// Emits the current value to every new listener, then each later change.
/// The source is subscribed first, so a write right after listening is kept.
Stream<T> _watchValue<T>(Stream<T> changes, T Function() currentValue) {
  return Stream<T>.multi((listener) {
    final subscription = changes.listen(
      listener.addSync,
      onError: listener.addErrorSync,
    );
    listener.addSync(currentValue());
    listener.onCancel = () {
      unawaited(subscription.cancel());
    };
  });
}

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([DocumentSettings? initialSettings])
    : _settings = initialSettings ?? DocumentSettings.initial();

  DocumentSettings _settings;
  final _changes = StreamController<DocumentSettings>.broadcast();

  /// How many times [saveSettings] succeeded.
  int saveCount = 0;

  /// Makes the next [saveSettings] call throw once.
  bool failNextSave = false;

  DocumentSettings get currentSettings => _settings;

  @override
  Stream<DocumentSettings> watchSettings() =>
      _watchValue(_changes.stream, () => _settings);

  @override
  Future<void> saveSettings(DocumentSettings settings) async {
    if (failNextSave) {
      failNextSave = false;
      throw const StorageWriteException('fake save failure');
    }
    _settings = settings;
    saveCount++;
    _changes.add(settings);
  }
}

class FakeAssetRepository implements AssetRepository {
  /// Makes the next [storeImage] call throw once.
  bool failNextStore = false;

  final Map<String, Uint8List> storedImages = {};

  @override
  Future<String> storeImage(Uint8List bytes) async {
    if (failNextStore) {
      failNextStore = false;
      throw const StorageWriteException('fake store failure');
    }
    final assetId = 'asset-${base64Url.encode(bytes)}';
    storedImages[assetId] = bytes;
    return assetId;
  }

  @override
  Future<Uint8List?> loadImage(String assetId) async => storedImages[assetId];
}

/// Mirrors `DriftNumberSequenceRepository`: year 0 holds the highest
/// sequence ever issued for a type, and each year's entry the highest issued
/// in that year; every allocation raises both.
class FakeNumberSequenceRepository implements NumberSequenceRepository {
  final Map<(DocumentType, int), int> _lastSequenceByTypeAndYear = {};

  @override
  Future<int> allocateNextSequence(
    DocumentType type, {
    required int year,
    required bool resetsYearly,
  }) async {
    final highestEver = _lastSequenceByTypeAndYear[(type, 0)] ?? 0;
    final highestThisYear = _lastSequenceByTypeAndYear[(type, year)] ?? 0;
    final next = (resetsYearly ? highestThisYear : highestEver) + 1;
    _lastSequenceByTypeAndYear[(type, 0)] = math.max(highestEver, next);
    _lastSequenceByTypeAndYear[(type, year)] = math.max(highestThisYear, next);
    return next;
  }

  @override
  Future<int> peekNextSequence(
    DocumentType type, {
    required int year,
    required bool resetsYearly,
  }) async =>
      (_lastSequenceByTypeAndYear[(type, resetsYearly ? year : 0)] ?? 0) + 1;
}

class FakeDocumentRepository implements DocumentRepository {
  final Map<String, BusinessDocument> _documents = {};
  final _changes = StreamController<void>.broadcast();

  /// How many times [saveDocument] succeeded.
  int saveCount = 0;

  /// Makes the next [saveDocument] call throw once.
  bool failNextSave = false;

  List<BusinessDocument> get storedDocuments => _documents.values.toList();

  void seed(BusinessDocument document) {
    _documents[document.documentId] = document;
    _changes.add(null);
  }

  DocumentSummary _summaryOf(BusinessDocument document) => DocumentSummary(
    documentId: document.documentId,
    documentType: document.documentType,
    documentNumber: document.documentNumber,
    chainId: document.chainId,
    sourceDocumentId: document.sourceDocumentId,
    customerName: document.customerDetails.customerName,
    issueDate: document.issueDate,
    grandTotalMinor: const DocumentTotalsCalculator()
        .calculate(document)
        .grandTotalMinor,
    currencyFormat: document.pricingTerms.currencyFormat,
    isLocked: document.lockedAt != null,
    updatedAt: document.updatedAt,
  );

  DateTime _startOfDay(DateTime value) => value.isUtc
      ? DateTime.utc(value.year, value.month, value.day)
      : DateTime(value.year, value.month, value.day);

  List<DocumentSummary> _matchingSummaries(DocumentListQuery query) {
    final search = query.searchText.trim().toLowerCase();
    final issuedFrom = query.issuedFrom == null
        ? null
        : _startOfDay(query.issuedFrom!);
    return _documents.values
        .where((document) => document.documentType == query.documentType)
        .map(_summaryOf)
        .where(
          (summary) =>
              (search.isEmpty ||
                  summary.documentNumber.toLowerCase().contains(search) ||
                  summary.customerName.toLowerCase().contains(search)) &&
              (issuedFrom == null || !summary.issueDate.isBefore(issuedFrom)) &&
              (query.issuedTo == null ||
                  summary.issueDate.isBefore(
                    DateTime(
                      query.issuedTo!.year,
                      query.issuedTo!.month,
                      query.issuedTo!.day + 1,
                    ),
                  )),
        )
        .toList();
  }

  List<DocumentSummary> _summariesFor(DocumentListQuery query) {
    int compare(DocumentSummary a, DocumentSummary b) {
      final result = switch (query.sortField) {
        DocumentSortField.documentNumber => a.documentNumber.compareTo(
          b.documentNumber,
        ),
        DocumentSortField.customerName =>
          a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase()),
        DocumentSortField.issueDate => a.issueDate.compareTo(b.issueDate),
        DocumentSortField.grandTotal => a.grandTotalMinor.compareTo(
          b.grandTotalMinor,
        ),
        DocumentSortField.updatedAt => a.updatedAt.compareTo(b.updatedAt),
      };
      if (result != 0) return query.sortDescending ? -result : result;
      // Like Drift, ties always break by ascending document id.
      return a.documentId.compareTo(b.documentId);
    }

    final sorted = _matchingSummaries(query)..sort(compare);
    return sorted.take(query.limit).toList();
  }

  DocumentChain _chainFor(String chainId) {
    final summaries = _documents.values
        .where((document) => document.chainId == chainId)
        .map(_summaryOf)
        .toList();
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
      deliveryOrders:
          summaries
              .where(
                (summary) => summary.documentType == DocumentType.deliveryOrder,
              )
              .toList()
            ..sort((a, b) => a.documentNumber.compareTo(b.documentNumber)),
    );
  }

  @override
  Stream<List<DocumentSummary>> watchDocumentSummaries(
    DocumentListQuery query,
  ) => _watchValue(
    _changes.stream.map((_) => _summariesFor(query)),
    () => _summariesFor(query),
  );

  @override
  Stream<int> watchDocumentCount(DocumentListQuery query) => _watchValue(
    _changes.stream.map((_) => _matchingSummaries(query).length),
    () => _matchingSummaries(query).length,
  );

  @override
  Future<BusinessDocument> getDocument(String documentId) async {
    final document = _documents[documentId];
    if (document == null) throw DocumentNotFoundException(documentId);
    return document;
  }

  /// Like Drift: the current document, then each change; a missing document
  /// is an error event and the stream keeps going.
  @override
  Stream<BusinessDocument> watchDocument(String documentId) {
    return Stream<BusinessDocument>.multi((listener) {
      void emitCurrent() {
        final document = _documents[documentId];
        if (document == null) {
          listener.addErrorSync(DocumentNotFoundException(documentId));
        } else {
          listener.addSync(document);
        }
      }

      final subscription = _changes.stream.listen((_) => emitCurrent());
      emitCurrent();
      listener.onCancel = subscription.cancel;
    });
  }

  @override
  Stream<DocumentChain> watchDocumentChain(String chainId) => _watchValue(
    _changes.stream.map((_) => _chainFor(chainId)),
    () => _chainFor(chainId),
  );

  @override
  Future<List<BusinessDocument>> getDocumentsInChain(String chainId) async =>
      _documents.values
          .where((document) => document.chainId == chainId)
          .toList();

  @override
  Future<bool> documentNumberExists(
    DocumentType type,
    String documentNumber,
  ) async => _documents.values.any(
    (document) =>
        document.documentType == type &&
        document.documentNumber == documentNumber,
  );

  /// Like the unique index in Drift.
  void _refuseDuplicateNumber(BusinessDocument document) {
    final isDuplicate = _documents.values.any(
      (stored) =>
          stored.documentId != document.documentId &&
          stored.documentType == document.documentType &&
          stored.documentNumber == document.documentNumber,
    );
    if (isDuplicate) {
      throw StorageWriteException(
        'duplicate number ${document.documentNumber}',
      );
    }
  }

  @override
  Future<void> saveDocument(BusinessDocument document) async {
    if (failNextSave) {
      failNextSave = false;
      throw const StorageWriteException('fake save failure');
    }
    final existing = _documents[document.documentId];
    if (existing?.lockedAt != null) {
      throw DocumentLockedException(document.documentId);
    }
    _refuseDuplicateNumber(document);
    saveCount++;
    seed(document);
  }

  @override
  Future<void> saveUpgrade({
    required BusinessDocument lockedSource,
    required BusinessDocument createdDocument,
  }) async {
    _refuseDuplicateNumber(createdDocument);
    _documents[lockedSource.documentId] = lockedSource;
    _documents[createdDocument.documentId] = createdDocument;
    _changes.add(null);
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    final existing = await getDocument(documentId);
    if (existing.lockedAt != null) throw DocumentLockedException(documentId);
    _documents.remove(documentId);
    _changes.add(null);
  }
}

/// Counts the open `watchDocument` and `watchDocumentChain` subscriptions, so
/// tests can check that leaving a screen stops its watchers.
class WatchCountingDocumentRepository extends FakeDocumentRepository {
  int openDocumentWatches = 0;
  int openChainWatches = 0;

  @override
  Stream<BusinessDocument> watchDocument(String documentId) => _counted(
    super.watchDocument(documentId),
    (change) => openDocumentWatches += change,
  );

  @override
  Stream<DocumentChain> watchDocumentChain(String chainId) => _counted(
    super.watchDocumentChain(chainId),
    (change) => openChainWatches += change,
  );

  Stream<T> _counted<T>(Stream<T> source, void Function(int) count) {
    return Stream<T>.multi((listener) {
      count(1);
      final subscription = source.listen(
        listener.addSync,
        onError: listener.addErrorSync,
        onDone: listener.closeSync,
      );
      listener.onCancel = () {
        count(-1);
        return subscription.cancel();
      };
    });
  }
}
