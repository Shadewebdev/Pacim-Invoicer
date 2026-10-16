import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/document_settings.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';

import '../../support/document_builders.dart';

void main() {
  test('BusinessDocument survives a JSON round trip', () {
    final document = buildTestDocument(
      lockedAt: DateTime.utc(2026, 10, 18),
      sourceDocumentId: 'doc-0',
    );

    final decoded = BusinessDocument.fromJson(
      jsonDecode(jsonEncode(document.toJson())) as Map<String, dynamic>,
    );

    expect(decoded, document);
    expect(decoded.isLocked, isTrue);
  });

  test('DocumentSettings.initial uses spec numbering patterns', () {
    final settings = DocumentSettings.initial();

    expect(
      settings.numberingRuleByType[DocumentType.quotation]!.pattern,
      'QT-{yyyy}-{seq:4}',
    );
    expect(
      settings.numberingRuleByType[DocumentType.salesOrder]!.pattern,
      'SO-{yyyy}-{seq:4}',
    );
    expect(
      settings.numberingRuleByType[DocumentType.deliveryOrder]!.pattern,
      'DO-{yyyy}-{seq:4}',
    );
  });

  test('DocumentType map keys serialize as enum names', () {
    final settings = DocumentSettings.initial();

    expect(jsonEncode(settings.toJson()), contains('"salesOrder"'));
    expect(
      DocumentSettings.fromJson(
        jsonDecode(jsonEncode(settings.toJson())) as Map<String, dynamic>,
      ),
      settings,
    );
  });
}
