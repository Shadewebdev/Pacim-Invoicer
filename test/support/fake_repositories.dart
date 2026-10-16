import 'dart:async';
import 'dart:convert';
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

class FakeNumberSequenceRepository implements NumberSequenceRepository {
  final Map<DocumentType, int> lastSequenceByType = {};

  @override
  Future<int> allocateNextSequence(
    DocumentType type, {
    required int year,
    required bool resetsYearly,
  }) async {
    final next = (lastSequenceByType[type] ?? 0) + 1;
    lastSequenceByType[type] = next;
    return next;
  }
}

class FakeDocumentRepository implements DocumentRepository {
  final Map<String, BusinessDocument> _documents = {};
  final _changes = StreamController<void>.broadcast();

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
    currencyCode: document.pricingTerms.currencyFormat.currencyCode,
    isLocked: document.lockedAt != null,
    updatedAt: document.updatedAt,
  );

  List<DocumentSummary> _matchingSummaries(DocumentListQuery query) {
    final search = query.searchText.toLowerCase();
    return _documents.values
        .where((document) => document.documentType == query.documentType)
        .map(_summaryOf)
        .where(
          (summary) =>
              (search.isEmpty ||
                  summary.documentNumber.toLowerCase().contains(search) ||
                  summary.customerName.toLowerCase().contains(search)) &&
              (query.issuedFrom == null ||
                  !summary.issueDate.isBefore(query.issuedFrom!)) &&
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
      return query.sortDescending ? -result : result;
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

  @override
  Stream<BusinessDocument> watchDocument(String documentId) async* {
    yield await getDocument(documentId);
    await for (final _ in _changes.stream) {
      yield await getDocument(documentId);
    }
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
  Future<void> saveDocument(BusinessDocument document) async {
    final existing = _documents[document.documentId];
    if (existing?.lockedAt != null) {
      throw DocumentLockedException(document.documentId);
    }
    seed(document);
  }

  @override
  Future<void> saveUpgrade({
    required BusinessDocument lockedSource,
    required BusinessDocument createdDocument,
  }) async {
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
