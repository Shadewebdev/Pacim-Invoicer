import 'package:pacim_invoicer/domain/models/business_document.dart';

/// Upgrades stored document payloads to the current schema version.
class DocumentPayloadMigrator {
  const DocumentPayloadMigrator();

  /// Version 1 is the current schema, so there are no steps yet. Add one step
  /// per version bump here.
  Map<String, dynamic> migrateToCurrent(
    Map<String, dynamic> payload,
    int fromVersion,
  ) {
    if (fromVersion > BusinessDocument.currentSchemaVersion) {
      throw FormatException(
        'Document schema version $fromVersion is newer than the supported '
        'version ${BusinessDocument.currentSchemaVersion}.',
      );
    }
    return payload;
  }
}
