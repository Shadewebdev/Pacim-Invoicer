import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/document_repository.dart';
import '../../data/repositories/number_sequence_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repository_providers.dart';
import '../../domain/exceptions/document_exceptions.dart';
import '../../domain/models/business_document.dart';
import '../../domain/models/document_settings.dart';
import '../../domain/models/document_type.dart';
import '../../domain/services/document_factory.dart';
import '../../domain/services/document_number_formatter.dart';
import '../../domain/services/document_upgrade_service.dart';

/// Creates, upgrades, duplicates and deletes documents. Every created document
/// gets its number allocated here, once, from the type's numbering rule.
class DocumentCommands {
  const DocumentCommands({
    required this.documentRepository,
    required this.numberSequenceRepository,
    required this.settingsRepository,
    required this.documentFactory,
    required this.upgradeService,
    required this.clock,
    this.numberFormatter = const DocumentNumberFormatter(),
  });

  final DocumentRepository documentRepository;
  final NumberSequenceRepository numberSequenceRepository;
  final SettingsRepository settingsRepository;
  final DocumentFactory documentFactory;
  final DocumentUpgradeService upgradeService;
  final DateTime Function() clock;
  final DocumentNumberFormatter numberFormatter;

  /// Creates a standalone document in a new chain and returns its id.
  Future<String> createDocument(DocumentType type) async {
    final settings = await _readSettings();
    final now = clock();
    final documentNumber = await _allocateDocumentNumber(type, settings, now);
    final document = documentFactory.createStandalone(
      documentType: type,
      documentNumber: documentNumber,
      settings: settings,
      now: now,
    );
    await documentRepository.saveDocument(document);
    return document.documentId;
  }

  /// Creates the next-stage document, locks the source and returns the new id.
  Future<String> upgradeDocument(String sourceDocumentId) async {
    final source = await documentRepository.getDocument(sourceDocumentId);
    final chainDocuments = await documentRepository.getDocumentsInChain(
      source.chainId,
    );
    final blocker = findUpgradeBlocker(
      source: source,
      chainDocuments: chainDocuments,
    );
    // Checked before allocating, so a refused upgrade burns no number.
    if (blocker != null) throw InvalidUpgradeException(blocker);
    final settings = await _readSettings();
    final now = clock();
    final documentNumber = await _allocateDocumentNumber(
      source.documentType.nextStage!,
      settings,
      now,
    );
    final result = upgradeService.createNextStage(
      source: source,
      chainDocuments: chainDocuments,
      documentNumber: documentNumber,
      settings: settings,
      now: now,
    );
    await documentRepository.saveUpgrade(
      lockedSource: result.lockedSource,
      createdDocument: result.createdDocument,
    );
    return result.createdDocument.documentId;
  }

  /// Copies a document into a new draft in a new chain and returns its id.
  Future<String> duplicateDocument(String sourceDocumentId) async {
    final source = await documentRepository.getDocument(sourceDocumentId);
    final settings = await _readSettings();
    final now = clock();
    final documentNumber = await _allocateDocumentNumber(
      source.documentType,
      settings,
      now,
    );
    final copy = documentFactory.duplicateAsDraft(
      source: source,
      documentNumber: documentNumber,
      now: now,
    );
    await documentRepository.saveDocument(copy);
    return copy.documentId;
  }

  Future<void> deleteDocument(String documentId) =>
      documentRepository.deleteDocument(documentId);

  /// The reason [source] cannot be upgraded, or `null` when it can.
  String? findUpgradeBlocker({
    required BusinessDocument source,
    required List<BusinessDocument> chainDocuments,
  }) => upgradeService.findUpgradeBlocker(
    source: source,
    chainDocuments: chainDocuments,
  );

  /// Reads a document and its chain, then returns the upgrade blocker.
  Future<String?> findUpgradeBlockerFor(String documentId) async {
    final source = await documentRepository.getDocument(documentId);
    final chainDocuments = await documentRepository.getDocumentsInChain(
      source.chainId,
    );
    return findUpgradeBlocker(source: source, chainDocuments: chainDocuments);
  }

  Future<DocumentSettings> _readSettings() =>
      settingsRepository.watchSettings().first;

  Future<String> _allocateDocumentNumber(
    DocumentType type,
    DocumentSettings settings,
    DateTime now,
  ) async {
    final rule = settings.numberingRuleByType[type]!;
    final sequence = await numberSequenceRepository.allocateNextSequence(
      type,
      year: now.year,
      resetsYearly: rule.resetsYearly,
    );
    return numberFormatter.format(rule.pattern, sequence: sequence, date: now);
  }
}

final documentCommandsProvider = Provider<DocumentCommands>(
  (ref) => DocumentCommands(
    documentRepository: ref.watch(documentRepositoryProvider),
    numberSequenceRepository: ref.watch(numberSequenceRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    documentFactory: ref.watch(documentFactoryProvider),
    upgradeService: ref.watch(documentUpgradeServiceProvider),
    clock: ref.watch(clockProvider),
  ),
);
