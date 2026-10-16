import 'package:drift/drift.dart';

part 'pacim_database.g.dart';

@TableIndex(
  name: 'documents_type_issue_date',
  columns: {#documentType, #issueDate},
)
@TableIndex(name: 'documents_chain', columns: {#chainId})
@TableIndex(
  name: 'documents_type_number',
  columns: {#documentType, #documentNumber},
)
class DocumentRows extends Table {
  @override
  String get tableName => 'documents';

  TextColumn get documentId => text()();
  TextColumn get documentType => text()();
  TextColumn get documentNumber => text()();
  TextColumn get chainId => text()();
  TextColumn get sourceDocumentId => text().nullable()();
  TextColumn get customerName => text()();
  DateTimeColumn get issueDate => dateTime()();
  IntColumn get grandTotalMinor => integer()();
  TextColumn get currencyCode => text()();
  DateTimeColumn get lockedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get schemaVersion => integer()();
  TextColumn get searchText => text()();
  TextColumn get payloadJson => text()();

  @override
  Set<Column> get primaryKey => {documentId};
}

class NumberSequenceRows extends Table {
  @override
  String get tableName => 'number_sequences';

  TextColumn get documentType => text()();
  IntColumn get year => integer()();
  IntColumn get lastSequence => integer()();

  @override
  Set<Column> get primaryKey => {documentType, year};
}

class AssetRows extends Table {
  @override
  String get tableName => 'assets';

  TextColumn get assetId => text()();
  BlobColumn get bytes => blob()();
  TextColumn get mimeType => text()();

  @override
  Set<Column> get primaryKey => {assetId};
}

class SettingsRows extends Table {
  @override
  String get tableName => 'settings';

  IntColumn get id => integer()();
  TextColumn get payloadJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [DocumentRows, NumberSequenceRows, AssetRows, SettingsRows],
)
class PacimDatabase extends _$PacimDatabase {
  PacimDatabase(super.executor);

  PacimDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
