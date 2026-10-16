class DocumentNotFoundException implements Exception {
  const DocumentNotFoundException(this.documentId);

  final String documentId;

  @override
  String toString() => 'DocumentNotFoundException: no document $documentId';
}

class DocumentLockedException implements Exception {
  const DocumentLockedException(this.documentId);

  final String documentId;

  @override
  String toString() =>
      'DocumentLockedException: document $documentId is locked';
}

class InvalidUpgradeException implements Exception {
  const InvalidUpgradeException(this.reason);

  final String reason;

  @override
  String toString() => 'InvalidUpgradeException: $reason';
}

class StorageWriteException implements Exception {
  const StorageWriteException(this.cause);

  final Object cause;

  @override
  String toString() => 'StorageWriteException: $cause';
}
