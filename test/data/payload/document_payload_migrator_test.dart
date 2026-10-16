import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/data/payload/document_payload_migrator.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';

void main() {
  const migrator = DocumentPayloadMigrator();

  test('v1 payload is unchanged', () {
    final payload = <String, dynamic>{'documentId': 'a', 'notes': 'x'};
    expect(migrator.migrateToCurrent(payload, 1), payload);
  });

  test('future version throws FormatException', () {
    expect(
      () => migrator.migrateToCurrent(
        <String, dynamic>{},
        BusinessDocument.currentSchemaVersion + 1,
      ),
      throwsFormatException,
    );
  });
}
