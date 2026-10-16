import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repository_providers.dart';
import '../../../domain/models/document_chain.dart';
import '../../../domain/models/document_summary.dart';
import '../document_commands.dart';

/// The documents of one chain, kept current as upgrades and deletions happen.
final documentChainProvider = StreamProvider.autoDispose
    .family<DocumentChain, String>(
      (ref, chainId) =>
          ref.watch(documentRepositoryProvider).watchDocumentChain(chainId),
    );

/// Identifies a document whose upgrade blocker is wanted.
typedef UpgradeBlockerKey = ({String documentId, String chainId});

/// The reason the document cannot be upgraded, or null when it can. Reads
/// again whenever the chain changes.
final upgradeBlockerProvider = FutureProvider.autoDispose
    .family<String?, UpgradeBlockerKey>((ref, key) async {
      await ref.watch(documentChainProvider(key.chainId).future);
      return ref
          .read(documentCommandsProvider)
          .findUpgradeBlockerFor(key.documentId);
    });

/// The first document of [chain] that was created from [documentId], or null
/// when nothing was.
DocumentSummary? documentCreatedFrom(DocumentChain chain, String documentId) {
  final documents = [
    ?chain.quotation,
    ?chain.salesOrder,
    ...chain.deliveryOrders,
  ];
  for (final candidate in documents) {
    if (candidate.sourceDocumentId == documentId) return candidate;
  }
  return null;
}
