// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pacim_database.dart';

// ignore_for_file: type=lint
class $DocumentRowsTable extends DocumentRows
    with TableInfo<$DocumentRowsTable, DocumentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentTypeMeta = const VerificationMeta(
    'documentType',
  );
  @override
  late final GeneratedColumn<String> documentType = GeneratedColumn<String>(
    'document_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentNumberMeta = const VerificationMeta(
    'documentNumber',
  );
  @override
  late final GeneratedColumn<String> documentNumber = GeneratedColumn<String>(
    'document_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chainIdMeta = const VerificationMeta(
    'chainId',
  );
  @override
  late final GeneratedColumn<String> chainId = GeneratedColumn<String>(
    'chain_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceDocumentIdMeta = const VerificationMeta(
    'sourceDocumentId',
  );
  @override
  late final GeneratedColumn<String> sourceDocumentId = GeneratedColumn<String>(
    'source_document_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issueDateMeta = const VerificationMeta(
    'issueDate',
  );
  @override
  late final GeneratedColumn<DateTime> issueDate = GeneratedColumn<DateTime>(
    'issue_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grandTotalMinorMeta = const VerificationMeta(
    'grandTotalMinor',
  );
  @override
  late final GeneratedColumn<int> grandTotalMinor = GeneratedColumn<int>(
    'grand_total_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lockedAtMeta = const VerificationMeta(
    'lockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lockedAt = GeneratedColumn<DateTime>(
    'locked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    documentId,
    documentType,
    documentNumber,
    chainId,
    sourceDocumentId,
    customerName,
    issueDate,
    grandTotalMinor,
    currencyCode,
    lockedAt,
    updatedAt,
    schemaVersion,
    searchText,
    payloadJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('document_type')) {
      context.handle(
        _documentTypeMeta,
        documentType.isAcceptableOrUnknown(
          data['document_type']!,
          _documentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentTypeMeta);
    }
    if (data.containsKey('document_number')) {
      context.handle(
        _documentNumberMeta,
        documentNumber.isAcceptableOrUnknown(
          data['document_number']!,
          _documentNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentNumberMeta);
    }
    if (data.containsKey('chain_id')) {
      context.handle(
        _chainIdMeta,
        chainId.isAcceptableOrUnknown(data['chain_id']!, _chainIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chainIdMeta);
    }
    if (data.containsKey('source_document_id')) {
      context.handle(
        _sourceDocumentIdMeta,
        sourceDocumentId.isAcceptableOrUnknown(
          data['source_document_id']!,
          _sourceDocumentIdMeta,
        ),
      );
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('issue_date')) {
      context.handle(
        _issueDateMeta,
        issueDate.isAcceptableOrUnknown(data['issue_date']!, _issueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_issueDateMeta);
    }
    if (data.containsKey('grand_total_minor')) {
      context.handle(
        _grandTotalMinorMeta,
        grandTotalMinor.isAcceptableOrUnknown(
          data['grand_total_minor']!,
          _grandTotalMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grandTotalMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('locked_at')) {
      context.handle(
        _lockedAtMeta,
        lockedAt.isAcceptableOrUnknown(data['locked_at']!, _lockedAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    } else if (isInserting) {
      context.missing(_searchTextMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {documentId};
  @override
  DocumentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentRow(
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      documentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_type'],
      )!,
      documentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_number'],
      )!,
      chainId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chain_id'],
      )!,
      sourceDocumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_document_id'],
      ),
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      issueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}issue_date'],
      )!,
      grandTotalMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grand_total_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      lockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locked_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
    );
  }

  @override
  $DocumentRowsTable createAlias(String alias) {
    return $DocumentRowsTable(attachedDatabase, alias);
  }
}

class DocumentRow extends DataClass implements Insertable<DocumentRow> {
  final String documentId;
  final String documentType;
  final String documentNumber;
  final String chainId;
  final String? sourceDocumentId;
  final String customerName;
  final DateTime issueDate;
  final int grandTotalMinor;
  final String currencyCode;
  final DateTime? lockedAt;
  final DateTime updatedAt;
  final int schemaVersion;
  final String searchText;
  final String payloadJson;
  const DocumentRow({
    required this.documentId,
    required this.documentType,
    required this.documentNumber,
    required this.chainId,
    this.sourceDocumentId,
    required this.customerName,
    required this.issueDate,
    required this.grandTotalMinor,
    required this.currencyCode,
    this.lockedAt,
    required this.updatedAt,
    required this.schemaVersion,
    required this.searchText,
    required this.payloadJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['document_id'] = Variable<String>(documentId);
    map['document_type'] = Variable<String>(documentType);
    map['document_number'] = Variable<String>(documentNumber);
    map['chain_id'] = Variable<String>(chainId);
    if (!nullToAbsent || sourceDocumentId != null) {
      map['source_document_id'] = Variable<String>(sourceDocumentId);
    }
    map['customer_name'] = Variable<String>(customerName);
    map['issue_date'] = Variable<DateTime>(issueDate);
    map['grand_total_minor'] = Variable<int>(grandTotalMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || lockedAt != null) {
      map['locked_at'] = Variable<DateTime>(lockedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['search_text'] = Variable<String>(searchText);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  DocumentRowsCompanion toCompanion(bool nullToAbsent) {
    return DocumentRowsCompanion(
      documentId: Value(documentId),
      documentType: Value(documentType),
      documentNumber: Value(documentNumber),
      chainId: Value(chainId),
      sourceDocumentId: sourceDocumentId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDocumentId),
      customerName: Value(customerName),
      issueDate: Value(issueDate),
      grandTotalMinor: Value(grandTotalMinor),
      currencyCode: Value(currencyCode),
      lockedAt: lockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedAt),
      updatedAt: Value(updatedAt),
      schemaVersion: Value(schemaVersion),
      searchText: Value(searchText),
      payloadJson: Value(payloadJson),
    );
  }

  factory DocumentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentRow(
      documentId: serializer.fromJson<String>(json['documentId']),
      documentType: serializer.fromJson<String>(json['documentType']),
      documentNumber: serializer.fromJson<String>(json['documentNumber']),
      chainId: serializer.fromJson<String>(json['chainId']),
      sourceDocumentId: serializer.fromJson<String?>(json['sourceDocumentId']),
      customerName: serializer.fromJson<String>(json['customerName']),
      issueDate: serializer.fromJson<DateTime>(json['issueDate']),
      grandTotalMinor: serializer.fromJson<int>(json['grandTotalMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      lockedAt: serializer.fromJson<DateTime?>(json['lockedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      searchText: serializer.fromJson<String>(json['searchText']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'documentId': serializer.toJson<String>(documentId),
      'documentType': serializer.toJson<String>(documentType),
      'documentNumber': serializer.toJson<String>(documentNumber),
      'chainId': serializer.toJson<String>(chainId),
      'sourceDocumentId': serializer.toJson<String?>(sourceDocumentId),
      'customerName': serializer.toJson<String>(customerName),
      'issueDate': serializer.toJson<DateTime>(issueDate),
      'grandTotalMinor': serializer.toJson<int>(grandTotalMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'lockedAt': serializer.toJson<DateTime?>(lockedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'searchText': serializer.toJson<String>(searchText),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  DocumentRow copyWith({
    String? documentId,
    String? documentType,
    String? documentNumber,
    String? chainId,
    Value<String?> sourceDocumentId = const Value.absent(),
    String? customerName,
    DateTime? issueDate,
    int? grandTotalMinor,
    String? currencyCode,
    Value<DateTime?> lockedAt = const Value.absent(),
    DateTime? updatedAt,
    int? schemaVersion,
    String? searchText,
    String? payloadJson,
  }) => DocumentRow(
    documentId: documentId ?? this.documentId,
    documentType: documentType ?? this.documentType,
    documentNumber: documentNumber ?? this.documentNumber,
    chainId: chainId ?? this.chainId,
    sourceDocumentId: sourceDocumentId.present
        ? sourceDocumentId.value
        : this.sourceDocumentId,
    customerName: customerName ?? this.customerName,
    issueDate: issueDate ?? this.issueDate,
    grandTotalMinor: grandTotalMinor ?? this.grandTotalMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    lockedAt: lockedAt.present ? lockedAt.value : this.lockedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    searchText: searchText ?? this.searchText,
    payloadJson: payloadJson ?? this.payloadJson,
  );
  DocumentRow copyWithCompanion(DocumentRowsCompanion data) {
    return DocumentRow(
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      documentType: data.documentType.present
          ? data.documentType.value
          : this.documentType,
      documentNumber: data.documentNumber.present
          ? data.documentNumber.value
          : this.documentNumber,
      chainId: data.chainId.present ? data.chainId.value : this.chainId,
      sourceDocumentId: data.sourceDocumentId.present
          ? data.sourceDocumentId.value
          : this.sourceDocumentId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      issueDate: data.issueDate.present ? data.issueDate.value : this.issueDate,
      grandTotalMinor: data.grandTotalMinor.present
          ? data.grandTotalMinor.value
          : this.grandTotalMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      lockedAt: data.lockedAt.present ? data.lockedAt.value : this.lockedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRow(')
          ..write('documentId: $documentId, ')
          ..write('documentType: $documentType, ')
          ..write('documentNumber: $documentNumber, ')
          ..write('chainId: $chainId, ')
          ..write('sourceDocumentId: $sourceDocumentId, ')
          ..write('customerName: $customerName, ')
          ..write('issueDate: $issueDate, ')
          ..write('grandTotalMinor: $grandTotalMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('lockedAt: $lockedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('searchText: $searchText, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    documentId,
    documentType,
    documentNumber,
    chainId,
    sourceDocumentId,
    customerName,
    issueDate,
    grandTotalMinor,
    currencyCode,
    lockedAt,
    updatedAt,
    schemaVersion,
    searchText,
    payloadJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentRow &&
          other.documentId == this.documentId &&
          other.documentType == this.documentType &&
          other.documentNumber == this.documentNumber &&
          other.chainId == this.chainId &&
          other.sourceDocumentId == this.sourceDocumentId &&
          other.customerName == this.customerName &&
          other.issueDate == this.issueDate &&
          other.grandTotalMinor == this.grandTotalMinor &&
          other.currencyCode == this.currencyCode &&
          other.lockedAt == this.lockedAt &&
          other.updatedAt == this.updatedAt &&
          other.schemaVersion == this.schemaVersion &&
          other.searchText == this.searchText &&
          other.payloadJson == this.payloadJson);
}

class DocumentRowsCompanion extends UpdateCompanion<DocumentRow> {
  final Value<String> documentId;
  final Value<String> documentType;
  final Value<String> documentNumber;
  final Value<String> chainId;
  final Value<String?> sourceDocumentId;
  final Value<String> customerName;
  final Value<DateTime> issueDate;
  final Value<int> grandTotalMinor;
  final Value<String> currencyCode;
  final Value<DateTime?> lockedAt;
  final Value<DateTime> updatedAt;
  final Value<int> schemaVersion;
  final Value<String> searchText;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const DocumentRowsCompanion({
    this.documentId = const Value.absent(),
    this.documentType = const Value.absent(),
    this.documentNumber = const Value.absent(),
    this.chainId = const Value.absent(),
    this.sourceDocumentId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.issueDate = const Value.absent(),
    this.grandTotalMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.lockedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.searchText = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentRowsCompanion.insert({
    required String documentId,
    required String documentType,
    required String documentNumber,
    required String chainId,
    this.sourceDocumentId = const Value.absent(),
    required String customerName,
    required DateTime issueDate,
    required int grandTotalMinor,
    required String currencyCode,
    this.lockedAt = const Value.absent(),
    required DateTime updatedAt,
    required int schemaVersion,
    required String searchText,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : documentId = Value(documentId),
       documentType = Value(documentType),
       documentNumber = Value(documentNumber),
       chainId = Value(chainId),
       customerName = Value(customerName),
       issueDate = Value(issueDate),
       grandTotalMinor = Value(grandTotalMinor),
       currencyCode = Value(currencyCode),
       updatedAt = Value(updatedAt),
       schemaVersion = Value(schemaVersion),
       searchText = Value(searchText),
       payloadJson = Value(payloadJson);
  static Insertable<DocumentRow> custom({
    Expression<String>? documentId,
    Expression<String>? documentType,
    Expression<String>? documentNumber,
    Expression<String>? chainId,
    Expression<String>? sourceDocumentId,
    Expression<String>? customerName,
    Expression<DateTime>? issueDate,
    Expression<int>? grandTotalMinor,
    Expression<String>? currencyCode,
    Expression<DateTime>? lockedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? schemaVersion,
    Expression<String>? searchText,
    Expression<String>? payloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (documentId != null) 'document_id': documentId,
      if (documentType != null) 'document_type': documentType,
      if (documentNumber != null) 'document_number': documentNumber,
      if (chainId != null) 'chain_id': chainId,
      if (sourceDocumentId != null) 'source_document_id': sourceDocumentId,
      if (customerName != null) 'customer_name': customerName,
      if (issueDate != null) 'issue_date': issueDate,
      if (grandTotalMinor != null) 'grand_total_minor': grandTotalMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (lockedAt != null) 'locked_at': lockedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (searchText != null) 'search_text': searchText,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentRowsCompanion copyWith({
    Value<String>? documentId,
    Value<String>? documentType,
    Value<String>? documentNumber,
    Value<String>? chainId,
    Value<String?>? sourceDocumentId,
    Value<String>? customerName,
    Value<DateTime>? issueDate,
    Value<int>? grandTotalMinor,
    Value<String>? currencyCode,
    Value<DateTime?>? lockedAt,
    Value<DateTime>? updatedAt,
    Value<int>? schemaVersion,
    Value<String>? searchText,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return DocumentRowsCompanion(
      documentId: documentId ?? this.documentId,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      chainId: chainId ?? this.chainId,
      sourceDocumentId: sourceDocumentId ?? this.sourceDocumentId,
      customerName: customerName ?? this.customerName,
      issueDate: issueDate ?? this.issueDate,
      grandTotalMinor: grandTotalMinor ?? this.grandTotalMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      lockedAt: lockedAt ?? this.lockedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      searchText: searchText ?? this.searchText,
      payloadJson: payloadJson ?? this.payloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (documentType.present) {
      map['document_type'] = Variable<String>(documentType.value);
    }
    if (documentNumber.present) {
      map['document_number'] = Variable<String>(documentNumber.value);
    }
    if (chainId.present) {
      map['chain_id'] = Variable<String>(chainId.value);
    }
    if (sourceDocumentId.present) {
      map['source_document_id'] = Variable<String>(sourceDocumentId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (issueDate.present) {
      map['issue_date'] = Variable<DateTime>(issueDate.value);
    }
    if (grandTotalMinor.present) {
      map['grand_total_minor'] = Variable<int>(grandTotalMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (lockedAt.present) {
      map['locked_at'] = Variable<DateTime>(lockedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRowsCompanion(')
          ..write('documentId: $documentId, ')
          ..write('documentType: $documentType, ')
          ..write('documentNumber: $documentNumber, ')
          ..write('chainId: $chainId, ')
          ..write('sourceDocumentId: $sourceDocumentId, ')
          ..write('customerName: $customerName, ')
          ..write('issueDate: $issueDate, ')
          ..write('grandTotalMinor: $grandTotalMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('lockedAt: $lockedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('searchText: $searchText, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NumberSequenceRowsTable extends NumberSequenceRows
    with TableInfo<$NumberSequenceRowsTable, NumberSequenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NumberSequenceRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _documentTypeMeta = const VerificationMeta(
    'documentType',
  );
  @override
  late final GeneratedColumn<String> documentType = GeneratedColumn<String>(
    'document_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSequenceMeta = const VerificationMeta(
    'lastSequence',
  );
  @override
  late final GeneratedColumn<int> lastSequence = GeneratedColumn<int>(
    'last_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [documentType, year, lastSequence];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'number_sequences';
  @override
  VerificationContext validateIntegrity(
    Insertable<NumberSequenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('document_type')) {
      context.handle(
        _documentTypeMeta,
        documentType.isAcceptableOrUnknown(
          data['document_type']!,
          _documentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentTypeMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('last_sequence')) {
      context.handle(
        _lastSequenceMeta,
        lastSequence.isAcceptableOrUnknown(
          data['last_sequence']!,
          _lastSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSequenceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {documentType, year};
  @override
  NumberSequenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NumberSequenceRow(
      documentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_type'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      lastSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sequence'],
      )!,
    );
  }

  @override
  $NumberSequenceRowsTable createAlias(String alias) {
    return $NumberSequenceRowsTable(attachedDatabase, alias);
  }
}

class NumberSequenceRow extends DataClass
    implements Insertable<NumberSequenceRow> {
  final String documentType;
  final int year;
  final int lastSequence;
  const NumberSequenceRow({
    required this.documentType,
    required this.year,
    required this.lastSequence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['document_type'] = Variable<String>(documentType);
    map['year'] = Variable<int>(year);
    map['last_sequence'] = Variable<int>(lastSequence);
    return map;
  }

  NumberSequenceRowsCompanion toCompanion(bool nullToAbsent) {
    return NumberSequenceRowsCompanion(
      documentType: Value(documentType),
      year: Value(year),
      lastSequence: Value(lastSequence),
    );
  }

  factory NumberSequenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NumberSequenceRow(
      documentType: serializer.fromJson<String>(json['documentType']),
      year: serializer.fromJson<int>(json['year']),
      lastSequence: serializer.fromJson<int>(json['lastSequence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'documentType': serializer.toJson<String>(documentType),
      'year': serializer.toJson<int>(year),
      'lastSequence': serializer.toJson<int>(lastSequence),
    };
  }

  NumberSequenceRow copyWith({
    String? documentType,
    int? year,
    int? lastSequence,
  }) => NumberSequenceRow(
    documentType: documentType ?? this.documentType,
    year: year ?? this.year,
    lastSequence: lastSequence ?? this.lastSequence,
  );
  NumberSequenceRow copyWithCompanion(NumberSequenceRowsCompanion data) {
    return NumberSequenceRow(
      documentType: data.documentType.present
          ? data.documentType.value
          : this.documentType,
      year: data.year.present ? data.year.value : this.year,
      lastSequence: data.lastSequence.present
          ? data.lastSequence.value
          : this.lastSequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NumberSequenceRow(')
          ..write('documentType: $documentType, ')
          ..write('year: $year, ')
          ..write('lastSequence: $lastSequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(documentType, year, lastSequence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NumberSequenceRow &&
          other.documentType == this.documentType &&
          other.year == this.year &&
          other.lastSequence == this.lastSequence);
}

class NumberSequenceRowsCompanion extends UpdateCompanion<NumberSequenceRow> {
  final Value<String> documentType;
  final Value<int> year;
  final Value<int> lastSequence;
  final Value<int> rowid;
  const NumberSequenceRowsCompanion({
    this.documentType = const Value.absent(),
    this.year = const Value.absent(),
    this.lastSequence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NumberSequenceRowsCompanion.insert({
    required String documentType,
    required int year,
    required int lastSequence,
    this.rowid = const Value.absent(),
  }) : documentType = Value(documentType),
       year = Value(year),
       lastSequence = Value(lastSequence);
  static Insertable<NumberSequenceRow> custom({
    Expression<String>? documentType,
    Expression<int>? year,
    Expression<int>? lastSequence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (documentType != null) 'document_type': documentType,
      if (year != null) 'year': year,
      if (lastSequence != null) 'last_sequence': lastSequence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NumberSequenceRowsCompanion copyWith({
    Value<String>? documentType,
    Value<int>? year,
    Value<int>? lastSequence,
    Value<int>? rowid,
  }) {
    return NumberSequenceRowsCompanion(
      documentType: documentType ?? this.documentType,
      year: year ?? this.year,
      lastSequence: lastSequence ?? this.lastSequence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (documentType.present) {
      map['document_type'] = Variable<String>(documentType.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (lastSequence.present) {
      map['last_sequence'] = Variable<int>(lastSequence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NumberSequenceRowsCompanion(')
          ..write('documentType: $documentType, ')
          ..write('year: $year, ')
          ..write('lastSequence: $lastSequence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetRowsTable extends AssetRows
    with TableInfo<$AssetRowsTable, AssetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [assetId, bytes, mimeType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assetId};
  @override
  AssetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetRow(
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bytes'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
    );
  }

  @override
  $AssetRowsTable createAlias(String alias) {
    return $AssetRowsTable(attachedDatabase, alias);
  }
}

class AssetRow extends DataClass implements Insertable<AssetRow> {
  final String assetId;
  final Uint8List bytes;
  final String mimeType;
  const AssetRow({
    required this.assetId,
    required this.bytes,
    required this.mimeType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset_id'] = Variable<String>(assetId);
    map['bytes'] = Variable<Uint8List>(bytes);
    map['mime_type'] = Variable<String>(mimeType);
    return map;
  }

  AssetRowsCompanion toCompanion(bool nullToAbsent) {
    return AssetRowsCompanion(
      assetId: Value(assetId),
      bytes: Value(bytes),
      mimeType: Value(mimeType),
    );
  }

  factory AssetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetRow(
      assetId: serializer.fromJson<String>(json['assetId']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assetId': serializer.toJson<String>(assetId),
      'bytes': serializer.toJson<Uint8List>(bytes),
      'mimeType': serializer.toJson<String>(mimeType),
    };
  }

  AssetRow copyWith({String? assetId, Uint8List? bytes, String? mimeType}) =>
      AssetRow(
        assetId: assetId ?? this.assetId,
        bytes: bytes ?? this.bytes,
        mimeType: mimeType ?? this.mimeType,
      );
  AssetRow copyWithCompanion(AssetRowsCompanion data) {
    return AssetRow(
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetRow(')
          ..write('assetId: $assetId, ')
          ..write('bytes: $bytes, ')
          ..write('mimeType: $mimeType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(assetId, $driftBlobEquality.hash(bytes), mimeType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetRow &&
          other.assetId == this.assetId &&
          $driftBlobEquality.equals(other.bytes, this.bytes) &&
          other.mimeType == this.mimeType);
}

class AssetRowsCompanion extends UpdateCompanion<AssetRow> {
  final Value<String> assetId;
  final Value<Uint8List> bytes;
  final Value<String> mimeType;
  final Value<int> rowid;
  const AssetRowsCompanion({
    this.assetId = const Value.absent(),
    this.bytes = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetRowsCompanion.insert({
    required String assetId,
    required Uint8List bytes,
    required String mimeType,
    this.rowid = const Value.absent(),
  }) : assetId = Value(assetId),
       bytes = Value(bytes),
       mimeType = Value(mimeType);
  static Insertable<AssetRow> custom({
    Expression<String>? assetId,
    Expression<Uint8List>? bytes,
    Expression<String>? mimeType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assetId != null) 'asset_id': assetId,
      if (bytes != null) 'bytes': bytes,
      if (mimeType != null) 'mime_type': mimeType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetRowsCompanion copyWith({
    Value<String>? assetId,
    Value<Uint8List>? bytes,
    Value<String>? mimeType,
    Value<int>? rowid,
  }) {
    return AssetRowsCompanion(
      assetId: assetId ?? this.assetId,
      bytes: bytes ?? this.bytes,
      mimeType: mimeType ?? this.mimeType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetRowsCompanion(')
          ..write('assetId: $assetId, ')
          ..write('bytes: $bytes, ')
          ..write('mimeType: $mimeType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsRowsTable extends SettingsRows
    with TableInfo<$SettingsRowsTable, SettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payloadJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
    );
  }

  @override
  $SettingsRowsTable createAlias(String alias) {
    return $SettingsRowsTable(attachedDatabase, alias);
  }
}

class SettingsRow extends DataClass implements Insertable<SettingsRow> {
  final int id;
  final String payloadJson;
  const SettingsRow({required this.id, required this.payloadJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  SettingsRowsCompanion toCompanion(bool nullToAbsent) {
    return SettingsRowsCompanion(
      id: Value(id),
      payloadJson: Value(payloadJson),
    );
  }

  factory SettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsRow(
      id: serializer.fromJson<int>(json['id']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  SettingsRow copyWith({int? id, String? payloadJson}) => SettingsRow(
    id: id ?? this.id,
    payloadJson: payloadJson ?? this.payloadJson,
  );
  SettingsRow copyWithCompanion(SettingsRowsCompanion data) {
    return SettingsRow(
      id: data.id.present ? data.id.value : this.id,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRow(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsRow &&
          other.id == this.id &&
          other.payloadJson == this.payloadJson);
}

class SettingsRowsCompanion extends UpdateCompanion<SettingsRow> {
  final Value<int> id;
  final Value<String> payloadJson;
  const SettingsRowsCompanion({
    this.id = const Value.absent(),
    this.payloadJson = const Value.absent(),
  });
  SettingsRowsCompanion.insert({
    this.id = const Value.absent(),
    required String payloadJson,
  }) : payloadJson = Value(payloadJson);
  static Insertable<SettingsRow> custom({
    Expression<int>? id,
    Expression<String>? payloadJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payloadJson != null) 'payload_json': payloadJson,
    });
  }

  SettingsRowsCompanion copyWith({Value<int>? id, Value<String>? payloadJson}) {
    return SettingsRowsCompanion(
      id: id ?? this.id,
      payloadJson: payloadJson ?? this.payloadJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRowsCompanion(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }
}

abstract class _$PacimDatabase extends GeneratedDatabase {
  _$PacimDatabase(QueryExecutor e) : super(e);
  $PacimDatabaseManager get managers => $PacimDatabaseManager(this);
  late final $DocumentRowsTable documentRows = $DocumentRowsTable(this);
  late final $NumberSequenceRowsTable numberSequenceRows =
      $NumberSequenceRowsTable(this);
  late final $AssetRowsTable assetRows = $AssetRowsTable(this);
  late final $SettingsRowsTable settingsRows = $SettingsRowsTable(this);
  late final Index documentsTypeIssueDate = Index(
    'documents_type_issue_date',
    'CREATE INDEX documents_type_issue_date ON documents (document_type, issue_date)',
  );
  late final Index documentsChain = Index(
    'documents_chain',
    'CREATE INDEX documents_chain ON documents (chain_id)',
  );
  late final Index documentsTypeNumber = Index(
    'documents_type_number',
    'CREATE INDEX documents_type_number ON documents (document_type, document_number)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    documentRows,
    numberSequenceRows,
    assetRows,
    settingsRows,
    documentsTypeIssueDate,
    documentsChain,
    documentsTypeNumber,
  ];
}

typedef $$DocumentRowsTableCreateCompanionBuilder =
    DocumentRowsCompanion Function({
      required String documentId,
      required String documentType,
      required String documentNumber,
      required String chainId,
      Value<String?> sourceDocumentId,
      required String customerName,
      required DateTime issueDate,
      required int grandTotalMinor,
      required String currencyCode,
      Value<DateTime?> lockedAt,
      required DateTime updatedAt,
      required int schemaVersion,
      required String searchText,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$DocumentRowsTableUpdateCompanionBuilder =
    DocumentRowsCompanion Function({
      Value<String> documentId,
      Value<String> documentType,
      Value<String> documentNumber,
      Value<String> chainId,
      Value<String?> sourceDocumentId,
      Value<String> customerName,
      Value<DateTime> issueDate,
      Value<int> grandTotalMinor,
      Value<String> currencyCode,
      Value<DateTime?> lockedAt,
      Value<DateTime> updatedAt,
      Value<int> schemaVersion,
      Value<String> searchText,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$DocumentRowsTableFilterComposer
    extends Composer<_$PacimDatabase, $DocumentRowsTable> {
  $$DocumentRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentNumber => $composableBuilder(
    column: $table.documentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chainId => $composableBuilder(
    column: $table.chainId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDocumentId => $composableBuilder(
    column: $table.sourceDocumentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grandTotalMinor => $composableBuilder(
    column: $table.grandTotalMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lockedAt => $composableBuilder(
    column: $table.lockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DocumentRowsTableOrderingComposer
    extends Composer<_$PacimDatabase, $DocumentRowsTable> {
  $$DocumentRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentNumber => $composableBuilder(
    column: $table.documentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chainId => $composableBuilder(
    column: $table.chainId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDocumentId => $composableBuilder(
    column: $table.sourceDocumentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grandTotalMinor => $composableBuilder(
    column: $table.grandTotalMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lockedAt => $composableBuilder(
    column: $table.lockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentRowsTableAnnotationComposer
    extends Composer<_$PacimDatabase, $DocumentRowsTable> {
  $$DocumentRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documentNumber => $composableBuilder(
    column: $table.documentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chainId =>
      $composableBuilder(column: $table.chainId, builder: (column) => column);

  GeneratedColumn<String> get sourceDocumentId => $composableBuilder(
    column: $table.sourceDocumentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get issueDate =>
      $composableBuilder(column: $table.issueDate, builder: (column) => column);

  GeneratedColumn<int> get grandTotalMinor => $composableBuilder(
    column: $table.grandTotalMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lockedAt =>
      $composableBuilder(column: $table.lockedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );
}

class $$DocumentRowsTableTableManager
    extends
        RootTableManager<
          _$PacimDatabase,
          $DocumentRowsTable,
          DocumentRow,
          $$DocumentRowsTableFilterComposer,
          $$DocumentRowsTableOrderingComposer,
          $$DocumentRowsTableAnnotationComposer,
          $$DocumentRowsTableCreateCompanionBuilder,
          $$DocumentRowsTableUpdateCompanionBuilder,
          (
            DocumentRow,
            BaseReferences<_$PacimDatabase, $DocumentRowsTable, DocumentRow>,
          ),
          DocumentRow,
          PrefetchHooks Function()
        > {
  $$DocumentRowsTableTableManager(_$PacimDatabase db, $DocumentRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> documentId = const Value.absent(),
                Value<String> documentType = const Value.absent(),
                Value<String> documentNumber = const Value.absent(),
                Value<String> chainId = const Value.absent(),
                Value<String?> sourceDocumentId = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<DateTime> issueDate = const Value.absent(),
                Value<int> grandTotalMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime?> lockedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentRowsCompanion(
                documentId: documentId,
                documentType: documentType,
                documentNumber: documentNumber,
                chainId: chainId,
                sourceDocumentId: sourceDocumentId,
                customerName: customerName,
                issueDate: issueDate,
                grandTotalMinor: grandTotalMinor,
                currencyCode: currencyCode,
                lockedAt: lockedAt,
                updatedAt: updatedAt,
                schemaVersion: schemaVersion,
                searchText: searchText,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String documentId,
                required String documentType,
                required String documentNumber,
                required String chainId,
                Value<String?> sourceDocumentId = const Value.absent(),
                required String customerName,
                required DateTime issueDate,
                required int grandTotalMinor,
                required String currencyCode,
                Value<DateTime?> lockedAt = const Value.absent(),
                required DateTime updatedAt,
                required int schemaVersion,
                required String searchText,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => DocumentRowsCompanion.insert(
                documentId: documentId,
                documentType: documentType,
                documentNumber: documentNumber,
                chainId: chainId,
                sourceDocumentId: sourceDocumentId,
                customerName: customerName,
                issueDate: issueDate,
                grandTotalMinor: grandTotalMinor,
                currencyCode: currencyCode,
                lockedAt: lockedAt,
                updatedAt: updatedAt,
                schemaVersion: schemaVersion,
                searchText: searchText,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentRowsTable, DocumentRow>(table),
                  BaseReferences<
                    _$PacimDatabase,
                    $DocumentRowsTable,
                    DocumentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DocumentRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$PacimDatabase,
      $DocumentRowsTable,
      DocumentRow,
      $$DocumentRowsTableFilterComposer,
      $$DocumentRowsTableOrderingComposer,
      $$DocumentRowsTableAnnotationComposer,
      $$DocumentRowsTableCreateCompanionBuilder,
      $$DocumentRowsTableUpdateCompanionBuilder,
      (
        DocumentRow,
        BaseReferences<_$PacimDatabase, $DocumentRowsTable, DocumentRow>,
      ),
      DocumentRow,
      PrefetchHooks Function()
    >;
typedef $$NumberSequenceRowsTableCreateCompanionBuilder =
    NumberSequenceRowsCompanion Function({
      required String documentType,
      required int year,
      required int lastSequence,
      Value<int> rowid,
    });
typedef $$NumberSequenceRowsTableUpdateCompanionBuilder =
    NumberSequenceRowsCompanion Function({
      Value<String> documentType,
      Value<int> year,
      Value<int> lastSequence,
      Value<int> rowid,
    });

class $$NumberSequenceRowsTableFilterComposer
    extends Composer<_$PacimDatabase, $NumberSequenceRowsTable> {
  $$NumberSequenceRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSequence => $composableBuilder(
    column: $table.lastSequence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NumberSequenceRowsTableOrderingComposer
    extends Composer<_$PacimDatabase, $NumberSequenceRowsTable> {
  $$NumberSequenceRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSequence => $composableBuilder(
    column: $table.lastSequence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NumberSequenceRowsTableAnnotationComposer
    extends Composer<_$PacimDatabase, $NumberSequenceRowsTable> {
  $$NumberSequenceRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get lastSequence => $composableBuilder(
    column: $table.lastSequence,
    builder: (column) => column,
  );
}

class $$NumberSequenceRowsTableTableManager
    extends
        RootTableManager<
          _$PacimDatabase,
          $NumberSequenceRowsTable,
          NumberSequenceRow,
          $$NumberSequenceRowsTableFilterComposer,
          $$NumberSequenceRowsTableOrderingComposer,
          $$NumberSequenceRowsTableAnnotationComposer,
          $$NumberSequenceRowsTableCreateCompanionBuilder,
          $$NumberSequenceRowsTableUpdateCompanionBuilder,
          (
            NumberSequenceRow,
            BaseReferences<
              _$PacimDatabase,
              $NumberSequenceRowsTable,
              NumberSequenceRow
            >,
          ),
          NumberSequenceRow,
          PrefetchHooks Function()
        > {
  $$NumberSequenceRowsTableTableManager(
    _$PacimDatabase db,
    $NumberSequenceRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NumberSequenceRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NumberSequenceRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NumberSequenceRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> documentType = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> lastSequence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NumberSequenceRowsCompanion(
                documentType: documentType,
                year: year,
                lastSequence: lastSequence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String documentType,
                required int year,
                required int lastSequence,
                Value<int> rowid = const Value.absent(),
              }) => NumberSequenceRowsCompanion.insert(
                documentType: documentType,
                year: year,
                lastSequence: lastSequence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NumberSequenceRowsTable, NumberSequenceRow>(
                    table,
                  ),
                  BaseReferences<
                    _$PacimDatabase,
                    $NumberSequenceRowsTable,
                    NumberSequenceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NumberSequenceRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$PacimDatabase,
      $NumberSequenceRowsTable,
      NumberSequenceRow,
      $$NumberSequenceRowsTableFilterComposer,
      $$NumberSequenceRowsTableOrderingComposer,
      $$NumberSequenceRowsTableAnnotationComposer,
      $$NumberSequenceRowsTableCreateCompanionBuilder,
      $$NumberSequenceRowsTableUpdateCompanionBuilder,
      (
        NumberSequenceRow,
        BaseReferences<
          _$PacimDatabase,
          $NumberSequenceRowsTable,
          NumberSequenceRow
        >,
      ),
      NumberSequenceRow,
      PrefetchHooks Function()
    >;
typedef $$AssetRowsTableCreateCompanionBuilder = AssetRowsCompanion Function({
  required String assetId,
  required Uint8List bytes,
  required String mimeType,
  Value<int> rowid,
});
typedef $$AssetRowsTableUpdateCompanionBuilder = AssetRowsCompanion Function({
  Value<String> assetId,
  Value<Uint8List> bytes,
  Value<String> mimeType,
  Value<int> rowid,
});

class $$AssetRowsTableFilterComposer
    extends Composer<_$PacimDatabase, $AssetRowsTable> {
  $$AssetRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssetRowsTableOrderingComposer
    extends Composer<_$PacimDatabase, $AssetRowsTable> {
  $$AssetRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetRowsTableAnnotationComposer
    extends Composer<_$PacimDatabase, $AssetRowsTable> {
  $$AssetRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);
}

class $$AssetRowsTableTableManager
    extends
        RootTableManager<
          _$PacimDatabase,
          $AssetRowsTable,
          AssetRow,
          $$AssetRowsTableFilterComposer,
          $$AssetRowsTableOrderingComposer,
          $$AssetRowsTableAnnotationComposer,
          $$AssetRowsTableCreateCompanionBuilder,
          $$AssetRowsTableUpdateCompanionBuilder,
          (
            AssetRow,
            BaseReferences<_$PacimDatabase, $AssetRowsTable, AssetRow>,
          ),
          AssetRow,
          PrefetchHooks Function()
        > {
  $$AssetRowsTableTableManager(_$PacimDatabase db, $AssetRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> assetId = const Value.absent(),
                Value<Uint8List> bytes = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetRowsCompanion(
                assetId: assetId,
                bytes: bytes,
                mimeType: mimeType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String assetId,
                required Uint8List bytes,
                required String mimeType,
                Value<int> rowid = const Value.absent(),
              }) => AssetRowsCompanion.insert(
                assetId: assetId,
                bytes: bytes,
                mimeType: mimeType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssetRowsTable, AssetRow>(table),
                  BaseReferences<_$PacimDatabase, $AssetRowsTable, AssetRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssetRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$PacimDatabase,
      $AssetRowsTable,
      AssetRow,
      $$AssetRowsTableFilterComposer,
      $$AssetRowsTableOrderingComposer,
      $$AssetRowsTableAnnotationComposer,
      $$AssetRowsTableCreateCompanionBuilder,
      $$AssetRowsTableUpdateCompanionBuilder,
      (AssetRow, BaseReferences<_$PacimDatabase, $AssetRowsTable, AssetRow>),
      AssetRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsRowsTableCreateCompanionBuilder =
    SettingsRowsCompanion Function({
      Value<int> id,
      required String payloadJson,
    });
typedef $$SettingsRowsTableUpdateCompanionBuilder =
    SettingsRowsCompanion Function({Value<int> id, Value<String> payloadJson});

class $$SettingsRowsTableFilterComposer
    extends Composer<_$PacimDatabase, $SettingsRowsTable> {
  $$SettingsRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsRowsTableOrderingComposer
    extends Composer<_$PacimDatabase, $SettingsRowsTable> {
  $$SettingsRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsRowsTableAnnotationComposer
    extends Composer<_$PacimDatabase, $SettingsRowsTable> {
  $$SettingsRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );
}

class $$SettingsRowsTableTableManager
    extends
        RootTableManager<
          _$PacimDatabase,
          $SettingsRowsTable,
          SettingsRow,
          $$SettingsRowsTableFilterComposer,
          $$SettingsRowsTableOrderingComposer,
          $$SettingsRowsTableAnnotationComposer,
          $$SettingsRowsTableCreateCompanionBuilder,
          $$SettingsRowsTableUpdateCompanionBuilder,
          (
            SettingsRow,
            BaseReferences<_$PacimDatabase, $SettingsRowsTable, SettingsRow>,
          ),
          SettingsRow,
          PrefetchHooks Function()
        > {
  $$SettingsRowsTableTableManager(_$PacimDatabase db, $SettingsRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
          }) => SettingsRowsCompanion(id: id, payloadJson: payloadJson),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String payloadJson,
          }) => SettingsRowsCompanion.insert(id: id, payloadJson: payloadJson),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsRowsTable, SettingsRow>(table),
                  BaseReferences<
                    _$PacimDatabase,
                    $SettingsRowsTable,
                    SettingsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$PacimDatabase,
      $SettingsRowsTable,
      SettingsRow,
      $$SettingsRowsTableFilterComposer,
      $$SettingsRowsTableOrderingComposer,
      $$SettingsRowsTableAnnotationComposer,
      $$SettingsRowsTableCreateCompanionBuilder,
      $$SettingsRowsTableUpdateCompanionBuilder,
      (
        SettingsRow,
        BaseReferences<_$PacimDatabase, $SettingsRowsTable, SettingsRow>,
      ),
      SettingsRow,
      PrefetchHooks Function()
    >;

class $PacimDatabaseManager {
  final _$PacimDatabase _db;
  $PacimDatabaseManager(this._db);
  $$DocumentRowsTableTableManager get documentRows =>
      $$DocumentRowsTableTableManager(_db, _db.documentRows);
  $$NumberSequenceRowsTableTableManager get numberSequenceRows =>
      $$NumberSequenceRowsTableTableManager(_db, _db.numberSequenceRows);
  $$AssetRowsTableTableManager get assetRows =>
      $$AssetRowsTableTableManager(_db, _db.assetRows);
  $$SettingsRowsTableTableManager get settingsRows =>
      $$SettingsRowsTableTableManager(_db, _db.settingsRows);
}
