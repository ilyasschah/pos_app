// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SecurityKeysTableTable extends SecurityKeysTable
    with TableInfo<$SecurityKeysTableTable, SecurityKeysTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SecurityKeysTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [companyId, name, level];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'security_keys';
  @override
  VerificationContext validateIntegrity(
    Insertable<SecurityKeysTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {companyId, name};
  @override
  SecurityKeysTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SecurityKeysTableData(
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
    );
  }

  @override
  $SecurityKeysTableTable createAlias(String alias) {
    return $SecurityKeysTableTable(attachedDatabase, alias);
  }
}

class SecurityKeysTableData extends DataClass
    implements Insertable<SecurityKeysTableData> {
  final int companyId;
  final String name;
  final int level;
  const SecurityKeysTableData({
    required this.companyId,
    required this.name,
    required this.level,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['company_id'] = Variable<int>(companyId);
    map['name'] = Variable<String>(name);
    map['level'] = Variable<int>(level);
    return map;
  }

  SecurityKeysTableCompanion toCompanion(bool nullToAbsent) {
    return SecurityKeysTableCompanion(
      companyId: Value(companyId),
      name: Value(name),
      level: Value(level),
    );
  }

  factory SecurityKeysTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SecurityKeysTableData(
      companyId: serializer.fromJson<int>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      level: serializer.fromJson<int>(json['level']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'companyId': serializer.toJson<int>(companyId),
      'name': serializer.toJson<String>(name),
      'level': serializer.toJson<int>(level),
    };
  }

  SecurityKeysTableData copyWith({int? companyId, String? name, int? level}) =>
      SecurityKeysTableData(
        companyId: companyId ?? this.companyId,
        name: name ?? this.name,
        level: level ?? this.level,
      );
  SecurityKeysTableData copyWithCompanion(SecurityKeysTableCompanion data) {
    return SecurityKeysTableData(
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      level: data.level.present ? data.level.value : this.level,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SecurityKeysTableData(')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('level: $level')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(companyId, name, level);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SecurityKeysTableData &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.level == this.level);
}

class SecurityKeysTableCompanion
    extends UpdateCompanion<SecurityKeysTableData> {
  final Value<int> companyId;
  final Value<String> name;
  final Value<int> level;
  final Value<int> rowid;
  const SecurityKeysTableCompanion({
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.level = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SecurityKeysTableCompanion.insert({
    required int companyId,
    required String name,
    this.level = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : companyId = Value(companyId),
       name = Value(name);
  static Insertable<SecurityKeysTableData> custom({
    Expression<int>? companyId,
    Expression<String>? name,
    Expression<int>? level,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (level != null) 'level': level,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SecurityKeysTableCompanion copyWith({
    Value<int>? companyId,
    Value<String>? name,
    Value<int>? level,
    Value<int>? rowid,
  }) {
    return SecurityKeysTableCompanion(
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      level: level ?? this.level,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SecurityKeysTableCompanion(')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('level: $level, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingUserOpsTableTable extends PendingUserOpsTable
    with TableInfo<$PendingUserOpsTableTable, PendingUserOpsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingUserOpsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, operation, companyId, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_user_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingUserOpsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingUserOpsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingUserOpsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $PendingUserOpsTableTable createAlias(String alias) {
    return $PendingUserOpsTableTable(attachedDatabase, alias);
  }
}

class PendingUserOpsTableData extends DataClass
    implements Insertable<PendingUserOpsTableData> {
  final int id;
  final String operation;
  final int companyId;
  final String payload;
  const PendingUserOpsTableData({
    required this.id,
    required this.operation,
    required this.companyId,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation'] = Variable<String>(operation);
    map['company_id'] = Variable<int>(companyId);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  PendingUserOpsTableCompanion toCompanion(bool nullToAbsent) {
    return PendingUserOpsTableCompanion(
      id: Value(id),
      operation: Value(operation),
      companyId: Value(companyId),
      payload: Value(payload),
    );
  }

  factory PendingUserOpsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingUserOpsTableData(
      id: serializer.fromJson<int>(json['id']),
      operation: serializer.fromJson<String>(json['operation']),
      companyId: serializer.fromJson<int>(json['companyId']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operation': serializer.toJson<String>(operation),
      'companyId': serializer.toJson<int>(companyId),
      'payload': serializer.toJson<String>(payload),
    };
  }

  PendingUserOpsTableData copyWith({
    int? id,
    String? operation,
    int? companyId,
    String? payload,
  }) => PendingUserOpsTableData(
    id: id ?? this.id,
    operation: operation ?? this.operation,
    companyId: companyId ?? this.companyId,
    payload: payload ?? this.payload,
  );
  PendingUserOpsTableData copyWithCompanion(PendingUserOpsTableCompanion data) {
    return PendingUserOpsTableData(
      id: data.id.present ? data.id.value : this.id,
      operation: data.operation.present ? data.operation.value : this.operation,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingUserOpsTableData(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('companyId: $companyId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, operation, companyId, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingUserOpsTableData &&
          other.id == this.id &&
          other.operation == this.operation &&
          other.companyId == this.companyId &&
          other.payload == this.payload);
}

class PendingUserOpsTableCompanion
    extends UpdateCompanion<PendingUserOpsTableData> {
  final Value<int> id;
  final Value<String> operation;
  final Value<int> companyId;
  final Value<String> payload;
  const PendingUserOpsTableCompanion({
    this.id = const Value.absent(),
    this.operation = const Value.absent(),
    this.companyId = const Value.absent(),
    this.payload = const Value.absent(),
  });
  PendingUserOpsTableCompanion.insert({
    this.id = const Value.absent(),
    required String operation,
    required int companyId,
    required String payload,
  }) : operation = Value(operation),
       companyId = Value(companyId),
       payload = Value(payload);
  static Insertable<PendingUserOpsTableData> custom({
    Expression<int>? id,
    Expression<String>? operation,
    Expression<int>? companyId,
    Expression<String>? payload,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operation != null) 'operation': operation,
      if (companyId != null) 'company_id': companyId,
      if (payload != null) 'payload': payload,
    });
  }

  PendingUserOpsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? operation,
    Value<int>? companyId,
    Value<String>? payload,
  }) {
    return PendingUserOpsTableCompanion(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      companyId: companyId ?? this.companyId,
      payload: payload ?? this.payload,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingUserOpsTableCompanion(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('companyId: $companyId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }
}

class $ProductsTableTable extends ProductsTable
    with TableInfo<$ProductsTableTable, ProductsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productGroupIdMeta = const VerificationMeta(
    'productGroupId',
  );
  @override
  late final GeneratedColumn<int> productGroupId = GeneratedColumn<int>(
    'product_group_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isServiceMeta = const VerificationMeta(
    'isService',
  );
  @override
  late final GeneratedColumn<bool> isService = GeneratedColumn<bool>(
    'is_service',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_service" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localImagePathMeta = const VerificationMeta(
    'localImagePath',
  );
  @override
  late final GeneratedColumn<String> localImagePath = GeneratedColumn<String>(
    'local_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pluMeta = const VerificationMeta('plu');
  @override
  late final GeneratedColumn<int> plu = GeneratedColumn<int>(
    'plu',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _measurementUnitMeta = const VerificationMeta(
    'measurementUnit',
  );
  @override
  late final GeneratedColumn<String> measurementUnit = GeneratedColumn<String>(
    'measurement_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _markupMeta = const VerificationMeta('markup');
  @override
  late final GeneratedColumn<double> markup = GeneratedColumn<double>(
    'markup',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currencyIdMeta = const VerificationMeta(
    'currencyId',
  );
  @override
  late final GeneratedColumn<int> currencyId = GeneratedColumn<int>(
    'currency_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ageRestrictionMeta = const VerificationMeta(
    'ageRestriction',
  );
  @override
  late final GeneratedColumn<int> ageRestriction = GeneratedColumn<int>(
    'age_restriction',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPurchasePriceMeta = const VerificationMeta(
    'lastPurchasePrice',
  );
  @override
  late final GeneratedColumn<double> lastPurchasePrice =
      GeneratedColumn<double>(
        'last_purchase_price',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateUpdatedMeta = const VerificationMeta(
    'dateUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
    'date_updated',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPriceChangeAllowedMeta =
      const VerificationMeta('isPriceChangeAllowed');
  @override
  late final GeneratedColumn<bool> isPriceChangeAllowed = GeneratedColumn<bool>(
    'is_price_change_allowed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_price_change_allowed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isUsingDefaultQuantityMeta =
      const VerificationMeta('isUsingDefaultQuantity');
  @override
  late final GeneratedColumn<bool> isUsingDefaultQuantity =
      GeneratedColumn<bool>(
        'is_using_default_quantity',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_using_default_quantity" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _isTaxInclusivePriceMeta =
      const VerificationMeta('isTaxInclusivePrice');
  @override
  late final GeneratedColumn<bool> isTaxInclusivePrice = GeneratedColumn<bool>(
    'is_tax_inclusive_price',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_tax_inclusive_price" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    price,
    cost,
    barcode,
    productGroupId,
    isService,
    colorHex,
    localImagePath,
    code,
    plu,
    measurementUnit,
    description,
    markup,
    rank,
    currencyId,
    ageRestriction,
    lastPurchasePrice,
    dateCreated,
    dateUpdated,
    isPriceChangeAllowed,
    isUsingDefaultQuantity,
    isTaxInclusivePrice,
    isEnabled,
    lastModified,
    syncStatus,
    syncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('product_group_id')) {
      context.handle(
        _productGroupIdMeta,
        productGroupId.isAcceptableOrUnknown(
          data['product_group_id']!,
          _productGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('is_service')) {
      context.handle(
        _isServiceMeta,
        isService.isAcceptableOrUnknown(data['is_service']!, _isServiceMeta),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('local_image_path')) {
      context.handle(
        _localImagePathMeta,
        localImagePath.isAcceptableOrUnknown(
          data['local_image_path']!,
          _localImagePathMeta,
        ),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('plu')) {
      context.handle(
        _pluMeta,
        plu.isAcceptableOrUnknown(data['plu']!, _pluMeta),
      );
    }
    if (data.containsKey('measurement_unit')) {
      context.handle(
        _measurementUnitMeta,
        measurementUnit.isAcceptableOrUnknown(
          data['measurement_unit']!,
          _measurementUnitMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('markup')) {
      context.handle(
        _markupMeta,
        markup.isAcceptableOrUnknown(data['markup']!, _markupMeta),
      );
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    }
    if (data.containsKey('currency_id')) {
      context.handle(
        _currencyIdMeta,
        currencyId.isAcceptableOrUnknown(data['currency_id']!, _currencyIdMeta),
      );
    }
    if (data.containsKey('age_restriction')) {
      context.handle(
        _ageRestrictionMeta,
        ageRestriction.isAcceptableOrUnknown(
          data['age_restriction']!,
          _ageRestrictionMeta,
        ),
      );
    }
    if (data.containsKey('last_purchase_price')) {
      context.handle(
        _lastPurchasePriceMeta,
        lastPurchasePrice.isAcceptableOrUnknown(
          data['last_purchase_price']!,
          _lastPurchasePriceMeta,
        ),
      );
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    if (data.containsKey('date_updated')) {
      context.handle(
        _dateUpdatedMeta,
        dateUpdated.isAcceptableOrUnknown(
          data['date_updated']!,
          _dateUpdatedMeta,
        ),
      );
    }
    if (data.containsKey('is_price_change_allowed')) {
      context.handle(
        _isPriceChangeAllowedMeta,
        isPriceChangeAllowed.isAcceptableOrUnknown(
          data['is_price_change_allowed']!,
          _isPriceChangeAllowedMeta,
        ),
      );
    }
    if (data.containsKey('is_using_default_quantity')) {
      context.handle(
        _isUsingDefaultQuantityMeta,
        isUsingDefaultQuantity.isAcceptableOrUnknown(
          data['is_using_default_quantity']!,
          _isUsingDefaultQuantityMeta,
        ),
      );
    }
    if (data.containsKey('is_tax_inclusive_price')) {
      context.handle(
        _isTaxInclusivePriceMeta,
        isTaxInclusivePrice.isAcceptableOrUnknown(
          data['is_tax_inclusive_price']!,
          _isTaxInclusivePriceMeta,
        ),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      productGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_group_id'],
      ),
      isService: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_service'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      ),
      localImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_image_path'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      plu: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plu'],
      ),
      measurementUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}measurement_unit'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      markup: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}markup'],
      ),
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank'],
      )!,
      currencyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}currency_id'],
      ),
      ageRestriction: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_restriction'],
      ),
      lastPurchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_purchase_price'],
      ),
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      ),
      dateUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_updated'],
      ),
      isPriceChangeAllowed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_price_change_allowed'],
      )!,
      isUsingDefaultQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_using_default_quantity'],
      )!,
      isTaxInclusivePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_tax_inclusive_price'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
    );
  }

  @override
  $ProductsTableTable createAlias(String alias) {
    return $ProductsTableTable(attachedDatabase, alias);
  }
}

class ProductsTableData extends DataClass
    implements Insertable<ProductsTableData> {
  final int id;
  final int companyId;
  final String name;
  final double price;
  final double cost;
  final String? barcode;
  final int? productGroupId;
  final bool isService;
  final String? colorHex;
  final String? localImagePath;
  final String? code;
  final int? plu;
  final String? measurementUnit;
  final String? description;
  final double? markup;
  final int rank;
  final int? currencyId;
  final int? ageRestriction;
  final double? lastPurchasePrice;
  final DateTime? dateCreated;
  final DateTime? dateUpdated;
  final bool isPriceChangeAllowed;
  final bool isUsingDefaultQuantity;
  final bool isTaxInclusivePrice;
  final bool isEnabled;
  final DateTime lastModified;
  final String syncStatus;
  final String? syncError;
  const ProductsTableData({
    required this.id,
    required this.companyId,
    required this.name,
    required this.price,
    required this.cost,
    this.barcode,
    this.productGroupId,
    required this.isService,
    this.colorHex,
    this.localImagePath,
    this.code,
    this.plu,
    this.measurementUnit,
    this.description,
    this.markup,
    required this.rank,
    this.currencyId,
    this.ageRestriction,
    this.lastPurchasePrice,
    this.dateCreated,
    this.dateUpdated,
    required this.isPriceChangeAllowed,
    required this.isUsingDefaultQuantity,
    required this.isTaxInclusivePrice,
    required this.isEnabled,
    required this.lastModified,
    required this.syncStatus,
    this.syncError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['name'] = Variable<String>(name);
    map['price'] = Variable<double>(price);
    map['cost'] = Variable<double>(cost);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || productGroupId != null) {
      map['product_group_id'] = Variable<int>(productGroupId);
    }
    map['is_service'] = Variable<bool>(isService);
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<String>(colorHex);
    }
    if (!nullToAbsent || localImagePath != null) {
      map['local_image_path'] = Variable<String>(localImagePath);
    }
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    if (!nullToAbsent || plu != null) {
      map['plu'] = Variable<int>(plu);
    }
    if (!nullToAbsent || measurementUnit != null) {
      map['measurement_unit'] = Variable<String>(measurementUnit);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || markup != null) {
      map['markup'] = Variable<double>(markup);
    }
    map['rank'] = Variable<int>(rank);
    if (!nullToAbsent || currencyId != null) {
      map['currency_id'] = Variable<int>(currencyId);
    }
    if (!nullToAbsent || ageRestriction != null) {
      map['age_restriction'] = Variable<int>(ageRestriction);
    }
    if (!nullToAbsent || lastPurchasePrice != null) {
      map['last_purchase_price'] = Variable<double>(lastPurchasePrice);
    }
    if (!nullToAbsent || dateCreated != null) {
      map['date_created'] = Variable<DateTime>(dateCreated);
    }
    if (!nullToAbsent || dateUpdated != null) {
      map['date_updated'] = Variable<DateTime>(dateUpdated);
    }
    map['is_price_change_allowed'] = Variable<bool>(isPriceChangeAllowed);
    map['is_using_default_quantity'] = Variable<bool>(isUsingDefaultQuantity);
    map['is_tax_inclusive_price'] = Variable<bool>(isTaxInclusivePrice);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['last_modified'] = Variable<DateTime>(lastModified);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  ProductsTableCompanion toCompanion(bool nullToAbsent) {
    return ProductsTableCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      price: Value(price),
      cost: Value(cost),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      productGroupId: productGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(productGroupId),
      isService: Value(isService),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
      localImagePath: localImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localImagePath),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      plu: plu == null && nullToAbsent ? const Value.absent() : Value(plu),
      measurementUnit: measurementUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(measurementUnit),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      markup: markup == null && nullToAbsent
          ? const Value.absent()
          : Value(markup),
      rank: Value(rank),
      currencyId: currencyId == null && nullToAbsent
          ? const Value.absent()
          : Value(currencyId),
      ageRestriction: ageRestriction == null && nullToAbsent
          ? const Value.absent()
          : Value(ageRestriction),
      lastPurchasePrice: lastPurchasePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPurchasePrice),
      dateCreated: dateCreated == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCreated),
      dateUpdated: dateUpdated == null && nullToAbsent
          ? const Value.absent()
          : Value(dateUpdated),
      isPriceChangeAllowed: Value(isPriceChangeAllowed),
      isUsingDefaultQuantity: Value(isUsingDefaultQuantity),
      isTaxInclusivePrice: Value(isTaxInclusivePrice),
      isEnabled: Value(isEnabled),
      lastModified: Value(lastModified),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory ProductsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductsTableData(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      price: serializer.fromJson<double>(json['price']),
      cost: serializer.fromJson<double>(json['cost']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      productGroupId: serializer.fromJson<int?>(json['productGroupId']),
      isService: serializer.fromJson<bool>(json['isService']),
      colorHex: serializer.fromJson<String?>(json['colorHex']),
      localImagePath: serializer.fromJson<String?>(json['localImagePath']),
      code: serializer.fromJson<String?>(json['code']),
      plu: serializer.fromJson<int?>(json['plu']),
      measurementUnit: serializer.fromJson<String?>(json['measurementUnit']),
      description: serializer.fromJson<String?>(json['description']),
      markup: serializer.fromJson<double?>(json['markup']),
      rank: serializer.fromJson<int>(json['rank']),
      currencyId: serializer.fromJson<int?>(json['currencyId']),
      ageRestriction: serializer.fromJson<int?>(json['ageRestriction']),
      lastPurchasePrice: serializer.fromJson<double?>(
        json['lastPurchasePrice'],
      ),
      dateCreated: serializer.fromJson<DateTime?>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime?>(json['dateUpdated']),
      isPriceChangeAllowed: serializer.fromJson<bool>(
        json['isPriceChangeAllowed'],
      ),
      isUsingDefaultQuantity: serializer.fromJson<bool>(
        json['isUsingDefaultQuantity'],
      ),
      isTaxInclusivePrice: serializer.fromJson<bool>(
        json['isTaxInclusivePrice'],
      ),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'name': serializer.toJson<String>(name),
      'price': serializer.toJson<double>(price),
      'cost': serializer.toJson<double>(cost),
      'barcode': serializer.toJson<String?>(barcode),
      'productGroupId': serializer.toJson<int?>(productGroupId),
      'isService': serializer.toJson<bool>(isService),
      'colorHex': serializer.toJson<String?>(colorHex),
      'localImagePath': serializer.toJson<String?>(localImagePath),
      'code': serializer.toJson<String?>(code),
      'plu': serializer.toJson<int?>(plu),
      'measurementUnit': serializer.toJson<String?>(measurementUnit),
      'description': serializer.toJson<String?>(description),
      'markup': serializer.toJson<double?>(markup),
      'rank': serializer.toJson<int>(rank),
      'currencyId': serializer.toJson<int?>(currencyId),
      'ageRestriction': serializer.toJson<int?>(ageRestriction),
      'lastPurchasePrice': serializer.toJson<double?>(lastPurchasePrice),
      'dateCreated': serializer.toJson<DateTime?>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime?>(dateUpdated),
      'isPriceChangeAllowed': serializer.toJson<bool>(isPriceChangeAllowed),
      'isUsingDefaultQuantity': serializer.toJson<bool>(isUsingDefaultQuantity),
      'isTaxInclusivePrice': serializer.toJson<bool>(isTaxInclusivePrice),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  ProductsTableData copyWith({
    int? id,
    int? companyId,
    String? name,
    double? price,
    double? cost,
    Value<String?> barcode = const Value.absent(),
    Value<int?> productGroupId = const Value.absent(),
    bool? isService,
    Value<String?> colorHex = const Value.absent(),
    Value<String?> localImagePath = const Value.absent(),
    Value<String?> code = const Value.absent(),
    Value<int?> plu = const Value.absent(),
    Value<String?> measurementUnit = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<double?> markup = const Value.absent(),
    int? rank,
    Value<int?> currencyId = const Value.absent(),
    Value<int?> ageRestriction = const Value.absent(),
    Value<double?> lastPurchasePrice = const Value.absent(),
    Value<DateTime?> dateCreated = const Value.absent(),
    Value<DateTime?> dateUpdated = const Value.absent(),
    bool? isPriceChangeAllowed,
    bool? isUsingDefaultQuantity,
    bool? isTaxInclusivePrice,
    bool? isEnabled,
    DateTime? lastModified,
    String? syncStatus,
    Value<String?> syncError = const Value.absent(),
  }) => ProductsTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    price: price ?? this.price,
    cost: cost ?? this.cost,
    barcode: barcode.present ? barcode.value : this.barcode,
    productGroupId: productGroupId.present
        ? productGroupId.value
        : this.productGroupId,
    isService: isService ?? this.isService,
    colorHex: colorHex.present ? colorHex.value : this.colorHex,
    localImagePath: localImagePath.present
        ? localImagePath.value
        : this.localImagePath,
    code: code.present ? code.value : this.code,
    plu: plu.present ? plu.value : this.plu,
    measurementUnit: measurementUnit.present
        ? measurementUnit.value
        : this.measurementUnit,
    description: description.present ? description.value : this.description,
    markup: markup.present ? markup.value : this.markup,
    rank: rank ?? this.rank,
    currencyId: currencyId.present ? currencyId.value : this.currencyId,
    ageRestriction: ageRestriction.present
        ? ageRestriction.value
        : this.ageRestriction,
    lastPurchasePrice: lastPurchasePrice.present
        ? lastPurchasePrice.value
        : this.lastPurchasePrice,
    dateCreated: dateCreated.present ? dateCreated.value : this.dateCreated,
    dateUpdated: dateUpdated.present ? dateUpdated.value : this.dateUpdated,
    isPriceChangeAllowed: isPriceChangeAllowed ?? this.isPriceChangeAllowed,
    isUsingDefaultQuantity:
        isUsingDefaultQuantity ?? this.isUsingDefaultQuantity,
    isTaxInclusivePrice: isTaxInclusivePrice ?? this.isTaxInclusivePrice,
    isEnabled: isEnabled ?? this.isEnabled,
    lastModified: lastModified ?? this.lastModified,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
  );
  ProductsTableData copyWithCompanion(ProductsTableCompanion data) {
    return ProductsTableData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      price: data.price.present ? data.price.value : this.price,
      cost: data.cost.present ? data.cost.value : this.cost,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      productGroupId: data.productGroupId.present
          ? data.productGroupId.value
          : this.productGroupId,
      isService: data.isService.present ? data.isService.value : this.isService,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      localImagePath: data.localImagePath.present
          ? data.localImagePath.value
          : this.localImagePath,
      code: data.code.present ? data.code.value : this.code,
      plu: data.plu.present ? data.plu.value : this.plu,
      measurementUnit: data.measurementUnit.present
          ? data.measurementUnit.value
          : this.measurementUnit,
      description: data.description.present
          ? data.description.value
          : this.description,
      markup: data.markup.present ? data.markup.value : this.markup,
      rank: data.rank.present ? data.rank.value : this.rank,
      currencyId: data.currencyId.present
          ? data.currencyId.value
          : this.currencyId,
      ageRestriction: data.ageRestriction.present
          ? data.ageRestriction.value
          : this.ageRestriction,
      lastPurchasePrice: data.lastPurchasePrice.present
          ? data.lastPurchasePrice.value
          : this.lastPurchasePrice,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      dateUpdated: data.dateUpdated.present
          ? data.dateUpdated.value
          : this.dateUpdated,
      isPriceChangeAllowed: data.isPriceChangeAllowed.present
          ? data.isPriceChangeAllowed.value
          : this.isPriceChangeAllowed,
      isUsingDefaultQuantity: data.isUsingDefaultQuantity.present
          ? data.isUsingDefaultQuantity.value
          : this.isUsingDefaultQuantity,
      isTaxInclusivePrice: data.isTaxInclusivePrice.present
          ? data.isTaxInclusivePrice.value
          : this.isTaxInclusivePrice,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductsTableData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('cost: $cost, ')
          ..write('barcode: $barcode, ')
          ..write('productGroupId: $productGroupId, ')
          ..write('isService: $isService, ')
          ..write('colorHex: $colorHex, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('code: $code, ')
          ..write('plu: $plu, ')
          ..write('measurementUnit: $measurementUnit, ')
          ..write('description: $description, ')
          ..write('markup: $markup, ')
          ..write('rank: $rank, ')
          ..write('currencyId: $currencyId, ')
          ..write('ageRestriction: $ageRestriction, ')
          ..write('lastPurchasePrice: $lastPurchasePrice, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('isPriceChangeAllowed: $isPriceChangeAllowed, ')
          ..write('isUsingDefaultQuantity: $isUsingDefaultQuantity, ')
          ..write('isTaxInclusivePrice: $isTaxInclusivePrice, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    companyId,
    name,
    price,
    cost,
    barcode,
    productGroupId,
    isService,
    colorHex,
    localImagePath,
    code,
    plu,
    measurementUnit,
    description,
    markup,
    rank,
    currencyId,
    ageRestriction,
    lastPurchasePrice,
    dateCreated,
    dateUpdated,
    isPriceChangeAllowed,
    isUsingDefaultQuantity,
    isTaxInclusivePrice,
    isEnabled,
    lastModified,
    syncStatus,
    syncError,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductsTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.price == this.price &&
          other.cost == this.cost &&
          other.barcode == this.barcode &&
          other.productGroupId == this.productGroupId &&
          other.isService == this.isService &&
          other.colorHex == this.colorHex &&
          other.localImagePath == this.localImagePath &&
          other.code == this.code &&
          other.plu == this.plu &&
          other.measurementUnit == this.measurementUnit &&
          other.description == this.description &&
          other.markup == this.markup &&
          other.rank == this.rank &&
          other.currencyId == this.currencyId &&
          other.ageRestriction == this.ageRestriction &&
          other.lastPurchasePrice == this.lastPurchasePrice &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.isPriceChangeAllowed == this.isPriceChangeAllowed &&
          other.isUsingDefaultQuantity == this.isUsingDefaultQuantity &&
          other.isTaxInclusivePrice == this.isTaxInclusivePrice &&
          other.isEnabled == this.isEnabled &&
          other.lastModified == this.lastModified &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError);
}

class ProductsTableCompanion extends UpdateCompanion<ProductsTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String> name;
  final Value<double> price;
  final Value<double> cost;
  final Value<String?> barcode;
  final Value<int?> productGroupId;
  final Value<bool> isService;
  final Value<String?> colorHex;
  final Value<String?> localImagePath;
  final Value<String?> code;
  final Value<int?> plu;
  final Value<String?> measurementUnit;
  final Value<String?> description;
  final Value<double?> markup;
  final Value<int> rank;
  final Value<int?> currencyId;
  final Value<int?> ageRestriction;
  final Value<double?> lastPurchasePrice;
  final Value<DateTime?> dateCreated;
  final Value<DateTime?> dateUpdated;
  final Value<bool> isPriceChangeAllowed;
  final Value<bool> isUsingDefaultQuantity;
  final Value<bool> isTaxInclusivePrice;
  final Value<bool> isEnabled;
  final Value<DateTime> lastModified;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  const ProductsTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.price = const Value.absent(),
    this.cost = const Value.absent(),
    this.barcode = const Value.absent(),
    this.productGroupId = const Value.absent(),
    this.isService = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.code = const Value.absent(),
    this.plu = const Value.absent(),
    this.measurementUnit = const Value.absent(),
    this.description = const Value.absent(),
    this.markup = const Value.absent(),
    this.rank = const Value.absent(),
    this.currencyId = const Value.absent(),
    this.ageRestriction = const Value.absent(),
    this.lastPurchasePrice = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.isPriceChangeAllowed = const Value.absent(),
    this.isUsingDefaultQuantity = const Value.absent(),
    this.isTaxInclusivePrice = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
  });
  ProductsTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required String name,
    this.price = const Value.absent(),
    this.cost = const Value.absent(),
    this.barcode = const Value.absent(),
    this.productGroupId = const Value.absent(),
    this.isService = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.code = const Value.absent(),
    this.plu = const Value.absent(),
    this.measurementUnit = const Value.absent(),
    this.description = const Value.absent(),
    this.markup = const Value.absent(),
    this.rank = const Value.absent(),
    this.currencyId = const Value.absent(),
    this.ageRestriction = const Value.absent(),
    this.lastPurchasePrice = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.isPriceChangeAllowed = const Value.absent(),
    this.isUsingDefaultQuantity = const Value.absent(),
    this.isTaxInclusivePrice = const Value.absent(),
    this.isEnabled = const Value.absent(),
    required DateTime lastModified,
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
  }) : companyId = Value(companyId),
       name = Value(name),
       lastModified = Value(lastModified);
  static Insertable<ProductsTableData> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<String>? name,
    Expression<double>? price,
    Expression<double>? cost,
    Expression<String>? barcode,
    Expression<int>? productGroupId,
    Expression<bool>? isService,
    Expression<String>? colorHex,
    Expression<String>? localImagePath,
    Expression<String>? code,
    Expression<int>? plu,
    Expression<String>? measurementUnit,
    Expression<String>? description,
    Expression<double>? markup,
    Expression<int>? rank,
    Expression<int>? currencyId,
    Expression<int>? ageRestriction,
    Expression<double>? lastPurchasePrice,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<bool>? isPriceChangeAllowed,
    Expression<bool>? isUsingDefaultQuantity,
    Expression<bool>? isTaxInclusivePrice,
    Expression<bool>? isEnabled,
    Expression<DateTime>? lastModified,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (cost != null) 'cost': cost,
      if (barcode != null) 'barcode': barcode,
      if (productGroupId != null) 'product_group_id': productGroupId,
      if (isService != null) 'is_service': isService,
      if (colorHex != null) 'color_hex': colorHex,
      if (localImagePath != null) 'local_image_path': localImagePath,
      if (code != null) 'code': code,
      if (plu != null) 'plu': plu,
      if (measurementUnit != null) 'measurement_unit': measurementUnit,
      if (description != null) 'description': description,
      if (markup != null) 'markup': markup,
      if (rank != null) 'rank': rank,
      if (currencyId != null) 'currency_id': currencyId,
      if (ageRestriction != null) 'age_restriction': ageRestriction,
      if (lastPurchasePrice != null) 'last_purchase_price': lastPurchasePrice,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (isPriceChangeAllowed != null)
        'is_price_change_allowed': isPriceChangeAllowed,
      if (isUsingDefaultQuantity != null)
        'is_using_default_quantity': isUsingDefaultQuantity,
      if (isTaxInclusivePrice != null)
        'is_tax_inclusive_price': isTaxInclusivePrice,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (lastModified != null) 'last_modified': lastModified,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
    });
  }

  ProductsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<String>? name,
    Value<double>? price,
    Value<double>? cost,
    Value<String?>? barcode,
    Value<int?>? productGroupId,
    Value<bool>? isService,
    Value<String?>? colorHex,
    Value<String?>? localImagePath,
    Value<String?>? code,
    Value<int?>? plu,
    Value<String?>? measurementUnit,
    Value<String?>? description,
    Value<double?>? markup,
    Value<int>? rank,
    Value<int?>? currencyId,
    Value<int?>? ageRestriction,
    Value<double?>? lastPurchasePrice,
    Value<DateTime?>? dateCreated,
    Value<DateTime?>? dateUpdated,
    Value<bool>? isPriceChangeAllowed,
    Value<bool>? isUsingDefaultQuantity,
    Value<bool>? isTaxInclusivePrice,
    Value<bool>? isEnabled,
    Value<DateTime>? lastModified,
    Value<String>? syncStatus,
    Value<String?>? syncError,
  }) {
    return ProductsTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      barcode: barcode ?? this.barcode,
      productGroupId: productGroupId ?? this.productGroupId,
      isService: isService ?? this.isService,
      colorHex: colorHex ?? this.colorHex,
      localImagePath: localImagePath ?? this.localImagePath,
      code: code ?? this.code,
      plu: plu ?? this.plu,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      description: description ?? this.description,
      markup: markup ?? this.markup,
      rank: rank ?? this.rank,
      currencyId: currencyId ?? this.currencyId,
      ageRestriction: ageRestriction ?? this.ageRestriction,
      lastPurchasePrice: lastPurchasePrice ?? this.lastPurchasePrice,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      isPriceChangeAllowed: isPriceChangeAllowed ?? this.isPriceChangeAllowed,
      isUsingDefaultQuantity:
          isUsingDefaultQuantity ?? this.isUsingDefaultQuantity,
      isTaxInclusivePrice: isTaxInclusivePrice ?? this.isTaxInclusivePrice,
      isEnabled: isEnabled ?? this.isEnabled,
      lastModified: lastModified ?? this.lastModified,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (productGroupId.present) {
      map['product_group_id'] = Variable<int>(productGroupId.value);
    }
    if (isService.present) {
      map['is_service'] = Variable<bool>(isService.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (localImagePath.present) {
      map['local_image_path'] = Variable<String>(localImagePath.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (plu.present) {
      map['plu'] = Variable<int>(plu.value);
    }
    if (measurementUnit.present) {
      map['measurement_unit'] = Variable<String>(measurementUnit.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (markup.present) {
      map['markup'] = Variable<double>(markup.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (currencyId.present) {
      map['currency_id'] = Variable<int>(currencyId.value);
    }
    if (ageRestriction.present) {
      map['age_restriction'] = Variable<int>(ageRestriction.value);
    }
    if (lastPurchasePrice.present) {
      map['last_purchase_price'] = Variable<double>(lastPurchasePrice.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (isPriceChangeAllowed.present) {
      map['is_price_change_allowed'] = Variable<bool>(
        isPriceChangeAllowed.value,
      );
    }
    if (isUsingDefaultQuantity.present) {
      map['is_using_default_quantity'] = Variable<bool>(
        isUsingDefaultQuantity.value,
      );
    }
    if (isTaxInclusivePrice.present) {
      map['is_tax_inclusive_price'] = Variable<bool>(isTaxInclusivePrice.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsTableCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('cost: $cost, ')
          ..write('barcode: $barcode, ')
          ..write('productGroupId: $productGroupId, ')
          ..write('isService: $isService, ')
          ..write('colorHex: $colorHex, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('code: $code, ')
          ..write('plu: $plu, ')
          ..write('measurementUnit: $measurementUnit, ')
          ..write('description: $description, ')
          ..write('markup: $markup, ')
          ..write('rank: $rank, ')
          ..write('currencyId: $currencyId, ')
          ..write('ageRestriction: $ageRestriction, ')
          ..write('lastPurchasePrice: $lastPurchasePrice, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('isPriceChangeAllowed: $isPriceChangeAllowed, ')
          ..write('isUsingDefaultQuantity: $isUsingDefaultQuantity, ')
          ..write('isTaxInclusivePrice: $isTaxInclusivePrice, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }
}

class $TaxesTableTable extends TaxesTable
    with TableInfo<$TaxesTableTable, TaxesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaxesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFixedMeta = const VerificationMeta(
    'isFixed',
  );
  @override
  late final GeneratedColumn<bool> isFixed = GeneratedColumn<bool>(
    'is_fixed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_fixed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isTaxOnTotalMeta = const VerificationMeta(
    'isTaxOnTotal',
  );
  @override
  late final GeneratedColumn<bool> isTaxOnTotal = GeneratedColumn<bool>(
    'is_tax_on_total',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_tax_on_total" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    rate,
    code,
    isFixed,
    isTaxOnTotal,
    isEnabled,
    lastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'taxes';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaxesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('is_fixed')) {
      context.handle(
        _isFixedMeta,
        isFixed.isAcceptableOrUnknown(data['is_fixed']!, _isFixedMeta),
      );
    }
    if (data.containsKey('is_tax_on_total')) {
      context.handle(
        _isTaxOnTotalMeta,
        isTaxOnTotal.isAcceptableOrUnknown(
          data['is_tax_on_total']!,
          _isTaxOnTotalMeta,
        ),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaxesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaxesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      isFixed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_fixed'],
      )!,
      isTaxOnTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_tax_on_total'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
    );
  }

  @override
  $TaxesTableTable createAlias(String alias) {
    return $TaxesTableTable(attachedDatabase, alias);
  }
}

class TaxesTableData extends DataClass implements Insertable<TaxesTableData> {
  final int id;
  final int companyId;
  final String name;
  final double rate;
  final String? code;
  final bool isFixed;
  final bool isTaxOnTotal;
  final bool isEnabled;
  final DateTime lastModified;
  const TaxesTableData({
    required this.id,
    required this.companyId,
    required this.name,
    required this.rate,
    this.code,
    required this.isFixed,
    required this.isTaxOnTotal,
    required this.isEnabled,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['name'] = Variable<String>(name);
    map['rate'] = Variable<double>(rate);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['is_fixed'] = Variable<bool>(isFixed);
    map['is_tax_on_total'] = Variable<bool>(isTaxOnTotal);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  TaxesTableCompanion toCompanion(bool nullToAbsent) {
    return TaxesTableCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      rate: Value(rate),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      isFixed: Value(isFixed),
      isTaxOnTotal: Value(isTaxOnTotal),
      isEnabled: Value(isEnabled),
      lastModified: Value(lastModified),
    );
  }

  factory TaxesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaxesTableData(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      rate: serializer.fromJson<double>(json['rate']),
      code: serializer.fromJson<String?>(json['code']),
      isFixed: serializer.fromJson<bool>(json['isFixed']),
      isTaxOnTotal: serializer.fromJson<bool>(json['isTaxOnTotal']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'name': serializer.toJson<String>(name),
      'rate': serializer.toJson<double>(rate),
      'code': serializer.toJson<String?>(code),
      'isFixed': serializer.toJson<bool>(isFixed),
      'isTaxOnTotal': serializer.toJson<bool>(isTaxOnTotal),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  TaxesTableData copyWith({
    int? id,
    int? companyId,
    String? name,
    double? rate,
    Value<String?> code = const Value.absent(),
    bool? isFixed,
    bool? isTaxOnTotal,
    bool? isEnabled,
    DateTime? lastModified,
  }) => TaxesTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    rate: rate ?? this.rate,
    code: code.present ? code.value : this.code,
    isFixed: isFixed ?? this.isFixed,
    isTaxOnTotal: isTaxOnTotal ?? this.isTaxOnTotal,
    isEnabled: isEnabled ?? this.isEnabled,
    lastModified: lastModified ?? this.lastModified,
  );
  TaxesTableData copyWithCompanion(TaxesTableCompanion data) {
    return TaxesTableData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      rate: data.rate.present ? data.rate.value : this.rate,
      code: data.code.present ? data.code.value : this.code,
      isFixed: data.isFixed.present ? data.isFixed.value : this.isFixed,
      isTaxOnTotal: data.isTaxOnTotal.present
          ? data.isTaxOnTotal.value
          : this.isTaxOnTotal,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaxesTableData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('rate: $rate, ')
          ..write('code: $code, ')
          ..write('isFixed: $isFixed, ')
          ..write('isTaxOnTotal: $isTaxOnTotal, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    name,
    rate,
    code,
    isFixed,
    isTaxOnTotal,
    isEnabled,
    lastModified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaxesTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.rate == this.rate &&
          other.code == this.code &&
          other.isFixed == this.isFixed &&
          other.isTaxOnTotal == this.isTaxOnTotal &&
          other.isEnabled == this.isEnabled &&
          other.lastModified == this.lastModified);
}

class TaxesTableCompanion extends UpdateCompanion<TaxesTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String> name;
  final Value<double> rate;
  final Value<String?> code;
  final Value<bool> isFixed;
  final Value<bool> isTaxOnTotal;
  final Value<bool> isEnabled;
  final Value<DateTime> lastModified;
  const TaxesTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.rate = const Value.absent(),
    this.code = const Value.absent(),
    this.isFixed = const Value.absent(),
    this.isTaxOnTotal = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  TaxesTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required String name,
    required double rate,
    this.code = const Value.absent(),
    this.isFixed = const Value.absent(),
    this.isTaxOnTotal = const Value.absent(),
    this.isEnabled = const Value.absent(),
    required DateTime lastModified,
  }) : companyId = Value(companyId),
       name = Value(name),
       rate = Value(rate),
       lastModified = Value(lastModified);
  static Insertable<TaxesTableData> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<String>? name,
    Expression<double>? rate,
    Expression<String>? code,
    Expression<bool>? isFixed,
    Expression<bool>? isTaxOnTotal,
    Expression<bool>? isEnabled,
    Expression<DateTime>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (rate != null) 'rate': rate,
      if (code != null) 'code': code,
      if (isFixed != null) 'is_fixed': isFixed,
      if (isTaxOnTotal != null) 'is_tax_on_total': isTaxOnTotal,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (lastModified != null) 'last_modified': lastModified,
    });
  }

  TaxesTableCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<String>? name,
    Value<double>? rate,
    Value<String?>? code,
    Value<bool>? isFixed,
    Value<bool>? isTaxOnTotal,
    Value<bool>? isEnabled,
    Value<DateTime>? lastModified,
  }) {
    return TaxesTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      code: code ?? this.code,
      isFixed: isFixed ?? this.isFixed,
      isTaxOnTotal: isTaxOnTotal ?? this.isTaxOnTotal,
      isEnabled: isEnabled ?? this.isEnabled,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (isFixed.present) {
      map['is_fixed'] = Variable<bool>(isFixed.value);
    }
    if (isTaxOnTotal.present) {
      map['is_tax_on_total'] = Variable<bool>(isTaxOnTotal.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaxesTableCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('rate: $rate, ')
          ..write('code: $code, ')
          ..write('isFixed: $isFixed, ')
          ..write('isTaxOnTotal: $isTaxOnTotal, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }
}

class $FloorPlansTableTable extends FloorPlansTable
    with TableInfo<$FloorPlansTableTable, FloorPlansTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FloorPlansTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Transparent'),
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    color,
    lastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'floor_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<FloorPlansTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FloorPlansTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FloorPlansTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
    );
  }

  @override
  $FloorPlansTableTable createAlias(String alias) {
    return $FloorPlansTableTable(attachedDatabase, alias);
  }
}

class FloorPlansTableData extends DataClass
    implements Insertable<FloorPlansTableData> {
  final int id;
  final int companyId;
  final String name;
  final String color;
  final DateTime lastModified;
  const FloorPlansTableData({
    required this.id,
    required this.companyId,
    required this.name,
    required this.color,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  FloorPlansTableCompanion toCompanion(bool nullToAbsent) {
    return FloorPlansTableCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      color: Value(color),
      lastModified: Value(lastModified),
    );
  }

  factory FloorPlansTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FloorPlansTableData(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  FloorPlansTableData copyWith({
    int? id,
    int? companyId,
    String? name,
    String? color,
    DateTime? lastModified,
  }) => FloorPlansTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    color: color ?? this.color,
    lastModified: lastModified ?? this.lastModified,
  );
  FloorPlansTableData copyWithCompanion(FloorPlansTableCompanion data) {
    return FloorPlansTableData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FloorPlansTableData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, companyId, name, color, lastModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FloorPlansTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.color == this.color &&
          other.lastModified == this.lastModified);
}

class FloorPlansTableCompanion extends UpdateCompanion<FloorPlansTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String> name;
  final Value<String> color;
  final Value<DateTime> lastModified;
  const FloorPlansTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  FloorPlansTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required String name,
    this.color = const Value.absent(),
    required DateTime lastModified,
  }) : companyId = Value(companyId),
       name = Value(name),
       lastModified = Value(lastModified);
  static Insertable<FloorPlansTableData> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<String>? name,
    Expression<String>? color,
    Expression<DateTime>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (lastModified != null) 'last_modified': lastModified,
    });
  }

  FloorPlansTableCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<String>? name,
    Value<String>? color,
    Value<DateTime>? lastModified,
  }) {
    return FloorPlansTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      color: color ?? this.color,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FloorPlansTableCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }
}

class $FloorPlanTablesTableTable extends FloorPlanTablesTable
    with TableInfo<$FloorPlanTablesTableTable, FloorPlanTablesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FloorPlanTablesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _floorPlanIdMeta = const VerificationMeta(
    'floorPlanId',
  );
  @override
  late final GeneratedColumn<int> floorPlanId = GeneratedColumn<int>(
    'floor_plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionXMeta = const VerificationMeta(
    'positionX',
  );
  @override
  late final GeneratedColumn<double> positionX = GeneratedColumn<double>(
    'position_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionYMeta = const VerificationMeta(
    'positionY',
  );
  @override
  late final GeneratedColumn<double> positionY = GeneratedColumn<double>(
    'position_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRoundMeta = const VerificationMeta(
    'isRound',
  );
  @override
  late final GeneratedColumn<bool> isRound = GeneratedColumn<bool>(
    'is_round',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_round" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    floorPlanId,
    name,
    positionX,
    positionY,
    width,
    height,
    isRound,
    status,
    lastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'floor_plan_tables';
  @override
  VerificationContext validateIntegrity(
    Insertable<FloorPlanTablesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('floor_plan_id')) {
      context.handle(
        _floorPlanIdMeta,
        floorPlanId.isAcceptableOrUnknown(
          data['floor_plan_id']!,
          _floorPlanIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_floorPlanIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position_x')) {
      context.handle(
        _positionXMeta,
        positionX.isAcceptableOrUnknown(data['position_x']!, _positionXMeta),
      );
    } else if (isInserting) {
      context.missing(_positionXMeta);
    }
    if (data.containsKey('position_y')) {
      context.handle(
        _positionYMeta,
        positionY.isAcceptableOrUnknown(data['position_y']!, _positionYMeta),
      );
    } else if (isInserting) {
      context.missing(_positionYMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('is_round')) {
      context.handle(
        _isRoundMeta,
        isRound.isAcceptableOrUnknown(data['is_round']!, _isRoundMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FloorPlanTablesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FloorPlanTablesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      floorPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}floor_plan_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      positionX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position_x'],
      )!,
      positionY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position_y'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      )!,
      isRound: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_round'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
    );
  }

  @override
  $FloorPlanTablesTableTable createAlias(String alias) {
    return $FloorPlanTablesTableTable(attachedDatabase, alias);
  }
}

class FloorPlanTablesTableData extends DataClass
    implements Insertable<FloorPlanTablesTableData> {
  final int id;
  final int companyId;
  final int floorPlanId;
  final String name;
  final double positionX;
  final double positionY;
  final double width;
  final double height;
  final bool isRound;
  final int status;
  final DateTime lastModified;
  const FloorPlanTablesTableData({
    required this.id,
    required this.companyId,
    required this.floorPlanId,
    required this.name,
    required this.positionX,
    required this.positionY,
    required this.width,
    required this.height,
    required this.isRound,
    required this.status,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['floor_plan_id'] = Variable<int>(floorPlanId);
    map['name'] = Variable<String>(name);
    map['position_x'] = Variable<double>(positionX);
    map['position_y'] = Variable<double>(positionY);
    map['width'] = Variable<double>(width);
    map['height'] = Variable<double>(height);
    map['is_round'] = Variable<bool>(isRound);
    map['status'] = Variable<int>(status);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  FloorPlanTablesTableCompanion toCompanion(bool nullToAbsent) {
    return FloorPlanTablesTableCompanion(
      id: Value(id),
      companyId: Value(companyId),
      floorPlanId: Value(floorPlanId),
      name: Value(name),
      positionX: Value(positionX),
      positionY: Value(positionY),
      width: Value(width),
      height: Value(height),
      isRound: Value(isRound),
      status: Value(status),
      lastModified: Value(lastModified),
    );
  }

  factory FloorPlanTablesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FloorPlanTablesTableData(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      floorPlanId: serializer.fromJson<int>(json['floorPlanId']),
      name: serializer.fromJson<String>(json['name']),
      positionX: serializer.fromJson<double>(json['positionX']),
      positionY: serializer.fromJson<double>(json['positionY']),
      width: serializer.fromJson<double>(json['width']),
      height: serializer.fromJson<double>(json['height']),
      isRound: serializer.fromJson<bool>(json['isRound']),
      status: serializer.fromJson<int>(json['status']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'floorPlanId': serializer.toJson<int>(floorPlanId),
      'name': serializer.toJson<String>(name),
      'positionX': serializer.toJson<double>(positionX),
      'positionY': serializer.toJson<double>(positionY),
      'width': serializer.toJson<double>(width),
      'height': serializer.toJson<double>(height),
      'isRound': serializer.toJson<bool>(isRound),
      'status': serializer.toJson<int>(status),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  FloorPlanTablesTableData copyWith({
    int? id,
    int? companyId,
    int? floorPlanId,
    String? name,
    double? positionX,
    double? positionY,
    double? width,
    double? height,
    bool? isRound,
    int? status,
    DateTime? lastModified,
  }) => FloorPlanTablesTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    floorPlanId: floorPlanId ?? this.floorPlanId,
    name: name ?? this.name,
    positionX: positionX ?? this.positionX,
    positionY: positionY ?? this.positionY,
    width: width ?? this.width,
    height: height ?? this.height,
    isRound: isRound ?? this.isRound,
    status: status ?? this.status,
    lastModified: lastModified ?? this.lastModified,
  );
  FloorPlanTablesTableData copyWithCompanion(
    FloorPlanTablesTableCompanion data,
  ) {
    return FloorPlanTablesTableData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      floorPlanId: data.floorPlanId.present
          ? data.floorPlanId.value
          : this.floorPlanId,
      name: data.name.present ? data.name.value : this.name,
      positionX: data.positionX.present ? data.positionX.value : this.positionX,
      positionY: data.positionY.present ? data.positionY.value : this.positionY,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      isRound: data.isRound.present ? data.isRound.value : this.isRound,
      status: data.status.present ? data.status.value : this.status,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FloorPlanTablesTableData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('floorPlanId: $floorPlanId, ')
          ..write('name: $name, ')
          ..write('positionX: $positionX, ')
          ..write('positionY: $positionY, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('isRound: $isRound, ')
          ..write('status: $status, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    floorPlanId,
    name,
    positionX,
    positionY,
    width,
    height,
    isRound,
    status,
    lastModified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FloorPlanTablesTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.floorPlanId == this.floorPlanId &&
          other.name == this.name &&
          other.positionX == this.positionX &&
          other.positionY == this.positionY &&
          other.width == this.width &&
          other.height == this.height &&
          other.isRound == this.isRound &&
          other.status == this.status &&
          other.lastModified == this.lastModified);
}

class FloorPlanTablesTableCompanion
    extends UpdateCompanion<FloorPlanTablesTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<int> floorPlanId;
  final Value<String> name;
  final Value<double> positionX;
  final Value<double> positionY;
  final Value<double> width;
  final Value<double> height;
  final Value<bool> isRound;
  final Value<int> status;
  final Value<DateTime> lastModified;
  const FloorPlanTablesTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.floorPlanId = const Value.absent(),
    this.name = const Value.absent(),
    this.positionX = const Value.absent(),
    this.positionY = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.isRound = const Value.absent(),
    this.status = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  FloorPlanTablesTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required int floorPlanId,
    required String name,
    required double positionX,
    required double positionY,
    required double width,
    required double height,
    this.isRound = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime lastModified,
  }) : companyId = Value(companyId),
       floorPlanId = Value(floorPlanId),
       name = Value(name),
       positionX = Value(positionX),
       positionY = Value(positionY),
       width = Value(width),
       height = Value(height),
       lastModified = Value(lastModified);
  static Insertable<FloorPlanTablesTableData> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<int>? floorPlanId,
    Expression<String>? name,
    Expression<double>? positionX,
    Expression<double>? positionY,
    Expression<double>? width,
    Expression<double>? height,
    Expression<bool>? isRound,
    Expression<int>? status,
    Expression<DateTime>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (floorPlanId != null) 'floor_plan_id': floorPlanId,
      if (name != null) 'name': name,
      if (positionX != null) 'position_x': positionX,
      if (positionY != null) 'position_y': positionY,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (isRound != null) 'is_round': isRound,
      if (status != null) 'status': status,
      if (lastModified != null) 'last_modified': lastModified,
    });
  }

  FloorPlanTablesTableCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<int>? floorPlanId,
    Value<String>? name,
    Value<double>? positionX,
    Value<double>? positionY,
    Value<double>? width,
    Value<double>? height,
    Value<bool>? isRound,
    Value<int>? status,
    Value<DateTime>? lastModified,
  }) {
    return FloorPlanTablesTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      floorPlanId: floorPlanId ?? this.floorPlanId,
      name: name ?? this.name,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      width: width ?? this.width,
      height: height ?? this.height,
      isRound: isRound ?? this.isRound,
      status: status ?? this.status,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (floorPlanId.present) {
      map['floor_plan_id'] = Variable<int>(floorPlanId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (positionX.present) {
      map['position_x'] = Variable<double>(positionX.value);
    }
    if (positionY.present) {
      map['position_y'] = Variable<double>(positionY.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (isRound.present) {
      map['is_round'] = Variable<bool>(isRound.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FloorPlanTablesTableCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('floorPlanId: $floorPlanId, ')
          ..write('name: $name, ')
          ..write('positionX: $positionX, ')
          ..write('positionY: $positionY, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('isRound: $isRound, ')
          ..write('status: $status, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }
}

class $UsersTableTable extends UsersTable
    with TableInfo<$UsersTableTable, UsersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<int> role = GeneratedColumn<int>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    firstName,
    lastName,
    username,
    email,
    pinHash,
    role,
    isEnabled,
    lastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      ),
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      ),
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
    );
  }

  @override
  $UsersTableTable createAlias(String alias) {
    return $UsersTableTable(attachedDatabase, alias);
  }
}

class UsersTableData extends DataClass implements Insertable<UsersTableData> {
  final int id;
  final int companyId;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? email;
  final String? pinHash;
  final int role;
  final bool isEnabled;
  final DateTime lastModified;
  const UsersTableData({
    required this.id,
    required this.companyId,
    required this.name,
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.pinHash,
    required this.role,
    required this.isEnabled,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    map['role'] = Variable<int>(role);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  UsersTableCompanion toCompanion(bool nullToAbsent) {
    return UsersTableCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
      role: Value(role),
      isEnabled: Value(isEnabled),
      lastModified: Value(lastModified),
    );
  }

  factory UsersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersTableData(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      username: serializer.fromJson<String?>(json['username']),
      email: serializer.fromJson<String?>(json['email']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      role: serializer.fromJson<int>(json['role']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'name': serializer.toJson<String>(name),
      'firstName': serializer.toJson<String?>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'username': serializer.toJson<String?>(username),
      'email': serializer.toJson<String?>(email),
      'pinHash': serializer.toJson<String?>(pinHash),
      'role': serializer.toJson<int>(role),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  UsersTableData copyWith({
    int? id,
    int? companyId,
    String? name,
    Value<String?> firstName = const Value.absent(),
    Value<String?> lastName = const Value.absent(),
    Value<String?> username = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> pinHash = const Value.absent(),
    int? role,
    bool? isEnabled,
    DateTime? lastModified,
  }) => UsersTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    firstName: firstName.present ? firstName.value : this.firstName,
    lastName: lastName.present ? lastName.value : this.lastName,
    username: username.present ? username.value : this.username,
    email: email.present ? email.value : this.email,
    pinHash: pinHash.present ? pinHash.value : this.pinHash,
    role: role ?? this.role,
    isEnabled: isEnabled ?? this.isEnabled,
    lastModified: lastModified ?? this.lastModified,
  );
  UsersTableData copyWithCompanion(UsersTableCompanion data) {
    return UsersTableData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      username: data.username.present ? data.username.value : this.username,
      email: data.email.present ? data.email.value : this.email,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      role: data.role.present ? data.role.value : this.role,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('username: $username, ')
          ..write('email: $email, ')
          ..write('pinHash: $pinHash, ')
          ..write('role: $role, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    name,
    firstName,
    lastName,
    username,
    email,
    pinHash,
    role,
    isEnabled,
    lastModified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.username == this.username &&
          other.email == this.email &&
          other.pinHash == this.pinHash &&
          other.role == this.role &&
          other.isEnabled == this.isEnabled &&
          other.lastModified == this.lastModified);
}

class UsersTableCompanion extends UpdateCompanion<UsersTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String> name;
  final Value<String?> firstName;
  final Value<String?> lastName;
  final Value<String?> username;
  final Value<String?> email;
  final Value<String?> pinHash;
  final Value<int> role;
  final Value<bool> isEnabled;
  final Value<DateTime> lastModified;
  const UsersTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.username = const Value.absent(),
    this.email = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.role = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  UsersTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required String name,
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.username = const Value.absent(),
    this.email = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.role = const Value.absent(),
    this.isEnabled = const Value.absent(),
    required DateTime lastModified,
  }) : companyId = Value(companyId),
       name = Value(name),
       lastModified = Value(lastModified);
  static Insertable<UsersTableData> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<String>? name,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? username,
    Expression<String>? email,
    Expression<String>? pinHash,
    Expression<int>? role,
    Expression<bool>? isEnabled,
    Expression<DateTime>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (pinHash != null) 'pin_hash': pinHash,
      if (role != null) 'role': role,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (lastModified != null) 'last_modified': lastModified,
    });
  }

  UsersTableCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<String>? name,
    Value<String?>? firstName,
    Value<String?>? lastName,
    Value<String?>? username,
    Value<String?>? email,
    Value<String?>? pinHash,
    Value<int>? role,
    Value<bool>? isEnabled,
    Value<DateTime>? lastModified,
  }) {
    return UsersTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      pinHash: pinHash ?? this.pinHash,
      role: role ?? this.role,
      isEnabled: isEnabled ?? this.isEnabled,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (role.present) {
      map['role'] = Variable<int>(role.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('username: $username, ')
          ..write('email: $email, ')
          ..write('pinHash: $pinHash, ')
          ..write('role: $role, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }
}

class $AppPropertiesTableTable extends AppPropertiesTable
    with TableInfo<$AppPropertiesTableTable, AppPropertiesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPropertiesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    value,
    lastModified,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_properties';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPropertiesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppPropertiesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPropertiesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $AppPropertiesTableTable createAlias(String alias) {
    return $AppPropertiesTableTable(attachedDatabase, alias);
  }
}

class AppPropertiesTableData extends DataClass
    implements Insertable<AppPropertiesTableData> {
  final int id;
  final int companyId;
  final String name;
  final String? value;
  final DateTime lastModified;

  /// 'synced' once the server has the current value; 'pending' after an offline
  /// edit so the sync engine knows to push it on reconnect.
  final String syncStatus;
  const AppPropertiesTableData({
    required this.id,
    required this.companyId,
    required this.name,
    this.value,
    required this.lastModified,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    map['last_modified'] = Variable<DateTime>(lastModified);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  AppPropertiesTableCompanion toCompanion(bool nullToAbsent) {
    return AppPropertiesTableCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      lastModified: Value(lastModified),
      syncStatus: Value(syncStatus),
    );
  }

  factory AppPropertiesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPropertiesTableData(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<String?>(json['value']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<String?>(value),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  AppPropertiesTableData copyWith({
    int? id,
    int? companyId,
    String? name,
    Value<String?> value = const Value.absent(),
    DateTime? lastModified,
    String? syncStatus,
  }) => AppPropertiesTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    value: value.present ? value.value : this.value,
    lastModified: lastModified ?? this.lastModified,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  AppPropertiesTableData copyWithCompanion(AppPropertiesTableCompanion data) {
    return AppPropertiesTableData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPropertiesTableData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, companyId, name, value, lastModified, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPropertiesTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.value == this.value &&
          other.lastModified == this.lastModified &&
          other.syncStatus == this.syncStatus);
}

class AppPropertiesTableCompanion
    extends UpdateCompanion<AppPropertiesTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String> name;
  final Value<String?> value;
  final Value<DateTime> lastModified;
  final Value<String> syncStatus;
  const AppPropertiesTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  AppPropertiesTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required String name,
    this.value = const Value.absent(),
    required DateTime lastModified,
    this.syncStatus = const Value.absent(),
  }) : companyId = Value(companyId),
       name = Value(name),
       lastModified = Value(lastModified);
  static Insertable<AppPropertiesTableData> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<String>? name,
    Expression<String>? value,
    Expression<DateTime>? lastModified,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (lastModified != null) 'last_modified': lastModified,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  AppPropertiesTableCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<String>? name,
    Value<String?>? value,
    Value<DateTime>? lastModified,
    Value<String>? syncStatus,
  }) {
    return AppPropertiesTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      value: value ?? this.value,
      lastModified: lastModified ?? this.lastModified,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPropertiesTableCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $ProductGroupsTableTable extends ProductGroupsTable
    with TableInfo<$ProductGroupsTableTable, ProductGroupsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductGroupsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentGroupIdMeta = const VerificationMeta(
    'parentGroupId',
  );
  @override
  late final GeneratedColumn<int> parentGroupId = GeneratedColumn<int>(
    'parent_group_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Transparent'),
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _localImagePathMeta = const VerificationMeta(
    'localImagePath',
  );
  @override
  late final GeneratedColumn<String> localImagePath = GeneratedColumn<String>(
    'local_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    parentGroupId,
    colorHex,
    rank,
    localImagePath,
    lastModified,
    syncStatus,
    syncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductGroupsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_group_id')) {
      context.handle(
        _parentGroupIdMeta,
        parentGroupId.isAcceptableOrUnknown(
          data['parent_group_id']!,
          _parentGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    }
    if (data.containsKey('local_image_path')) {
      context.handle(
        _localImagePathMeta,
        localImagePath.isAcceptableOrUnknown(
          data['local_image_path']!,
          _localImagePathMeta,
        ),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductGroupsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductGroupsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_group_id'],
      ),
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank'],
      )!,
      localImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_image_path'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
    );
  }

  @override
  $ProductGroupsTableTable createAlias(String alias) {
    return $ProductGroupsTableTable(attachedDatabase, alias);
  }
}

class ProductGroupsTableData extends DataClass
    implements Insertable<ProductGroupsTableData> {
  final int id;
  final int companyId;
  final String name;
  final int? parentGroupId;
  final String colorHex;
  final int rank;
  final String? localImagePath;
  final DateTime lastModified;
  final String syncStatus;
  final String? syncError;
  const ProductGroupsTableData({
    required this.id,
    required this.companyId,
    required this.name,
    this.parentGroupId,
    required this.colorHex,
    required this.rank,
    this.localImagePath,
    required this.lastModified,
    required this.syncStatus,
    this.syncError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentGroupId != null) {
      map['parent_group_id'] = Variable<int>(parentGroupId);
    }
    map['color_hex'] = Variable<String>(colorHex);
    map['rank'] = Variable<int>(rank);
    if (!nullToAbsent || localImagePath != null) {
      map['local_image_path'] = Variable<String>(localImagePath);
    }
    map['last_modified'] = Variable<DateTime>(lastModified);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  ProductGroupsTableCompanion toCompanion(bool nullToAbsent) {
    return ProductGroupsTableCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      parentGroupId: parentGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentGroupId),
      colorHex: Value(colorHex),
      rank: Value(rank),
      localImagePath: localImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localImagePath),
      lastModified: Value(lastModified),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory ProductGroupsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductGroupsTableData(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      parentGroupId: serializer.fromJson<int?>(json['parentGroupId']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      rank: serializer.fromJson<int>(json['rank']),
      localImagePath: serializer.fromJson<String?>(json['localImagePath']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'name': serializer.toJson<String>(name),
      'parentGroupId': serializer.toJson<int?>(parentGroupId),
      'colorHex': serializer.toJson<String>(colorHex),
      'rank': serializer.toJson<int>(rank),
      'localImagePath': serializer.toJson<String?>(localImagePath),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  ProductGroupsTableData copyWith({
    int? id,
    int? companyId,
    String? name,
    Value<int?> parentGroupId = const Value.absent(),
    String? colorHex,
    int? rank,
    Value<String?> localImagePath = const Value.absent(),
    DateTime? lastModified,
    String? syncStatus,
    Value<String?> syncError = const Value.absent(),
  }) => ProductGroupsTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    parentGroupId: parentGroupId.present
        ? parentGroupId.value
        : this.parentGroupId,
    colorHex: colorHex ?? this.colorHex,
    rank: rank ?? this.rank,
    localImagePath: localImagePath.present
        ? localImagePath.value
        : this.localImagePath,
    lastModified: lastModified ?? this.lastModified,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
  );
  ProductGroupsTableData copyWithCompanion(ProductGroupsTableCompanion data) {
    return ProductGroupsTableData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      parentGroupId: data.parentGroupId.present
          ? data.parentGroupId.value
          : this.parentGroupId,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      rank: data.rank.present ? data.rank.value : this.rank,
      localImagePath: data.localImagePath.present
          ? data.localImagePath.value
          : this.localImagePath,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductGroupsTableData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('parentGroupId: $parentGroupId, ')
          ..write('colorHex: $colorHex, ')
          ..write('rank: $rank, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    name,
    parentGroupId,
    colorHex,
    rank,
    localImagePath,
    lastModified,
    syncStatus,
    syncError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductGroupsTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.parentGroupId == this.parentGroupId &&
          other.colorHex == this.colorHex &&
          other.rank == this.rank &&
          other.localImagePath == this.localImagePath &&
          other.lastModified == this.lastModified &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError);
}

class ProductGroupsTableCompanion
    extends UpdateCompanion<ProductGroupsTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String> name;
  final Value<int?> parentGroupId;
  final Value<String> colorHex;
  final Value<int> rank;
  final Value<String?> localImagePath;
  final Value<DateTime> lastModified;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  const ProductGroupsTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.parentGroupId = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.rank = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
  });
  ProductGroupsTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required String name,
    this.parentGroupId = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.rank = const Value.absent(),
    this.localImagePath = const Value.absent(),
    required DateTime lastModified,
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
  }) : companyId = Value(companyId),
       name = Value(name),
       lastModified = Value(lastModified);
  static Insertable<ProductGroupsTableData> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<String>? name,
    Expression<int>? parentGroupId,
    Expression<String>? colorHex,
    Expression<int>? rank,
    Expression<String>? localImagePath,
    Expression<DateTime>? lastModified,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (parentGroupId != null) 'parent_group_id': parentGroupId,
      if (colorHex != null) 'color_hex': colorHex,
      if (rank != null) 'rank': rank,
      if (localImagePath != null) 'local_image_path': localImagePath,
      if (lastModified != null) 'last_modified': lastModified,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
    });
  }

  ProductGroupsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<String>? name,
    Value<int?>? parentGroupId,
    Value<String>? colorHex,
    Value<int>? rank,
    Value<String?>? localImagePath,
    Value<DateTime>? lastModified,
    Value<String>? syncStatus,
    Value<String?>? syncError,
  }) {
    return ProductGroupsTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      parentGroupId: parentGroupId ?? this.parentGroupId,
      colorHex: colorHex ?? this.colorHex,
      rank: rank ?? this.rank,
      localImagePath: localImagePath ?? this.localImagePath,
      lastModified: lastModified ?? this.lastModified,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentGroupId.present) {
      map['parent_group_id'] = Variable<int>(parentGroupId.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (localImagePath.present) {
      map['local_image_path'] = Variable<String>(localImagePath.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductGroupsTableCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('parentGroupId: $parentGroupId, ')
          ..write('colorHex: $colorHex, ')
          ..write('rank: $rank, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }
}

class $PaymentTypesTableTable extends PaymentTypesTable
    with TableInfo<$PaymentTypesTableTable, PaymentTypesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentTypesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCustomerRequiredMeta =
      const VerificationMeta('isCustomerRequired');
  @override
  late final GeneratedColumn<bool> isCustomerRequired = GeneratedColumn<bool>(
    'is_customer_required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_customer_required" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isFiscalMeta = const VerificationMeta(
    'isFiscal',
  );
  @override
  late final GeneratedColumn<bool> isFiscal = GeneratedColumn<bool>(
    'is_fiscal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_fiscal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSlipRequiredMeta = const VerificationMeta(
    'isSlipRequired',
  );
  @override
  late final GeneratedColumn<bool> isSlipRequired = GeneratedColumn<bool>(
    'is_slip_required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_slip_required" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isChangeAllowedMeta = const VerificationMeta(
    'isChangeAllowed',
  );
  @override
  late final GeneratedColumn<bool> isChangeAllowed = GeneratedColumn<bool>(
    'is_change_allowed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_change_allowed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isQuickPaymentMeta = const VerificationMeta(
    'isQuickPayment',
  );
  @override
  late final GeneratedColumn<bool> isQuickPayment = GeneratedColumn<bool>(
    'is_quick_payment',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_quick_payment" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _openCashDrawerMeta = const VerificationMeta(
    'openCashDrawer',
  );
  @override
  late final GeneratedColumn<bool> openCashDrawer = GeneratedColumn<bool>(
    'open_cash_drawer',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("open_cash_drawer" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _shortcutKeyMeta = const VerificationMeta(
    'shortcutKey',
  );
  @override
  late final GeneratedColumn<String> shortcutKey = GeneratedColumn<String>(
    'shortcut_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _markAsPaidMeta = const VerificationMeta(
    'markAsPaid',
  );
  @override
  late final GeneratedColumn<bool> markAsPaid = GeneratedColumn<bool>(
    'mark_as_paid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("mark_as_paid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    code,
    isCustomerRequired,
    isFiscal,
    isSlipRequired,
    isChangeAllowed,
    ordinal,
    isEnabled,
    isQuickPayment,
    openCashDrawer,
    shortcutKey,
    markAsPaid,
    lastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentTypesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('is_customer_required')) {
      context.handle(
        _isCustomerRequiredMeta,
        isCustomerRequired.isAcceptableOrUnknown(
          data['is_customer_required']!,
          _isCustomerRequiredMeta,
        ),
      );
    }
    if (data.containsKey('is_fiscal')) {
      context.handle(
        _isFiscalMeta,
        isFiscal.isAcceptableOrUnknown(data['is_fiscal']!, _isFiscalMeta),
      );
    }
    if (data.containsKey('is_slip_required')) {
      context.handle(
        _isSlipRequiredMeta,
        isSlipRequired.isAcceptableOrUnknown(
          data['is_slip_required']!,
          _isSlipRequiredMeta,
        ),
      );
    }
    if (data.containsKey('is_change_allowed')) {
      context.handle(
        _isChangeAllowedMeta,
        isChangeAllowed.isAcceptableOrUnknown(
          data['is_change_allowed']!,
          _isChangeAllowedMeta,
        ),
      );
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('is_quick_payment')) {
      context.handle(
        _isQuickPaymentMeta,
        isQuickPayment.isAcceptableOrUnknown(
          data['is_quick_payment']!,
          _isQuickPaymentMeta,
        ),
      );
    }
    if (data.containsKey('open_cash_drawer')) {
      context.handle(
        _openCashDrawerMeta,
        openCashDrawer.isAcceptableOrUnknown(
          data['open_cash_drawer']!,
          _openCashDrawerMeta,
        ),
      );
    }
    if (data.containsKey('shortcut_key')) {
      context.handle(
        _shortcutKeyMeta,
        shortcutKey.isAcceptableOrUnknown(
          data['shortcut_key']!,
          _shortcutKeyMeta,
        ),
      );
    }
    if (data.containsKey('mark_as_paid')) {
      context.handle(
        _markAsPaidMeta,
        markAsPaid.isAcceptableOrUnknown(
          data['mark_as_paid']!,
          _markAsPaidMeta,
        ),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentTypesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentTypesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      isCustomerRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_customer_required'],
      )!,
      isFiscal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_fiscal'],
      )!,
      isSlipRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_slip_required'],
      )!,
      isChangeAllowed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_change_allowed'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      isQuickPayment: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_quick_payment'],
      )!,
      openCashDrawer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}open_cash_drawer'],
      )!,
      shortcutKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shortcut_key'],
      ),
      markAsPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}mark_as_paid'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
    );
  }

  @override
  $PaymentTypesTableTable createAlias(String alias) {
    return $PaymentTypesTableTable(attachedDatabase, alias);
  }
}

class PaymentTypesTableData extends DataClass
    implements Insertable<PaymentTypesTableData> {
  final int id;
  final int companyId;
  final String name;
  final String? code;
  final bool isCustomerRequired;
  final bool isFiscal;
  final bool isSlipRequired;
  final bool isChangeAllowed;
  final int ordinal;
  final bool isEnabled;
  final bool isQuickPayment;
  final bool openCashDrawer;
  final String? shortcutKey;
  final bool markAsPaid;
  final DateTime lastModified;
  const PaymentTypesTableData({
    required this.id,
    required this.companyId,
    required this.name,
    this.code,
    required this.isCustomerRequired,
    required this.isFiscal,
    required this.isSlipRequired,
    required this.isChangeAllowed,
    required this.ordinal,
    required this.isEnabled,
    required this.isQuickPayment,
    required this.openCashDrawer,
    this.shortcutKey,
    required this.markAsPaid,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['is_customer_required'] = Variable<bool>(isCustomerRequired);
    map['is_fiscal'] = Variable<bool>(isFiscal);
    map['is_slip_required'] = Variable<bool>(isSlipRequired);
    map['is_change_allowed'] = Variable<bool>(isChangeAllowed);
    map['ordinal'] = Variable<int>(ordinal);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['is_quick_payment'] = Variable<bool>(isQuickPayment);
    map['open_cash_drawer'] = Variable<bool>(openCashDrawer);
    if (!nullToAbsent || shortcutKey != null) {
      map['shortcut_key'] = Variable<String>(shortcutKey);
    }
    map['mark_as_paid'] = Variable<bool>(markAsPaid);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  PaymentTypesTableCompanion toCompanion(bool nullToAbsent) {
    return PaymentTypesTableCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      isCustomerRequired: Value(isCustomerRequired),
      isFiscal: Value(isFiscal),
      isSlipRequired: Value(isSlipRequired),
      isChangeAllowed: Value(isChangeAllowed),
      ordinal: Value(ordinal),
      isEnabled: Value(isEnabled),
      isQuickPayment: Value(isQuickPayment),
      openCashDrawer: Value(openCashDrawer),
      shortcutKey: shortcutKey == null && nullToAbsent
          ? const Value.absent()
          : Value(shortcutKey),
      markAsPaid: Value(markAsPaid),
      lastModified: Value(lastModified),
    );
  }

  factory PaymentTypesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentTypesTableData(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String?>(json['code']),
      isCustomerRequired: serializer.fromJson<bool>(json['isCustomerRequired']),
      isFiscal: serializer.fromJson<bool>(json['isFiscal']),
      isSlipRequired: serializer.fromJson<bool>(json['isSlipRequired']),
      isChangeAllowed: serializer.fromJson<bool>(json['isChangeAllowed']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      isQuickPayment: serializer.fromJson<bool>(json['isQuickPayment']),
      openCashDrawer: serializer.fromJson<bool>(json['openCashDrawer']),
      shortcutKey: serializer.fromJson<String?>(json['shortcutKey']),
      markAsPaid: serializer.fromJson<bool>(json['markAsPaid']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String?>(code),
      'isCustomerRequired': serializer.toJson<bool>(isCustomerRequired),
      'isFiscal': serializer.toJson<bool>(isFiscal),
      'isSlipRequired': serializer.toJson<bool>(isSlipRequired),
      'isChangeAllowed': serializer.toJson<bool>(isChangeAllowed),
      'ordinal': serializer.toJson<int>(ordinal),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'isQuickPayment': serializer.toJson<bool>(isQuickPayment),
      'openCashDrawer': serializer.toJson<bool>(openCashDrawer),
      'shortcutKey': serializer.toJson<String?>(shortcutKey),
      'markAsPaid': serializer.toJson<bool>(markAsPaid),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  PaymentTypesTableData copyWith({
    int? id,
    int? companyId,
    String? name,
    Value<String?> code = const Value.absent(),
    bool? isCustomerRequired,
    bool? isFiscal,
    bool? isSlipRequired,
    bool? isChangeAllowed,
    int? ordinal,
    bool? isEnabled,
    bool? isQuickPayment,
    bool? openCashDrawer,
    Value<String?> shortcutKey = const Value.absent(),
    bool? markAsPaid,
    DateTime? lastModified,
  }) => PaymentTypesTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    code: code.present ? code.value : this.code,
    isCustomerRequired: isCustomerRequired ?? this.isCustomerRequired,
    isFiscal: isFiscal ?? this.isFiscal,
    isSlipRequired: isSlipRequired ?? this.isSlipRequired,
    isChangeAllowed: isChangeAllowed ?? this.isChangeAllowed,
    ordinal: ordinal ?? this.ordinal,
    isEnabled: isEnabled ?? this.isEnabled,
    isQuickPayment: isQuickPayment ?? this.isQuickPayment,
    openCashDrawer: openCashDrawer ?? this.openCashDrawer,
    shortcutKey: shortcutKey.present ? shortcutKey.value : this.shortcutKey,
    markAsPaid: markAsPaid ?? this.markAsPaid,
    lastModified: lastModified ?? this.lastModified,
  );
  PaymentTypesTableData copyWithCompanion(PaymentTypesTableCompanion data) {
    return PaymentTypesTableData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      isCustomerRequired: data.isCustomerRequired.present
          ? data.isCustomerRequired.value
          : this.isCustomerRequired,
      isFiscal: data.isFiscal.present ? data.isFiscal.value : this.isFiscal,
      isSlipRequired: data.isSlipRequired.present
          ? data.isSlipRequired.value
          : this.isSlipRequired,
      isChangeAllowed: data.isChangeAllowed.present
          ? data.isChangeAllowed.value
          : this.isChangeAllowed,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      isQuickPayment: data.isQuickPayment.present
          ? data.isQuickPayment.value
          : this.isQuickPayment,
      openCashDrawer: data.openCashDrawer.present
          ? data.openCashDrawer.value
          : this.openCashDrawer,
      shortcutKey: data.shortcutKey.present
          ? data.shortcutKey.value
          : this.shortcutKey,
      markAsPaid: data.markAsPaid.present
          ? data.markAsPaid.value
          : this.markAsPaid,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentTypesTableData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('isCustomerRequired: $isCustomerRequired, ')
          ..write('isFiscal: $isFiscal, ')
          ..write('isSlipRequired: $isSlipRequired, ')
          ..write('isChangeAllowed: $isChangeAllowed, ')
          ..write('ordinal: $ordinal, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('isQuickPayment: $isQuickPayment, ')
          ..write('openCashDrawer: $openCashDrawer, ')
          ..write('shortcutKey: $shortcutKey, ')
          ..write('markAsPaid: $markAsPaid, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    name,
    code,
    isCustomerRequired,
    isFiscal,
    isSlipRequired,
    isChangeAllowed,
    ordinal,
    isEnabled,
    isQuickPayment,
    openCashDrawer,
    shortcutKey,
    markAsPaid,
    lastModified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentTypesTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.code == this.code &&
          other.isCustomerRequired == this.isCustomerRequired &&
          other.isFiscal == this.isFiscal &&
          other.isSlipRequired == this.isSlipRequired &&
          other.isChangeAllowed == this.isChangeAllowed &&
          other.ordinal == this.ordinal &&
          other.isEnabled == this.isEnabled &&
          other.isQuickPayment == this.isQuickPayment &&
          other.openCashDrawer == this.openCashDrawer &&
          other.shortcutKey == this.shortcutKey &&
          other.markAsPaid == this.markAsPaid &&
          other.lastModified == this.lastModified);
}

class PaymentTypesTableCompanion
    extends UpdateCompanion<PaymentTypesTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String> name;
  final Value<String?> code;
  final Value<bool> isCustomerRequired;
  final Value<bool> isFiscal;
  final Value<bool> isSlipRequired;
  final Value<bool> isChangeAllowed;
  final Value<int> ordinal;
  final Value<bool> isEnabled;
  final Value<bool> isQuickPayment;
  final Value<bool> openCashDrawer;
  final Value<String?> shortcutKey;
  final Value<bool> markAsPaid;
  final Value<DateTime> lastModified;
  const PaymentTypesTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.isCustomerRequired = const Value.absent(),
    this.isFiscal = const Value.absent(),
    this.isSlipRequired = const Value.absent(),
    this.isChangeAllowed = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.isQuickPayment = const Value.absent(),
    this.openCashDrawer = const Value.absent(),
    this.shortcutKey = const Value.absent(),
    this.markAsPaid = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  PaymentTypesTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required String name,
    this.code = const Value.absent(),
    this.isCustomerRequired = const Value.absent(),
    this.isFiscal = const Value.absent(),
    this.isSlipRequired = const Value.absent(),
    this.isChangeAllowed = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.isQuickPayment = const Value.absent(),
    this.openCashDrawer = const Value.absent(),
    this.shortcutKey = const Value.absent(),
    this.markAsPaid = const Value.absent(),
    required DateTime lastModified,
  }) : companyId = Value(companyId),
       name = Value(name),
       lastModified = Value(lastModified);
  static Insertable<PaymentTypesTableData> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<String>? name,
    Expression<String>? code,
    Expression<bool>? isCustomerRequired,
    Expression<bool>? isFiscal,
    Expression<bool>? isSlipRequired,
    Expression<bool>? isChangeAllowed,
    Expression<int>? ordinal,
    Expression<bool>? isEnabled,
    Expression<bool>? isQuickPayment,
    Expression<bool>? openCashDrawer,
    Expression<String>? shortcutKey,
    Expression<bool>? markAsPaid,
    Expression<DateTime>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (isCustomerRequired != null)
        'is_customer_required': isCustomerRequired,
      if (isFiscal != null) 'is_fiscal': isFiscal,
      if (isSlipRequired != null) 'is_slip_required': isSlipRequired,
      if (isChangeAllowed != null) 'is_change_allowed': isChangeAllowed,
      if (ordinal != null) 'ordinal': ordinal,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (isQuickPayment != null) 'is_quick_payment': isQuickPayment,
      if (openCashDrawer != null) 'open_cash_drawer': openCashDrawer,
      if (shortcutKey != null) 'shortcut_key': shortcutKey,
      if (markAsPaid != null) 'mark_as_paid': markAsPaid,
      if (lastModified != null) 'last_modified': lastModified,
    });
  }

  PaymentTypesTableCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<String>? name,
    Value<String?>? code,
    Value<bool>? isCustomerRequired,
    Value<bool>? isFiscal,
    Value<bool>? isSlipRequired,
    Value<bool>? isChangeAllowed,
    Value<int>? ordinal,
    Value<bool>? isEnabled,
    Value<bool>? isQuickPayment,
    Value<bool>? openCashDrawer,
    Value<String?>? shortcutKey,
    Value<bool>? markAsPaid,
    Value<DateTime>? lastModified,
  }) {
    return PaymentTypesTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      code: code ?? this.code,
      isCustomerRequired: isCustomerRequired ?? this.isCustomerRequired,
      isFiscal: isFiscal ?? this.isFiscal,
      isSlipRequired: isSlipRequired ?? this.isSlipRequired,
      isChangeAllowed: isChangeAllowed ?? this.isChangeAllowed,
      ordinal: ordinal ?? this.ordinal,
      isEnabled: isEnabled ?? this.isEnabled,
      isQuickPayment: isQuickPayment ?? this.isQuickPayment,
      openCashDrawer: openCashDrawer ?? this.openCashDrawer,
      shortcutKey: shortcutKey ?? this.shortcutKey,
      markAsPaid: markAsPaid ?? this.markAsPaid,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (isCustomerRequired.present) {
      map['is_customer_required'] = Variable<bool>(isCustomerRequired.value);
    }
    if (isFiscal.present) {
      map['is_fiscal'] = Variable<bool>(isFiscal.value);
    }
    if (isSlipRequired.present) {
      map['is_slip_required'] = Variable<bool>(isSlipRequired.value);
    }
    if (isChangeAllowed.present) {
      map['is_change_allowed'] = Variable<bool>(isChangeAllowed.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (isQuickPayment.present) {
      map['is_quick_payment'] = Variable<bool>(isQuickPayment.value);
    }
    if (openCashDrawer.present) {
      map['open_cash_drawer'] = Variable<bool>(openCashDrawer.value);
    }
    if (shortcutKey.present) {
      map['shortcut_key'] = Variable<String>(shortcutKey.value);
    }
    if (markAsPaid.present) {
      map['mark_as_paid'] = Variable<bool>(markAsPaid.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentTypesTableCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('isCustomerRequired: $isCustomerRequired, ')
          ..write('isFiscal: $isFiscal, ')
          ..write('isSlipRequired: $isSlipRequired, ')
          ..write('isChangeAllowed: $isChangeAllowed, ')
          ..write('ordinal: $ordinal, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('isQuickPayment: $isQuickPayment, ')
          ..write('openCashDrawer: $openCashDrawer, ')
          ..write('shortcutKey: $shortcutKey, ')
          ..write('markAsPaid: $markAsPaid, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }
}

class $CustomersTableTable extends CustomersTable
    with TableInfo<$CustomersTableTable, CustomersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxNumberMeta = const VerificationMeta(
    'taxNumber',
  );
  @override
  late final GeneratedColumn<String> taxNumber = GeneratedColumn<String>(
    'tax_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postalCodeMeta = const VerificationMeta(
    'postalCode',
  );
  @override
  late final GeneratedColumn<String> postalCode = GeneratedColumn<String>(
    'postal_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryIdMeta = const VerificationMeta(
    'countryId',
  );
  @override
  late final GeneratedColumn<int> countryId = GeneratedColumn<int>(
    'country_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isCustomerMeta = const VerificationMeta(
    'isCustomer',
  );
  @override
  late final GeneratedColumn<bool> isCustomer = GeneratedColumn<bool>(
    'is_customer',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_customer" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isSupplierMeta = const VerificationMeta(
    'isSupplier',
  );
  @override
  late final GeneratedColumn<bool> isSupplier = GeneratedColumn<bool>(
    'is_supplier',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_supplier" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dueDatePeriodMeta = const VerificationMeta(
    'dueDatePeriod',
  );
  @override
  late final GeneratedColumn<int> dueDatePeriod = GeneratedColumn<int>(
    'due_date_period',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _streetNameMeta = const VerificationMeta(
    'streetName',
  );
  @override
  late final GeneratedColumn<String> streetName = GeneratedColumn<String>(
    'street_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _additionalStreetNameMeta =
      const VerificationMeta('additionalStreetName');
  @override
  late final GeneratedColumn<String> additionalStreetName =
      GeneratedColumn<String>(
        'additional_street_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _buildingNumberMeta = const VerificationMeta(
    'buildingNumber',
  );
  @override
  late final GeneratedColumn<String> buildingNumber = GeneratedColumn<String>(
    'building_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plotIdentificationMeta =
      const VerificationMeta('plotIdentification');
  @override
  late final GeneratedColumn<String> plotIdentification =
      GeneratedColumn<String>(
        'plot_identification',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _citySubdivisionNameMeta =
      const VerificationMeta('citySubdivisionName');
  @override
  late final GeneratedColumn<String> citySubdivisionName =
      GeneratedColumn<String>(
        'city_subdivision_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isTaxExemptMeta = const VerificationMeta(
    'isTaxExempt',
  );
  @override
  late final GeneratedColumn<bool> isTaxExempt = GeneratedColumn<bool>(
    'is_tax_exempt',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_tax_exempt" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    code,
    name,
    taxNumber,
    address,
    postalCode,
    city,
    countryId,
    email,
    phoneNumber,
    isEnabled,
    isCustomer,
    isSupplier,
    dueDatePeriod,
    streetName,
    additionalStreetName,
    buildingNumber,
    plotIdentification,
    citySubdivisionName,
    isTaxExempt,
    lastModified,
    syncStatus,
    syncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('tax_number')) {
      context.handle(
        _taxNumberMeta,
        taxNumber.isAcceptableOrUnknown(data['tax_number']!, _taxNumberMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('postal_code')) {
      context.handle(
        _postalCodeMeta,
        postalCode.isAcceptableOrUnknown(data['postal_code']!, _postalCodeMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('country_id')) {
      context.handle(
        _countryIdMeta,
        countryId.isAcceptableOrUnknown(data['country_id']!, _countryIdMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('is_customer')) {
      context.handle(
        _isCustomerMeta,
        isCustomer.isAcceptableOrUnknown(data['is_customer']!, _isCustomerMeta),
      );
    }
    if (data.containsKey('is_supplier')) {
      context.handle(
        _isSupplierMeta,
        isSupplier.isAcceptableOrUnknown(data['is_supplier']!, _isSupplierMeta),
      );
    }
    if (data.containsKey('due_date_period')) {
      context.handle(
        _dueDatePeriodMeta,
        dueDatePeriod.isAcceptableOrUnknown(
          data['due_date_period']!,
          _dueDatePeriodMeta,
        ),
      );
    }
    if (data.containsKey('street_name')) {
      context.handle(
        _streetNameMeta,
        streetName.isAcceptableOrUnknown(data['street_name']!, _streetNameMeta),
      );
    }
    if (data.containsKey('additional_street_name')) {
      context.handle(
        _additionalStreetNameMeta,
        additionalStreetName.isAcceptableOrUnknown(
          data['additional_street_name']!,
          _additionalStreetNameMeta,
        ),
      );
    }
    if (data.containsKey('building_number')) {
      context.handle(
        _buildingNumberMeta,
        buildingNumber.isAcceptableOrUnknown(
          data['building_number']!,
          _buildingNumberMeta,
        ),
      );
    }
    if (data.containsKey('plot_identification')) {
      context.handle(
        _plotIdentificationMeta,
        plotIdentification.isAcceptableOrUnknown(
          data['plot_identification']!,
          _plotIdentificationMeta,
        ),
      );
    }
    if (data.containsKey('city_subdivision_name')) {
      context.handle(
        _citySubdivisionNameMeta,
        citySubdivisionName.isAcceptableOrUnknown(
          data['city_subdivision_name']!,
          _citySubdivisionNameMeta,
        ),
      );
    }
    if (data.containsKey('is_tax_exempt')) {
      context.handle(
        _isTaxExemptMeta,
        isTaxExempt.isAcceptableOrUnknown(
          data['is_tax_exempt']!,
          _isTaxExemptMeta,
        ),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomersTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      taxNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_number'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      postalCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postal_code'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      countryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}country_id'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      isCustomer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_customer'],
      )!,
      isSupplier: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_supplier'],
      )!,
      dueDatePeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_date_period'],
      ),
      streetName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}street_name'],
      ),
      additionalStreetName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}additional_street_name'],
      ),
      buildingNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}building_number'],
      ),
      plotIdentification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plot_identification'],
      ),
      citySubdivisionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_subdivision_name'],
      ),
      isTaxExempt: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_tax_exempt'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
    );
  }

  @override
  $CustomersTableTable createAlias(String alias) {
    return $CustomersTableTable(attachedDatabase, alias);
  }
}

class CustomersTableData extends DataClass
    implements Insertable<CustomersTableData> {
  final int id;
  final int companyId;
  final String? code;
  final String name;
  final String? taxNumber;
  final String? address;
  final String? postalCode;
  final String? city;
  final int? countryId;
  final String? email;
  final String? phoneNumber;
  final bool isEnabled;
  final bool isCustomer;
  final bool isSupplier;
  final int? dueDatePeriod;
  final String? streetName;
  final String? additionalStreetName;
  final String? buildingNumber;
  final String? plotIdentification;
  final String? citySubdivisionName;
  final bool isTaxExempt;
  final DateTime lastModified;
  final String syncStatus;
  final String? syncError;
  const CustomersTableData({
    required this.id,
    required this.companyId,
    this.code,
    required this.name,
    this.taxNumber,
    this.address,
    this.postalCode,
    this.city,
    this.countryId,
    this.email,
    this.phoneNumber,
    required this.isEnabled,
    required this.isCustomer,
    required this.isSupplier,
    this.dueDatePeriod,
    this.streetName,
    this.additionalStreetName,
    this.buildingNumber,
    this.plotIdentification,
    this.citySubdivisionName,
    required this.isTaxExempt,
    required this.lastModified,
    required this.syncStatus,
    this.syncError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || taxNumber != null) {
      map['tax_number'] = Variable<String>(taxNumber);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || postalCode != null) {
      map['postal_code'] = Variable<String>(postalCode);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || countryId != null) {
      map['country_id'] = Variable<int>(countryId);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['is_customer'] = Variable<bool>(isCustomer);
    map['is_supplier'] = Variable<bool>(isSupplier);
    if (!nullToAbsent || dueDatePeriod != null) {
      map['due_date_period'] = Variable<int>(dueDatePeriod);
    }
    if (!nullToAbsent || streetName != null) {
      map['street_name'] = Variable<String>(streetName);
    }
    if (!nullToAbsent || additionalStreetName != null) {
      map['additional_street_name'] = Variable<String>(additionalStreetName);
    }
    if (!nullToAbsent || buildingNumber != null) {
      map['building_number'] = Variable<String>(buildingNumber);
    }
    if (!nullToAbsent || plotIdentification != null) {
      map['plot_identification'] = Variable<String>(plotIdentification);
    }
    if (!nullToAbsent || citySubdivisionName != null) {
      map['city_subdivision_name'] = Variable<String>(citySubdivisionName);
    }
    map['is_tax_exempt'] = Variable<bool>(isTaxExempt);
    map['last_modified'] = Variable<DateTime>(lastModified);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  CustomersTableCompanion toCompanion(bool nullToAbsent) {
    return CustomersTableCompanion(
      id: Value(id),
      companyId: Value(companyId),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      name: Value(name),
      taxNumber: taxNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(taxNumber),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      postalCode: postalCode == null && nullToAbsent
          ? const Value.absent()
          : Value(postalCode),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      countryId: countryId == null && nullToAbsent
          ? const Value.absent()
          : Value(countryId),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      isEnabled: Value(isEnabled),
      isCustomer: Value(isCustomer),
      isSupplier: Value(isSupplier),
      dueDatePeriod: dueDatePeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDatePeriod),
      streetName: streetName == null && nullToAbsent
          ? const Value.absent()
          : Value(streetName),
      additionalStreetName: additionalStreetName == null && nullToAbsent
          ? const Value.absent()
          : Value(additionalStreetName),
      buildingNumber: buildingNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(buildingNumber),
      plotIdentification: plotIdentification == null && nullToAbsent
          ? const Value.absent()
          : Value(plotIdentification),
      citySubdivisionName: citySubdivisionName == null && nullToAbsent
          ? const Value.absent()
          : Value(citySubdivisionName),
      isTaxExempt: Value(isTaxExempt),
      lastModified: Value(lastModified),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory CustomersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomersTableData(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      code: serializer.fromJson<String?>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      taxNumber: serializer.fromJson<String?>(json['taxNumber']),
      address: serializer.fromJson<String?>(json['address']),
      postalCode: serializer.fromJson<String?>(json['postalCode']),
      city: serializer.fromJson<String?>(json['city']),
      countryId: serializer.fromJson<int?>(json['countryId']),
      email: serializer.fromJson<String?>(json['email']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      isCustomer: serializer.fromJson<bool>(json['isCustomer']),
      isSupplier: serializer.fromJson<bool>(json['isSupplier']),
      dueDatePeriod: serializer.fromJson<int?>(json['dueDatePeriod']),
      streetName: serializer.fromJson<String?>(json['streetName']),
      additionalStreetName: serializer.fromJson<String?>(
        json['additionalStreetName'],
      ),
      buildingNumber: serializer.fromJson<String?>(json['buildingNumber']),
      plotIdentification: serializer.fromJson<String?>(
        json['plotIdentification'],
      ),
      citySubdivisionName: serializer.fromJson<String?>(
        json['citySubdivisionName'],
      ),
      isTaxExempt: serializer.fromJson<bool>(json['isTaxExempt']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'code': serializer.toJson<String?>(code),
      'name': serializer.toJson<String>(name),
      'taxNumber': serializer.toJson<String?>(taxNumber),
      'address': serializer.toJson<String?>(address),
      'postalCode': serializer.toJson<String?>(postalCode),
      'city': serializer.toJson<String?>(city),
      'countryId': serializer.toJson<int?>(countryId),
      'email': serializer.toJson<String?>(email),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'isCustomer': serializer.toJson<bool>(isCustomer),
      'isSupplier': serializer.toJson<bool>(isSupplier),
      'dueDatePeriod': serializer.toJson<int?>(dueDatePeriod),
      'streetName': serializer.toJson<String?>(streetName),
      'additionalStreetName': serializer.toJson<String?>(additionalStreetName),
      'buildingNumber': serializer.toJson<String?>(buildingNumber),
      'plotIdentification': serializer.toJson<String?>(plotIdentification),
      'citySubdivisionName': serializer.toJson<String?>(citySubdivisionName),
      'isTaxExempt': serializer.toJson<bool>(isTaxExempt),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  CustomersTableData copyWith({
    int? id,
    int? companyId,
    Value<String?> code = const Value.absent(),
    String? name,
    Value<String?> taxNumber = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> postalCode = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<int?> countryId = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phoneNumber = const Value.absent(),
    bool? isEnabled,
    bool? isCustomer,
    bool? isSupplier,
    Value<int?> dueDatePeriod = const Value.absent(),
    Value<String?> streetName = const Value.absent(),
    Value<String?> additionalStreetName = const Value.absent(),
    Value<String?> buildingNumber = const Value.absent(),
    Value<String?> plotIdentification = const Value.absent(),
    Value<String?> citySubdivisionName = const Value.absent(),
    bool? isTaxExempt,
    DateTime? lastModified,
    String? syncStatus,
    Value<String?> syncError = const Value.absent(),
  }) => CustomersTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    code: code.present ? code.value : this.code,
    name: name ?? this.name,
    taxNumber: taxNumber.present ? taxNumber.value : this.taxNumber,
    address: address.present ? address.value : this.address,
    postalCode: postalCode.present ? postalCode.value : this.postalCode,
    city: city.present ? city.value : this.city,
    countryId: countryId.present ? countryId.value : this.countryId,
    email: email.present ? email.value : this.email,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    isEnabled: isEnabled ?? this.isEnabled,
    isCustomer: isCustomer ?? this.isCustomer,
    isSupplier: isSupplier ?? this.isSupplier,
    dueDatePeriod: dueDatePeriod.present
        ? dueDatePeriod.value
        : this.dueDatePeriod,
    streetName: streetName.present ? streetName.value : this.streetName,
    additionalStreetName: additionalStreetName.present
        ? additionalStreetName.value
        : this.additionalStreetName,
    buildingNumber: buildingNumber.present
        ? buildingNumber.value
        : this.buildingNumber,
    plotIdentification: plotIdentification.present
        ? plotIdentification.value
        : this.plotIdentification,
    citySubdivisionName: citySubdivisionName.present
        ? citySubdivisionName.value
        : this.citySubdivisionName,
    isTaxExempt: isTaxExempt ?? this.isTaxExempt,
    lastModified: lastModified ?? this.lastModified,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
  );
  CustomersTableData copyWithCompanion(CustomersTableCompanion data) {
    return CustomersTableData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      taxNumber: data.taxNumber.present ? data.taxNumber.value : this.taxNumber,
      address: data.address.present ? data.address.value : this.address,
      postalCode: data.postalCode.present
          ? data.postalCode.value
          : this.postalCode,
      city: data.city.present ? data.city.value : this.city,
      countryId: data.countryId.present ? data.countryId.value : this.countryId,
      email: data.email.present ? data.email.value : this.email,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      isCustomer: data.isCustomer.present
          ? data.isCustomer.value
          : this.isCustomer,
      isSupplier: data.isSupplier.present
          ? data.isSupplier.value
          : this.isSupplier,
      dueDatePeriod: data.dueDatePeriod.present
          ? data.dueDatePeriod.value
          : this.dueDatePeriod,
      streetName: data.streetName.present
          ? data.streetName.value
          : this.streetName,
      additionalStreetName: data.additionalStreetName.present
          ? data.additionalStreetName.value
          : this.additionalStreetName,
      buildingNumber: data.buildingNumber.present
          ? data.buildingNumber.value
          : this.buildingNumber,
      plotIdentification: data.plotIdentification.present
          ? data.plotIdentification.value
          : this.plotIdentification,
      citySubdivisionName: data.citySubdivisionName.present
          ? data.citySubdivisionName.value
          : this.citySubdivisionName,
      isTaxExempt: data.isTaxExempt.present
          ? data.isTaxExempt.value
          : this.isTaxExempt,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomersTableData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('taxNumber: $taxNumber, ')
          ..write('address: $address, ')
          ..write('postalCode: $postalCode, ')
          ..write('city: $city, ')
          ..write('countryId: $countryId, ')
          ..write('email: $email, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('isCustomer: $isCustomer, ')
          ..write('isSupplier: $isSupplier, ')
          ..write('dueDatePeriod: $dueDatePeriod, ')
          ..write('streetName: $streetName, ')
          ..write('additionalStreetName: $additionalStreetName, ')
          ..write('buildingNumber: $buildingNumber, ')
          ..write('plotIdentification: $plotIdentification, ')
          ..write('citySubdivisionName: $citySubdivisionName, ')
          ..write('isTaxExempt: $isTaxExempt, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    companyId,
    code,
    name,
    taxNumber,
    address,
    postalCode,
    city,
    countryId,
    email,
    phoneNumber,
    isEnabled,
    isCustomer,
    isSupplier,
    dueDatePeriod,
    streetName,
    additionalStreetName,
    buildingNumber,
    plotIdentification,
    citySubdivisionName,
    isTaxExempt,
    lastModified,
    syncStatus,
    syncError,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomersTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.code == this.code &&
          other.name == this.name &&
          other.taxNumber == this.taxNumber &&
          other.address == this.address &&
          other.postalCode == this.postalCode &&
          other.city == this.city &&
          other.countryId == this.countryId &&
          other.email == this.email &&
          other.phoneNumber == this.phoneNumber &&
          other.isEnabled == this.isEnabled &&
          other.isCustomer == this.isCustomer &&
          other.isSupplier == this.isSupplier &&
          other.dueDatePeriod == this.dueDatePeriod &&
          other.streetName == this.streetName &&
          other.additionalStreetName == this.additionalStreetName &&
          other.buildingNumber == this.buildingNumber &&
          other.plotIdentification == this.plotIdentification &&
          other.citySubdivisionName == this.citySubdivisionName &&
          other.isTaxExempt == this.isTaxExempt &&
          other.lastModified == this.lastModified &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError);
}

class CustomersTableCompanion extends UpdateCompanion<CustomersTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String?> code;
  final Value<String> name;
  final Value<String?> taxNumber;
  final Value<String?> address;
  final Value<String?> postalCode;
  final Value<String?> city;
  final Value<int?> countryId;
  final Value<String?> email;
  final Value<String?> phoneNumber;
  final Value<bool> isEnabled;
  final Value<bool> isCustomer;
  final Value<bool> isSupplier;
  final Value<int?> dueDatePeriod;
  final Value<String?> streetName;
  final Value<String?> additionalStreetName;
  final Value<String?> buildingNumber;
  final Value<String?> plotIdentification;
  final Value<String?> citySubdivisionName;
  final Value<bool> isTaxExempt;
  final Value<DateTime> lastModified;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  const CustomersTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.taxNumber = const Value.absent(),
    this.address = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.city = const Value.absent(),
    this.countryId = const Value.absent(),
    this.email = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.isCustomer = const Value.absent(),
    this.isSupplier = const Value.absent(),
    this.dueDatePeriod = const Value.absent(),
    this.streetName = const Value.absent(),
    this.additionalStreetName = const Value.absent(),
    this.buildingNumber = const Value.absent(),
    this.plotIdentification = const Value.absent(),
    this.citySubdivisionName = const Value.absent(),
    this.isTaxExempt = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
  });
  CustomersTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    this.code = const Value.absent(),
    required String name,
    this.taxNumber = const Value.absent(),
    this.address = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.city = const Value.absent(),
    this.countryId = const Value.absent(),
    this.email = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.isCustomer = const Value.absent(),
    this.isSupplier = const Value.absent(),
    this.dueDatePeriod = const Value.absent(),
    this.streetName = const Value.absent(),
    this.additionalStreetName = const Value.absent(),
    this.buildingNumber = const Value.absent(),
    this.plotIdentification = const Value.absent(),
    this.citySubdivisionName = const Value.absent(),
    this.isTaxExempt = const Value.absent(),
    required DateTime lastModified,
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
  }) : companyId = Value(companyId),
       name = Value(name),
       lastModified = Value(lastModified);
  static Insertable<CustomersTableData> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? taxNumber,
    Expression<String>? address,
    Expression<String>? postalCode,
    Expression<String>? city,
    Expression<int>? countryId,
    Expression<String>? email,
    Expression<String>? phoneNumber,
    Expression<bool>? isEnabled,
    Expression<bool>? isCustomer,
    Expression<bool>? isSupplier,
    Expression<int>? dueDatePeriod,
    Expression<String>? streetName,
    Expression<String>? additionalStreetName,
    Expression<String>? buildingNumber,
    Expression<String>? plotIdentification,
    Expression<String>? citySubdivisionName,
    Expression<bool>? isTaxExempt,
    Expression<DateTime>? lastModified,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (taxNumber != null) 'tax_number': taxNumber,
      if (address != null) 'address': address,
      if (postalCode != null) 'postal_code': postalCode,
      if (city != null) 'city': city,
      if (countryId != null) 'country_id': countryId,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (isCustomer != null) 'is_customer': isCustomer,
      if (isSupplier != null) 'is_supplier': isSupplier,
      if (dueDatePeriod != null) 'due_date_period': dueDatePeriod,
      if (streetName != null) 'street_name': streetName,
      if (additionalStreetName != null)
        'additional_street_name': additionalStreetName,
      if (buildingNumber != null) 'building_number': buildingNumber,
      if (plotIdentification != null) 'plot_identification': plotIdentification,
      if (citySubdivisionName != null)
        'city_subdivision_name': citySubdivisionName,
      if (isTaxExempt != null) 'is_tax_exempt': isTaxExempt,
      if (lastModified != null) 'last_modified': lastModified,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
    });
  }

  CustomersTableCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<String?>? code,
    Value<String>? name,
    Value<String?>? taxNumber,
    Value<String?>? address,
    Value<String?>? postalCode,
    Value<String?>? city,
    Value<int?>? countryId,
    Value<String?>? email,
    Value<String?>? phoneNumber,
    Value<bool>? isEnabled,
    Value<bool>? isCustomer,
    Value<bool>? isSupplier,
    Value<int?>? dueDatePeriod,
    Value<String?>? streetName,
    Value<String?>? additionalStreetName,
    Value<String?>? buildingNumber,
    Value<String?>? plotIdentification,
    Value<String?>? citySubdivisionName,
    Value<bool>? isTaxExempt,
    Value<DateTime>? lastModified,
    Value<String>? syncStatus,
    Value<String?>? syncError,
  }) {
    return CustomersTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      code: code ?? this.code,
      name: name ?? this.name,
      taxNumber: taxNumber ?? this.taxNumber,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      countryId: countryId ?? this.countryId,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEnabled: isEnabled ?? this.isEnabled,
      isCustomer: isCustomer ?? this.isCustomer,
      isSupplier: isSupplier ?? this.isSupplier,
      dueDatePeriod: dueDatePeriod ?? this.dueDatePeriod,
      streetName: streetName ?? this.streetName,
      additionalStreetName: additionalStreetName ?? this.additionalStreetName,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      plotIdentification: plotIdentification ?? this.plotIdentification,
      citySubdivisionName: citySubdivisionName ?? this.citySubdivisionName,
      isTaxExempt: isTaxExempt ?? this.isTaxExempt,
      lastModified: lastModified ?? this.lastModified,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (taxNumber.present) {
      map['tax_number'] = Variable<String>(taxNumber.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (postalCode.present) {
      map['postal_code'] = Variable<String>(postalCode.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (countryId.present) {
      map['country_id'] = Variable<int>(countryId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (isCustomer.present) {
      map['is_customer'] = Variable<bool>(isCustomer.value);
    }
    if (isSupplier.present) {
      map['is_supplier'] = Variable<bool>(isSupplier.value);
    }
    if (dueDatePeriod.present) {
      map['due_date_period'] = Variable<int>(dueDatePeriod.value);
    }
    if (streetName.present) {
      map['street_name'] = Variable<String>(streetName.value);
    }
    if (additionalStreetName.present) {
      map['additional_street_name'] = Variable<String>(
        additionalStreetName.value,
      );
    }
    if (buildingNumber.present) {
      map['building_number'] = Variable<String>(buildingNumber.value);
    }
    if (plotIdentification.present) {
      map['plot_identification'] = Variable<String>(plotIdentification.value);
    }
    if (citySubdivisionName.present) {
      map['city_subdivision_name'] = Variable<String>(
        citySubdivisionName.value,
      );
    }
    if (isTaxExempt.present) {
      map['is_tax_exempt'] = Variable<bool>(isTaxExempt.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersTableCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('taxNumber: $taxNumber, ')
          ..write('address: $address, ')
          ..write('postalCode: $postalCode, ')
          ..write('city: $city, ')
          ..write('countryId: $countryId, ')
          ..write('email: $email, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('isCustomer: $isCustomer, ')
          ..write('isSupplier: $isSupplier, ')
          ..write('dueDatePeriod: $dueDatePeriod, ')
          ..write('streetName: $streetName, ')
          ..write('additionalStreetName: $additionalStreetName, ')
          ..write('buildingNumber: $buildingNumber, ')
          ..write('plotIdentification: $plotIdentification, ')
          ..write('citySubdivisionName: $citySubdivisionName, ')
          ..write('isTaxExempt: $isTaxExempt, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }
}

class $PromotionsTableTable extends PromotionsTable
    with TableInfo<$PromotionsTableTable, PromotionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromotionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysOfWeekMeta = const VerificationMeta(
    'daysOfWeek',
  );
  @override
  late final GeneratedColumn<int> daysOfWeek = GeneratedColumn<int>(
    'days_of_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(127),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    daysOfWeek,
    isEnabled,
    startDate,
    startTime,
    endDate,
    endTime,
    lastModified,
    syncStatus,
    syncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'promotions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PromotionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('days_of_week')) {
      context.handle(
        _daysOfWeekMeta,
        daysOfWeek.isAcceptableOrUnknown(
          data['days_of_week']!,
          _daysOfWeekMeta,
        ),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PromotionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PromotionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      daysOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_of_week'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
    );
  }

  @override
  $PromotionsTableTable createAlias(String alias) {
    return $PromotionsTableTable(attachedDatabase, alias);
  }
}

class PromotionsTableData extends DataClass
    implements Insertable<PromotionsTableData> {
  final int id;
  final int companyId;
  final String name;
  final int daysOfWeek;
  final bool isEnabled;
  final DateTime? startDate;
  final String? startTime;
  final DateTime? endDate;
  final String? endTime;
  final DateTime lastModified;
  final String syncStatus;
  final String? syncError;
  const PromotionsTableData({
    required this.id,
    required this.companyId,
    required this.name,
    required this.daysOfWeek,
    required this.isEnabled,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    required this.lastModified,
    required this.syncStatus,
    this.syncError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['name'] = Variable<String>(name);
    map['days_of_week'] = Variable<int>(daysOfWeek);
    map['is_enabled'] = Variable<bool>(isEnabled);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<String>(startTime);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<String>(endTime);
    }
    map['last_modified'] = Variable<DateTime>(lastModified);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  PromotionsTableCompanion toCompanion(bool nullToAbsent) {
    return PromotionsTableCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      daysOfWeek: Value(daysOfWeek),
      isEnabled: Value(isEnabled),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      lastModified: Value(lastModified),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory PromotionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PromotionsTableData(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      daysOfWeek: serializer.fromJson<int>(json['daysOfWeek']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      startTime: serializer.fromJson<String?>(json['startTime']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      endTime: serializer.fromJson<String?>(json['endTime']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'name': serializer.toJson<String>(name),
      'daysOfWeek': serializer.toJson<int>(daysOfWeek),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'startTime': serializer.toJson<String?>(startTime),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'endTime': serializer.toJson<String?>(endTime),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  PromotionsTableData copyWith({
    int? id,
    int? companyId,
    String? name,
    int? daysOfWeek,
    bool? isEnabled,
    Value<DateTime?> startDate = const Value.absent(),
    Value<String?> startTime = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    Value<String?> endTime = const Value.absent(),
    DateTime? lastModified,
    String? syncStatus,
    Value<String?> syncError = const Value.absent(),
  }) => PromotionsTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    isEnabled: isEnabled ?? this.isEnabled,
    startDate: startDate.present ? startDate.value : this.startDate,
    startTime: startTime.present ? startTime.value : this.startTime,
    endDate: endDate.present ? endDate.value : this.endDate,
    endTime: endTime.present ? endTime.value : this.endTime,
    lastModified: lastModified ?? this.lastModified,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
  );
  PromotionsTableData copyWithCompanion(PromotionsTableCompanion data) {
    return PromotionsTableData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      daysOfWeek: data.daysOfWeek.present
          ? data.daysOfWeek.value
          : this.daysOfWeek,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PromotionsTableData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('startDate: $startDate, ')
          ..write('startTime: $startTime, ')
          ..write('endDate: $endDate, ')
          ..write('endTime: $endTime, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    name,
    daysOfWeek,
    isEnabled,
    startDate,
    startTime,
    endDate,
    endTime,
    lastModified,
    syncStatus,
    syncError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PromotionsTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.daysOfWeek == this.daysOfWeek &&
          other.isEnabled == this.isEnabled &&
          other.startDate == this.startDate &&
          other.startTime == this.startTime &&
          other.endDate == this.endDate &&
          other.endTime == this.endTime &&
          other.lastModified == this.lastModified &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError);
}

class PromotionsTableCompanion extends UpdateCompanion<PromotionsTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String> name;
  final Value<int> daysOfWeek;
  final Value<bool> isEnabled;
  final Value<DateTime?> startDate;
  final Value<String?> startTime;
  final Value<DateTime?> endDate;
  final Value<String?> endTime;
  final Value<DateTime> lastModified;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  const PromotionsTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.startDate = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endDate = const Value.absent(),
    this.endTime = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
  });
  PromotionsTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required String name,
    this.daysOfWeek = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.startDate = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endDate = const Value.absent(),
    this.endTime = const Value.absent(),
    required DateTime lastModified,
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
  }) : companyId = Value(companyId),
       name = Value(name),
       lastModified = Value(lastModified);
  static Insertable<PromotionsTableData> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<String>? name,
    Expression<int>? daysOfWeek,
    Expression<bool>? isEnabled,
    Expression<DateTime>? startDate,
    Expression<String>? startTime,
    Expression<DateTime>? endDate,
    Expression<String>? endTime,
    Expression<DateTime>? lastModified,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (daysOfWeek != null) 'days_of_week': daysOfWeek,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (startDate != null) 'start_date': startDate,
      if (startTime != null) 'start_time': startTime,
      if (endDate != null) 'end_date': endDate,
      if (endTime != null) 'end_time': endTime,
      if (lastModified != null) 'last_modified': lastModified,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
    });
  }

  PromotionsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<String>? name,
    Value<int>? daysOfWeek,
    Value<bool>? isEnabled,
    Value<DateTime?>? startDate,
    Value<String?>? startTime,
    Value<DateTime?>? endDate,
    Value<String?>? endTime,
    Value<DateTime>? lastModified,
    Value<String>? syncStatus,
    Value<String?>? syncError,
  }) {
    return PromotionsTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isEnabled: isEnabled ?? this.isEnabled,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
      lastModified: lastModified ?? this.lastModified,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (daysOfWeek.present) {
      map['days_of_week'] = Variable<int>(daysOfWeek.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromotionsTableCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('startDate: $startDate, ')
          ..write('startTime: $startTime, ')
          ..write('endDate: $endDate, ')
          ..write('endTime: $endTime, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }
}

class $PromotionItemsTableTable extends PromotionItemsTable
    with TableInfo<$PromotionItemsTableTable, PromotionItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromotionItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promotionIdMeta = const VerificationMeta(
    'promotionId',
  );
  @override
  late final GeneratedColumn<int> promotionId = GeneratedColumn<int>(
    'promotion_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountTypeMeta = const VerificationMeta(
    'discountType',
  );
  @override
  late final GeneratedColumn<int> discountType = GeneratedColumn<int>(
    'discount_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _priceTypeMeta = const VerificationMeta(
    'priceType',
  );
  @override
  late final GeneratedColumn<int> priceType = GeneratedColumn<int>(
    'price_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isConditionalMeta = const VerificationMeta(
    'isConditional',
  );
  @override
  late final GeneratedColumn<bool> isConditional = GeneratedColumn<bool>(
    'is_conditional',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_conditional" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _conditionTypeMeta = const VerificationMeta(
    'conditionType',
  );
  @override
  late final GeneratedColumn<int> conditionType = GeneratedColumn<int>(
    'condition_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _quantityLimitMeta = const VerificationMeta(
    'quantityLimit',
  );
  @override
  late final GeneratedColumn<double> quantityLimit = GeneratedColumn<double>(
    'quantity_limit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    promotionId,
    productId,
    discountType,
    priceType,
    value,
    isConditional,
    quantity,
    conditionType,
    quantityLimit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'promotion_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PromotionItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('promotion_id')) {
      context.handle(
        _promotionIdMeta,
        promotionId.isAcceptableOrUnknown(
          data['promotion_id']!,
          _promotionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_promotionIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('discount_type')) {
      context.handle(
        _discountTypeMeta,
        discountType.isAcceptableOrUnknown(
          data['discount_type']!,
          _discountTypeMeta,
        ),
      );
    }
    if (data.containsKey('price_type')) {
      context.handle(
        _priceTypeMeta,
        priceType.isAcceptableOrUnknown(data['price_type']!, _priceTypeMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('is_conditional')) {
      context.handle(
        _isConditionalMeta,
        isConditional.isAcceptableOrUnknown(
          data['is_conditional']!,
          _isConditionalMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('condition_type')) {
      context.handle(
        _conditionTypeMeta,
        conditionType.isAcceptableOrUnknown(
          data['condition_type']!,
          _conditionTypeMeta,
        ),
      );
    }
    if (data.containsKey('quantity_limit')) {
      context.handle(
        _quantityLimitMeta,
        quantityLimit.isAcceptableOrUnknown(
          data['quantity_limit']!,
          _quantityLimitMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PromotionItemsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PromotionItemsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      promotionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}promotion_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      discountType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_type'],
      )!,
      priceType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      isConditional: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_conditional'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      conditionType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}condition_type'],
      )!,
      quantityLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_limit'],
      )!,
    );
  }

  @override
  $PromotionItemsTableTable createAlias(String alias) {
    return $PromotionItemsTableTable(attachedDatabase, alias);
  }
}

class PromotionItemsTableData extends DataClass
    implements Insertable<PromotionItemsTableData> {
  final int id;
  final int promotionId;
  final int productId;
  final int discountType;
  final int priceType;
  final double value;
  final bool isConditional;
  final double quantity;
  final int conditionType;
  final double quantityLimit;
  const PromotionItemsTableData({
    required this.id,
    required this.promotionId,
    required this.productId,
    required this.discountType,
    required this.priceType,
    required this.value,
    required this.isConditional,
    required this.quantity,
    required this.conditionType,
    required this.quantityLimit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['promotion_id'] = Variable<int>(promotionId);
    map['product_id'] = Variable<int>(productId);
    map['discount_type'] = Variable<int>(discountType);
    map['price_type'] = Variable<int>(priceType);
    map['value'] = Variable<double>(value);
    map['is_conditional'] = Variable<bool>(isConditional);
    map['quantity'] = Variable<double>(quantity);
    map['condition_type'] = Variable<int>(conditionType);
    map['quantity_limit'] = Variable<double>(quantityLimit);
    return map;
  }

  PromotionItemsTableCompanion toCompanion(bool nullToAbsent) {
    return PromotionItemsTableCompanion(
      id: Value(id),
      promotionId: Value(promotionId),
      productId: Value(productId),
      discountType: Value(discountType),
      priceType: Value(priceType),
      value: Value(value),
      isConditional: Value(isConditional),
      quantity: Value(quantity),
      conditionType: Value(conditionType),
      quantityLimit: Value(quantityLimit),
    );
  }

  factory PromotionItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PromotionItemsTableData(
      id: serializer.fromJson<int>(json['id']),
      promotionId: serializer.fromJson<int>(json['promotionId']),
      productId: serializer.fromJson<int>(json['productId']),
      discountType: serializer.fromJson<int>(json['discountType']),
      priceType: serializer.fromJson<int>(json['priceType']),
      value: serializer.fromJson<double>(json['value']),
      isConditional: serializer.fromJson<bool>(json['isConditional']),
      quantity: serializer.fromJson<double>(json['quantity']),
      conditionType: serializer.fromJson<int>(json['conditionType']),
      quantityLimit: serializer.fromJson<double>(json['quantityLimit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'promotionId': serializer.toJson<int>(promotionId),
      'productId': serializer.toJson<int>(productId),
      'discountType': serializer.toJson<int>(discountType),
      'priceType': serializer.toJson<int>(priceType),
      'value': serializer.toJson<double>(value),
      'isConditional': serializer.toJson<bool>(isConditional),
      'quantity': serializer.toJson<double>(quantity),
      'conditionType': serializer.toJson<int>(conditionType),
      'quantityLimit': serializer.toJson<double>(quantityLimit),
    };
  }

  PromotionItemsTableData copyWith({
    int? id,
    int? promotionId,
    int? productId,
    int? discountType,
    int? priceType,
    double? value,
    bool? isConditional,
    double? quantity,
    int? conditionType,
    double? quantityLimit,
  }) => PromotionItemsTableData(
    id: id ?? this.id,
    promotionId: promotionId ?? this.promotionId,
    productId: productId ?? this.productId,
    discountType: discountType ?? this.discountType,
    priceType: priceType ?? this.priceType,
    value: value ?? this.value,
    isConditional: isConditional ?? this.isConditional,
    quantity: quantity ?? this.quantity,
    conditionType: conditionType ?? this.conditionType,
    quantityLimit: quantityLimit ?? this.quantityLimit,
  );
  PromotionItemsTableData copyWithCompanion(PromotionItemsTableCompanion data) {
    return PromotionItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      promotionId: data.promotionId.present
          ? data.promotionId.value
          : this.promotionId,
      productId: data.productId.present ? data.productId.value : this.productId,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      priceType: data.priceType.present ? data.priceType.value : this.priceType,
      value: data.value.present ? data.value.value : this.value,
      isConditional: data.isConditional.present
          ? data.isConditional.value
          : this.isConditional,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      conditionType: data.conditionType.present
          ? data.conditionType.value
          : this.conditionType,
      quantityLimit: data.quantityLimit.present
          ? data.quantityLimit.value
          : this.quantityLimit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PromotionItemsTableData(')
          ..write('id: $id, ')
          ..write('promotionId: $promotionId, ')
          ..write('productId: $productId, ')
          ..write('discountType: $discountType, ')
          ..write('priceType: $priceType, ')
          ..write('value: $value, ')
          ..write('isConditional: $isConditional, ')
          ..write('quantity: $quantity, ')
          ..write('conditionType: $conditionType, ')
          ..write('quantityLimit: $quantityLimit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    promotionId,
    productId,
    discountType,
    priceType,
    value,
    isConditional,
    quantity,
    conditionType,
    quantityLimit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PromotionItemsTableData &&
          other.id == this.id &&
          other.promotionId == this.promotionId &&
          other.productId == this.productId &&
          other.discountType == this.discountType &&
          other.priceType == this.priceType &&
          other.value == this.value &&
          other.isConditional == this.isConditional &&
          other.quantity == this.quantity &&
          other.conditionType == this.conditionType &&
          other.quantityLimit == this.quantityLimit);
}

class PromotionItemsTableCompanion
    extends UpdateCompanion<PromotionItemsTableData> {
  final Value<int> id;
  final Value<int> promotionId;
  final Value<int> productId;
  final Value<int> discountType;
  final Value<int> priceType;
  final Value<double> value;
  final Value<bool> isConditional;
  final Value<double> quantity;
  final Value<int> conditionType;
  final Value<double> quantityLimit;
  const PromotionItemsTableCompanion({
    this.id = const Value.absent(),
    this.promotionId = const Value.absent(),
    this.productId = const Value.absent(),
    this.discountType = const Value.absent(),
    this.priceType = const Value.absent(),
    this.value = const Value.absent(),
    this.isConditional = const Value.absent(),
    this.quantity = const Value.absent(),
    this.conditionType = const Value.absent(),
    this.quantityLimit = const Value.absent(),
  });
  PromotionItemsTableCompanion.insert({
    this.id = const Value.absent(),
    required int promotionId,
    required int productId,
    this.discountType = const Value.absent(),
    this.priceType = const Value.absent(),
    this.value = const Value.absent(),
    this.isConditional = const Value.absent(),
    this.quantity = const Value.absent(),
    this.conditionType = const Value.absent(),
    this.quantityLimit = const Value.absent(),
  }) : promotionId = Value(promotionId),
       productId = Value(productId);
  static Insertable<PromotionItemsTableData> custom({
    Expression<int>? id,
    Expression<int>? promotionId,
    Expression<int>? productId,
    Expression<int>? discountType,
    Expression<int>? priceType,
    Expression<double>? value,
    Expression<bool>? isConditional,
    Expression<double>? quantity,
    Expression<int>? conditionType,
    Expression<double>? quantityLimit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (promotionId != null) 'promotion_id': promotionId,
      if (productId != null) 'product_id': productId,
      if (discountType != null) 'discount_type': discountType,
      if (priceType != null) 'price_type': priceType,
      if (value != null) 'value': value,
      if (isConditional != null) 'is_conditional': isConditional,
      if (quantity != null) 'quantity': quantity,
      if (conditionType != null) 'condition_type': conditionType,
      if (quantityLimit != null) 'quantity_limit': quantityLimit,
    });
  }

  PromotionItemsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? promotionId,
    Value<int>? productId,
    Value<int>? discountType,
    Value<int>? priceType,
    Value<double>? value,
    Value<bool>? isConditional,
    Value<double>? quantity,
    Value<int>? conditionType,
    Value<double>? quantityLimit,
  }) {
    return PromotionItemsTableCompanion(
      id: id ?? this.id,
      promotionId: promotionId ?? this.promotionId,
      productId: productId ?? this.productId,
      discountType: discountType ?? this.discountType,
      priceType: priceType ?? this.priceType,
      value: value ?? this.value,
      isConditional: isConditional ?? this.isConditional,
      quantity: quantity ?? this.quantity,
      conditionType: conditionType ?? this.conditionType,
      quantityLimit: quantityLimit ?? this.quantityLimit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (promotionId.present) {
      map['promotion_id'] = Variable<int>(promotionId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<int>(discountType.value);
    }
    if (priceType.present) {
      map['price_type'] = Variable<int>(priceType.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (isConditional.present) {
      map['is_conditional'] = Variable<bool>(isConditional.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (conditionType.present) {
      map['condition_type'] = Variable<int>(conditionType.value);
    }
    if (quantityLimit.present) {
      map['quantity_limit'] = Variable<double>(quantityLimit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromotionItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('promotionId: $promotionId, ')
          ..write('productId: $productId, ')
          ..write('discountType: $discountType, ')
          ..write('priceType: $priceType, ')
          ..write('value: $value, ')
          ..write('isConditional: $isConditional, ')
          ..write('quantity: $quantity, ')
          ..write('conditionType: $conditionType, ')
          ..write('quantityLimit: $quantityLimit')
          ..write(')'))
        .toString();
  }
}

class $ProductCommentsTableTable extends ProductCommentsTable
    with TableInfo<$ProductCommentsTableTable, ProductCommentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductCommentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    productId,
    comment,
    lastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_comments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductCommentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    } else if (isInserting) {
      context.missing(_commentMeta);
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductCommentsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductCommentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
    );
  }

  @override
  $ProductCommentsTableTable createAlias(String alias) {
    return $ProductCommentsTableTable(attachedDatabase, alias);
  }
}

class ProductCommentsTableData extends DataClass
    implements Insertable<ProductCommentsTableData> {
  final int id;
  final int companyId;
  final int productId;
  final String comment;
  final DateTime lastModified;
  const ProductCommentsTableData({
    required this.id,
    required this.companyId,
    required this.productId,
    required this.comment,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['product_id'] = Variable<int>(productId);
    map['comment'] = Variable<String>(comment);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  ProductCommentsTableCompanion toCompanion(bool nullToAbsent) {
    return ProductCommentsTableCompanion(
      id: Value(id),
      companyId: Value(companyId),
      productId: Value(productId),
      comment: Value(comment),
      lastModified: Value(lastModified),
    );
  }

  factory ProductCommentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductCommentsTableData(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      productId: serializer.fromJson<int>(json['productId']),
      comment: serializer.fromJson<String>(json['comment']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'productId': serializer.toJson<int>(productId),
      'comment': serializer.toJson<String>(comment),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  ProductCommentsTableData copyWith({
    int? id,
    int? companyId,
    int? productId,
    String? comment,
    DateTime? lastModified,
  }) => ProductCommentsTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    productId: productId ?? this.productId,
    comment: comment ?? this.comment,
    lastModified: lastModified ?? this.lastModified,
  );
  ProductCommentsTableData copyWithCompanion(
    ProductCommentsTableCompanion data,
  ) {
    return ProductCommentsTableData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      productId: data.productId.present ? data.productId.value : this.productId,
      comment: data.comment.present ? data.comment.value : this.comment,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductCommentsTableData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('productId: $productId, ')
          ..write('comment: $comment, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, companyId, productId, comment, lastModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductCommentsTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.productId == this.productId &&
          other.comment == this.comment &&
          other.lastModified == this.lastModified);
}

class ProductCommentsTableCompanion
    extends UpdateCompanion<ProductCommentsTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<int> productId;
  final Value<String> comment;
  final Value<DateTime> lastModified;
  const ProductCommentsTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.productId = const Value.absent(),
    this.comment = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  ProductCommentsTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required int productId,
    required String comment,
    required DateTime lastModified,
  }) : companyId = Value(companyId),
       productId = Value(productId),
       comment = Value(comment),
       lastModified = Value(lastModified);
  static Insertable<ProductCommentsTableData> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<int>? productId,
    Expression<String>? comment,
    Expression<DateTime>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (productId != null) 'product_id': productId,
      if (comment != null) 'comment': comment,
      if (lastModified != null) 'last_modified': lastModified,
    });
  }

  ProductCommentsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<int>? productId,
    Value<String>? comment,
    Value<DateTime>? lastModified,
  }) {
    return ProductCommentsTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      productId: productId ?? this.productId,
      comment: comment ?? this.comment,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductCommentsTableCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('productId: $productId, ')
          ..write('comment: $comment, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }
}

class $CompaniesTableTable extends CompaniesTable
    with TableInfo<$CompaniesTableTable, CompaniesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompaniesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxNumberMeta = const VerificationMeta(
    'taxNumber',
  );
  @override
  late final GeneratedColumn<String> taxNumber = GeneratedColumn<String>(
    'tax_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localLogoPathMeta = const VerificationMeta(
    'localLogoPath',
  );
  @override
  late final GeneratedColumn<String> localLogoPath = GeneratedColumn<String>(
    'local_logo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    taxNumber,
    address,
    phone,
    localLogoPath,
    lastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompaniesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('tax_number')) {
      context.handle(
        _taxNumberMeta,
        taxNumber.isAcceptableOrUnknown(data['tax_number']!, _taxNumberMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('local_logo_path')) {
      context.handle(
        _localLogoPathMeta,
        localLogoPath.isAcceptableOrUnknown(
          data['local_logo_path']!,
          _localLogoPathMeta,
        ),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompaniesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompaniesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      taxNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_number'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      localLogoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_logo_path'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
    );
  }

  @override
  $CompaniesTableTable createAlias(String alias) {
    return $CompaniesTableTable(attachedDatabase, alias);
  }
}

class CompaniesTableData extends DataClass
    implements Insertable<CompaniesTableData> {
  final int id;
  final String name;
  final String? taxNumber;
  final String? address;
  final String? phone;
  final String? localLogoPath;
  final DateTime lastModified;
  const CompaniesTableData({
    required this.id,
    required this.name,
    this.taxNumber,
    this.address,
    this.phone,
    this.localLogoPath,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || taxNumber != null) {
      map['tax_number'] = Variable<String>(taxNumber);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || localLogoPath != null) {
      map['local_logo_path'] = Variable<String>(localLogoPath);
    }
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  CompaniesTableCompanion toCompanion(bool nullToAbsent) {
    return CompaniesTableCompanion(
      id: Value(id),
      name: Value(name),
      taxNumber: taxNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(taxNumber),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      localLogoPath: localLogoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localLogoPath),
      lastModified: Value(lastModified),
    );
  }

  factory CompaniesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompaniesTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      taxNumber: serializer.fromJson<String?>(json['taxNumber']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String?>(json['phone']),
      localLogoPath: serializer.fromJson<String?>(json['localLogoPath']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'taxNumber': serializer.toJson<String?>(taxNumber),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String?>(phone),
      'localLogoPath': serializer.toJson<String?>(localLogoPath),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  CompaniesTableData copyWith({
    int? id,
    String? name,
    Value<String?> taxNumber = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> localLogoPath = const Value.absent(),
    DateTime? lastModified,
  }) => CompaniesTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    taxNumber: taxNumber.present ? taxNumber.value : this.taxNumber,
    address: address.present ? address.value : this.address,
    phone: phone.present ? phone.value : this.phone,
    localLogoPath: localLogoPath.present
        ? localLogoPath.value
        : this.localLogoPath,
    lastModified: lastModified ?? this.lastModified,
  );
  CompaniesTableData copyWithCompanion(CompaniesTableCompanion data) {
    return CompaniesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      taxNumber: data.taxNumber.present ? data.taxNumber.value : this.taxNumber,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      localLogoPath: data.localLogoPath.present
          ? data.localLogoPath.value
          : this.localLogoPath,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('taxNumber: $taxNumber, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('localLogoPath: $localLogoPath, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    taxNumber,
    address,
    phone,
    localLogoPath,
    lastModified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompaniesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.taxNumber == this.taxNumber &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.localLogoPath == this.localLogoPath &&
          other.lastModified == this.lastModified);
}

class CompaniesTableCompanion extends UpdateCompanion<CompaniesTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> taxNumber;
  final Value<String?> address;
  final Value<String?> phone;
  final Value<String?> localLogoPath;
  final Value<DateTime> lastModified;
  const CompaniesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.taxNumber = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.localLogoPath = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  CompaniesTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.taxNumber = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.localLogoPath = const Value.absent(),
    required DateTime lastModified,
  }) : name = Value(name),
       lastModified = Value(lastModified);
  static Insertable<CompaniesTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? taxNumber,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<String>? localLogoPath,
    Expression<DateTime>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (taxNumber != null) 'tax_number': taxNumber,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (localLogoPath != null) 'local_logo_path': localLogoPath,
      if (lastModified != null) 'last_modified': lastModified,
    });
  }

  CompaniesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? taxNumber,
    Value<String?>? address,
    Value<String?>? phone,
    Value<String?>? localLogoPath,
    Value<DateTime>? lastModified,
  }) {
    return CompaniesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      taxNumber: taxNumber ?? this.taxNumber,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      localLogoPath: localLogoPath ?? this.localLogoPath,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (taxNumber.present) {
      map['tax_number'] = Variable<String>(taxNumber.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (localLogoPath.present) {
      map['local_logo_path'] = Variable<String>(localLogoPath.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('taxNumber: $taxNumber, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('localLogoPath: $localLogoPath, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }
}

class $PosOrdersTableTable extends PosOrdersTable
    with TableInfo<$PosOrdersTableTable, PosOrdersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PosOrdersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tableIdMeta = const VerificationMeta(
    'tableId',
  );
  @override
  late final GeneratedColumn<int> tableId = GeneratedColumn<int>(
    'table_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serviceTypeMeta = const VerificationMeta(
    'serviceType',
  );
  @override
  late final GeneratedColumn<int> serviceType = GeneratedColumn<int>(
    'service_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceStatusMeta = const VerificationMeta(
    'serviceStatus',
  );
  @override
  late final GeneratedColumn<int> serviceStatus = GeneratedColumn<int>(
    'service_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _orderNameMeta = const VerificationMeta(
    'orderName',
  );
  @override
  late final GeneratedColumn<String> orderName = GeneratedColumn<String>(
    'order_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountMeta = const VerificationMeta(
    'discount',
  );
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
    'discount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountTypeMeta = const VerificationMeta(
    'discountType',
  );
  @override
  late final GeneratedColumn<int> discountType = GeneratedColumn<int>(
    'discount_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _warehouseIdMeta = const VerificationMeta(
    'warehouseId',
  );
  @override
  late final GeneratedColumn<int> warehouseId = GeneratedColumn<int>(
    'warehouse_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentTypeIdMeta = const VerificationMeta(
    'paymentTypeId',
  );
  @override
  late final GeneratedColumn<int> paymentTypeId = GeneratedColumn<int>(
    'payment_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'amount_paid',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    companyId,
    userId,
    tableId,
    serviceType,
    serviceStatus,
    orderName,
    openedAt,
    closedAt,
    status,
    total,
    discount,
    discountType,
    warehouseId,
    paymentTypeId,
    amountPaid,
    customerId,
    syncStatus,
    syncError,
    lastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pos_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<PosOrdersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('table_id')) {
      context.handle(
        _tableIdMeta,
        tableId.isAcceptableOrUnknown(data['table_id']!, _tableIdMeta),
      );
    }
    if (data.containsKey('service_type')) {
      context.handle(
        _serviceTypeMeta,
        serviceType.isAcceptableOrUnknown(
          data['service_type']!,
          _serviceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceTypeMeta);
    }
    if (data.containsKey('service_status')) {
      context.handle(
        _serviceStatusMeta,
        serviceStatus.isAcceptableOrUnknown(
          data['service_status']!,
          _serviceStatusMeta,
        ),
      );
    }
    if (data.containsKey('order_name')) {
      context.handle(
        _orderNameMeta,
        orderName.isAcceptableOrUnknown(data['order_name']!, _orderNameMeta),
      );
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    if (data.containsKey('discount')) {
      context.handle(
        _discountMeta,
        discount.isAcceptableOrUnknown(data['discount']!, _discountMeta),
      );
    }
    if (data.containsKey('discount_type')) {
      context.handle(
        _discountTypeMeta,
        discountType.isAcceptableOrUnknown(
          data['discount_type']!,
          _discountTypeMeta,
        ),
      );
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
        _warehouseIdMeta,
        warehouseId.isAcceptableOrUnknown(
          data['warehouse_id']!,
          _warehouseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('payment_type_id')) {
      context.handle(
        _paymentTypeIdMeta,
        paymentTypeId.isAcceptableOrUnknown(
          data['payment_type_id']!,
          _paymentTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  PosOrdersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PosOrdersTableData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      tableId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}table_id'],
      ),
      serviceType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}service_type'],
      )!,
      serviceStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}service_status'],
      )!,
      orderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_name'],
      ),
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      ),
      discount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount'],
      )!,
      discountType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_type'],
      )!,
      warehouseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warehouse_id'],
      )!,
      paymentTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_type_id'],
      ),
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
    );
  }

  @override
  $PosOrdersTableTable createAlias(String alias) {
    return $PosOrdersTableTable(attachedDatabase, alias);
  }
}

class PosOrdersTableData extends DataClass
    implements Insertable<PosOrdersTableData> {
  final String localId;
  final int? serverId;
  final int companyId;
  final int userId;
  final int? tableId;
  final int serviceType;
  final int serviceStatus;
  final String? orderName;
  final DateTime openedAt;
  final DateTime? closedAt;
  final int status;
  final double? total;
  final double discount;
  final int discountType;
  final int warehouseId;
  final int? paymentTypeId;
  final double? amountPaid;
  final int? customerId;
  final String syncStatus;
  final String? syncError;
  final DateTime lastModified;
  const PosOrdersTableData({
    required this.localId,
    this.serverId,
    required this.companyId,
    required this.userId,
    this.tableId,
    required this.serviceType,
    required this.serviceStatus,
    this.orderName,
    required this.openedAt,
    this.closedAt,
    required this.status,
    this.total,
    required this.discount,
    required this.discountType,
    required this.warehouseId,
    this.paymentTypeId,
    this.amountPaid,
    this.customerId,
    required this.syncStatus,
    this.syncError,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['company_id'] = Variable<int>(companyId);
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || tableId != null) {
      map['table_id'] = Variable<int>(tableId);
    }
    map['service_type'] = Variable<int>(serviceType);
    map['service_status'] = Variable<int>(serviceStatus);
    if (!nullToAbsent || orderName != null) {
      map['order_name'] = Variable<String>(orderName);
    }
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || total != null) {
      map['total'] = Variable<double>(total);
    }
    map['discount'] = Variable<double>(discount);
    map['discount_type'] = Variable<int>(discountType);
    map['warehouse_id'] = Variable<int>(warehouseId);
    if (!nullToAbsent || paymentTypeId != null) {
      map['payment_type_id'] = Variable<int>(paymentTypeId);
    }
    if (!nullToAbsent || amountPaid != null) {
      map['amount_paid'] = Variable<double>(amountPaid);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<int>(customerId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  PosOrdersTableCompanion toCompanion(bool nullToAbsent) {
    return PosOrdersTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      companyId: Value(companyId),
      userId: Value(userId),
      tableId: tableId == null && nullToAbsent
          ? const Value.absent()
          : Value(tableId),
      serviceType: Value(serviceType),
      serviceStatus: Value(serviceStatus),
      orderName: orderName == null && nullToAbsent
          ? const Value.absent()
          : Value(orderName),
      openedAt: Value(openedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      status: Value(status),
      total: total == null && nullToAbsent
          ? const Value.absent()
          : Value(total),
      discount: Value(discount),
      discountType: Value(discountType),
      warehouseId: Value(warehouseId),
      paymentTypeId: paymentTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentTypeId),
      amountPaid: amountPaid == null && nullToAbsent
          ? const Value.absent()
          : Value(amountPaid),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      lastModified: Value(lastModified),
    );
  }

  factory PosOrdersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PosOrdersTableData(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      companyId: serializer.fromJson<int>(json['companyId']),
      userId: serializer.fromJson<int>(json['userId']),
      tableId: serializer.fromJson<int?>(json['tableId']),
      serviceType: serializer.fromJson<int>(json['serviceType']),
      serviceStatus: serializer.fromJson<int>(json['serviceStatus']),
      orderName: serializer.fromJson<String?>(json['orderName']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      status: serializer.fromJson<int>(json['status']),
      total: serializer.fromJson<double?>(json['total']),
      discount: serializer.fromJson<double>(json['discount']),
      discountType: serializer.fromJson<int>(json['discountType']),
      warehouseId: serializer.fromJson<int>(json['warehouseId']),
      paymentTypeId: serializer.fromJson<int?>(json['paymentTypeId']),
      amountPaid: serializer.fromJson<double?>(json['amountPaid']),
      customerId: serializer.fromJson<int?>(json['customerId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<int?>(serverId),
      'companyId': serializer.toJson<int>(companyId),
      'userId': serializer.toJson<int>(userId),
      'tableId': serializer.toJson<int?>(tableId),
      'serviceType': serializer.toJson<int>(serviceType),
      'serviceStatus': serializer.toJson<int>(serviceStatus),
      'orderName': serializer.toJson<String?>(orderName),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'status': serializer.toJson<int>(status),
      'total': serializer.toJson<double?>(total),
      'discount': serializer.toJson<double>(discount),
      'discountType': serializer.toJson<int>(discountType),
      'warehouseId': serializer.toJson<int>(warehouseId),
      'paymentTypeId': serializer.toJson<int?>(paymentTypeId),
      'amountPaid': serializer.toJson<double?>(amountPaid),
      'customerId': serializer.toJson<int?>(customerId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  PosOrdersTableData copyWith({
    String? localId,
    Value<int?> serverId = const Value.absent(),
    int? companyId,
    int? userId,
    Value<int?> tableId = const Value.absent(),
    int? serviceType,
    int? serviceStatus,
    Value<String?> orderName = const Value.absent(),
    DateTime? openedAt,
    Value<DateTime?> closedAt = const Value.absent(),
    int? status,
    Value<double?> total = const Value.absent(),
    double? discount,
    int? discountType,
    int? warehouseId,
    Value<int?> paymentTypeId = const Value.absent(),
    Value<double?> amountPaid = const Value.absent(),
    Value<int?> customerId = const Value.absent(),
    String? syncStatus,
    Value<String?> syncError = const Value.absent(),
    DateTime? lastModified,
  }) => PosOrdersTableData(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    companyId: companyId ?? this.companyId,
    userId: userId ?? this.userId,
    tableId: tableId.present ? tableId.value : this.tableId,
    serviceType: serviceType ?? this.serviceType,
    serviceStatus: serviceStatus ?? this.serviceStatus,
    orderName: orderName.present ? orderName.value : this.orderName,
    openedAt: openedAt ?? this.openedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    status: status ?? this.status,
    total: total.present ? total.value : this.total,
    discount: discount ?? this.discount,
    discountType: discountType ?? this.discountType,
    warehouseId: warehouseId ?? this.warehouseId,
    paymentTypeId: paymentTypeId.present
        ? paymentTypeId.value
        : this.paymentTypeId,
    amountPaid: amountPaid.present ? amountPaid.value : this.amountPaid,
    customerId: customerId.present ? customerId.value : this.customerId,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
    lastModified: lastModified ?? this.lastModified,
  );
  PosOrdersTableData copyWithCompanion(PosOrdersTableCompanion data) {
    return PosOrdersTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      userId: data.userId.present ? data.userId.value : this.userId,
      tableId: data.tableId.present ? data.tableId.value : this.tableId,
      serviceType: data.serviceType.present
          ? data.serviceType.value
          : this.serviceType,
      serviceStatus: data.serviceStatus.present
          ? data.serviceStatus.value
          : this.serviceStatus,
      orderName: data.orderName.present ? data.orderName.value : this.orderName,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      status: data.status.present ? data.status.value : this.status,
      total: data.total.present ? data.total.value : this.total,
      discount: data.discount.present ? data.discount.value : this.discount,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      warehouseId: data.warehouseId.present
          ? data.warehouseId.value
          : this.warehouseId,
      paymentTypeId: data.paymentTypeId.present
          ? data.paymentTypeId.value
          : this.paymentTypeId,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PosOrdersTableData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('companyId: $companyId, ')
          ..write('userId: $userId, ')
          ..write('tableId: $tableId, ')
          ..write('serviceType: $serviceType, ')
          ..write('serviceStatus: $serviceStatus, ')
          ..write('orderName: $orderName, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('status: $status, ')
          ..write('total: $total, ')
          ..write('discount: $discount, ')
          ..write('discountType: $discountType, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('paymentTypeId: $paymentTypeId, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('customerId: $customerId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    localId,
    serverId,
    companyId,
    userId,
    tableId,
    serviceType,
    serviceStatus,
    orderName,
    openedAt,
    closedAt,
    status,
    total,
    discount,
    discountType,
    warehouseId,
    paymentTypeId,
    amountPaid,
    customerId,
    syncStatus,
    syncError,
    lastModified,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PosOrdersTableData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.companyId == this.companyId &&
          other.userId == this.userId &&
          other.tableId == this.tableId &&
          other.serviceType == this.serviceType &&
          other.serviceStatus == this.serviceStatus &&
          other.orderName == this.orderName &&
          other.openedAt == this.openedAt &&
          other.closedAt == this.closedAt &&
          other.status == this.status &&
          other.total == this.total &&
          other.discount == this.discount &&
          other.discountType == this.discountType &&
          other.warehouseId == this.warehouseId &&
          other.paymentTypeId == this.paymentTypeId &&
          other.amountPaid == this.amountPaid &&
          other.customerId == this.customerId &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.lastModified == this.lastModified);
}

class PosOrdersTableCompanion extends UpdateCompanion<PosOrdersTableData> {
  final Value<String> localId;
  final Value<int?> serverId;
  final Value<int> companyId;
  final Value<int> userId;
  final Value<int?> tableId;
  final Value<int> serviceType;
  final Value<int> serviceStatus;
  final Value<String?> orderName;
  final Value<DateTime> openedAt;
  final Value<DateTime?> closedAt;
  final Value<int> status;
  final Value<double?> total;
  final Value<double> discount;
  final Value<int> discountType;
  final Value<int> warehouseId;
  final Value<int?> paymentTypeId;
  final Value<double?> amountPaid;
  final Value<int?> customerId;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  final Value<DateTime> lastModified;
  final Value<int> rowid;
  const PosOrdersTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.userId = const Value.absent(),
    this.tableId = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.serviceStatus = const Value.absent(),
    this.orderName = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.total = const Value.absent(),
    this.discount = const Value.absent(),
    this.discountType = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.paymentTypeId = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.customerId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PosOrdersTableCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required int companyId,
    required int userId,
    this.tableId = const Value.absent(),
    required int serviceType,
    this.serviceStatus = const Value.absent(),
    this.orderName = const Value.absent(),
    required DateTime openedAt,
    this.closedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.total = const Value.absent(),
    this.discount = const Value.absent(),
    this.discountType = const Value.absent(),
    required int warehouseId,
    this.paymentTypeId = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.customerId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    required DateTime lastModified,
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       companyId = Value(companyId),
       userId = Value(userId),
       serviceType = Value(serviceType),
       openedAt = Value(openedAt),
       warehouseId = Value(warehouseId),
       lastModified = Value(lastModified);
  static Insertable<PosOrdersTableData> custom({
    Expression<String>? localId,
    Expression<int>? serverId,
    Expression<int>? companyId,
    Expression<int>? userId,
    Expression<int>? tableId,
    Expression<int>? serviceType,
    Expression<int>? serviceStatus,
    Expression<String>? orderName,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closedAt,
    Expression<int>? status,
    Expression<double>? total,
    Expression<double>? discount,
    Expression<int>? discountType,
    Expression<int>? warehouseId,
    Expression<int>? paymentTypeId,
    Expression<double>? amountPaid,
    Expression<int>? customerId,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<DateTime>? lastModified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (companyId != null) 'company_id': companyId,
      if (userId != null) 'user_id': userId,
      if (tableId != null) 'table_id': tableId,
      if (serviceType != null) 'service_type': serviceType,
      if (serviceStatus != null) 'service_status': serviceStatus,
      if (orderName != null) 'order_name': orderName,
      if (openedAt != null) 'opened_at': openedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (status != null) 'status': status,
      if (total != null) 'total': total,
      if (discount != null) 'discount': discount,
      if (discountType != null) 'discount_type': discountType,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (paymentTypeId != null) 'payment_type_id': paymentTypeId,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (customerId != null) 'customer_id': customerId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (lastModified != null) 'last_modified': lastModified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PosOrdersTableCompanion copyWith({
    Value<String>? localId,
    Value<int?>? serverId,
    Value<int>? companyId,
    Value<int>? userId,
    Value<int?>? tableId,
    Value<int>? serviceType,
    Value<int>? serviceStatus,
    Value<String?>? orderName,
    Value<DateTime>? openedAt,
    Value<DateTime?>? closedAt,
    Value<int>? status,
    Value<double?>? total,
    Value<double>? discount,
    Value<int>? discountType,
    Value<int>? warehouseId,
    Value<int?>? paymentTypeId,
    Value<double?>? amountPaid,
    Value<int?>? customerId,
    Value<String>? syncStatus,
    Value<String?>? syncError,
    Value<DateTime>? lastModified,
    Value<int>? rowid,
  }) {
    return PosOrdersTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      tableId: tableId ?? this.tableId,
      serviceType: serviceType ?? this.serviceType,
      serviceStatus: serviceStatus ?? this.serviceStatus,
      orderName: orderName ?? this.orderName,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      status: status ?? this.status,
      total: total ?? this.total,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      warehouseId: warehouseId ?? this.warehouseId,
      paymentTypeId: paymentTypeId ?? this.paymentTypeId,
      amountPaid: amountPaid ?? this.amountPaid,
      customerId: customerId ?? this.customerId,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      lastModified: lastModified ?? this.lastModified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (tableId.present) {
      map['table_id'] = Variable<int>(tableId.value);
    }
    if (serviceType.present) {
      map['service_type'] = Variable<int>(serviceType.value);
    }
    if (serviceStatus.present) {
      map['service_status'] = Variable<int>(serviceStatus.value);
    }
    if (orderName.present) {
      map['order_name'] = Variable<String>(orderName.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<int>(discountType.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<int>(warehouseId.value);
    }
    if (paymentTypeId.present) {
      map['payment_type_id'] = Variable<int>(paymentTypeId.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PosOrdersTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('companyId: $companyId, ')
          ..write('userId: $userId, ')
          ..write('tableId: $tableId, ')
          ..write('serviceType: $serviceType, ')
          ..write('serviceStatus: $serviceStatus, ')
          ..write('orderName: $orderName, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('status: $status, ')
          ..write('total: $total, ')
          ..write('discount: $discount, ')
          ..write('discountType: $discountType, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('paymentTypeId: $paymentTypeId, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('customerId: $customerId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('lastModified: $lastModified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PosOrderItemsTableTable extends PosOrderItemsTable
    with TableInfo<$PosOrderItemsTableTable, PosOrderItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PosOrderItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pos_orders (local_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountMeta = const VerificationMeta(
    'discount',
  );
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
    'discount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountTypeMeta = const VerificationMeta(
    'discountType',
  );
  @override
  late final GeneratedColumn<int> discountType = GeneratedColumn<int>(
    'discount_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _taxRateMeta = const VerificationMeta(
    'taxRate',
  );
  @override
  late final GeneratedColumn<double> taxRate = GeneratedColumn<double>(
    'tax_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _taxesJsonMeta = const VerificationMeta(
    'taxesJson',
  );
  @override
  late final GeneratedColumn<String> taxesJson = GeneratedColumn<String>(
    'taxes_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warehouseIdMeta = const VerificationMeta(
    'warehouseId',
  );
  @override
  late final GeneratedColumn<int> warehouseId = GeneratedColumn<int>(
    'warehouse_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    orderId,
    productId,
    quantity,
    unitPrice,
    discount,
    discountType,
    taxRate,
    taxesJson,
    comment,
    warehouseId,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pos_order_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PosOrderItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('discount')) {
      context.handle(
        _discountMeta,
        discount.isAcceptableOrUnknown(data['discount']!, _discountMeta),
      );
    }
    if (data.containsKey('discount_type')) {
      context.handle(
        _discountTypeMeta,
        discountType.isAcceptableOrUnknown(
          data['discount_type']!,
          _discountTypeMeta,
        ),
      );
    }
    if (data.containsKey('tax_rate')) {
      context.handle(
        _taxRateMeta,
        taxRate.isAcceptableOrUnknown(data['tax_rate']!, _taxRateMeta),
      );
    }
    if (data.containsKey('taxes_json')) {
      context.handle(
        _taxesJsonMeta,
        taxesJson.isAcceptableOrUnknown(data['taxes_json']!, _taxesJsonMeta),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
        _warehouseIdMeta,
        warehouseId.isAcceptableOrUnknown(
          data['warehouse_id']!,
          _warehouseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  PosOrderItemsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PosOrderItemsTableData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      discount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount'],
      )!,
      discountType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_type'],
      )!,
      taxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_rate'],
      )!,
      taxesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}taxes_json'],
      ),
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      warehouseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warehouse_id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $PosOrderItemsTableTable createAlias(String alias) {
    return $PosOrderItemsTableTable(attachedDatabase, alias);
  }
}

class PosOrderItemsTableData extends DataClass
    implements Insertable<PosOrderItemsTableData> {
  final String localId;
  final String orderId;
  final int productId;
  final double quantity;
  final double unitPrice;
  final double discount;
  final int discountType;
  final double taxRate;
  final String? taxesJson;
  final String? comment;
  final int warehouseId;
  final String syncStatus;
  const PosOrderItemsTableData({
    required this.localId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.discountType,
    required this.taxRate,
    this.taxesJson,
    this.comment,
    required this.warehouseId,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['order_id'] = Variable<String>(orderId);
    map['product_id'] = Variable<int>(productId);
    map['quantity'] = Variable<double>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['discount'] = Variable<double>(discount);
    map['discount_type'] = Variable<int>(discountType);
    map['tax_rate'] = Variable<double>(taxRate);
    if (!nullToAbsent || taxesJson != null) {
      map['taxes_json'] = Variable<String>(taxesJson);
    }
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    map['warehouse_id'] = Variable<int>(warehouseId);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  PosOrderItemsTableCompanion toCompanion(bool nullToAbsent) {
    return PosOrderItemsTableCompanion(
      localId: Value(localId),
      orderId: Value(orderId),
      productId: Value(productId),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      discount: Value(discount),
      discountType: Value(discountType),
      taxRate: Value(taxRate),
      taxesJson: taxesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(taxesJson),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      warehouseId: Value(warehouseId),
      syncStatus: Value(syncStatus),
    );
  }

  factory PosOrderItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PosOrderItemsTableData(
      localId: serializer.fromJson<String>(json['localId']),
      orderId: serializer.fromJson<String>(json['orderId']),
      productId: serializer.fromJson<int>(json['productId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      discount: serializer.fromJson<double>(json['discount']),
      discountType: serializer.fromJson<int>(json['discountType']),
      taxRate: serializer.fromJson<double>(json['taxRate']),
      taxesJson: serializer.fromJson<String?>(json['taxesJson']),
      comment: serializer.fromJson<String?>(json['comment']),
      warehouseId: serializer.fromJson<int>(json['warehouseId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'orderId': serializer.toJson<String>(orderId),
      'productId': serializer.toJson<int>(productId),
      'quantity': serializer.toJson<double>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'discount': serializer.toJson<double>(discount),
      'discountType': serializer.toJson<int>(discountType),
      'taxRate': serializer.toJson<double>(taxRate),
      'taxesJson': serializer.toJson<String?>(taxesJson),
      'comment': serializer.toJson<String?>(comment),
      'warehouseId': serializer.toJson<int>(warehouseId),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  PosOrderItemsTableData copyWith({
    String? localId,
    String? orderId,
    int? productId,
    double? quantity,
    double? unitPrice,
    double? discount,
    int? discountType,
    double? taxRate,
    Value<String?> taxesJson = const Value.absent(),
    Value<String?> comment = const Value.absent(),
    int? warehouseId,
    String? syncStatus,
  }) => PosOrderItemsTableData(
    localId: localId ?? this.localId,
    orderId: orderId ?? this.orderId,
    productId: productId ?? this.productId,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    discount: discount ?? this.discount,
    discountType: discountType ?? this.discountType,
    taxRate: taxRate ?? this.taxRate,
    taxesJson: taxesJson.present ? taxesJson.value : this.taxesJson,
    comment: comment.present ? comment.value : this.comment,
    warehouseId: warehouseId ?? this.warehouseId,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  PosOrderItemsTableData copyWithCompanion(PosOrderItemsTableCompanion data) {
    return PosOrderItemsTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      discount: data.discount.present ? data.discount.value : this.discount,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      taxRate: data.taxRate.present ? data.taxRate.value : this.taxRate,
      taxesJson: data.taxesJson.present ? data.taxesJson.value : this.taxesJson,
      comment: data.comment.present ? data.comment.value : this.comment,
      warehouseId: data.warehouseId.present
          ? data.warehouseId.value
          : this.warehouseId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PosOrderItemsTableData(')
          ..write('localId: $localId, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('discount: $discount, ')
          ..write('discountType: $discountType, ')
          ..write('taxRate: $taxRate, ')
          ..write('taxesJson: $taxesJson, ')
          ..write('comment: $comment, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    orderId,
    productId,
    quantity,
    unitPrice,
    discount,
    discountType,
    taxRate,
    taxesJson,
    comment,
    warehouseId,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PosOrderItemsTableData &&
          other.localId == this.localId &&
          other.orderId == this.orderId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.discount == this.discount &&
          other.discountType == this.discountType &&
          other.taxRate == this.taxRate &&
          other.taxesJson == this.taxesJson &&
          other.comment == this.comment &&
          other.warehouseId == this.warehouseId &&
          other.syncStatus == this.syncStatus);
}

class PosOrderItemsTableCompanion
    extends UpdateCompanion<PosOrderItemsTableData> {
  final Value<String> localId;
  final Value<String> orderId;
  final Value<int> productId;
  final Value<double> quantity;
  final Value<double> unitPrice;
  final Value<double> discount;
  final Value<int> discountType;
  final Value<double> taxRate;
  final Value<String?> taxesJson;
  final Value<String?> comment;
  final Value<int> warehouseId;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const PosOrderItemsTableCompanion({
    this.localId = const Value.absent(),
    this.orderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.discount = const Value.absent(),
    this.discountType = const Value.absent(),
    this.taxRate = const Value.absent(),
    this.taxesJson = const Value.absent(),
    this.comment = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PosOrderItemsTableCompanion.insert({
    required String localId,
    required String orderId,
    required int productId,
    required double quantity,
    required double unitPrice,
    this.discount = const Value.absent(),
    this.discountType = const Value.absent(),
    this.taxRate = const Value.absent(),
    this.taxesJson = const Value.absent(),
    this.comment = const Value.absent(),
    required int warehouseId,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       orderId = Value(orderId),
       productId = Value(productId),
       quantity = Value(quantity),
       unitPrice = Value(unitPrice),
       warehouseId = Value(warehouseId);
  static Insertable<PosOrderItemsTableData> custom({
    Expression<String>? localId,
    Expression<String>? orderId,
    Expression<int>? productId,
    Expression<double>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? discount,
    Expression<int>? discountType,
    Expression<double>? taxRate,
    Expression<String>? taxesJson,
    Expression<String>? comment,
    Expression<int>? warehouseId,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (orderId != null) 'order_id': orderId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (discount != null) 'discount': discount,
      if (discountType != null) 'discount_type': discountType,
      if (taxRate != null) 'tax_rate': taxRate,
      if (taxesJson != null) 'taxes_json': taxesJson,
      if (comment != null) 'comment': comment,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PosOrderItemsTableCompanion copyWith({
    Value<String>? localId,
    Value<String>? orderId,
    Value<int>? productId,
    Value<double>? quantity,
    Value<double>? unitPrice,
    Value<double>? discount,
    Value<int>? discountType,
    Value<double>? taxRate,
    Value<String?>? taxesJson,
    Value<String?>? comment,
    Value<int>? warehouseId,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return PosOrderItemsTableCompanion(
      localId: localId ?? this.localId,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      taxRate: taxRate ?? this.taxRate,
      taxesJson: taxesJson ?? this.taxesJson,
      comment: comment ?? this.comment,
      warehouseId: warehouseId ?? this.warehouseId,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<int>(discountType.value);
    }
    if (taxRate.present) {
      map['tax_rate'] = Variable<double>(taxRate.value);
    }
    if (taxesJson.present) {
      map['taxes_json'] = Variable<String>(taxesJson.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<int>(warehouseId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PosOrderItemsTableCompanion(')
          ..write('localId: $localId, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('discount: $discount, ')
          ..write('discountType: $discountType, ')
          ..write('taxRate: $taxRate, ')
          ..write('taxesJson: $taxesJson, ')
          ..write('comment: $comment, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PosOrderItemTaxesTableTable extends PosOrderItemTaxesTable
    with TableInfo<$PosOrderItemTaxesTableTable, PosOrderItemTaxesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PosOrderItemTaxesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pos_orders (local_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxRateIdMeta = const VerificationMeta(
    'taxRateId',
  );
  @override
  late final GeneratedColumn<int> taxRateId = GeneratedColumn<int>(
    'tax_rate_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxAmountMeta = const VerificationMeta(
    'taxAmount',
  );
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
    'tax_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    orderId,
    productId,
    taxRateId,
    taxAmount,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pos_order_item_taxes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PosOrderItemTaxesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('tax_rate_id')) {
      context.handle(
        _taxRateIdMeta,
        taxRateId.isAcceptableOrUnknown(data['tax_rate_id']!, _taxRateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taxRateIdMeta);
    }
    if (data.containsKey('tax_amount')) {
      context.handle(
        _taxAmountMeta,
        taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_taxAmountMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  PosOrderItemTaxesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PosOrderItemTaxesTableData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      taxRateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_rate_id'],
      )!,
      taxAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_amount'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $PosOrderItemTaxesTableTable createAlias(String alias) {
    return $PosOrderItemTaxesTableTable(attachedDatabase, alias);
  }
}

class PosOrderItemTaxesTableData extends DataClass
    implements Insertable<PosOrderItemTaxesTableData> {
  final String localId;
  final String orderId;
  final int productId;
  final int taxRateId;
  final double taxAmount;
  final String syncStatus;
  const PosOrderItemTaxesTableData({
    required this.localId,
    required this.orderId,
    required this.productId,
    required this.taxRateId,
    required this.taxAmount,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['order_id'] = Variable<String>(orderId);
    map['product_id'] = Variable<int>(productId);
    map['tax_rate_id'] = Variable<int>(taxRateId);
    map['tax_amount'] = Variable<double>(taxAmount);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  PosOrderItemTaxesTableCompanion toCompanion(bool nullToAbsent) {
    return PosOrderItemTaxesTableCompanion(
      localId: Value(localId),
      orderId: Value(orderId),
      productId: Value(productId),
      taxRateId: Value(taxRateId),
      taxAmount: Value(taxAmount),
      syncStatus: Value(syncStatus),
    );
  }

  factory PosOrderItemTaxesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PosOrderItemTaxesTableData(
      localId: serializer.fromJson<String>(json['localId']),
      orderId: serializer.fromJson<String>(json['orderId']),
      productId: serializer.fromJson<int>(json['productId']),
      taxRateId: serializer.fromJson<int>(json['taxRateId']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'orderId': serializer.toJson<String>(orderId),
      'productId': serializer.toJson<int>(productId),
      'taxRateId': serializer.toJson<int>(taxRateId),
      'taxAmount': serializer.toJson<double>(taxAmount),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  PosOrderItemTaxesTableData copyWith({
    String? localId,
    String? orderId,
    int? productId,
    int? taxRateId,
    double? taxAmount,
    String? syncStatus,
  }) => PosOrderItemTaxesTableData(
    localId: localId ?? this.localId,
    orderId: orderId ?? this.orderId,
    productId: productId ?? this.productId,
    taxRateId: taxRateId ?? this.taxRateId,
    taxAmount: taxAmount ?? this.taxAmount,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  PosOrderItemTaxesTableData copyWithCompanion(
    PosOrderItemTaxesTableCompanion data,
  ) {
    return PosOrderItemTaxesTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      taxRateId: data.taxRateId.present ? data.taxRateId.value : this.taxRateId,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PosOrderItemTaxesTableData(')
          ..write('localId: $localId, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('taxRateId: $taxRateId, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    orderId,
    productId,
    taxRateId,
    taxAmount,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PosOrderItemTaxesTableData &&
          other.localId == this.localId &&
          other.orderId == this.orderId &&
          other.productId == this.productId &&
          other.taxRateId == this.taxRateId &&
          other.taxAmount == this.taxAmount &&
          other.syncStatus == this.syncStatus);
}

class PosOrderItemTaxesTableCompanion
    extends UpdateCompanion<PosOrderItemTaxesTableData> {
  final Value<String> localId;
  final Value<String> orderId;
  final Value<int> productId;
  final Value<int> taxRateId;
  final Value<double> taxAmount;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const PosOrderItemTaxesTableCompanion({
    this.localId = const Value.absent(),
    this.orderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.taxRateId = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PosOrderItemTaxesTableCompanion.insert({
    required String localId,
    required String orderId,
    required int productId,
    required int taxRateId,
    required double taxAmount,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       orderId = Value(orderId),
       productId = Value(productId),
       taxRateId = Value(taxRateId),
       taxAmount = Value(taxAmount);
  static Insertable<PosOrderItemTaxesTableData> custom({
    Expression<String>? localId,
    Expression<String>? orderId,
    Expression<int>? productId,
    Expression<int>? taxRateId,
    Expression<double>? taxAmount,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (orderId != null) 'order_id': orderId,
      if (productId != null) 'product_id': productId,
      if (taxRateId != null) 'tax_rate_id': taxRateId,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PosOrderItemTaxesTableCompanion copyWith({
    Value<String>? localId,
    Value<String>? orderId,
    Value<int>? productId,
    Value<int>? taxRateId,
    Value<double>? taxAmount,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return PosOrderItemTaxesTableCompanion(
      localId: localId ?? this.localId,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      taxRateId: taxRateId ?? this.taxRateId,
      taxAmount: taxAmount ?? this.taxAmount,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (taxRateId.present) {
      map['tax_rate_id'] = Variable<int>(taxRateId.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PosOrderItemTaxesTableCompanion(')
          ..write('localId: $localId, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('taxRateId: $taxRateId, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StartingCashTableTable extends StartingCashTable
    with TableInfo<$StartingCashTableTable, StartingCashTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StartingCashTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zReportNumberMeta = const VerificationMeta(
    'zReportNumber',
  );
  @override
  late final GeneratedColumn<int> zReportNumber = GeneratedColumn<int>(
    'z_report_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    companyId,
    userId,
    amount,
    type,
    note,
    createdAt,
    zReportNumber,
    syncStatus,
    syncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'starting_cash';
  @override
  VerificationContext validateIntegrity(
    Insertable<StartingCashTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('z_report_number')) {
      context.handle(
        _zReportNumberMeta,
        zReportNumber.isAcceptableOrUnknown(
          data['z_report_number']!,
          _zReportNumberMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  StartingCashTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StartingCashTableData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      zReportNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}z_report_number'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
    );
  }

  @override
  $StartingCashTableTable createAlias(String alias) {
    return $StartingCashTableTable(attachedDatabase, alias);
  }
}

class StartingCashTableData extends DataClass
    implements Insertable<StartingCashTableData> {
  final String localId;
  final int? serverId;
  final int companyId;
  final int userId;
  final double amount;
  final String type;
  final String? note;
  final DateTime createdAt;

  /// Server Z-report number (mirrors `StartingCash.ZReportNumber`). NULL while
  /// the entry is active/unfinalized; once a Z-report is generated the server
  /// stamps this and the next pull hides the row from the active list.
  final int? zReportNumber;
  final String syncStatus;
  final String? syncError;
  const StartingCashTableData({
    required this.localId,
    this.serverId,
    required this.companyId,
    required this.userId,
    required this.amount,
    required this.type,
    this.note,
    required this.createdAt,
    this.zReportNumber,
    required this.syncStatus,
    this.syncError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['company_id'] = Variable<int>(companyId);
    map['user_id'] = Variable<int>(userId);
    map['amount'] = Variable<double>(amount);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || zReportNumber != null) {
      map['z_report_number'] = Variable<int>(zReportNumber);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  StartingCashTableCompanion toCompanion(bool nullToAbsent) {
    return StartingCashTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      companyId: Value(companyId),
      userId: Value(userId),
      amount: Value(amount),
      type: Value(type),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      zReportNumber: zReportNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(zReportNumber),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory StartingCashTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StartingCashTableData(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      companyId: serializer.fromJson<int>(json['companyId']),
      userId: serializer.fromJson<int>(json['userId']),
      amount: serializer.fromJson<double>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      zReportNumber: serializer.fromJson<int?>(json['zReportNumber']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<int?>(serverId),
      'companyId': serializer.toJson<int>(companyId),
      'userId': serializer.toJson<int>(userId),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<String>(type),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'zReportNumber': serializer.toJson<int?>(zReportNumber),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  StartingCashTableData copyWith({
    String? localId,
    Value<int?> serverId = const Value.absent(),
    int? companyId,
    int? userId,
    double? amount,
    String? type,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    Value<int?> zReportNumber = const Value.absent(),
    String? syncStatus,
    Value<String?> syncError = const Value.absent(),
  }) => StartingCashTableData(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    companyId: companyId ?? this.companyId,
    userId: userId ?? this.userId,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    zReportNumber: zReportNumber.present
        ? zReportNumber.value
        : this.zReportNumber,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
  );
  StartingCashTableData copyWithCompanion(StartingCashTableCompanion data) {
    return StartingCashTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      userId: data.userId.present ? data.userId.value : this.userId,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      zReportNumber: data.zReportNumber.present
          ? data.zReportNumber.value
          : this.zReportNumber,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StartingCashTableData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('companyId: $companyId, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('zReportNumber: $zReportNumber, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    companyId,
    userId,
    amount,
    type,
    note,
    createdAt,
    zReportNumber,
    syncStatus,
    syncError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StartingCashTableData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.companyId == this.companyId &&
          other.userId == this.userId &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.zReportNumber == this.zReportNumber &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError);
}

class StartingCashTableCompanion
    extends UpdateCompanion<StartingCashTableData> {
  final Value<String> localId;
  final Value<int?> serverId;
  final Value<int> companyId;
  final Value<int> userId;
  final Value<double> amount;
  final Value<String> type;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int?> zReportNumber;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  final Value<int> rowid;
  const StartingCashTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.userId = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.zReportNumber = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StartingCashTableCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required int companyId,
    required int userId,
    required double amount,
    required String type,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.zReportNumber = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       companyId = Value(companyId),
       userId = Value(userId),
       amount = Value(amount),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<StartingCashTableData> custom({
    Expression<String>? localId,
    Expression<int>? serverId,
    Expression<int>? companyId,
    Expression<int>? userId,
    Expression<double>? amount,
    Expression<String>? type,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? zReportNumber,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (companyId != null) 'company_id': companyId,
      if (userId != null) 'user_id': userId,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (zReportNumber != null) 'z_report_number': zReportNumber,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StartingCashTableCompanion copyWith({
    Value<String>? localId,
    Value<int?>? serverId,
    Value<int>? companyId,
    Value<int>? userId,
    Value<double>? amount,
    Value<String>? type,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int?>? zReportNumber,
    Value<String>? syncStatus,
    Value<String?>? syncError,
    Value<int>? rowid,
  }) {
    return StartingCashTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      zReportNumber: zReportNumber ?? this.zReportNumber,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (zReportNumber.present) {
      map['z_report_number'] = Variable<int>(zReportNumber.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StartingCashTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('companyId: $companyId, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('zReportNumber: $zReportNumber, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ZReportsTableTable extends ZReportsTable
    with TableInfo<$ZReportsTableTable, ZReportsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZReportsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalSalesMeta = const VerificationMeta(
    'totalSales',
  );
  @override
  late final GeneratedColumn<double> totalSales = GeneratedColumn<double>(
    'total_sales',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCashInMeta = const VerificationMeta(
    'totalCashIn',
  );
  @override
  late final GeneratedColumn<double> totalCashIn = GeneratedColumn<double>(
    'total_cash_in',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCashOutMeta = const VerificationMeta(
    'totalCashOut',
  );
  @override
  late final GeneratedColumn<double> totalCashOut = GeneratedColumn<double>(
    'total_cash_out',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentBreakdownJsonMeta =
      const VerificationMeta('paymentBreakdownJson');
  @override
  late final GeneratedColumn<String> paymentBreakdownJson =
      GeneratedColumn<String>(
        'payment_breakdown_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    companyId,
    userId,
    totalSales,
    totalCashIn,
    totalCashOut,
    paymentBreakdownJson,
    closedAt,
    syncStatus,
    syncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'z_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<ZReportsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('total_sales')) {
      context.handle(
        _totalSalesMeta,
        totalSales.isAcceptableOrUnknown(data['total_sales']!, _totalSalesMeta),
      );
    } else if (isInserting) {
      context.missing(_totalSalesMeta);
    }
    if (data.containsKey('total_cash_in')) {
      context.handle(
        _totalCashInMeta,
        totalCashIn.isAcceptableOrUnknown(
          data['total_cash_in']!,
          _totalCashInMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalCashInMeta);
    }
    if (data.containsKey('total_cash_out')) {
      context.handle(
        _totalCashOutMeta,
        totalCashOut.isAcceptableOrUnknown(
          data['total_cash_out']!,
          _totalCashOutMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalCashOutMeta);
    }
    if (data.containsKey('payment_breakdown_json')) {
      context.handle(
        _paymentBreakdownJsonMeta,
        paymentBreakdownJson.isAcceptableOrUnknown(
          data['payment_breakdown_json']!,
          _paymentBreakdownJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentBreakdownJsonMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_closedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  ZReportsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZReportsTableData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      totalSales: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_sales'],
      )!,
      totalCashIn: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_cash_in'],
      )!,
      totalCashOut: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_cash_out'],
      )!,
      paymentBreakdownJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_breakdown_json'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
    );
  }

  @override
  $ZReportsTableTable createAlias(String alias) {
    return $ZReportsTableTable(attachedDatabase, alias);
  }
}

class ZReportsTableData extends DataClass
    implements Insertable<ZReportsTableData> {
  final String localId;
  final int? serverId;
  final int companyId;
  final int userId;
  final double totalSales;
  final double totalCashIn;
  final double totalCashOut;
  final String paymentBreakdownJson;
  final DateTime closedAt;
  final String syncStatus;
  final String? syncError;
  const ZReportsTableData({
    required this.localId,
    this.serverId,
    required this.companyId,
    required this.userId,
    required this.totalSales,
    required this.totalCashIn,
    required this.totalCashOut,
    required this.paymentBreakdownJson,
    required this.closedAt,
    required this.syncStatus,
    this.syncError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['company_id'] = Variable<int>(companyId);
    map['user_id'] = Variable<int>(userId);
    map['total_sales'] = Variable<double>(totalSales);
    map['total_cash_in'] = Variable<double>(totalCashIn);
    map['total_cash_out'] = Variable<double>(totalCashOut);
    map['payment_breakdown_json'] = Variable<String>(paymentBreakdownJson);
    map['closed_at'] = Variable<DateTime>(closedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  ZReportsTableCompanion toCompanion(bool nullToAbsent) {
    return ZReportsTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      companyId: Value(companyId),
      userId: Value(userId),
      totalSales: Value(totalSales),
      totalCashIn: Value(totalCashIn),
      totalCashOut: Value(totalCashOut),
      paymentBreakdownJson: Value(paymentBreakdownJson),
      closedAt: Value(closedAt),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory ZReportsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZReportsTableData(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      companyId: serializer.fromJson<int>(json['companyId']),
      userId: serializer.fromJson<int>(json['userId']),
      totalSales: serializer.fromJson<double>(json['totalSales']),
      totalCashIn: serializer.fromJson<double>(json['totalCashIn']),
      totalCashOut: serializer.fromJson<double>(json['totalCashOut']),
      paymentBreakdownJson: serializer.fromJson<String>(
        json['paymentBreakdownJson'],
      ),
      closedAt: serializer.fromJson<DateTime>(json['closedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<int?>(serverId),
      'companyId': serializer.toJson<int>(companyId),
      'userId': serializer.toJson<int>(userId),
      'totalSales': serializer.toJson<double>(totalSales),
      'totalCashIn': serializer.toJson<double>(totalCashIn),
      'totalCashOut': serializer.toJson<double>(totalCashOut),
      'paymentBreakdownJson': serializer.toJson<String>(paymentBreakdownJson),
      'closedAt': serializer.toJson<DateTime>(closedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  ZReportsTableData copyWith({
    String? localId,
    Value<int?> serverId = const Value.absent(),
    int? companyId,
    int? userId,
    double? totalSales,
    double? totalCashIn,
    double? totalCashOut,
    String? paymentBreakdownJson,
    DateTime? closedAt,
    String? syncStatus,
    Value<String?> syncError = const Value.absent(),
  }) => ZReportsTableData(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    companyId: companyId ?? this.companyId,
    userId: userId ?? this.userId,
    totalSales: totalSales ?? this.totalSales,
    totalCashIn: totalCashIn ?? this.totalCashIn,
    totalCashOut: totalCashOut ?? this.totalCashOut,
    paymentBreakdownJson: paymentBreakdownJson ?? this.paymentBreakdownJson,
    closedAt: closedAt ?? this.closedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
  );
  ZReportsTableData copyWithCompanion(ZReportsTableCompanion data) {
    return ZReportsTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      userId: data.userId.present ? data.userId.value : this.userId,
      totalSales: data.totalSales.present
          ? data.totalSales.value
          : this.totalSales,
      totalCashIn: data.totalCashIn.present
          ? data.totalCashIn.value
          : this.totalCashIn,
      totalCashOut: data.totalCashOut.present
          ? data.totalCashOut.value
          : this.totalCashOut,
      paymentBreakdownJson: data.paymentBreakdownJson.present
          ? data.paymentBreakdownJson.value
          : this.paymentBreakdownJson,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZReportsTableData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('companyId: $companyId, ')
          ..write('userId: $userId, ')
          ..write('totalSales: $totalSales, ')
          ..write('totalCashIn: $totalCashIn, ')
          ..write('totalCashOut: $totalCashOut, ')
          ..write('paymentBreakdownJson: $paymentBreakdownJson, ')
          ..write('closedAt: $closedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    companyId,
    userId,
    totalSales,
    totalCashIn,
    totalCashOut,
    paymentBreakdownJson,
    closedAt,
    syncStatus,
    syncError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZReportsTableData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.companyId == this.companyId &&
          other.userId == this.userId &&
          other.totalSales == this.totalSales &&
          other.totalCashIn == this.totalCashIn &&
          other.totalCashOut == this.totalCashOut &&
          other.paymentBreakdownJson == this.paymentBreakdownJson &&
          other.closedAt == this.closedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError);
}

class ZReportsTableCompanion extends UpdateCompanion<ZReportsTableData> {
  final Value<String> localId;
  final Value<int?> serverId;
  final Value<int> companyId;
  final Value<int> userId;
  final Value<double> totalSales;
  final Value<double> totalCashIn;
  final Value<double> totalCashOut;
  final Value<String> paymentBreakdownJson;
  final Value<DateTime> closedAt;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  final Value<int> rowid;
  const ZReportsTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.userId = const Value.absent(),
    this.totalSales = const Value.absent(),
    this.totalCashIn = const Value.absent(),
    this.totalCashOut = const Value.absent(),
    this.paymentBreakdownJson = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ZReportsTableCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required int companyId,
    required int userId,
    required double totalSales,
    required double totalCashIn,
    required double totalCashOut,
    required String paymentBreakdownJson,
    required DateTime closedAt,
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       companyId = Value(companyId),
       userId = Value(userId),
       totalSales = Value(totalSales),
       totalCashIn = Value(totalCashIn),
       totalCashOut = Value(totalCashOut),
       paymentBreakdownJson = Value(paymentBreakdownJson),
       closedAt = Value(closedAt);
  static Insertable<ZReportsTableData> custom({
    Expression<String>? localId,
    Expression<int>? serverId,
    Expression<int>? companyId,
    Expression<int>? userId,
    Expression<double>? totalSales,
    Expression<double>? totalCashIn,
    Expression<double>? totalCashOut,
    Expression<String>? paymentBreakdownJson,
    Expression<DateTime>? closedAt,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (companyId != null) 'company_id': companyId,
      if (userId != null) 'user_id': userId,
      if (totalSales != null) 'total_sales': totalSales,
      if (totalCashIn != null) 'total_cash_in': totalCashIn,
      if (totalCashOut != null) 'total_cash_out': totalCashOut,
      if (paymentBreakdownJson != null)
        'payment_breakdown_json': paymentBreakdownJson,
      if (closedAt != null) 'closed_at': closedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ZReportsTableCompanion copyWith({
    Value<String>? localId,
    Value<int?>? serverId,
    Value<int>? companyId,
    Value<int>? userId,
    Value<double>? totalSales,
    Value<double>? totalCashIn,
    Value<double>? totalCashOut,
    Value<String>? paymentBreakdownJson,
    Value<DateTime>? closedAt,
    Value<String>? syncStatus,
    Value<String?>? syncError,
    Value<int>? rowid,
  }) {
    return ZReportsTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      totalSales: totalSales ?? this.totalSales,
      totalCashIn: totalCashIn ?? this.totalCashIn,
      totalCashOut: totalCashOut ?? this.totalCashOut,
      paymentBreakdownJson: paymentBreakdownJson ?? this.paymentBreakdownJson,
      closedAt: closedAt ?? this.closedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (totalSales.present) {
      map['total_sales'] = Variable<double>(totalSales.value);
    }
    if (totalCashIn.present) {
      map['total_cash_in'] = Variable<double>(totalCashIn.value);
    }
    if (totalCashOut.present) {
      map['total_cash_out'] = Variable<double>(totalCashOut.value);
    }
    if (paymentBreakdownJson.present) {
      map['payment_breakdown_json'] = Variable<String>(
        paymentBreakdownJson.value,
      );
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZReportsTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('companyId: $companyId, ')
          ..write('userId: $userId, ')
          ..write('totalSales: $totalSales, ')
          ..write('totalCashIn: $totalCashIn, ')
          ..write('totalCashOut: $totalCashOut, ')
          ..write('paymentBreakdownJson: $paymentBreakdownJson, ')
          ..write('closedAt: $closedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTableTable extends SyncMetaTable
    with TableInfo<$SyncMetaTableTable, SyncMetaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [entity, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity};
  @override
  SyncMetaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaTableData(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $SyncMetaTableTable createAlias(String alias) {
    return $SyncMetaTableTable(attachedDatabase, alias);
  }
}

class SyncMetaTableData extends DataClass
    implements Insertable<SyncMetaTableData> {
  final String entity;
  final DateTime? lastSyncedAt;
  const SyncMetaTableData({required this.entity, this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  SyncMetaTableCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaTableCompanion(
      entity: Value(entity),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory SyncMetaTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaTableData(
      entity: serializer.fromJson<String>(json['entity']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  SyncMetaTableData copyWith({
    String? entity,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => SyncMetaTableData(
    entity: entity ?? this.entity,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  SyncMetaTableData copyWithCompanion(SyncMetaTableCompanion data) {
    return SyncMetaTableData(
      entity: data.entity.present ? data.entity.value : this.entity,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaTableData(')
          ..write('entity: $entity, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaTableData &&
          other.entity == this.entity &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncMetaTableCompanion extends UpdateCompanion<SyncMetaTableData> {
  final Value<String> entity;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const SyncMetaTableCompanion({
    this.entity = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaTableCompanion.insert({
    required String entity,
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entity = Value(entity);
  static Insertable<SyncMetaTableData> custom({
    Expression<String>? entity,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaTableCompanion copyWith({
    Value<String>? entity,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return SyncMetaTableCompanion(
      entity: entity ?? this.entity,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaTableCompanion(')
          ..write('entity: $entity, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StocksTableTable extends StocksTable
    with TableInfo<$StocksTableTable, StocksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StocksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _warehouseIdMeta = const VerificationMeta(
    'warehouseId',
  );
  @override
  late final GeneratedColumn<int> warehouseId = GeneratedColumn<int>(
    'warehouse_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    warehouseId,
    companyId,
    quantity,
    lastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<StocksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
        _warehouseIdMeta,
        warehouseId.isAcceptableOrUnknown(
          data['warehouse_id']!,
          _warehouseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StocksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StocksTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      warehouseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warehouse_id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
    );
  }

  @override
  $StocksTableTable createAlias(String alias) {
    return $StocksTableTable(attachedDatabase, alias);
  }
}

class StocksTableData extends DataClass implements Insertable<StocksTableData> {
  final int id;
  final int productId;
  final int warehouseId;
  final int companyId;
  final double quantity;
  final DateTime lastModified;
  const StocksTableData({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.companyId,
    required this.quantity,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    map['warehouse_id'] = Variable<int>(warehouseId);
    map['company_id'] = Variable<int>(companyId);
    map['quantity'] = Variable<double>(quantity);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  StocksTableCompanion toCompanion(bool nullToAbsent) {
    return StocksTableCompanion(
      id: Value(id),
      productId: Value(productId),
      warehouseId: Value(warehouseId),
      companyId: Value(companyId),
      quantity: Value(quantity),
      lastModified: Value(lastModified),
    );
  }

  factory StocksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StocksTableData(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      warehouseId: serializer.fromJson<int>(json['warehouseId']),
      companyId: serializer.fromJson<int>(json['companyId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'warehouseId': serializer.toJson<int>(warehouseId),
      'companyId': serializer.toJson<int>(companyId),
      'quantity': serializer.toJson<double>(quantity),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  StocksTableData copyWith({
    int? id,
    int? productId,
    int? warehouseId,
    int? companyId,
    double? quantity,
    DateTime? lastModified,
  }) => StocksTableData(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    warehouseId: warehouseId ?? this.warehouseId,
    companyId: companyId ?? this.companyId,
    quantity: quantity ?? this.quantity,
    lastModified: lastModified ?? this.lastModified,
  );
  StocksTableData copyWithCompanion(StocksTableCompanion data) {
    return StocksTableData(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      warehouseId: data.warehouseId.present
          ? data.warehouseId.value
          : this.warehouseId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StocksTableData(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('companyId: $companyId, ')
          ..write('quantity: $quantity, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    warehouseId,
    companyId,
    quantity,
    lastModified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StocksTableData &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.warehouseId == this.warehouseId &&
          other.companyId == this.companyId &&
          other.quantity == this.quantity &&
          other.lastModified == this.lastModified);
}

class StocksTableCompanion extends UpdateCompanion<StocksTableData> {
  final Value<int> id;
  final Value<int> productId;
  final Value<int> warehouseId;
  final Value<int> companyId;
  final Value<double> quantity;
  final Value<DateTime> lastModified;
  const StocksTableCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  StocksTableCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    required int warehouseId,
    required int companyId,
    this.quantity = const Value.absent(),
    required DateTime lastModified,
  }) : productId = Value(productId),
       warehouseId = Value(warehouseId),
       companyId = Value(companyId),
       lastModified = Value(lastModified);
  static Insertable<StocksTableData> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<int>? warehouseId,
    Expression<int>? companyId,
    Expression<double>? quantity,
    Expression<DateTime>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (companyId != null) 'company_id': companyId,
      if (quantity != null) 'quantity': quantity,
      if (lastModified != null) 'last_modified': lastModified,
    });
  }

  StocksTableCompanion copyWith({
    Value<int>? id,
    Value<int>? productId,
    Value<int>? warehouseId,
    Value<int>? companyId,
    Value<double>? quantity,
    Value<DateTime>? lastModified,
  }) {
    return StocksTableCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      warehouseId: warehouseId ?? this.warehouseId,
      companyId: companyId ?? this.companyId,
      quantity: quantity ?? this.quantity,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<int>(warehouseId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StocksTableCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('companyId: $companyId, ')
          ..write('quantity: $quantity, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }
}

class $PendingVoidsTableTable extends PendingVoidsTable
    with TableInfo<$PendingVoidsTableTable, PendingVoidsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingVoidsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverOrderIdMeta = const VerificationMeta(
    'serverOrderId',
  );
  @override
  late final GeneratedColumn<int> serverOrderId = GeneratedColumn<int>(
    'server_order_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderNumberMeta = const VerificationMeta(
    'orderNumber',
  );
  @override
  late final GeneratedColumn<String> orderNumber = GeneratedColumn<String>(
    'order_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _warehouseIdMeta = const VerificationMeta(
    'warehouseId',
  );
  @override
  late final GeneratedColumn<int> warehouseId = GeneratedColumn<int>(
    'warehouse_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemsJsonMeta = const VerificationMeta(
    'itemsJson',
  );
  @override
  late final GeneratedColumn<String> itemsJson = GeneratedColumn<String>(
    'items_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidedAtMeta = const VerificationMeta(
    'voidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> voidedAt = GeneratedColumn<DateTime>(
    'voided_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverOrderId,
    companyId,
    userId,
    orderNumber,
    warehouseId,
    itemsJson,
    reason,
    voidedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_voids';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingVoidsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_order_id')) {
      context.handle(
        _serverOrderIdMeta,
        serverOrderId.isAcceptableOrUnknown(
          data['server_order_id']!,
          _serverOrderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverOrderIdMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('order_number')) {
      context.handle(
        _orderNumberMeta,
        orderNumber.isAcceptableOrUnknown(
          data['order_number']!,
          _orderNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_orderNumberMeta);
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
        _warehouseIdMeta,
        warehouseId.isAcceptableOrUnknown(
          data['warehouse_id']!,
          _warehouseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('items_json')) {
      context.handle(
        _itemsJsonMeta,
        itemsJson.isAcceptableOrUnknown(data['items_json']!, _itemsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_itemsJsonMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('voided_at')) {
      context.handle(
        _voidedAtMeta,
        voidedAt.isAcceptableOrUnknown(data['voided_at']!, _voidedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_voidedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  PendingVoidsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingVoidsTableData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverOrderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_order_id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      orderNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_number'],
      )!,
      warehouseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warehouse_id'],
      )!,
      itemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}items_json'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      voidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}voided_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $PendingVoidsTableTable createAlias(String alias) {
    return $PendingVoidsTableTable(attachedDatabase, alias);
  }
}

class PendingVoidsTableData extends DataClass
    implements Insertable<PendingVoidsTableData> {
  final String localId;
  final int serverOrderId;
  final int companyId;
  final int userId;
  final String orderNumber;
  final int warehouseId;
  final String itemsJson;
  final String? reason;
  final DateTime voidedAt;
  final String syncStatus;
  const PendingVoidsTableData({
    required this.localId,
    required this.serverOrderId,
    required this.companyId,
    required this.userId,
    required this.orderNumber,
    required this.warehouseId,
    required this.itemsJson,
    this.reason,
    required this.voidedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['server_order_id'] = Variable<int>(serverOrderId);
    map['company_id'] = Variable<int>(companyId);
    map['user_id'] = Variable<int>(userId);
    map['order_number'] = Variable<String>(orderNumber);
    map['warehouse_id'] = Variable<int>(warehouseId);
    map['items_json'] = Variable<String>(itemsJson);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['voided_at'] = Variable<DateTime>(voidedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  PendingVoidsTableCompanion toCompanion(bool nullToAbsent) {
    return PendingVoidsTableCompanion(
      localId: Value(localId),
      serverOrderId: Value(serverOrderId),
      companyId: Value(companyId),
      userId: Value(userId),
      orderNumber: Value(orderNumber),
      warehouseId: Value(warehouseId),
      itemsJson: Value(itemsJson),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      voidedAt: Value(voidedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory PendingVoidsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingVoidsTableData(
      localId: serializer.fromJson<String>(json['localId']),
      serverOrderId: serializer.fromJson<int>(json['serverOrderId']),
      companyId: serializer.fromJson<int>(json['companyId']),
      userId: serializer.fromJson<int>(json['userId']),
      orderNumber: serializer.fromJson<String>(json['orderNumber']),
      warehouseId: serializer.fromJson<int>(json['warehouseId']),
      itemsJson: serializer.fromJson<String>(json['itemsJson']),
      reason: serializer.fromJson<String?>(json['reason']),
      voidedAt: serializer.fromJson<DateTime>(json['voidedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverOrderId': serializer.toJson<int>(serverOrderId),
      'companyId': serializer.toJson<int>(companyId),
      'userId': serializer.toJson<int>(userId),
      'orderNumber': serializer.toJson<String>(orderNumber),
      'warehouseId': serializer.toJson<int>(warehouseId),
      'itemsJson': serializer.toJson<String>(itemsJson),
      'reason': serializer.toJson<String?>(reason),
      'voidedAt': serializer.toJson<DateTime>(voidedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  PendingVoidsTableData copyWith({
    String? localId,
    int? serverOrderId,
    int? companyId,
    int? userId,
    String? orderNumber,
    int? warehouseId,
    String? itemsJson,
    Value<String?> reason = const Value.absent(),
    DateTime? voidedAt,
    String? syncStatus,
  }) => PendingVoidsTableData(
    localId: localId ?? this.localId,
    serverOrderId: serverOrderId ?? this.serverOrderId,
    companyId: companyId ?? this.companyId,
    userId: userId ?? this.userId,
    orderNumber: orderNumber ?? this.orderNumber,
    warehouseId: warehouseId ?? this.warehouseId,
    itemsJson: itemsJson ?? this.itemsJson,
    reason: reason.present ? reason.value : this.reason,
    voidedAt: voidedAt ?? this.voidedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  PendingVoidsTableData copyWithCompanion(PendingVoidsTableCompanion data) {
    return PendingVoidsTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverOrderId: data.serverOrderId.present
          ? data.serverOrderId.value
          : this.serverOrderId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      userId: data.userId.present ? data.userId.value : this.userId,
      orderNumber: data.orderNumber.present
          ? data.orderNumber.value
          : this.orderNumber,
      warehouseId: data.warehouseId.present
          ? data.warehouseId.value
          : this.warehouseId,
      itemsJson: data.itemsJson.present ? data.itemsJson.value : this.itemsJson,
      reason: data.reason.present ? data.reason.value : this.reason,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingVoidsTableData(')
          ..write('localId: $localId, ')
          ..write('serverOrderId: $serverOrderId, ')
          ..write('companyId: $companyId, ')
          ..write('userId: $userId, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('reason: $reason, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverOrderId,
    companyId,
    userId,
    orderNumber,
    warehouseId,
    itemsJson,
    reason,
    voidedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingVoidsTableData &&
          other.localId == this.localId &&
          other.serverOrderId == this.serverOrderId &&
          other.companyId == this.companyId &&
          other.userId == this.userId &&
          other.orderNumber == this.orderNumber &&
          other.warehouseId == this.warehouseId &&
          other.itemsJson == this.itemsJson &&
          other.reason == this.reason &&
          other.voidedAt == this.voidedAt &&
          other.syncStatus == this.syncStatus);
}

class PendingVoidsTableCompanion
    extends UpdateCompanion<PendingVoidsTableData> {
  final Value<String> localId;
  final Value<int> serverOrderId;
  final Value<int> companyId;
  final Value<int> userId;
  final Value<String> orderNumber;
  final Value<int> warehouseId;
  final Value<String> itemsJson;
  final Value<String?> reason;
  final Value<DateTime> voidedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const PendingVoidsTableCompanion({
    this.localId = const Value.absent(),
    this.serverOrderId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.userId = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.reason = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingVoidsTableCompanion.insert({
    required String localId,
    required int serverOrderId,
    required int companyId,
    required int userId,
    required String orderNumber,
    required int warehouseId,
    required String itemsJson,
    this.reason = const Value.absent(),
    required DateTime voidedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       serverOrderId = Value(serverOrderId),
       companyId = Value(companyId),
       userId = Value(userId),
       orderNumber = Value(orderNumber),
       warehouseId = Value(warehouseId),
       itemsJson = Value(itemsJson),
       voidedAt = Value(voidedAt);
  static Insertable<PendingVoidsTableData> custom({
    Expression<String>? localId,
    Expression<int>? serverOrderId,
    Expression<int>? companyId,
    Expression<int>? userId,
    Expression<String>? orderNumber,
    Expression<int>? warehouseId,
    Expression<String>? itemsJson,
    Expression<String>? reason,
    Expression<DateTime>? voidedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverOrderId != null) 'server_order_id': serverOrderId,
      if (companyId != null) 'company_id': companyId,
      if (userId != null) 'user_id': userId,
      if (orderNumber != null) 'order_number': orderNumber,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (itemsJson != null) 'items_json': itemsJson,
      if (reason != null) 'reason': reason,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingVoidsTableCompanion copyWith({
    Value<String>? localId,
    Value<int>? serverOrderId,
    Value<int>? companyId,
    Value<int>? userId,
    Value<String>? orderNumber,
    Value<int>? warehouseId,
    Value<String>? itemsJson,
    Value<String?>? reason,
    Value<DateTime>? voidedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return PendingVoidsTableCompanion(
      localId: localId ?? this.localId,
      serverOrderId: serverOrderId ?? this.serverOrderId,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      warehouseId: warehouseId ?? this.warehouseId,
      itemsJson: itemsJson ?? this.itemsJson,
      reason: reason ?? this.reason,
      voidedAt: voidedAt ?? this.voidedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverOrderId.present) {
      map['server_order_id'] = Variable<int>(serverOrderId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (orderNumber.present) {
      map['order_number'] = Variable<String>(orderNumber.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<int>(warehouseId.value);
    }
    if (itemsJson.present) {
      map['items_json'] = Variable<String>(itemsJson.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<DateTime>(voidedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingVoidsTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverOrderId: $serverOrderId, ')
          ..write('companyId: $companyId, ')
          ..write('userId: $userId, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('reason: $reason, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTableTable extends DocumentsTable
    with TableInfo<$DocumentsTableTable, DocumentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentTypeIdMeta = const VerificationMeta(
    'documentTypeId',
  );
  @override
  late final GeneratedColumn<int> documentTypeId = GeneratedColumn<int>(
    'document_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _warehouseIdMeta = const VerificationMeta(
    'warehouseId',
  );
  @override
  late final GeneratedColumn<int> warehouseId = GeneratedColumn<int>(
    'warehouse_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountMeta = const VerificationMeta(
    'discount',
  );
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
    'discount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountTypeMeta = const VerificationMeta(
    'discountType',
  );
  @override
  late final GeneratedColumn<int> discountType = GeneratedColumn<int>(
    'discount_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderNumberMeta = const VerificationMeta(
    'orderNumber',
  );
  @override
  late final GeneratedColumn<String> orderNumber = GeneratedColumn<String>(
    'order_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serviceTypeMeta = const VerificationMeta(
    'serviceType',
  );
  @override
  late final GeneratedColumn<int> serviceType = GeneratedColumn<int>(
    'service_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paidStatusMeta = const VerificationMeta(
    'paidStatus',
  );
  @override
  late final GeneratedColumn<int> paidStatus = GeneratedColumn<int>(
    'paid_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    companyId,
    documentTypeId,
    number,
    userId,
    warehouseId,
    total,
    discount,
    discountType,
    customerId,
    orderNumber,
    serviceType,
    paidStatus,
    date,
    syncStatus,
    lastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('document_type_id')) {
      context.handle(
        _documentTypeIdMeta,
        documentTypeId.isAcceptableOrUnknown(
          data['document_type_id']!,
          _documentTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
        _warehouseIdMeta,
        warehouseId.isAcceptableOrUnknown(
          data['warehouse_id']!,
          _warehouseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    if (data.containsKey('discount')) {
      context.handle(
        _discountMeta,
        discount.isAcceptableOrUnknown(data['discount']!, _discountMeta),
      );
    }
    if (data.containsKey('discount_type')) {
      context.handle(
        _discountTypeMeta,
        discountType.isAcceptableOrUnknown(
          data['discount_type']!,
          _discountTypeMeta,
        ),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('order_number')) {
      context.handle(
        _orderNumberMeta,
        orderNumber.isAcceptableOrUnknown(
          data['order_number']!,
          _orderNumberMeta,
        ),
      );
    }
    if (data.containsKey('service_type')) {
      context.handle(
        _serviceTypeMeta,
        serviceType.isAcceptableOrUnknown(
          data['service_type']!,
          _serviceTypeMeta,
        ),
      );
    }
    if (data.containsKey('paid_status')) {
      context.handle(
        _paidStatusMeta,
        paidStatus.isAcceptableOrUnknown(data['paid_status']!, _paidStatusMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  DocumentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentsTableData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      documentTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}document_type_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      warehouseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warehouse_id'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      discount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount'],
      )!,
      discountType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_type'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      ),
      orderNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_number'],
      ),
      serviceType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}service_type'],
      )!,
      paidStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_status'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
    );
  }

  @override
  $DocumentsTableTable createAlias(String alias) {
    return $DocumentsTableTable(attachedDatabase, alias);
  }
}

class DocumentsTableData extends DataClass
    implements Insertable<DocumentsTableData> {
  final String localId;
  final int? serverId;
  final int companyId;
  final int documentTypeId;
  final String? number;
  final int userId;
  final int warehouseId;
  final double total;
  final double discount;
  final int discountType;
  final int? customerId;
  final String? orderNumber;
  final int serviceType;
  final int paidStatus;
  final DateTime date;
  final String syncStatus;
  final DateTime lastModified;
  const DocumentsTableData({
    required this.localId,
    this.serverId,
    required this.companyId,
    required this.documentTypeId,
    this.number,
    required this.userId,
    required this.warehouseId,
    required this.total,
    required this.discount,
    required this.discountType,
    this.customerId,
    this.orderNumber,
    required this.serviceType,
    required this.paidStatus,
    required this.date,
    required this.syncStatus,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['company_id'] = Variable<int>(companyId);
    map['document_type_id'] = Variable<int>(documentTypeId);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<String>(number);
    }
    map['user_id'] = Variable<int>(userId);
    map['warehouse_id'] = Variable<int>(warehouseId);
    map['total'] = Variable<double>(total);
    map['discount'] = Variable<double>(discount);
    map['discount_type'] = Variable<int>(discountType);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<int>(customerId);
    }
    if (!nullToAbsent || orderNumber != null) {
      map['order_number'] = Variable<String>(orderNumber);
    }
    map['service_type'] = Variable<int>(serviceType);
    map['paid_status'] = Variable<int>(paidStatus);
    map['date'] = Variable<DateTime>(date);
    map['sync_status'] = Variable<String>(syncStatus);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  DocumentsTableCompanion toCompanion(bool nullToAbsent) {
    return DocumentsTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      companyId: Value(companyId),
      documentTypeId: Value(documentTypeId),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      userId: Value(userId),
      warehouseId: Value(warehouseId),
      total: Value(total),
      discount: Value(discount),
      discountType: Value(discountType),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      orderNumber: orderNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(orderNumber),
      serviceType: Value(serviceType),
      paidStatus: Value(paidStatus),
      date: Value(date),
      syncStatus: Value(syncStatus),
      lastModified: Value(lastModified),
    );
  }

  factory DocumentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentsTableData(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      companyId: serializer.fromJson<int>(json['companyId']),
      documentTypeId: serializer.fromJson<int>(json['documentTypeId']),
      number: serializer.fromJson<String?>(json['number']),
      userId: serializer.fromJson<int>(json['userId']),
      warehouseId: serializer.fromJson<int>(json['warehouseId']),
      total: serializer.fromJson<double>(json['total']),
      discount: serializer.fromJson<double>(json['discount']),
      discountType: serializer.fromJson<int>(json['discountType']),
      customerId: serializer.fromJson<int?>(json['customerId']),
      orderNumber: serializer.fromJson<String?>(json['orderNumber']),
      serviceType: serializer.fromJson<int>(json['serviceType']),
      paidStatus: serializer.fromJson<int>(json['paidStatus']),
      date: serializer.fromJson<DateTime>(json['date']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<int?>(serverId),
      'companyId': serializer.toJson<int>(companyId),
      'documentTypeId': serializer.toJson<int>(documentTypeId),
      'number': serializer.toJson<String?>(number),
      'userId': serializer.toJson<int>(userId),
      'warehouseId': serializer.toJson<int>(warehouseId),
      'total': serializer.toJson<double>(total),
      'discount': serializer.toJson<double>(discount),
      'discountType': serializer.toJson<int>(discountType),
      'customerId': serializer.toJson<int?>(customerId),
      'orderNumber': serializer.toJson<String?>(orderNumber),
      'serviceType': serializer.toJson<int>(serviceType),
      'paidStatus': serializer.toJson<int>(paidStatus),
      'date': serializer.toJson<DateTime>(date),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  DocumentsTableData copyWith({
    String? localId,
    Value<int?> serverId = const Value.absent(),
    int? companyId,
    int? documentTypeId,
    Value<String?> number = const Value.absent(),
    int? userId,
    int? warehouseId,
    double? total,
    double? discount,
    int? discountType,
    Value<int?> customerId = const Value.absent(),
    Value<String?> orderNumber = const Value.absent(),
    int? serviceType,
    int? paidStatus,
    DateTime? date,
    String? syncStatus,
    DateTime? lastModified,
  }) => DocumentsTableData(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    companyId: companyId ?? this.companyId,
    documentTypeId: documentTypeId ?? this.documentTypeId,
    number: number.present ? number.value : this.number,
    userId: userId ?? this.userId,
    warehouseId: warehouseId ?? this.warehouseId,
    total: total ?? this.total,
    discount: discount ?? this.discount,
    discountType: discountType ?? this.discountType,
    customerId: customerId.present ? customerId.value : this.customerId,
    orderNumber: orderNumber.present ? orderNumber.value : this.orderNumber,
    serviceType: serviceType ?? this.serviceType,
    paidStatus: paidStatus ?? this.paidStatus,
    date: date ?? this.date,
    syncStatus: syncStatus ?? this.syncStatus,
    lastModified: lastModified ?? this.lastModified,
  );
  DocumentsTableData copyWithCompanion(DocumentsTableCompanion data) {
    return DocumentsTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      documentTypeId: data.documentTypeId.present
          ? data.documentTypeId.value
          : this.documentTypeId,
      number: data.number.present ? data.number.value : this.number,
      userId: data.userId.present ? data.userId.value : this.userId,
      warehouseId: data.warehouseId.present
          ? data.warehouseId.value
          : this.warehouseId,
      total: data.total.present ? data.total.value : this.total,
      discount: data.discount.present ? data.discount.value : this.discount,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      orderNumber: data.orderNumber.present
          ? data.orderNumber.value
          : this.orderNumber,
      serviceType: data.serviceType.present
          ? data.serviceType.value
          : this.serviceType,
      paidStatus: data.paidStatus.present
          ? data.paidStatus.value
          : this.paidStatus,
      date: data.date.present ? data.date.value : this.date,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsTableData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('companyId: $companyId, ')
          ..write('documentTypeId: $documentTypeId, ')
          ..write('number: $number, ')
          ..write('userId: $userId, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('total: $total, ')
          ..write('discount: $discount, ')
          ..write('discountType: $discountType, ')
          ..write('customerId: $customerId, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('serviceType: $serviceType, ')
          ..write('paidStatus: $paidStatus, ')
          ..write('date: $date, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    companyId,
    documentTypeId,
    number,
    userId,
    warehouseId,
    total,
    discount,
    discountType,
    customerId,
    orderNumber,
    serviceType,
    paidStatus,
    date,
    syncStatus,
    lastModified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentsTableData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.companyId == this.companyId &&
          other.documentTypeId == this.documentTypeId &&
          other.number == this.number &&
          other.userId == this.userId &&
          other.warehouseId == this.warehouseId &&
          other.total == this.total &&
          other.discount == this.discount &&
          other.discountType == this.discountType &&
          other.customerId == this.customerId &&
          other.orderNumber == this.orderNumber &&
          other.serviceType == this.serviceType &&
          other.paidStatus == this.paidStatus &&
          other.date == this.date &&
          other.syncStatus == this.syncStatus &&
          other.lastModified == this.lastModified);
}

class DocumentsTableCompanion extends UpdateCompanion<DocumentsTableData> {
  final Value<String> localId;
  final Value<int?> serverId;
  final Value<int> companyId;
  final Value<int> documentTypeId;
  final Value<String?> number;
  final Value<int> userId;
  final Value<int> warehouseId;
  final Value<double> total;
  final Value<double> discount;
  final Value<int> discountType;
  final Value<int?> customerId;
  final Value<String?> orderNumber;
  final Value<int> serviceType;
  final Value<int> paidStatus;
  final Value<DateTime> date;
  final Value<String> syncStatus;
  final Value<DateTime> lastModified;
  final Value<int> rowid;
  const DocumentsTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.documentTypeId = const Value.absent(),
    this.number = const Value.absent(),
    this.userId = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.total = const Value.absent(),
    this.discount = const Value.absent(),
    this.discountType = const Value.absent(),
    this.customerId = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.paidStatus = const Value.absent(),
    this.date = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsTableCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required int companyId,
    this.documentTypeId = const Value.absent(),
    this.number = const Value.absent(),
    required int userId,
    required int warehouseId,
    this.total = const Value.absent(),
    this.discount = const Value.absent(),
    this.discountType = const Value.absent(),
    this.customerId = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.paidStatus = const Value.absent(),
    required DateTime date,
    this.syncStatus = const Value.absent(),
    required DateTime lastModified,
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       companyId = Value(companyId),
       userId = Value(userId),
       warehouseId = Value(warehouseId),
       date = Value(date),
       lastModified = Value(lastModified);
  static Insertable<DocumentsTableData> custom({
    Expression<String>? localId,
    Expression<int>? serverId,
    Expression<int>? companyId,
    Expression<int>? documentTypeId,
    Expression<String>? number,
    Expression<int>? userId,
    Expression<int>? warehouseId,
    Expression<double>? total,
    Expression<double>? discount,
    Expression<int>? discountType,
    Expression<int>? customerId,
    Expression<String>? orderNumber,
    Expression<int>? serviceType,
    Expression<int>? paidStatus,
    Expression<DateTime>? date,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastModified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (companyId != null) 'company_id': companyId,
      if (documentTypeId != null) 'document_type_id': documentTypeId,
      if (number != null) 'number': number,
      if (userId != null) 'user_id': userId,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (total != null) 'total': total,
      if (discount != null) 'discount': discount,
      if (discountType != null) 'discount_type': discountType,
      if (customerId != null) 'customer_id': customerId,
      if (orderNumber != null) 'order_number': orderNumber,
      if (serviceType != null) 'service_type': serviceType,
      if (paidStatus != null) 'paid_status': paidStatus,
      if (date != null) 'date': date,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModified != null) 'last_modified': lastModified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsTableCompanion copyWith({
    Value<String>? localId,
    Value<int?>? serverId,
    Value<int>? companyId,
    Value<int>? documentTypeId,
    Value<String?>? number,
    Value<int>? userId,
    Value<int>? warehouseId,
    Value<double>? total,
    Value<double>? discount,
    Value<int>? discountType,
    Value<int?>? customerId,
    Value<String?>? orderNumber,
    Value<int>? serviceType,
    Value<int>? paidStatus,
    Value<DateTime>? date,
    Value<String>? syncStatus,
    Value<DateTime>? lastModified,
    Value<int>? rowid,
  }) {
    return DocumentsTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      companyId: companyId ?? this.companyId,
      documentTypeId: documentTypeId ?? this.documentTypeId,
      number: number ?? this.number,
      userId: userId ?? this.userId,
      warehouseId: warehouseId ?? this.warehouseId,
      total: total ?? this.total,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      customerId: customerId ?? this.customerId,
      orderNumber: orderNumber ?? this.orderNumber,
      serviceType: serviceType ?? this.serviceType,
      paidStatus: paidStatus ?? this.paidStatus,
      date: date ?? this.date,
      syncStatus: syncStatus ?? this.syncStatus,
      lastModified: lastModified ?? this.lastModified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (documentTypeId.present) {
      map['document_type_id'] = Variable<int>(documentTypeId.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<int>(warehouseId.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<int>(discountType.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (orderNumber.present) {
      map['order_number'] = Variable<String>(orderNumber.value);
    }
    if (serviceType.present) {
      map['service_type'] = Variable<int>(serviceType.value);
    }
    if (paidStatus.present) {
      map['paid_status'] = Variable<int>(paidStatus.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('companyId: $companyId, ')
          ..write('documentTypeId: $documentTypeId, ')
          ..write('number: $number, ')
          ..write('userId: $userId, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('total: $total, ')
          ..write('discount: $discount, ')
          ..write('discountType: $discountType, ')
          ..write('customerId: $customerId, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('serviceType: $serviceType, ')
          ..write('paidStatus: $paidStatus, ')
          ..write('date: $date, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModified: $lastModified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentItemsTableTable extends DocumentItemsTable
    with TableInfo<$DocumentItemsTableTable, DocumentItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (local_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountMeta = const VerificationMeta(
    'discount',
  );
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
    'discount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountTypeMeta = const VerificationMeta(
    'discountType',
  );
  @override
  late final GeneratedColumn<int> discountType = GeneratedColumn<int>(
    'discount_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxAmountMeta = const VerificationMeta(
    'taxAmount',
  );
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
    'tax_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    documentId,
    productId,
    quantity,
    unitPrice,
    discount,
    discountType,
    total,
    taxAmount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('discount')) {
      context.handle(
        _discountMeta,
        discount.isAcceptableOrUnknown(data['discount']!, _discountMeta),
      );
    }
    if (data.containsKey('discount_type')) {
      context.handle(
        _discountTypeMeta,
        discountType.isAcceptableOrUnknown(
          data['discount_type']!,
          _discountTypeMeta,
        ),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('tax_amount')) {
      context.handle(
        _taxAmountMeta,
        taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  DocumentItemsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentItemsTableData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      discount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount'],
      )!,
      discountType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_type'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      taxAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_amount'],
      )!,
    );
  }

  @override
  $DocumentItemsTableTable createAlias(String alias) {
    return $DocumentItemsTableTable(attachedDatabase, alias);
  }
}

class DocumentItemsTableData extends DataClass
    implements Insertable<DocumentItemsTableData> {
  final String localId;
  final String documentId;
  final int productId;
  final double quantity;
  final double unitPrice;
  final double discount;
  final int discountType;
  final double total;
  final double taxAmount;
  const DocumentItemsTableData({
    required this.localId,
    required this.documentId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.discountType,
    required this.total,
    required this.taxAmount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['document_id'] = Variable<String>(documentId);
    map['product_id'] = Variable<int>(productId);
    map['quantity'] = Variable<double>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['discount'] = Variable<double>(discount);
    map['discount_type'] = Variable<int>(discountType);
    map['total'] = Variable<double>(total);
    map['tax_amount'] = Variable<double>(taxAmount);
    return map;
  }

  DocumentItemsTableCompanion toCompanion(bool nullToAbsent) {
    return DocumentItemsTableCompanion(
      localId: Value(localId),
      documentId: Value(documentId),
      productId: Value(productId),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      discount: Value(discount),
      discountType: Value(discountType),
      total: Value(total),
      taxAmount: Value(taxAmount),
    );
  }

  factory DocumentItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentItemsTableData(
      localId: serializer.fromJson<String>(json['localId']),
      documentId: serializer.fromJson<String>(json['documentId']),
      productId: serializer.fromJson<int>(json['productId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      discount: serializer.fromJson<double>(json['discount']),
      discountType: serializer.fromJson<int>(json['discountType']),
      total: serializer.fromJson<double>(json['total']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'documentId': serializer.toJson<String>(documentId),
      'productId': serializer.toJson<int>(productId),
      'quantity': serializer.toJson<double>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'discount': serializer.toJson<double>(discount),
      'discountType': serializer.toJson<int>(discountType),
      'total': serializer.toJson<double>(total),
      'taxAmount': serializer.toJson<double>(taxAmount),
    };
  }

  DocumentItemsTableData copyWith({
    String? localId,
    String? documentId,
    int? productId,
    double? quantity,
    double? unitPrice,
    double? discount,
    int? discountType,
    double? total,
    double? taxAmount,
  }) => DocumentItemsTableData(
    localId: localId ?? this.localId,
    documentId: documentId ?? this.documentId,
    productId: productId ?? this.productId,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    discount: discount ?? this.discount,
    discountType: discountType ?? this.discountType,
    total: total ?? this.total,
    taxAmount: taxAmount ?? this.taxAmount,
  );
  DocumentItemsTableData copyWithCompanion(DocumentItemsTableCompanion data) {
    return DocumentItemsTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      discount: data.discount.present ? data.discount.value : this.discount,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      total: data.total.present ? data.total.value : this.total,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentItemsTableData(')
          ..write('localId: $localId, ')
          ..write('documentId: $documentId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('discount: $discount, ')
          ..write('discountType: $discountType, ')
          ..write('total: $total, ')
          ..write('taxAmount: $taxAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    documentId,
    productId,
    quantity,
    unitPrice,
    discount,
    discountType,
    total,
    taxAmount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentItemsTableData &&
          other.localId == this.localId &&
          other.documentId == this.documentId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.discount == this.discount &&
          other.discountType == this.discountType &&
          other.total == this.total &&
          other.taxAmount == this.taxAmount);
}

class DocumentItemsTableCompanion
    extends UpdateCompanion<DocumentItemsTableData> {
  final Value<String> localId;
  final Value<String> documentId;
  final Value<int> productId;
  final Value<double> quantity;
  final Value<double> unitPrice;
  final Value<double> discount;
  final Value<int> discountType;
  final Value<double> total;
  final Value<double> taxAmount;
  final Value<int> rowid;
  const DocumentItemsTableCompanion({
    this.localId = const Value.absent(),
    this.documentId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.discount = const Value.absent(),
    this.discountType = const Value.absent(),
    this.total = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentItemsTableCompanion.insert({
    required String localId,
    required String documentId,
    required int productId,
    required double quantity,
    required double unitPrice,
    this.discount = const Value.absent(),
    this.discountType = const Value.absent(),
    required double total,
    this.taxAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       documentId = Value(documentId),
       productId = Value(productId),
       quantity = Value(quantity),
       unitPrice = Value(unitPrice),
       total = Value(total);
  static Insertable<DocumentItemsTableData> custom({
    Expression<String>? localId,
    Expression<String>? documentId,
    Expression<int>? productId,
    Expression<double>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? discount,
    Expression<int>? discountType,
    Expression<double>? total,
    Expression<double>? taxAmount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (documentId != null) 'document_id': documentId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (discount != null) 'discount': discount,
      if (discountType != null) 'discount_type': discountType,
      if (total != null) 'total': total,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentItemsTableCompanion copyWith({
    Value<String>? localId,
    Value<String>? documentId,
    Value<int>? productId,
    Value<double>? quantity,
    Value<double>? unitPrice,
    Value<double>? discount,
    Value<int>? discountType,
    Value<double>? total,
    Value<double>? taxAmount,
    Value<int>? rowid,
  }) {
    return DocumentItemsTableCompanion(
      localId: localId ?? this.localId,
      documentId: documentId ?? this.documentId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      total: total ?? this.total,
      taxAmount: taxAmount ?? this.taxAmount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<int>(discountType.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentItemsTableCompanion(')
          ..write('localId: $localId, ')
          ..write('documentId: $documentId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('discount: $discount, ')
          ..write('discountType: $discountType, ')
          ..write('total: $total, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTableTable extends PaymentsTable
    with TableInfo<$PaymentsTableTable, PaymentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (local_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _paymentTypeIdMeta = const VerificationMeta(
    'paymentTypeId',
  );
  @override
  late final GeneratedColumn<int> paymentTypeId = GeneratedColumn<int>(
    'payment_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    documentId,
    paymentTypeId,
    amount,
    userId,
    date,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('payment_type_id')) {
      context.handle(
        _paymentTypeIdMeta,
        paymentTypeId.isAcceptableOrUnknown(
          data['payment_type_id']!,
          _paymentTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentTypeIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  PaymentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentsTableData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      paymentTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_type_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $PaymentsTableTable createAlias(String alias) {
    return $PaymentsTableTable(attachedDatabase, alias);
  }
}

class PaymentsTableData extends DataClass
    implements Insertable<PaymentsTableData> {
  final String localId;
  final String documentId;
  final int paymentTypeId;
  final double amount;
  final int userId;
  final DateTime date;
  final String syncStatus;
  const PaymentsTableData({
    required this.localId,
    required this.documentId,
    required this.paymentTypeId,
    required this.amount,
    required this.userId,
    required this.date,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['document_id'] = Variable<String>(documentId);
    map['payment_type_id'] = Variable<int>(paymentTypeId);
    map['amount'] = Variable<double>(amount);
    map['user_id'] = Variable<int>(userId);
    map['date'] = Variable<DateTime>(date);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  PaymentsTableCompanion toCompanion(bool nullToAbsent) {
    return PaymentsTableCompanion(
      localId: Value(localId),
      documentId: Value(documentId),
      paymentTypeId: Value(paymentTypeId),
      amount: Value(amount),
      userId: Value(userId),
      date: Value(date),
      syncStatus: Value(syncStatus),
    );
  }

  factory PaymentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentsTableData(
      localId: serializer.fromJson<String>(json['localId']),
      documentId: serializer.fromJson<String>(json['documentId']),
      paymentTypeId: serializer.fromJson<int>(json['paymentTypeId']),
      amount: serializer.fromJson<double>(json['amount']),
      userId: serializer.fromJson<int>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'documentId': serializer.toJson<String>(documentId),
      'paymentTypeId': serializer.toJson<int>(paymentTypeId),
      'amount': serializer.toJson<double>(amount),
      'userId': serializer.toJson<int>(userId),
      'date': serializer.toJson<DateTime>(date),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  PaymentsTableData copyWith({
    String? localId,
    String? documentId,
    int? paymentTypeId,
    double? amount,
    int? userId,
    DateTime? date,
    String? syncStatus,
  }) => PaymentsTableData(
    localId: localId ?? this.localId,
    documentId: documentId ?? this.documentId,
    paymentTypeId: paymentTypeId ?? this.paymentTypeId,
    amount: amount ?? this.amount,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  PaymentsTableData copyWithCompanion(PaymentsTableCompanion data) {
    return PaymentsTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      paymentTypeId: data.paymentTypeId.present
          ? data.paymentTypeId.value
          : this.paymentTypeId,
      amount: data.amount.present ? data.amount.value : this.amount,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsTableData(')
          ..write('localId: $localId, ')
          ..write('documentId: $documentId, ')
          ..write('paymentTypeId: $paymentTypeId, ')
          ..write('amount: $amount, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    documentId,
    paymentTypeId,
    amount,
    userId,
    date,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentsTableData &&
          other.localId == this.localId &&
          other.documentId == this.documentId &&
          other.paymentTypeId == this.paymentTypeId &&
          other.amount == this.amount &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.syncStatus == this.syncStatus);
}

class PaymentsTableCompanion extends UpdateCompanion<PaymentsTableData> {
  final Value<String> localId;
  final Value<String> documentId;
  final Value<int> paymentTypeId;
  final Value<double> amount;
  final Value<int> userId;
  final Value<DateTime> date;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const PaymentsTableCompanion({
    this.localId = const Value.absent(),
    this.documentId = const Value.absent(),
    this.paymentTypeId = const Value.absent(),
    this.amount = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsTableCompanion.insert({
    required String localId,
    required String documentId,
    required int paymentTypeId,
    required double amount,
    required int userId,
    required DateTime date,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       documentId = Value(documentId),
       paymentTypeId = Value(paymentTypeId),
       amount = Value(amount),
       userId = Value(userId),
       date = Value(date);
  static Insertable<PaymentsTableData> custom({
    Expression<String>? localId,
    Expression<String>? documentId,
    Expression<int>? paymentTypeId,
    Expression<double>? amount,
    Expression<int>? userId,
    Expression<DateTime>? date,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (documentId != null) 'document_id': documentId,
      if (paymentTypeId != null) 'payment_type_id': paymentTypeId,
      if (amount != null) 'amount': amount,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsTableCompanion copyWith({
    Value<String>? localId,
    Value<String>? documentId,
    Value<int>? paymentTypeId,
    Value<double>? amount,
    Value<int>? userId,
    Value<DateTime>? date,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return PaymentsTableCompanion(
      localId: localId ?? this.localId,
      documentId: documentId ?? this.documentId,
      paymentTypeId: paymentTypeId ?? this.paymentTypeId,
      amount: amount ?? this.amount,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (paymentTypeId.present) {
      map['payment_type_id'] = Variable<int>(paymentTypeId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsTableCompanion(')
          ..write('localId: $localId, ')
          ..write('documentId: $documentId, ')
          ..write('paymentTypeId: $paymentTypeId, ')
          ..write('amount: $amount, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BarcodesTableTable extends BarcodesTable
    with TableInfo<$BarcodesTableTable, BarcodesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BarcodesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    productId,
    companyId,
    value,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'barcodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<BarcodesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  BarcodesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BarcodesTableData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $BarcodesTableTable createAlias(String alias) {
    return $BarcodesTableTable(attachedDatabase, alias);
  }
}

class BarcodesTableData extends DataClass
    implements Insertable<BarcodesTableData> {
  final String localId;
  final int? serverId;
  final int productId;
  final int companyId;
  final String value;
  final String syncStatus;
  const BarcodesTableData({
    required this.localId,
    this.serverId,
    required this.productId,
    required this.companyId,
    required this.value,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['product_id'] = Variable<int>(productId);
    map['company_id'] = Variable<int>(companyId);
    map['value'] = Variable<String>(value);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  BarcodesTableCompanion toCompanion(bool nullToAbsent) {
    return BarcodesTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      productId: Value(productId),
      companyId: Value(companyId),
      value: Value(value),
      syncStatus: Value(syncStatus),
    );
  }

  factory BarcodesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BarcodesTableData(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      productId: serializer.fromJson<int>(json['productId']),
      companyId: serializer.fromJson<int>(json['companyId']),
      value: serializer.fromJson<String>(json['value']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<int?>(serverId),
      'productId': serializer.toJson<int>(productId),
      'companyId': serializer.toJson<int>(companyId),
      'value': serializer.toJson<String>(value),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  BarcodesTableData copyWith({
    String? localId,
    Value<int?> serverId = const Value.absent(),
    int? productId,
    int? companyId,
    String? value,
    String? syncStatus,
  }) => BarcodesTableData(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    productId: productId ?? this.productId,
    companyId: companyId ?? this.companyId,
    value: value ?? this.value,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  BarcodesTableData copyWithCompanion(BarcodesTableCompanion data) {
    return BarcodesTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      productId: data.productId.present ? data.productId.value : this.productId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      value: data.value.present ? data.value.value : this.value,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BarcodesTableData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('productId: $productId, ')
          ..write('companyId: $companyId, ')
          ..write('value: $value, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(localId, serverId, productId, companyId, value, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BarcodesTableData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.productId == this.productId &&
          other.companyId == this.companyId &&
          other.value == this.value &&
          other.syncStatus == this.syncStatus);
}

class BarcodesTableCompanion extends UpdateCompanion<BarcodesTableData> {
  final Value<String> localId;
  final Value<int?> serverId;
  final Value<int> productId;
  final Value<int> companyId;
  final Value<String> value;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const BarcodesTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.productId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.value = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BarcodesTableCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required int productId,
    required int companyId,
    required String value,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       productId = Value(productId),
       companyId = Value(companyId),
       value = Value(value);
  static Insertable<BarcodesTableData> custom({
    Expression<String>? localId,
    Expression<int>? serverId,
    Expression<int>? productId,
    Expression<int>? companyId,
    Expression<String>? value,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (productId != null) 'product_id': productId,
      if (companyId != null) 'company_id': companyId,
      if (value != null) 'value': value,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BarcodesTableCompanion copyWith({
    Value<String>? localId,
    Value<int?>? serverId,
    Value<int>? productId,
    Value<int>? companyId,
    Value<String>? value,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return BarcodesTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      productId: productId ?? this.productId,
      companyId: companyId ?? this.companyId,
      value: value ?? this.value,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BarcodesTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('productId: $productId, ')
          ..write('companyId: $companyId, ')
          ..write('value: $value, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomerDiscountsTableTable extends CustomerDiscountsTable
    with TableInfo<$CustomerDiscountsTableTable, CustomerDiscountsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerDiscountsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<int> uid = GeneratedColumn<int>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    customerId,
    type,
    uid,
    value,
    lastModified,
    syncStatus,
    syncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_discounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerDiscountsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerDiscountsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerDiscountsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}uid'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
    );
  }

  @override
  $CustomerDiscountsTableTable createAlias(String alias) {
    return $CustomerDiscountsTableTable(attachedDatabase, alias);
  }
}

class CustomerDiscountsTableData extends DataClass
    implements Insertable<CustomerDiscountsTableData> {
  final int id;
  final int companyId;
  final int customerId;
  final int type;
  final int uid;
  final double value;
  final DateTime lastModified;
  final String syncStatus;
  final String? syncError;
  const CustomerDiscountsTableData({
    required this.id,
    required this.companyId,
    required this.customerId,
    required this.type,
    required this.uid,
    required this.value,
    required this.lastModified,
    required this.syncStatus,
    this.syncError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['customer_id'] = Variable<int>(customerId);
    map['type'] = Variable<int>(type);
    map['uid'] = Variable<int>(uid);
    map['value'] = Variable<double>(value);
    map['last_modified'] = Variable<DateTime>(lastModified);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  CustomerDiscountsTableCompanion toCompanion(bool nullToAbsent) {
    return CustomerDiscountsTableCompanion(
      id: Value(id),
      companyId: Value(companyId),
      customerId: Value(customerId),
      type: Value(type),
      uid: Value(uid),
      value: Value(value),
      lastModified: Value(lastModified),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory CustomerDiscountsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerDiscountsTableData(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      customerId: serializer.fromJson<int>(json['customerId']),
      type: serializer.fromJson<int>(json['type']),
      uid: serializer.fromJson<int>(json['uid']),
      value: serializer.fromJson<double>(json['value']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'customerId': serializer.toJson<int>(customerId),
      'type': serializer.toJson<int>(type),
      'uid': serializer.toJson<int>(uid),
      'value': serializer.toJson<double>(value),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  CustomerDiscountsTableData copyWith({
    int? id,
    int? companyId,
    int? customerId,
    int? type,
    int? uid,
    double? value,
    DateTime? lastModified,
    String? syncStatus,
    Value<String?> syncError = const Value.absent(),
  }) => CustomerDiscountsTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    customerId: customerId ?? this.customerId,
    type: type ?? this.type,
    uid: uid ?? this.uid,
    value: value ?? this.value,
    lastModified: lastModified ?? this.lastModified,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
  );
  CustomerDiscountsTableData copyWithCompanion(
    CustomerDiscountsTableCompanion data,
  ) {
    return CustomerDiscountsTableData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      type: data.type.present ? data.type.value : this.type,
      uid: data.uid.present ? data.uid.value : this.uid,
      value: data.value.present ? data.value.value : this.value,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerDiscountsTableData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('customerId: $customerId, ')
          ..write('type: $type, ')
          ..write('uid: $uid, ')
          ..write('value: $value, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    customerId,
    type,
    uid,
    value,
    lastModified,
    syncStatus,
    syncError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerDiscountsTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.customerId == this.customerId &&
          other.type == this.type &&
          other.uid == this.uid &&
          other.value == this.value &&
          other.lastModified == this.lastModified &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError);
}

class CustomerDiscountsTableCompanion
    extends UpdateCompanion<CustomerDiscountsTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<int> customerId;
  final Value<int> type;
  final Value<int> uid;
  final Value<double> value;
  final Value<DateTime> lastModified;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  const CustomerDiscountsTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.type = const Value.absent(),
    this.uid = const Value.absent(),
    this.value = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
  });
  CustomerDiscountsTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required int customerId,
    this.type = const Value.absent(),
    this.uid = const Value.absent(),
    this.value = const Value.absent(),
    required DateTime lastModified,
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
  }) : companyId = Value(companyId),
       customerId = Value(customerId),
       lastModified = Value(lastModified);
  static Insertable<CustomerDiscountsTableData> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<int>? customerId,
    Expression<int>? type,
    Expression<int>? uid,
    Expression<double>? value,
    Expression<DateTime>? lastModified,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (customerId != null) 'customer_id': customerId,
      if (type != null) 'type': type,
      if (uid != null) 'uid': uid,
      if (value != null) 'value': value,
      if (lastModified != null) 'last_modified': lastModified,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
    });
  }

  CustomerDiscountsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<int>? customerId,
    Value<int>? type,
    Value<int>? uid,
    Value<double>? value,
    Value<DateTime>? lastModified,
    Value<String>? syncStatus,
    Value<String?>? syncError,
  }) {
    return CustomerDiscountsTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      uid: uid ?? this.uid,
      value: value ?? this.value,
      lastModified: lastModified ?? this.lastModified,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (uid.present) {
      map['uid'] = Variable<int>(uid.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerDiscountsTableCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('customerId: $customerId, ')
          ..write('type: $type, ')
          ..write('uid: $uid, ')
          ..write('value: $value, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }
}

class $LoyaltyCardsTableTable extends LoyaltyCardsTable
    with TableInfo<$LoyaltyCardsTableTable, LoyaltyCardsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoyaltyCardsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardNumberMeta = const VerificationMeta(
    'cardNumber',
  );
  @override
  late final GeneratedColumn<String> cardNumber = GeneratedColumn<String>(
    'card_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<double> points = GeneratedColumn<double>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    customerId,
    cardNumber,
    points,
    lastModified,
    syncStatus,
    syncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loyalty_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoyaltyCardsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('card_number')) {
      context.handle(
        _cardNumberMeta,
        cardNumber.isAcceptableOrUnknown(data['card_number']!, _cardNumberMeta),
      );
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoyaltyCardsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoyaltyCardsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      cardNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_number'],
      ),
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}points'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
    );
  }

  @override
  $LoyaltyCardsTableTable createAlias(String alias) {
    return $LoyaltyCardsTableTable(attachedDatabase, alias);
  }
}

class LoyaltyCardsTableData extends DataClass
    implements Insertable<LoyaltyCardsTableData> {
  final int id;
  final int companyId;
  final int customerId;
  final String? cardNumber;
  final double points;
  final DateTime lastModified;
  final String syncStatus;
  final String? syncError;
  const LoyaltyCardsTableData({
    required this.id,
    required this.companyId,
    required this.customerId,
    this.cardNumber,
    required this.points,
    required this.lastModified,
    required this.syncStatus,
    this.syncError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['customer_id'] = Variable<int>(customerId);
    if (!nullToAbsent || cardNumber != null) {
      map['card_number'] = Variable<String>(cardNumber);
    }
    map['points'] = Variable<double>(points);
    map['last_modified'] = Variable<DateTime>(lastModified);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  LoyaltyCardsTableCompanion toCompanion(bool nullToAbsent) {
    return LoyaltyCardsTableCompanion(
      id: Value(id),
      companyId: Value(companyId),
      customerId: Value(customerId),
      cardNumber: cardNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(cardNumber),
      points: Value(points),
      lastModified: Value(lastModified),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory LoyaltyCardsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoyaltyCardsTableData(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      customerId: serializer.fromJson<int>(json['customerId']),
      cardNumber: serializer.fromJson<String?>(json['cardNumber']),
      points: serializer.fromJson<double>(json['points']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'customerId': serializer.toJson<int>(customerId),
      'cardNumber': serializer.toJson<String?>(cardNumber),
      'points': serializer.toJson<double>(points),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  LoyaltyCardsTableData copyWith({
    int? id,
    int? companyId,
    int? customerId,
    Value<String?> cardNumber = const Value.absent(),
    double? points,
    DateTime? lastModified,
    String? syncStatus,
    Value<String?> syncError = const Value.absent(),
  }) => LoyaltyCardsTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    customerId: customerId ?? this.customerId,
    cardNumber: cardNumber.present ? cardNumber.value : this.cardNumber,
    points: points ?? this.points,
    lastModified: lastModified ?? this.lastModified,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
  );
  LoyaltyCardsTableData copyWithCompanion(LoyaltyCardsTableCompanion data) {
    return LoyaltyCardsTableData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      cardNumber: data.cardNumber.present
          ? data.cardNumber.value
          : this.cardNumber,
      points: data.points.present ? data.points.value : this.points,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoyaltyCardsTableData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('customerId: $customerId, ')
          ..write('cardNumber: $cardNumber, ')
          ..write('points: $points, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    customerId,
    cardNumber,
    points,
    lastModified,
    syncStatus,
    syncError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoyaltyCardsTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.customerId == this.customerId &&
          other.cardNumber == this.cardNumber &&
          other.points == this.points &&
          other.lastModified == this.lastModified &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError);
}

class LoyaltyCardsTableCompanion
    extends UpdateCompanion<LoyaltyCardsTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<int> customerId;
  final Value<String?> cardNumber;
  final Value<double> points;
  final Value<DateTime> lastModified;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  const LoyaltyCardsTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.cardNumber = const Value.absent(),
    this.points = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
  });
  LoyaltyCardsTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required int customerId,
    this.cardNumber = const Value.absent(),
    this.points = const Value.absent(),
    required DateTime lastModified,
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
  }) : companyId = Value(companyId),
       customerId = Value(customerId),
       lastModified = Value(lastModified);
  static Insertable<LoyaltyCardsTableData> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<int>? customerId,
    Expression<String>? cardNumber,
    Expression<double>? points,
    Expression<DateTime>? lastModified,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (customerId != null) 'customer_id': customerId,
      if (cardNumber != null) 'card_number': cardNumber,
      if (points != null) 'points': points,
      if (lastModified != null) 'last_modified': lastModified,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
    });
  }

  LoyaltyCardsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<int>? customerId,
    Value<String?>? cardNumber,
    Value<double>? points,
    Value<DateTime>? lastModified,
    Value<String>? syncStatus,
    Value<String?>? syncError,
  }) {
    return LoyaltyCardsTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      customerId: customerId ?? this.customerId,
      cardNumber: cardNumber ?? this.cardNumber,
      points: points ?? this.points,
      lastModified: lastModified ?? this.lastModified,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (cardNumber.present) {
      map['card_number'] = Variable<String>(cardNumber.value);
    }
    if (points.present) {
      map['points'] = Variable<double>(points.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoyaltyCardsTableCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('customerId: $customerId, ')
          ..write('cardNumber: $cardNumber, ')
          ..write('points: $points, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }
}

class $TimeClockEntriesTableTable extends TimeClockEntriesTable
    with TableInfo<$TimeClockEntriesTableTable, TimeClockEntriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeClockEntriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clockInTimeMeta = const VerificationMeta(
    'clockInTime',
  );
  @override
  late final GeneratedColumn<DateTime> clockInTime = GeneratedColumn<DateTime>(
    'clock_in_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clockOutTimeMeta = const VerificationMeta(
    'clockOutTime',
  );
  @override
  late final GeneratedColumn<DateTime> clockOutTime = GeneratedColumn<DateTime>(
    'clock_out_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    companyId,
    userId,
    clockInTime,
    clockOutTime,
    syncStatus,
    syncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_clock_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimeClockEntriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('clock_in_time')) {
      context.handle(
        _clockInTimeMeta,
        clockInTime.isAcceptableOrUnknown(
          data['clock_in_time']!,
          _clockInTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clockInTimeMeta);
    }
    if (data.containsKey('clock_out_time')) {
      context.handle(
        _clockOutTimeMeta,
        clockOutTime.isAcceptableOrUnknown(
          data['clock_out_time']!,
          _clockOutTimeMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  TimeClockEntriesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeClockEntriesTableData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      clockInTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}clock_in_time'],
      )!,
      clockOutTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}clock_out_time'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
    );
  }

  @override
  $TimeClockEntriesTableTable createAlias(String alias) {
    return $TimeClockEntriesTableTable(attachedDatabase, alias);
  }
}

class TimeClockEntriesTableData extends DataClass
    implements Insertable<TimeClockEntriesTableData> {
  final String localId;
  final int? serverId;
  final int companyId;
  final int userId;
  final DateTime clockInTime;
  final DateTime? clockOutTime;
  final String syncStatus;
  final String? syncError;
  const TimeClockEntriesTableData({
    required this.localId,
    this.serverId,
    required this.companyId,
    required this.userId,
    required this.clockInTime,
    this.clockOutTime,
    required this.syncStatus,
    this.syncError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['company_id'] = Variable<int>(companyId);
    map['user_id'] = Variable<int>(userId);
    map['clock_in_time'] = Variable<DateTime>(clockInTime);
    if (!nullToAbsent || clockOutTime != null) {
      map['clock_out_time'] = Variable<DateTime>(clockOutTime);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  TimeClockEntriesTableCompanion toCompanion(bool nullToAbsent) {
    return TimeClockEntriesTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      companyId: Value(companyId),
      userId: Value(userId),
      clockInTime: Value(clockInTime),
      clockOutTime: clockOutTime == null && nullToAbsent
          ? const Value.absent()
          : Value(clockOutTime),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory TimeClockEntriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeClockEntriesTableData(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      companyId: serializer.fromJson<int>(json['companyId']),
      userId: serializer.fromJson<int>(json['userId']),
      clockInTime: serializer.fromJson<DateTime>(json['clockInTime']),
      clockOutTime: serializer.fromJson<DateTime?>(json['clockOutTime']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<int?>(serverId),
      'companyId': serializer.toJson<int>(companyId),
      'userId': serializer.toJson<int>(userId),
      'clockInTime': serializer.toJson<DateTime>(clockInTime),
      'clockOutTime': serializer.toJson<DateTime?>(clockOutTime),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  TimeClockEntriesTableData copyWith({
    String? localId,
    Value<int?> serverId = const Value.absent(),
    int? companyId,
    int? userId,
    DateTime? clockInTime,
    Value<DateTime?> clockOutTime = const Value.absent(),
    String? syncStatus,
    Value<String?> syncError = const Value.absent(),
  }) => TimeClockEntriesTableData(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    companyId: companyId ?? this.companyId,
    userId: userId ?? this.userId,
    clockInTime: clockInTime ?? this.clockInTime,
    clockOutTime: clockOutTime.present ? clockOutTime.value : this.clockOutTime,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
  );
  TimeClockEntriesTableData copyWithCompanion(
    TimeClockEntriesTableCompanion data,
  ) {
    return TimeClockEntriesTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      userId: data.userId.present ? data.userId.value : this.userId,
      clockInTime: data.clockInTime.present
          ? data.clockInTime.value
          : this.clockInTime,
      clockOutTime: data.clockOutTime.present
          ? data.clockOutTime.value
          : this.clockOutTime,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeClockEntriesTableData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('companyId: $companyId, ')
          ..write('userId: $userId, ')
          ..write('clockInTime: $clockInTime, ')
          ..write('clockOutTime: $clockOutTime, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    companyId,
    userId,
    clockInTime,
    clockOutTime,
    syncStatus,
    syncError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeClockEntriesTableData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.companyId == this.companyId &&
          other.userId == this.userId &&
          other.clockInTime == this.clockInTime &&
          other.clockOutTime == this.clockOutTime &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError);
}

class TimeClockEntriesTableCompanion
    extends UpdateCompanion<TimeClockEntriesTableData> {
  final Value<String> localId;
  final Value<int?> serverId;
  final Value<int> companyId;
  final Value<int> userId;
  final Value<DateTime> clockInTime;
  final Value<DateTime?> clockOutTime;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  final Value<int> rowid;
  const TimeClockEntriesTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.userId = const Value.absent(),
    this.clockInTime = const Value.absent(),
    this.clockOutTime = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimeClockEntriesTableCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required int companyId,
    required int userId,
    required DateTime clockInTime,
    this.clockOutTime = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       companyId = Value(companyId),
       userId = Value(userId),
       clockInTime = Value(clockInTime);
  static Insertable<TimeClockEntriesTableData> custom({
    Expression<String>? localId,
    Expression<int>? serverId,
    Expression<int>? companyId,
    Expression<int>? userId,
    Expression<DateTime>? clockInTime,
    Expression<DateTime>? clockOutTime,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (companyId != null) 'company_id': companyId,
      if (userId != null) 'user_id': userId,
      if (clockInTime != null) 'clock_in_time': clockInTime,
      if (clockOutTime != null) 'clock_out_time': clockOutTime,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimeClockEntriesTableCompanion copyWith({
    Value<String>? localId,
    Value<int?>? serverId,
    Value<int>? companyId,
    Value<int>? userId,
    Value<DateTime>? clockInTime,
    Value<DateTime?>? clockOutTime,
    Value<String>? syncStatus,
    Value<String?>? syncError,
    Value<int>? rowid,
  }) {
    return TimeClockEntriesTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (clockInTime.present) {
      map['clock_in_time'] = Variable<DateTime>(clockInTime.value);
    }
    if (clockOutTime.present) {
      map['clock_out_time'] = Variable<DateTime>(clockOutTime.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeClockEntriesTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('companyId: $companyId, ')
          ..write('userId: $userId, ')
          ..write('clockInTime: $clockInTime, ')
          ..write('clockOutTime: $clockOutTime, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShiftsTableTable extends ShiftsTable
    with TableInfo<$ShiftsTableTable, ShiftsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startingCashMeta = const VerificationMeta(
    'startingCash',
  );
  @override
  late final GeneratedColumn<double> startingCash = GeneratedColumn<double>(
    'starting_cash',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _actualEndingCashMeta = const VerificationMeta(
    'actualEndingCash',
  );
  @override
  late final GeneratedColumn<double> actualEndingCash = GeneratedColumn<double>(
    'actual_ending_cash',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDrawerShiftMeta = const VerificationMeta(
    'isDrawerShift',
  );
  @override
  late final GeneratedColumn<bool> isDrawerShift = GeneratedColumn<bool>(
    'is_drawer_shift',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_drawer_shift" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    companyId,
    userId,
    startingCash,
    actualEndingCash,
    status,
    openedAt,
    closedAt,
    lastModified,
    isDrawerShift,
    syncStatus,
    syncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShiftsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('starting_cash')) {
      context.handle(
        _startingCashMeta,
        startingCash.isAcceptableOrUnknown(
          data['starting_cash']!,
          _startingCashMeta,
        ),
      );
    }
    if (data.containsKey('actual_ending_cash')) {
      context.handle(
        _actualEndingCashMeta,
        actualEndingCash.isAcceptableOrUnknown(
          data['actual_ending_cash']!,
          _actualEndingCashMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('is_drawer_shift')) {
      context.handle(
        _isDrawerShiftMeta,
        isDrawerShift.isAcceptableOrUnknown(
          data['is_drawer_shift']!,
          _isDrawerShiftMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  ShiftsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftsTableData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      startingCash: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}starting_cash'],
      )!,
      actualEndingCash: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_ending_cash'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
      isDrawerShift: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_drawer_shift'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
    );
  }

  @override
  $ShiftsTableTable createAlias(String alias) {
    return $ShiftsTableTable(attachedDatabase, alias);
  }
}

class ShiftsTableData extends DataClass implements Insertable<ShiftsTableData> {
  final String localId;
  final int? serverId;
  final int companyId;
  final int userId;
  final double startingCash;
  final double? actualEndingCash;
  final int status;
  final DateTime openedAt;
  final DateTime? closedAt;
  final DateTime lastModified;

  /// Distinguishes the station's master cash-drawer shift (true) from bare
  /// per-employee attendance sessions (false). Lets many servers clock in for
  /// hours simultaneously on one station without colliding with the single
  /// drawer shift. Local-only differentiation flag.
  final bool isDrawerShift;
  final String syncStatus;
  final String? syncError;
  const ShiftsTableData({
    required this.localId,
    this.serverId,
    required this.companyId,
    required this.userId,
    required this.startingCash,
    this.actualEndingCash,
    required this.status,
    required this.openedAt,
    this.closedAt,
    required this.lastModified,
    required this.isDrawerShift,
    required this.syncStatus,
    this.syncError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['company_id'] = Variable<int>(companyId);
    map['user_id'] = Variable<int>(userId);
    map['starting_cash'] = Variable<double>(startingCash);
    if (!nullToAbsent || actualEndingCash != null) {
      map['actual_ending_cash'] = Variable<double>(actualEndingCash);
    }
    map['status'] = Variable<int>(status);
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    map['last_modified'] = Variable<DateTime>(lastModified);
    map['is_drawer_shift'] = Variable<bool>(isDrawerShift);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  ShiftsTableCompanion toCompanion(bool nullToAbsent) {
    return ShiftsTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      companyId: Value(companyId),
      userId: Value(userId),
      startingCash: Value(startingCash),
      actualEndingCash: actualEndingCash == null && nullToAbsent
          ? const Value.absent()
          : Value(actualEndingCash),
      status: Value(status),
      openedAt: Value(openedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      lastModified: Value(lastModified),
      isDrawerShift: Value(isDrawerShift),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory ShiftsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftsTableData(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      companyId: serializer.fromJson<int>(json['companyId']),
      userId: serializer.fromJson<int>(json['userId']),
      startingCash: serializer.fromJson<double>(json['startingCash']),
      actualEndingCash: serializer.fromJson<double?>(json['actualEndingCash']),
      status: serializer.fromJson<int>(json['status']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      isDrawerShift: serializer.fromJson<bool>(json['isDrawerShift']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<int?>(serverId),
      'companyId': serializer.toJson<int>(companyId),
      'userId': serializer.toJson<int>(userId),
      'startingCash': serializer.toJson<double>(startingCash),
      'actualEndingCash': serializer.toJson<double?>(actualEndingCash),
      'status': serializer.toJson<int>(status),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'isDrawerShift': serializer.toJson<bool>(isDrawerShift),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  ShiftsTableData copyWith({
    String? localId,
    Value<int?> serverId = const Value.absent(),
    int? companyId,
    int? userId,
    double? startingCash,
    Value<double?> actualEndingCash = const Value.absent(),
    int? status,
    DateTime? openedAt,
    Value<DateTime?> closedAt = const Value.absent(),
    DateTime? lastModified,
    bool? isDrawerShift,
    String? syncStatus,
    Value<String?> syncError = const Value.absent(),
  }) => ShiftsTableData(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    companyId: companyId ?? this.companyId,
    userId: userId ?? this.userId,
    startingCash: startingCash ?? this.startingCash,
    actualEndingCash: actualEndingCash.present
        ? actualEndingCash.value
        : this.actualEndingCash,
    status: status ?? this.status,
    openedAt: openedAt ?? this.openedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    lastModified: lastModified ?? this.lastModified,
    isDrawerShift: isDrawerShift ?? this.isDrawerShift,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
  );
  ShiftsTableData copyWithCompanion(ShiftsTableCompanion data) {
    return ShiftsTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      userId: data.userId.present ? data.userId.value : this.userId,
      startingCash: data.startingCash.present
          ? data.startingCash.value
          : this.startingCash,
      actualEndingCash: data.actualEndingCash.present
          ? data.actualEndingCash.value
          : this.actualEndingCash,
      status: data.status.present ? data.status.value : this.status,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      isDrawerShift: data.isDrawerShift.present
          ? data.isDrawerShift.value
          : this.isDrawerShift,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsTableData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('companyId: $companyId, ')
          ..write('userId: $userId, ')
          ..write('startingCash: $startingCash, ')
          ..write('actualEndingCash: $actualEndingCash, ')
          ..write('status: $status, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('lastModified: $lastModified, ')
          ..write('isDrawerShift: $isDrawerShift, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    companyId,
    userId,
    startingCash,
    actualEndingCash,
    status,
    openedAt,
    closedAt,
    lastModified,
    isDrawerShift,
    syncStatus,
    syncError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftsTableData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.companyId == this.companyId &&
          other.userId == this.userId &&
          other.startingCash == this.startingCash &&
          other.actualEndingCash == this.actualEndingCash &&
          other.status == this.status &&
          other.openedAt == this.openedAt &&
          other.closedAt == this.closedAt &&
          other.lastModified == this.lastModified &&
          other.isDrawerShift == this.isDrawerShift &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError);
}

class ShiftsTableCompanion extends UpdateCompanion<ShiftsTableData> {
  final Value<String> localId;
  final Value<int?> serverId;
  final Value<int> companyId;
  final Value<int> userId;
  final Value<double> startingCash;
  final Value<double?> actualEndingCash;
  final Value<int> status;
  final Value<DateTime> openedAt;
  final Value<DateTime?> closedAt;
  final Value<DateTime> lastModified;
  final Value<bool> isDrawerShift;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  final Value<int> rowid;
  const ShiftsTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.userId = const Value.absent(),
    this.startingCash = const Value.absent(),
    this.actualEndingCash = const Value.absent(),
    this.status = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.isDrawerShift = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftsTableCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required int companyId,
    required int userId,
    this.startingCash = const Value.absent(),
    this.actualEndingCash = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime openedAt,
    this.closedAt = const Value.absent(),
    required DateTime lastModified,
    this.isDrawerShift = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       companyId = Value(companyId),
       userId = Value(userId),
       openedAt = Value(openedAt),
       lastModified = Value(lastModified);
  static Insertable<ShiftsTableData> custom({
    Expression<String>? localId,
    Expression<int>? serverId,
    Expression<int>? companyId,
    Expression<int>? userId,
    Expression<double>? startingCash,
    Expression<double>? actualEndingCash,
    Expression<int>? status,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closedAt,
    Expression<DateTime>? lastModified,
    Expression<bool>? isDrawerShift,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (companyId != null) 'company_id': companyId,
      if (userId != null) 'user_id': userId,
      if (startingCash != null) 'starting_cash': startingCash,
      if (actualEndingCash != null) 'actual_ending_cash': actualEndingCash,
      if (status != null) 'status': status,
      if (openedAt != null) 'opened_at': openedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (lastModified != null) 'last_modified': lastModified,
      if (isDrawerShift != null) 'is_drawer_shift': isDrawerShift,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftsTableCompanion copyWith({
    Value<String>? localId,
    Value<int?>? serverId,
    Value<int>? companyId,
    Value<int>? userId,
    Value<double>? startingCash,
    Value<double?>? actualEndingCash,
    Value<int>? status,
    Value<DateTime>? openedAt,
    Value<DateTime?>? closedAt,
    Value<DateTime>? lastModified,
    Value<bool>? isDrawerShift,
    Value<String>? syncStatus,
    Value<String?>? syncError,
    Value<int>? rowid,
  }) {
    return ShiftsTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      startingCash: startingCash ?? this.startingCash,
      actualEndingCash: actualEndingCash ?? this.actualEndingCash,
      status: status ?? this.status,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      lastModified: lastModified ?? this.lastModified,
      isDrawerShift: isDrawerShift ?? this.isDrawerShift,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (startingCash.present) {
      map['starting_cash'] = Variable<double>(startingCash.value);
    }
    if (actualEndingCash.present) {
      map['actual_ending_cash'] = Variable<double>(actualEndingCash.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (isDrawerShift.present) {
      map['is_drawer_shift'] = Variable<bool>(isDrawerShift.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('companyId: $companyId, ')
          ..write('userId: $userId, ')
          ..write('startingCash: $startingCash, ')
          ..write('actualEndingCash: $actualEndingCash, ')
          ..write('status: $status, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('lastModified: $lastModified, ')
          ..write('isDrawerShift: $isDrawerShift, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SecurityKeysTableTable securityKeysTable =
      $SecurityKeysTableTable(this);
  late final $PendingUserOpsTableTable pendingUserOpsTable =
      $PendingUserOpsTableTable(this);
  late final $ProductsTableTable productsTable = $ProductsTableTable(this);
  late final $TaxesTableTable taxesTable = $TaxesTableTable(this);
  late final $FloorPlansTableTable floorPlansTable = $FloorPlansTableTable(
    this,
  );
  late final $FloorPlanTablesTableTable floorPlanTablesTable =
      $FloorPlanTablesTableTable(this);
  late final $UsersTableTable usersTable = $UsersTableTable(this);
  late final $AppPropertiesTableTable appPropertiesTable =
      $AppPropertiesTableTable(this);
  late final $ProductGroupsTableTable productGroupsTable =
      $ProductGroupsTableTable(this);
  late final $PaymentTypesTableTable paymentTypesTable =
      $PaymentTypesTableTable(this);
  late final $CustomersTableTable customersTable = $CustomersTableTable(this);
  late final $PromotionsTableTable promotionsTable = $PromotionsTableTable(
    this,
  );
  late final $PromotionItemsTableTable promotionItemsTable =
      $PromotionItemsTableTable(this);
  late final $ProductCommentsTableTable productCommentsTable =
      $ProductCommentsTableTable(this);
  late final $CompaniesTableTable companiesTable = $CompaniesTableTable(this);
  late final $PosOrdersTableTable posOrdersTable = $PosOrdersTableTable(this);
  late final $PosOrderItemsTableTable posOrderItemsTable =
      $PosOrderItemsTableTable(this);
  late final $PosOrderItemTaxesTableTable posOrderItemTaxesTable =
      $PosOrderItemTaxesTableTable(this);
  late final $StartingCashTableTable startingCashTable =
      $StartingCashTableTable(this);
  late final $ZReportsTableTable zReportsTable = $ZReportsTableTable(this);
  late final $SyncMetaTableTable syncMetaTable = $SyncMetaTableTable(this);
  late final $StocksTableTable stocksTable = $StocksTableTable(this);
  late final $PendingVoidsTableTable pendingVoidsTable =
      $PendingVoidsTableTable(this);
  late final $DocumentsTableTable documentsTable = $DocumentsTableTable(this);
  late final $DocumentItemsTableTable documentItemsTable =
      $DocumentItemsTableTable(this);
  late final $PaymentsTableTable paymentsTable = $PaymentsTableTable(this);
  late final $BarcodesTableTable barcodesTable = $BarcodesTableTable(this);
  late final $CustomerDiscountsTableTable customerDiscountsTable =
      $CustomerDiscountsTableTable(this);
  late final $LoyaltyCardsTableTable loyaltyCardsTable =
      $LoyaltyCardsTableTable(this);
  late final $TimeClockEntriesTableTable timeClockEntriesTable =
      $TimeClockEntriesTableTable(this);
  late final $ShiftsTableTable shiftsTable = $ShiftsTableTable(this);
  late final Index idxProductsGroupId = Index(
    'idx_products_group_id',
    'CREATE INDEX idx_products_group_id ON products (product_group_id)',
  );
  late final Index idxProductsBarcode = Index(
    'idx_products_barcode',
    'CREATE INDEX idx_products_barcode ON products (barcode)',
  );
  late final Index idxPosOrdersSyncStatus = Index(
    'idx_pos_orders_sync_status',
    'CREATE INDEX idx_pos_orders_sync_status ON pos_orders (sync_status)',
  );
  late final Index idxPosOrdersStatus = Index(
    'idx_pos_orders_status',
    'CREATE INDEX idx_pos_orders_status ON pos_orders (status)',
  );
  late final Index idxPosOrderItemsOrderId = Index(
    'idx_pos_order_items_order_id',
    'CREATE INDEX idx_pos_order_items_order_id ON pos_order_items (order_id)',
  );
  late final Index idxPosOrderItemTaxesOrderId = Index(
    'idx_pos_order_item_taxes_order_id',
    'CREATE INDEX idx_pos_order_item_taxes_order_id ON pos_order_item_taxes (order_id)',
  );
  late final Index idxCustomerDiscountsCustomerId = Index(
    'idx_customer_discounts_customer_id',
    'CREATE INDEX idx_customer_discounts_customer_id ON customer_discounts (customer_id)',
  );
  late final Index idxLoyaltyCardsCustomerId = Index(
    'idx_loyalty_cards_customer_id',
    'CREATE INDEX idx_loyalty_cards_customer_id ON loyalty_cards (customer_id)',
  );
  late final Index idxLoyaltyCardsSyncStatus = Index(
    'idx_loyalty_cards_sync_status',
    'CREATE INDEX idx_loyalty_cards_sync_status ON loyalty_cards (sync_status)',
  );
  late final Index idxTimeClockUserId = Index(
    'idx_time_clock_user_id',
    'CREATE INDEX idx_time_clock_user_id ON time_clock_entries (user_id)',
  );
  late final Index idxTimeClockSyncStatus = Index(
    'idx_time_clock_sync_status',
    'CREATE INDEX idx_time_clock_sync_status ON time_clock_entries (sync_status)',
  );
  late final Index idxShiftsCompanyStatus = Index(
    'idx_shifts_company_status',
    'CREATE INDEX idx_shifts_company_status ON shifts (company_id, status)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    securityKeysTable,
    pendingUserOpsTable,
    productsTable,
    taxesTable,
    floorPlansTable,
    floorPlanTablesTable,
    usersTable,
    appPropertiesTable,
    productGroupsTable,
    paymentTypesTable,
    customersTable,
    promotionsTable,
    promotionItemsTable,
    productCommentsTable,
    companiesTable,
    posOrdersTable,
    posOrderItemsTable,
    posOrderItemTaxesTable,
    startingCashTable,
    zReportsTable,
    syncMetaTable,
    stocksTable,
    pendingVoidsTable,
    documentsTable,
    documentItemsTable,
    paymentsTable,
    barcodesTable,
    customerDiscountsTable,
    loyaltyCardsTable,
    timeClockEntriesTable,
    shiftsTable,
    idxProductsGroupId,
    idxProductsBarcode,
    idxPosOrdersSyncStatus,
    idxPosOrdersStatus,
    idxPosOrderItemsOrderId,
    idxPosOrderItemTaxesOrderId,
    idxCustomerDiscountsCustomerId,
    idxLoyaltyCardsCustomerId,
    idxLoyaltyCardsSyncStatus,
    idxTimeClockUserId,
    idxTimeClockSyncStatus,
    idxShiftsCompanyStatus,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pos_orders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pos_order_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pos_orders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pos_order_item_taxes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('payments', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SecurityKeysTableTableCreateCompanionBuilder =
    SecurityKeysTableCompanion Function({
      required int companyId,
      required String name,
      Value<int> level,
      Value<int> rowid,
    });
typedef $$SecurityKeysTableTableUpdateCompanionBuilder =
    SecurityKeysTableCompanion Function({
      Value<int> companyId,
      Value<String> name,
      Value<int> level,
      Value<int> rowid,
    });

class $$SecurityKeysTableTableFilterComposer
    extends Composer<_$AppDatabase, $SecurityKeysTableTable> {
  $$SecurityKeysTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SecurityKeysTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SecurityKeysTableTable> {
  $$SecurityKeysTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SecurityKeysTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SecurityKeysTableTable> {
  $$SecurityKeysTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);
}

class $$SecurityKeysTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SecurityKeysTableTable,
          SecurityKeysTableData,
          $$SecurityKeysTableTableFilterComposer,
          $$SecurityKeysTableTableOrderingComposer,
          $$SecurityKeysTableTableAnnotationComposer,
          $$SecurityKeysTableTableCreateCompanionBuilder,
          $$SecurityKeysTableTableUpdateCompanionBuilder,
          (
            SecurityKeysTableData,
            BaseReferences<
              _$AppDatabase,
              $SecurityKeysTableTable,
              SecurityKeysTableData
            >,
          ),
          SecurityKeysTableData,
          PrefetchHooks Function()
        > {
  $$SecurityKeysTableTableTableManager(
    _$AppDatabase db,
    $SecurityKeysTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SecurityKeysTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SecurityKeysTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SecurityKeysTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SecurityKeysTableCompanion(
                companyId: companyId,
                name: name,
                level: level,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int companyId,
                required String name,
                Value<int> level = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SecurityKeysTableCompanion.insert(
                companyId: companyId,
                name: name,
                level: level,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SecurityKeysTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SecurityKeysTableTable,
      SecurityKeysTableData,
      $$SecurityKeysTableTableFilterComposer,
      $$SecurityKeysTableTableOrderingComposer,
      $$SecurityKeysTableTableAnnotationComposer,
      $$SecurityKeysTableTableCreateCompanionBuilder,
      $$SecurityKeysTableTableUpdateCompanionBuilder,
      (
        SecurityKeysTableData,
        BaseReferences<
          _$AppDatabase,
          $SecurityKeysTableTable,
          SecurityKeysTableData
        >,
      ),
      SecurityKeysTableData,
      PrefetchHooks Function()
    >;
typedef $$PendingUserOpsTableTableCreateCompanionBuilder =
    PendingUserOpsTableCompanion Function({
      Value<int> id,
      required String operation,
      required int companyId,
      required String payload,
    });
typedef $$PendingUserOpsTableTableUpdateCompanionBuilder =
    PendingUserOpsTableCompanion Function({
      Value<int> id,
      Value<String> operation,
      Value<int> companyId,
      Value<String> payload,
    });

class $$PendingUserOpsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PendingUserOpsTableTable> {
  $$PendingUserOpsTableTableFilterComposer({
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

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingUserOpsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingUserOpsTableTable> {
  $$PendingUserOpsTableTableOrderingComposer({
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

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingUserOpsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingUserOpsTableTable> {
  $$PendingUserOpsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$PendingUserOpsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingUserOpsTableTable,
          PendingUserOpsTableData,
          $$PendingUserOpsTableTableFilterComposer,
          $$PendingUserOpsTableTableOrderingComposer,
          $$PendingUserOpsTableTableAnnotationComposer,
          $$PendingUserOpsTableTableCreateCompanionBuilder,
          $$PendingUserOpsTableTableUpdateCompanionBuilder,
          (
            PendingUserOpsTableData,
            BaseReferences<
              _$AppDatabase,
              $PendingUserOpsTableTable,
              PendingUserOpsTableData
            >,
          ),
          PendingUserOpsTableData,
          PrefetchHooks Function()
        > {
  $$PendingUserOpsTableTableTableManager(
    _$AppDatabase db,
    $PendingUserOpsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingUserOpsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingUserOpsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingUserOpsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<String> payload = const Value.absent(),
              }) => PendingUserOpsTableCompanion(
                id: id,
                operation: operation,
                companyId: companyId,
                payload: payload,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String operation,
                required int companyId,
                required String payload,
              }) => PendingUserOpsTableCompanion.insert(
                id: id,
                operation: operation,
                companyId: companyId,
                payload: payload,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingUserOpsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingUserOpsTableTable,
      PendingUserOpsTableData,
      $$PendingUserOpsTableTableFilterComposer,
      $$PendingUserOpsTableTableOrderingComposer,
      $$PendingUserOpsTableTableAnnotationComposer,
      $$PendingUserOpsTableTableCreateCompanionBuilder,
      $$PendingUserOpsTableTableUpdateCompanionBuilder,
      (
        PendingUserOpsTableData,
        BaseReferences<
          _$AppDatabase,
          $PendingUserOpsTableTable,
          PendingUserOpsTableData
        >,
      ),
      PendingUserOpsTableData,
      PrefetchHooks Function()
    >;
typedef $$ProductsTableTableCreateCompanionBuilder =
    ProductsTableCompanion Function({
      Value<int> id,
      required int companyId,
      required String name,
      Value<double> price,
      Value<double> cost,
      Value<String?> barcode,
      Value<int?> productGroupId,
      Value<bool> isService,
      Value<String?> colorHex,
      Value<String?> localImagePath,
      Value<String?> code,
      Value<int?> plu,
      Value<String?> measurementUnit,
      Value<String?> description,
      Value<double?> markup,
      Value<int> rank,
      Value<int?> currencyId,
      Value<int?> ageRestriction,
      Value<double?> lastPurchasePrice,
      Value<DateTime?> dateCreated,
      Value<DateTime?> dateUpdated,
      Value<bool> isPriceChangeAllowed,
      Value<bool> isUsingDefaultQuantity,
      Value<bool> isTaxInclusivePrice,
      Value<bool> isEnabled,
      required DateTime lastModified,
      Value<String> syncStatus,
      Value<String?> syncError,
    });
typedef $$ProductsTableTableUpdateCompanionBuilder =
    ProductsTableCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<String> name,
      Value<double> price,
      Value<double> cost,
      Value<String?> barcode,
      Value<int?> productGroupId,
      Value<bool> isService,
      Value<String?> colorHex,
      Value<String?> localImagePath,
      Value<String?> code,
      Value<int?> plu,
      Value<String?> measurementUnit,
      Value<String?> description,
      Value<double?> markup,
      Value<int> rank,
      Value<int?> currencyId,
      Value<int?> ageRestriction,
      Value<double?> lastPurchasePrice,
      Value<DateTime?> dateCreated,
      Value<DateTime?> dateUpdated,
      Value<bool> isPriceChangeAllowed,
      Value<bool> isUsingDefaultQuantity,
      Value<bool> isTaxInclusivePrice,
      Value<bool> isEnabled,
      Value<DateTime> lastModified,
      Value<String> syncStatus,
      Value<String?> syncError,
    });

class $$ProductsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableFilterComposer({
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

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productGroupId => $composableBuilder(
    column: $table.productGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isService => $composableBuilder(
    column: $table.isService,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plu => $composableBuilder(
    column: $table.plu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get measurementUnit => $composableBuilder(
    column: $table.measurementUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get markup => $composableBuilder(
    column: $table.markup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currencyId => $composableBuilder(
    column: $table.currencyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageRestriction => $composableBuilder(
    column: $table.ageRestriction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastPurchasePrice => $composableBuilder(
    column: $table.lastPurchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPriceChangeAllowed => $composableBuilder(
    column: $table.isPriceChangeAllowed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUsingDefaultQuantity => $composableBuilder(
    column: $table.isUsingDefaultQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTaxInclusivePrice => $composableBuilder(
    column: $table.isTaxInclusivePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableOrderingComposer({
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

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productGroupId => $composableBuilder(
    column: $table.productGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isService => $composableBuilder(
    column: $table.isService,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plu => $composableBuilder(
    column: $table.plu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get measurementUnit => $composableBuilder(
    column: $table.measurementUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get markup => $composableBuilder(
    column: $table.markup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currencyId => $composableBuilder(
    column: $table.currencyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageRestriction => $composableBuilder(
    column: $table.ageRestriction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastPurchasePrice => $composableBuilder(
    column: $table.lastPurchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPriceChangeAllowed => $composableBuilder(
    column: $table.isPriceChangeAllowed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUsingDefaultQuantity => $composableBuilder(
    column: $table.isUsingDefaultQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTaxInclusivePrice => $composableBuilder(
    column: $table.isTaxInclusivePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<int> get productGroupId => $composableBuilder(
    column: $table.productGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isService =>
      $composableBuilder(column: $table.isService, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get plu =>
      $composableBuilder(column: $table.plu, builder: (column) => column);

  GeneratedColumn<String> get measurementUnit => $composableBuilder(
    column: $table.measurementUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get markup =>
      $composableBuilder(column: $table.markup, builder: (column) => column);

  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<int> get currencyId => $composableBuilder(
    column: $table.currencyId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ageRestriction => $composableBuilder(
    column: $table.ageRestriction,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastPurchasePrice => $composableBuilder(
    column: $table.lastPurchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPriceChangeAllowed => $composableBuilder(
    column: $table.isPriceChangeAllowed,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isUsingDefaultQuantity => $composableBuilder(
    column: $table.isUsingDefaultQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTaxInclusivePrice => $composableBuilder(
    column: $table.isTaxInclusivePrice,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$ProductsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTableTable,
          ProductsTableData,
          $$ProductsTableTableFilterComposer,
          $$ProductsTableTableOrderingComposer,
          $$ProductsTableTableAnnotationComposer,
          $$ProductsTableTableCreateCompanionBuilder,
          $$ProductsTableTableUpdateCompanionBuilder,
          (
            ProductsTableData,
            BaseReferences<
              _$AppDatabase,
              $ProductsTableTable,
              ProductsTableData
            >,
          ),
          ProductsTableData,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableTableManager(_$AppDatabase db, $ProductsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<int?> productGroupId = const Value.absent(),
                Value<bool> isService = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<String?> localImagePath = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<int?> plu = const Value.absent(),
                Value<String?> measurementUnit = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> markup = const Value.absent(),
                Value<int> rank = const Value.absent(),
                Value<int?> currencyId = const Value.absent(),
                Value<int?> ageRestriction = const Value.absent(),
                Value<double?> lastPurchasePrice = const Value.absent(),
                Value<DateTime?> dateCreated = const Value.absent(),
                Value<DateTime?> dateUpdated = const Value.absent(),
                Value<bool> isPriceChangeAllowed = const Value.absent(),
                Value<bool> isUsingDefaultQuantity = const Value.absent(),
                Value<bool> isTaxInclusivePrice = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
              }) => ProductsTableCompanion(
                id: id,
                companyId: companyId,
                name: name,
                price: price,
                cost: cost,
                barcode: barcode,
                productGroupId: productGroupId,
                isService: isService,
                colorHex: colorHex,
                localImagePath: localImagePath,
                code: code,
                plu: plu,
                measurementUnit: measurementUnit,
                description: description,
                markup: markup,
                rank: rank,
                currencyId: currencyId,
                ageRestriction: ageRestriction,
                lastPurchasePrice: lastPurchasePrice,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                isPriceChangeAllowed: isPriceChangeAllowed,
                isUsingDefaultQuantity: isUsingDefaultQuantity,
                isTaxInclusivePrice: isTaxInclusivePrice,
                isEnabled: isEnabled,
                lastModified: lastModified,
                syncStatus: syncStatus,
                syncError: syncError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required String name,
                Value<double> price = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<int?> productGroupId = const Value.absent(),
                Value<bool> isService = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<String?> localImagePath = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<int?> plu = const Value.absent(),
                Value<String?> measurementUnit = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> markup = const Value.absent(),
                Value<int> rank = const Value.absent(),
                Value<int?> currencyId = const Value.absent(),
                Value<int?> ageRestriction = const Value.absent(),
                Value<double?> lastPurchasePrice = const Value.absent(),
                Value<DateTime?> dateCreated = const Value.absent(),
                Value<DateTime?> dateUpdated = const Value.absent(),
                Value<bool> isPriceChangeAllowed = const Value.absent(),
                Value<bool> isUsingDefaultQuantity = const Value.absent(),
                Value<bool> isTaxInclusivePrice = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                required DateTime lastModified,
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
              }) => ProductsTableCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                price: price,
                cost: cost,
                barcode: barcode,
                productGroupId: productGroupId,
                isService: isService,
                colorHex: colorHex,
                localImagePath: localImagePath,
                code: code,
                plu: plu,
                measurementUnit: measurementUnit,
                description: description,
                markup: markup,
                rank: rank,
                currencyId: currencyId,
                ageRestriction: ageRestriction,
                lastPurchasePrice: lastPurchasePrice,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                isPriceChangeAllowed: isPriceChangeAllowed,
                isUsingDefaultQuantity: isUsingDefaultQuantity,
                isTaxInclusivePrice: isTaxInclusivePrice,
                isEnabled: isEnabled,
                lastModified: lastModified,
                syncStatus: syncStatus,
                syncError: syncError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTableTable,
      ProductsTableData,
      $$ProductsTableTableFilterComposer,
      $$ProductsTableTableOrderingComposer,
      $$ProductsTableTableAnnotationComposer,
      $$ProductsTableTableCreateCompanionBuilder,
      $$ProductsTableTableUpdateCompanionBuilder,
      (
        ProductsTableData,
        BaseReferences<_$AppDatabase, $ProductsTableTable, ProductsTableData>,
      ),
      ProductsTableData,
      PrefetchHooks Function()
    >;
typedef $$TaxesTableTableCreateCompanionBuilder =
    TaxesTableCompanion Function({
      Value<int> id,
      required int companyId,
      required String name,
      required double rate,
      Value<String?> code,
      Value<bool> isFixed,
      Value<bool> isTaxOnTotal,
      Value<bool> isEnabled,
      required DateTime lastModified,
    });
typedef $$TaxesTableTableUpdateCompanionBuilder =
    TaxesTableCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<String> name,
      Value<double> rate,
      Value<String?> code,
      Value<bool> isFixed,
      Value<bool> isTaxOnTotal,
      Value<bool> isEnabled,
      Value<DateTime> lastModified,
    });

class $$TaxesTableTableFilterComposer
    extends Composer<_$AppDatabase, $TaxesTableTable> {
  $$TaxesTableTableFilterComposer({
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

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFixed => $composableBuilder(
    column: $table.isFixed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTaxOnTotal => $composableBuilder(
    column: $table.isTaxOnTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaxesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TaxesTableTable> {
  $$TaxesTableTableOrderingComposer({
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

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFixed => $composableBuilder(
    column: $table.isFixed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTaxOnTotal => $composableBuilder(
    column: $table.isTaxOnTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaxesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaxesTableTable> {
  $$TaxesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<bool> get isFixed =>
      $composableBuilder(column: $table.isFixed, builder: (column) => column);

  GeneratedColumn<bool> get isTaxOnTotal => $composableBuilder(
    column: $table.isTaxOnTotal,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );
}

class $$TaxesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaxesTableTable,
          TaxesTableData,
          $$TaxesTableTableFilterComposer,
          $$TaxesTableTableOrderingComposer,
          $$TaxesTableTableAnnotationComposer,
          $$TaxesTableTableCreateCompanionBuilder,
          $$TaxesTableTableUpdateCompanionBuilder,
          (
            TaxesTableData,
            BaseReferences<_$AppDatabase, $TaxesTableTable, TaxesTableData>,
          ),
          TaxesTableData,
          PrefetchHooks Function()
        > {
  $$TaxesTableTableTableManager(_$AppDatabase db, $TaxesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaxesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaxesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaxesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<bool> isFixed = const Value.absent(),
                Value<bool> isTaxOnTotal = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
              }) => TaxesTableCompanion(
                id: id,
                companyId: companyId,
                name: name,
                rate: rate,
                code: code,
                isFixed: isFixed,
                isTaxOnTotal: isTaxOnTotal,
                isEnabled: isEnabled,
                lastModified: lastModified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required String name,
                required double rate,
                Value<String?> code = const Value.absent(),
                Value<bool> isFixed = const Value.absent(),
                Value<bool> isTaxOnTotal = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                required DateTime lastModified,
              }) => TaxesTableCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                rate: rate,
                code: code,
                isFixed: isFixed,
                isTaxOnTotal: isTaxOnTotal,
                isEnabled: isEnabled,
                lastModified: lastModified,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaxesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaxesTableTable,
      TaxesTableData,
      $$TaxesTableTableFilterComposer,
      $$TaxesTableTableOrderingComposer,
      $$TaxesTableTableAnnotationComposer,
      $$TaxesTableTableCreateCompanionBuilder,
      $$TaxesTableTableUpdateCompanionBuilder,
      (
        TaxesTableData,
        BaseReferences<_$AppDatabase, $TaxesTableTable, TaxesTableData>,
      ),
      TaxesTableData,
      PrefetchHooks Function()
    >;
typedef $$FloorPlansTableTableCreateCompanionBuilder =
    FloorPlansTableCompanion Function({
      Value<int> id,
      required int companyId,
      required String name,
      Value<String> color,
      required DateTime lastModified,
    });
typedef $$FloorPlansTableTableUpdateCompanionBuilder =
    FloorPlansTableCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<String> name,
      Value<String> color,
      Value<DateTime> lastModified,
    });

class $$FloorPlansTableTableFilterComposer
    extends Composer<_$AppDatabase, $FloorPlansTableTable> {
  $$FloorPlansTableTableFilterComposer({
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

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FloorPlansTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FloorPlansTableTable> {
  $$FloorPlansTableTableOrderingComposer({
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

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FloorPlansTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FloorPlansTableTable> {
  $$FloorPlansTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );
}

class $$FloorPlansTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FloorPlansTableTable,
          FloorPlansTableData,
          $$FloorPlansTableTableFilterComposer,
          $$FloorPlansTableTableOrderingComposer,
          $$FloorPlansTableTableAnnotationComposer,
          $$FloorPlansTableTableCreateCompanionBuilder,
          $$FloorPlansTableTableUpdateCompanionBuilder,
          (
            FloorPlansTableData,
            BaseReferences<
              _$AppDatabase,
              $FloorPlansTableTable,
              FloorPlansTableData
            >,
          ),
          FloorPlansTableData,
          PrefetchHooks Function()
        > {
  $$FloorPlansTableTableTableManager(
    _$AppDatabase db,
    $FloorPlansTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FloorPlansTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FloorPlansTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FloorPlansTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
              }) => FloorPlansTableCompanion(
                id: id,
                companyId: companyId,
                name: name,
                color: color,
                lastModified: lastModified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required String name,
                Value<String> color = const Value.absent(),
                required DateTime lastModified,
              }) => FloorPlansTableCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                color: color,
                lastModified: lastModified,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FloorPlansTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FloorPlansTableTable,
      FloorPlansTableData,
      $$FloorPlansTableTableFilterComposer,
      $$FloorPlansTableTableOrderingComposer,
      $$FloorPlansTableTableAnnotationComposer,
      $$FloorPlansTableTableCreateCompanionBuilder,
      $$FloorPlansTableTableUpdateCompanionBuilder,
      (
        FloorPlansTableData,
        BaseReferences<
          _$AppDatabase,
          $FloorPlansTableTable,
          FloorPlansTableData
        >,
      ),
      FloorPlansTableData,
      PrefetchHooks Function()
    >;
typedef $$FloorPlanTablesTableTableCreateCompanionBuilder =
    FloorPlanTablesTableCompanion Function({
      Value<int> id,
      required int companyId,
      required int floorPlanId,
      required String name,
      required double positionX,
      required double positionY,
      required double width,
      required double height,
      Value<bool> isRound,
      Value<int> status,
      required DateTime lastModified,
    });
typedef $$FloorPlanTablesTableTableUpdateCompanionBuilder =
    FloorPlanTablesTableCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<int> floorPlanId,
      Value<String> name,
      Value<double> positionX,
      Value<double> positionY,
      Value<double> width,
      Value<double> height,
      Value<bool> isRound,
      Value<int> status,
      Value<DateTime> lastModified,
    });

class $$FloorPlanTablesTableTableFilterComposer
    extends Composer<_$AppDatabase, $FloorPlanTablesTableTable> {
  $$FloorPlanTablesTableTableFilterComposer({
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

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get floorPlanId => $composableBuilder(
    column: $table.floorPlanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get positionX => $composableBuilder(
    column: $table.positionX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get positionY => $composableBuilder(
    column: $table.positionY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRound => $composableBuilder(
    column: $table.isRound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FloorPlanTablesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FloorPlanTablesTableTable> {
  $$FloorPlanTablesTableTableOrderingComposer({
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

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get floorPlanId => $composableBuilder(
    column: $table.floorPlanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get positionX => $composableBuilder(
    column: $table.positionX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get positionY => $composableBuilder(
    column: $table.positionY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRound => $composableBuilder(
    column: $table.isRound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FloorPlanTablesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FloorPlanTablesTableTable> {
  $$FloorPlanTablesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<int> get floorPlanId => $composableBuilder(
    column: $table.floorPlanId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get positionX =>
      $composableBuilder(column: $table.positionX, builder: (column) => column);

  GeneratedColumn<double> get positionY =>
      $composableBuilder(column: $table.positionY, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<bool> get isRound =>
      $composableBuilder(column: $table.isRound, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );
}

class $$FloorPlanTablesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FloorPlanTablesTableTable,
          FloorPlanTablesTableData,
          $$FloorPlanTablesTableTableFilterComposer,
          $$FloorPlanTablesTableTableOrderingComposer,
          $$FloorPlanTablesTableTableAnnotationComposer,
          $$FloorPlanTablesTableTableCreateCompanionBuilder,
          $$FloorPlanTablesTableTableUpdateCompanionBuilder,
          (
            FloorPlanTablesTableData,
            BaseReferences<
              _$AppDatabase,
              $FloorPlanTablesTableTable,
              FloorPlanTablesTableData
            >,
          ),
          FloorPlanTablesTableData,
          PrefetchHooks Function()
        > {
  $$FloorPlanTablesTableTableTableManager(
    _$AppDatabase db,
    $FloorPlanTablesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FloorPlanTablesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FloorPlanTablesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FloorPlanTablesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> floorPlanId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> positionX = const Value.absent(),
                Value<double> positionY = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<bool> isRound = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
              }) => FloorPlanTablesTableCompanion(
                id: id,
                companyId: companyId,
                floorPlanId: floorPlanId,
                name: name,
                positionX: positionX,
                positionY: positionY,
                width: width,
                height: height,
                isRound: isRound,
                status: status,
                lastModified: lastModified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required int floorPlanId,
                required String name,
                required double positionX,
                required double positionY,
                required double width,
                required double height,
                Value<bool> isRound = const Value.absent(),
                Value<int> status = const Value.absent(),
                required DateTime lastModified,
              }) => FloorPlanTablesTableCompanion.insert(
                id: id,
                companyId: companyId,
                floorPlanId: floorPlanId,
                name: name,
                positionX: positionX,
                positionY: positionY,
                width: width,
                height: height,
                isRound: isRound,
                status: status,
                lastModified: lastModified,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FloorPlanTablesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FloorPlanTablesTableTable,
      FloorPlanTablesTableData,
      $$FloorPlanTablesTableTableFilterComposer,
      $$FloorPlanTablesTableTableOrderingComposer,
      $$FloorPlanTablesTableTableAnnotationComposer,
      $$FloorPlanTablesTableTableCreateCompanionBuilder,
      $$FloorPlanTablesTableTableUpdateCompanionBuilder,
      (
        FloorPlanTablesTableData,
        BaseReferences<
          _$AppDatabase,
          $FloorPlanTablesTableTable,
          FloorPlanTablesTableData
        >,
      ),
      FloorPlanTablesTableData,
      PrefetchHooks Function()
    >;
typedef $$UsersTableTableCreateCompanionBuilder =
    UsersTableCompanion Function({
      Value<int> id,
      required int companyId,
      required String name,
      Value<String?> firstName,
      Value<String?> lastName,
      Value<String?> username,
      Value<String?> email,
      Value<String?> pinHash,
      Value<int> role,
      Value<bool> isEnabled,
      required DateTime lastModified,
    });
typedef $$UsersTableTableUpdateCompanionBuilder =
    UsersTableCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<String> name,
      Value<String?> firstName,
      Value<String?> lastName,
      Value<String?> username,
      Value<String?> email,
      Value<String?> pinHash,
      Value<int> role,
      Value<bool> isEnabled,
      Value<DateTime> lastModified,
    });

class $$UsersTableTableFilterComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableFilterComposer({
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

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableOrderingComposer({
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

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<int> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );
}

class $$UsersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTableTable,
          UsersTableData,
          $$UsersTableTableFilterComposer,
          $$UsersTableTableOrderingComposer,
          $$UsersTableTableAnnotationComposer,
          $$UsersTableTableCreateCompanionBuilder,
          $$UsersTableTableUpdateCompanionBuilder,
          (
            UsersTableData,
            BaseReferences<_$AppDatabase, $UsersTableTable, UsersTableData>,
          ),
          UsersTableData,
          PrefetchHooks Function()
        > {
  $$UsersTableTableTableManager(_$AppDatabase db, $UsersTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<int> role = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
              }) => UsersTableCompanion(
                id: id,
                companyId: companyId,
                name: name,
                firstName: firstName,
                lastName: lastName,
                username: username,
                email: email,
                pinHash: pinHash,
                role: role,
                isEnabled: isEnabled,
                lastModified: lastModified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required String name,
                Value<String?> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<int> role = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                required DateTime lastModified,
              }) => UsersTableCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                firstName: firstName,
                lastName: lastName,
                username: username,
                email: email,
                pinHash: pinHash,
                role: role,
                isEnabled: isEnabled,
                lastModified: lastModified,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTableTable,
      UsersTableData,
      $$UsersTableTableFilterComposer,
      $$UsersTableTableOrderingComposer,
      $$UsersTableTableAnnotationComposer,
      $$UsersTableTableCreateCompanionBuilder,
      $$UsersTableTableUpdateCompanionBuilder,
      (
        UsersTableData,
        BaseReferences<_$AppDatabase, $UsersTableTable, UsersTableData>,
      ),
      UsersTableData,
      PrefetchHooks Function()
    >;
typedef $$AppPropertiesTableTableCreateCompanionBuilder =
    AppPropertiesTableCompanion Function({
      Value<int> id,
      required int companyId,
      required String name,
      Value<String?> value,
      required DateTime lastModified,
      Value<String> syncStatus,
    });
typedef $$AppPropertiesTableTableUpdateCompanionBuilder =
    AppPropertiesTableCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<String> name,
      Value<String?> value,
      Value<DateTime> lastModified,
      Value<String> syncStatus,
    });

class $$AppPropertiesTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppPropertiesTableTable> {
  $$AppPropertiesTableTableFilterComposer({
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

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPropertiesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPropertiesTableTable> {
  $$AppPropertiesTableTableOrderingComposer({
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

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPropertiesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPropertiesTableTable> {
  $$AppPropertiesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$AppPropertiesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppPropertiesTableTable,
          AppPropertiesTableData,
          $$AppPropertiesTableTableFilterComposer,
          $$AppPropertiesTableTableOrderingComposer,
          $$AppPropertiesTableTableAnnotationComposer,
          $$AppPropertiesTableTableCreateCompanionBuilder,
          $$AppPropertiesTableTableUpdateCompanionBuilder,
          (
            AppPropertiesTableData,
            BaseReferences<
              _$AppDatabase,
              $AppPropertiesTableTable,
              AppPropertiesTableData
            >,
          ),
          AppPropertiesTableData,
          PrefetchHooks Function()
        > {
  $$AppPropertiesTableTableTableManager(
    _$AppDatabase db,
    $AppPropertiesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPropertiesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPropertiesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPropertiesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
              }) => AppPropertiesTableCompanion(
                id: id,
                companyId: companyId,
                name: name,
                value: value,
                lastModified: lastModified,
                syncStatus: syncStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required String name,
                Value<String?> value = const Value.absent(),
                required DateTime lastModified,
                Value<String> syncStatus = const Value.absent(),
              }) => AppPropertiesTableCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                value: value,
                lastModified: lastModified,
                syncStatus: syncStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPropertiesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppPropertiesTableTable,
      AppPropertiesTableData,
      $$AppPropertiesTableTableFilterComposer,
      $$AppPropertiesTableTableOrderingComposer,
      $$AppPropertiesTableTableAnnotationComposer,
      $$AppPropertiesTableTableCreateCompanionBuilder,
      $$AppPropertiesTableTableUpdateCompanionBuilder,
      (
        AppPropertiesTableData,
        BaseReferences<
          _$AppDatabase,
          $AppPropertiesTableTable,
          AppPropertiesTableData
        >,
      ),
      AppPropertiesTableData,
      PrefetchHooks Function()
    >;
typedef $$ProductGroupsTableTableCreateCompanionBuilder =
    ProductGroupsTableCompanion Function({
      Value<int> id,
      required int companyId,
      required String name,
      Value<int?> parentGroupId,
      Value<String> colorHex,
      Value<int> rank,
      Value<String?> localImagePath,
      required DateTime lastModified,
      Value<String> syncStatus,
      Value<String?> syncError,
    });
typedef $$ProductGroupsTableTableUpdateCompanionBuilder =
    ProductGroupsTableCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<String> name,
      Value<int?> parentGroupId,
      Value<String> colorHex,
      Value<int> rank,
      Value<String?> localImagePath,
      Value<DateTime> lastModified,
      Value<String> syncStatus,
      Value<String?> syncError,
    });

class $$ProductGroupsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductGroupsTableTable> {
  $$ProductGroupsTableTableFilterComposer({
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

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentGroupId => $composableBuilder(
    column: $table.parentGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductGroupsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductGroupsTableTable> {
  $$ProductGroupsTableTableOrderingComposer({
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

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentGroupId => $composableBuilder(
    column: $table.parentGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductGroupsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductGroupsTableTable> {
  $$ProductGroupsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get parentGroupId => $composableBuilder(
    column: $table.parentGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$ProductGroupsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductGroupsTableTable,
          ProductGroupsTableData,
          $$ProductGroupsTableTableFilterComposer,
          $$ProductGroupsTableTableOrderingComposer,
          $$ProductGroupsTableTableAnnotationComposer,
          $$ProductGroupsTableTableCreateCompanionBuilder,
          $$ProductGroupsTableTableUpdateCompanionBuilder,
          (
            ProductGroupsTableData,
            BaseReferences<
              _$AppDatabase,
              $ProductGroupsTableTable,
              ProductGroupsTableData
            >,
          ),
          ProductGroupsTableData,
          PrefetchHooks Function()
        > {
  $$ProductGroupsTableTableTableManager(
    _$AppDatabase db,
    $ProductGroupsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductGroupsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductGroupsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductGroupsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> parentGroupId = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> rank = const Value.absent(),
                Value<String?> localImagePath = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
              }) => ProductGroupsTableCompanion(
                id: id,
                companyId: companyId,
                name: name,
                parentGroupId: parentGroupId,
                colorHex: colorHex,
                rank: rank,
                localImagePath: localImagePath,
                lastModified: lastModified,
                syncStatus: syncStatus,
                syncError: syncError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required String name,
                Value<int?> parentGroupId = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> rank = const Value.absent(),
                Value<String?> localImagePath = const Value.absent(),
                required DateTime lastModified,
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
              }) => ProductGroupsTableCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                parentGroupId: parentGroupId,
                colorHex: colorHex,
                rank: rank,
                localImagePath: localImagePath,
                lastModified: lastModified,
                syncStatus: syncStatus,
                syncError: syncError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductGroupsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductGroupsTableTable,
      ProductGroupsTableData,
      $$ProductGroupsTableTableFilterComposer,
      $$ProductGroupsTableTableOrderingComposer,
      $$ProductGroupsTableTableAnnotationComposer,
      $$ProductGroupsTableTableCreateCompanionBuilder,
      $$ProductGroupsTableTableUpdateCompanionBuilder,
      (
        ProductGroupsTableData,
        BaseReferences<
          _$AppDatabase,
          $ProductGroupsTableTable,
          ProductGroupsTableData
        >,
      ),
      ProductGroupsTableData,
      PrefetchHooks Function()
    >;
typedef $$PaymentTypesTableTableCreateCompanionBuilder =
    PaymentTypesTableCompanion Function({
      Value<int> id,
      required int companyId,
      required String name,
      Value<String?> code,
      Value<bool> isCustomerRequired,
      Value<bool> isFiscal,
      Value<bool> isSlipRequired,
      Value<bool> isChangeAllowed,
      Value<int> ordinal,
      Value<bool> isEnabled,
      Value<bool> isQuickPayment,
      Value<bool> openCashDrawer,
      Value<String?> shortcutKey,
      Value<bool> markAsPaid,
      required DateTime lastModified,
    });
typedef $$PaymentTypesTableTableUpdateCompanionBuilder =
    PaymentTypesTableCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<String> name,
      Value<String?> code,
      Value<bool> isCustomerRequired,
      Value<bool> isFiscal,
      Value<bool> isSlipRequired,
      Value<bool> isChangeAllowed,
      Value<int> ordinal,
      Value<bool> isEnabled,
      Value<bool> isQuickPayment,
      Value<bool> openCashDrawer,
      Value<String?> shortcutKey,
      Value<bool> markAsPaid,
      Value<DateTime> lastModified,
    });

class $$PaymentTypesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentTypesTableTable> {
  $$PaymentTypesTableTableFilterComposer({
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

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustomerRequired => $composableBuilder(
    column: $table.isCustomerRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFiscal => $composableBuilder(
    column: $table.isFiscal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSlipRequired => $composableBuilder(
    column: $table.isSlipRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isChangeAllowed => $composableBuilder(
    column: $table.isChangeAllowed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isQuickPayment => $composableBuilder(
    column: $table.isQuickPayment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get openCashDrawer => $composableBuilder(
    column: $table.openCashDrawer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortcutKey => $composableBuilder(
    column: $table.shortcutKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get markAsPaid => $composableBuilder(
    column: $table.markAsPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentTypesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentTypesTableTable> {
  $$PaymentTypesTableTableOrderingComposer({
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

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustomerRequired => $composableBuilder(
    column: $table.isCustomerRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFiscal => $composableBuilder(
    column: $table.isFiscal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSlipRequired => $composableBuilder(
    column: $table.isSlipRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isChangeAllowed => $composableBuilder(
    column: $table.isChangeAllowed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isQuickPayment => $composableBuilder(
    column: $table.isQuickPayment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get openCashDrawer => $composableBuilder(
    column: $table.openCashDrawer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortcutKey => $composableBuilder(
    column: $table.shortcutKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get markAsPaid => $composableBuilder(
    column: $table.markAsPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentTypesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentTypesTableTable> {
  $$PaymentTypesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<bool> get isCustomerRequired => $composableBuilder(
    column: $table.isCustomerRequired,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFiscal =>
      $composableBuilder(column: $table.isFiscal, builder: (column) => column);

  GeneratedColumn<bool> get isSlipRequired => $composableBuilder(
    column: $table.isSlipRequired,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isChangeAllowed => $composableBuilder(
    column: $table.isChangeAllowed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<bool> get isQuickPayment => $composableBuilder(
    column: $table.isQuickPayment,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get openCashDrawer => $composableBuilder(
    column: $table.openCashDrawer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shortcutKey => $composableBuilder(
    column: $table.shortcutKey,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get markAsPaid => $composableBuilder(
    column: $table.markAsPaid,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );
}

class $$PaymentTypesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentTypesTableTable,
          PaymentTypesTableData,
          $$PaymentTypesTableTableFilterComposer,
          $$PaymentTypesTableTableOrderingComposer,
          $$PaymentTypesTableTableAnnotationComposer,
          $$PaymentTypesTableTableCreateCompanionBuilder,
          $$PaymentTypesTableTableUpdateCompanionBuilder,
          (
            PaymentTypesTableData,
            BaseReferences<
              _$AppDatabase,
              $PaymentTypesTableTable,
              PaymentTypesTableData
            >,
          ),
          PaymentTypesTableData,
          PrefetchHooks Function()
        > {
  $$PaymentTypesTableTableTableManager(
    _$AppDatabase db,
    $PaymentTypesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentTypesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentTypesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentTypesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<bool> isCustomerRequired = const Value.absent(),
                Value<bool> isFiscal = const Value.absent(),
                Value<bool> isSlipRequired = const Value.absent(),
                Value<bool> isChangeAllowed = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<bool> isQuickPayment = const Value.absent(),
                Value<bool> openCashDrawer = const Value.absent(),
                Value<String?> shortcutKey = const Value.absent(),
                Value<bool> markAsPaid = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
              }) => PaymentTypesTableCompanion(
                id: id,
                companyId: companyId,
                name: name,
                code: code,
                isCustomerRequired: isCustomerRequired,
                isFiscal: isFiscal,
                isSlipRequired: isSlipRequired,
                isChangeAllowed: isChangeAllowed,
                ordinal: ordinal,
                isEnabled: isEnabled,
                isQuickPayment: isQuickPayment,
                openCashDrawer: openCashDrawer,
                shortcutKey: shortcutKey,
                markAsPaid: markAsPaid,
                lastModified: lastModified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required String name,
                Value<String?> code = const Value.absent(),
                Value<bool> isCustomerRequired = const Value.absent(),
                Value<bool> isFiscal = const Value.absent(),
                Value<bool> isSlipRequired = const Value.absent(),
                Value<bool> isChangeAllowed = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<bool> isQuickPayment = const Value.absent(),
                Value<bool> openCashDrawer = const Value.absent(),
                Value<String?> shortcutKey = const Value.absent(),
                Value<bool> markAsPaid = const Value.absent(),
                required DateTime lastModified,
              }) => PaymentTypesTableCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                code: code,
                isCustomerRequired: isCustomerRequired,
                isFiscal: isFiscal,
                isSlipRequired: isSlipRequired,
                isChangeAllowed: isChangeAllowed,
                ordinal: ordinal,
                isEnabled: isEnabled,
                isQuickPayment: isQuickPayment,
                openCashDrawer: openCashDrawer,
                shortcutKey: shortcutKey,
                markAsPaid: markAsPaid,
                lastModified: lastModified,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentTypesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentTypesTableTable,
      PaymentTypesTableData,
      $$PaymentTypesTableTableFilterComposer,
      $$PaymentTypesTableTableOrderingComposer,
      $$PaymentTypesTableTableAnnotationComposer,
      $$PaymentTypesTableTableCreateCompanionBuilder,
      $$PaymentTypesTableTableUpdateCompanionBuilder,
      (
        PaymentTypesTableData,
        BaseReferences<
          _$AppDatabase,
          $PaymentTypesTableTable,
          PaymentTypesTableData
        >,
      ),
      PaymentTypesTableData,
      PrefetchHooks Function()
    >;
typedef $$CustomersTableTableCreateCompanionBuilder =
    CustomersTableCompanion Function({
      Value<int> id,
      required int companyId,
      Value<String?> code,
      required String name,
      Value<String?> taxNumber,
      Value<String?> address,
      Value<String?> postalCode,
      Value<String?> city,
      Value<int?> countryId,
      Value<String?> email,
      Value<String?> phoneNumber,
      Value<bool> isEnabled,
      Value<bool> isCustomer,
      Value<bool> isSupplier,
      Value<int?> dueDatePeriod,
      Value<String?> streetName,
      Value<String?> additionalStreetName,
      Value<String?> buildingNumber,
      Value<String?> plotIdentification,
      Value<String?> citySubdivisionName,
      Value<bool> isTaxExempt,
      required DateTime lastModified,
      Value<String> syncStatus,
      Value<String?> syncError,
    });
typedef $$CustomersTableTableUpdateCompanionBuilder =
    CustomersTableCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<String?> code,
      Value<String> name,
      Value<String?> taxNumber,
      Value<String?> address,
      Value<String?> postalCode,
      Value<String?> city,
      Value<int?> countryId,
      Value<String?> email,
      Value<String?> phoneNumber,
      Value<bool> isEnabled,
      Value<bool> isCustomer,
      Value<bool> isSupplier,
      Value<int?> dueDatePeriod,
      Value<String?> streetName,
      Value<String?> additionalStreetName,
      Value<String?> buildingNumber,
      Value<String?> plotIdentification,
      Value<String?> citySubdivisionName,
      Value<bool> isTaxExempt,
      Value<DateTime> lastModified,
      Value<String> syncStatus,
      Value<String?> syncError,
    });

class $$CustomersTableTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTableTable> {
  $$CustomersTableTableFilterComposer({
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

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxNumber => $composableBuilder(
    column: $table.taxNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get countryId => $composableBuilder(
    column: $table.countryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustomer => $composableBuilder(
    column: $table.isCustomer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSupplier => $composableBuilder(
    column: $table.isSupplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDatePeriod => $composableBuilder(
    column: $table.dueDatePeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streetName => $composableBuilder(
    column: $table.streetName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get additionalStreetName => $composableBuilder(
    column: $table.additionalStreetName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buildingNumber => $composableBuilder(
    column: $table.buildingNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plotIdentification => $composableBuilder(
    column: $table.plotIdentification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get citySubdivisionName => $composableBuilder(
    column: $table.citySubdivisionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTaxExempt => $composableBuilder(
    column: $table.isTaxExempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTableTable> {
  $$CustomersTableTableOrderingComposer({
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

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxNumber => $composableBuilder(
    column: $table.taxNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get countryId => $composableBuilder(
    column: $table.countryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustomer => $composableBuilder(
    column: $table.isCustomer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSupplier => $composableBuilder(
    column: $table.isSupplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDatePeriod => $composableBuilder(
    column: $table.dueDatePeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streetName => $composableBuilder(
    column: $table.streetName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get additionalStreetName => $composableBuilder(
    column: $table.additionalStreetName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buildingNumber => $composableBuilder(
    column: $table.buildingNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plotIdentification => $composableBuilder(
    column: $table.plotIdentification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get citySubdivisionName => $composableBuilder(
    column: $table.citySubdivisionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTaxExempt => $composableBuilder(
    column: $table.isTaxExempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTableTable> {
  $$CustomersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get taxNumber =>
      $composableBuilder(column: $table.taxNumber, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<int> get countryId =>
      $composableBuilder(column: $table.countryId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<bool> get isCustomer => $composableBuilder(
    column: $table.isCustomer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSupplier => $composableBuilder(
    column: $table.isSupplier,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueDatePeriod => $composableBuilder(
    column: $table.dueDatePeriod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get streetName => $composableBuilder(
    column: $table.streetName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get additionalStreetName => $composableBuilder(
    column: $table.additionalStreetName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get buildingNumber => $composableBuilder(
    column: $table.buildingNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plotIdentification => $composableBuilder(
    column: $table.plotIdentification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get citySubdivisionName => $composableBuilder(
    column: $table.citySubdivisionName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTaxExempt => $composableBuilder(
    column: $table.isTaxExempt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$CustomersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTableTable,
          CustomersTableData,
          $$CustomersTableTableFilterComposer,
          $$CustomersTableTableOrderingComposer,
          $$CustomersTableTableAnnotationComposer,
          $$CustomersTableTableCreateCompanionBuilder,
          $$CustomersTableTableUpdateCompanionBuilder,
          (
            CustomersTableData,
            BaseReferences<
              _$AppDatabase,
              $CustomersTableTable,
              CustomersTableData
            >,
          ),
          CustomersTableData,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableTableManager(
    _$AppDatabase db,
    $CustomersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> taxNumber = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> postalCode = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<int?> countryId = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<bool> isCustomer = const Value.absent(),
                Value<bool> isSupplier = const Value.absent(),
                Value<int?> dueDatePeriod = const Value.absent(),
                Value<String?> streetName = const Value.absent(),
                Value<String?> additionalStreetName = const Value.absent(),
                Value<String?> buildingNumber = const Value.absent(),
                Value<String?> plotIdentification = const Value.absent(),
                Value<String?> citySubdivisionName = const Value.absent(),
                Value<bool> isTaxExempt = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
              }) => CustomersTableCompanion(
                id: id,
                companyId: companyId,
                code: code,
                name: name,
                taxNumber: taxNumber,
                address: address,
                postalCode: postalCode,
                city: city,
                countryId: countryId,
                email: email,
                phoneNumber: phoneNumber,
                isEnabled: isEnabled,
                isCustomer: isCustomer,
                isSupplier: isSupplier,
                dueDatePeriod: dueDatePeriod,
                streetName: streetName,
                additionalStreetName: additionalStreetName,
                buildingNumber: buildingNumber,
                plotIdentification: plotIdentification,
                citySubdivisionName: citySubdivisionName,
                isTaxExempt: isTaxExempt,
                lastModified: lastModified,
                syncStatus: syncStatus,
                syncError: syncError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                Value<String?> code = const Value.absent(),
                required String name,
                Value<String?> taxNumber = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> postalCode = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<int?> countryId = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<bool> isCustomer = const Value.absent(),
                Value<bool> isSupplier = const Value.absent(),
                Value<int?> dueDatePeriod = const Value.absent(),
                Value<String?> streetName = const Value.absent(),
                Value<String?> additionalStreetName = const Value.absent(),
                Value<String?> buildingNumber = const Value.absent(),
                Value<String?> plotIdentification = const Value.absent(),
                Value<String?> citySubdivisionName = const Value.absent(),
                Value<bool> isTaxExempt = const Value.absent(),
                required DateTime lastModified,
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
              }) => CustomersTableCompanion.insert(
                id: id,
                companyId: companyId,
                code: code,
                name: name,
                taxNumber: taxNumber,
                address: address,
                postalCode: postalCode,
                city: city,
                countryId: countryId,
                email: email,
                phoneNumber: phoneNumber,
                isEnabled: isEnabled,
                isCustomer: isCustomer,
                isSupplier: isSupplier,
                dueDatePeriod: dueDatePeriod,
                streetName: streetName,
                additionalStreetName: additionalStreetName,
                buildingNumber: buildingNumber,
                plotIdentification: plotIdentification,
                citySubdivisionName: citySubdivisionName,
                isTaxExempt: isTaxExempt,
                lastModified: lastModified,
                syncStatus: syncStatus,
                syncError: syncError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTableTable,
      CustomersTableData,
      $$CustomersTableTableFilterComposer,
      $$CustomersTableTableOrderingComposer,
      $$CustomersTableTableAnnotationComposer,
      $$CustomersTableTableCreateCompanionBuilder,
      $$CustomersTableTableUpdateCompanionBuilder,
      (
        CustomersTableData,
        BaseReferences<_$AppDatabase, $CustomersTableTable, CustomersTableData>,
      ),
      CustomersTableData,
      PrefetchHooks Function()
    >;
typedef $$PromotionsTableTableCreateCompanionBuilder =
    PromotionsTableCompanion Function({
      Value<int> id,
      required int companyId,
      required String name,
      Value<int> daysOfWeek,
      Value<bool> isEnabled,
      Value<DateTime?> startDate,
      Value<String?> startTime,
      Value<DateTime?> endDate,
      Value<String?> endTime,
      required DateTime lastModified,
      Value<String> syncStatus,
      Value<String?> syncError,
    });
typedef $$PromotionsTableTableUpdateCompanionBuilder =
    PromotionsTableCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<String> name,
      Value<int> daysOfWeek,
      Value<bool> isEnabled,
      Value<DateTime?> startDate,
      Value<String?> startTime,
      Value<DateTime?> endDate,
      Value<String?> endTime,
      Value<DateTime> lastModified,
      Value<String> syncStatus,
      Value<String?> syncError,
    });

class $$PromotionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PromotionsTableTable> {
  $$PromotionsTableTableFilterComposer({
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

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PromotionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PromotionsTableTable> {
  $$PromotionsTableTableOrderingComposer({
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

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PromotionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromotionsTableTable> {
  $$PromotionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$PromotionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PromotionsTableTable,
          PromotionsTableData,
          $$PromotionsTableTableFilterComposer,
          $$PromotionsTableTableOrderingComposer,
          $$PromotionsTableTableAnnotationComposer,
          $$PromotionsTableTableCreateCompanionBuilder,
          $$PromotionsTableTableUpdateCompanionBuilder,
          (
            PromotionsTableData,
            BaseReferences<
              _$AppDatabase,
              $PromotionsTableTable,
              PromotionsTableData
            >,
          ),
          PromotionsTableData,
          PrefetchHooks Function()
        > {
  $$PromotionsTableTableTableManager(
    _$AppDatabase db,
    $PromotionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromotionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromotionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromotionsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> daysOfWeek = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
              }) => PromotionsTableCompanion(
                id: id,
                companyId: companyId,
                name: name,
                daysOfWeek: daysOfWeek,
                isEnabled: isEnabled,
                startDate: startDate,
                startTime: startTime,
                endDate: endDate,
                endTime: endTime,
                lastModified: lastModified,
                syncStatus: syncStatus,
                syncError: syncError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required String name,
                Value<int> daysOfWeek = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                required DateTime lastModified,
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
              }) => PromotionsTableCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                daysOfWeek: daysOfWeek,
                isEnabled: isEnabled,
                startDate: startDate,
                startTime: startTime,
                endDate: endDate,
                endTime: endTime,
                lastModified: lastModified,
                syncStatus: syncStatus,
                syncError: syncError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PromotionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PromotionsTableTable,
      PromotionsTableData,
      $$PromotionsTableTableFilterComposer,
      $$PromotionsTableTableOrderingComposer,
      $$PromotionsTableTableAnnotationComposer,
      $$PromotionsTableTableCreateCompanionBuilder,
      $$PromotionsTableTableUpdateCompanionBuilder,
      (
        PromotionsTableData,
        BaseReferences<
          _$AppDatabase,
          $PromotionsTableTable,
          PromotionsTableData
        >,
      ),
      PromotionsTableData,
      PrefetchHooks Function()
    >;
typedef $$PromotionItemsTableTableCreateCompanionBuilder =
    PromotionItemsTableCompanion Function({
      Value<int> id,
      required int promotionId,
      required int productId,
      Value<int> discountType,
      Value<int> priceType,
      Value<double> value,
      Value<bool> isConditional,
      Value<double> quantity,
      Value<int> conditionType,
      Value<double> quantityLimit,
    });
typedef $$PromotionItemsTableTableUpdateCompanionBuilder =
    PromotionItemsTableCompanion Function({
      Value<int> id,
      Value<int> promotionId,
      Value<int> productId,
      Value<int> discountType,
      Value<int> priceType,
      Value<double> value,
      Value<bool> isConditional,
      Value<double> quantity,
      Value<int> conditionType,
      Value<double> quantityLimit,
    });

class $$PromotionItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PromotionItemsTableTable> {
  $$PromotionItemsTableTableFilterComposer({
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

  ColumnFilters<int> get promotionId => $composableBuilder(
    column: $table.promotionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceType => $composableBuilder(
    column: $table.priceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isConditional => $composableBuilder(
    column: $table.isConditional,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conditionType => $composableBuilder(
    column: $table.conditionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityLimit => $composableBuilder(
    column: $table.quantityLimit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PromotionItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PromotionItemsTableTable> {
  $$PromotionItemsTableTableOrderingComposer({
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

  ColumnOrderings<int> get promotionId => $composableBuilder(
    column: $table.promotionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceType => $composableBuilder(
    column: $table.priceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isConditional => $composableBuilder(
    column: $table.isConditional,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conditionType => $composableBuilder(
    column: $table.conditionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityLimit => $composableBuilder(
    column: $table.quantityLimit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PromotionItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromotionItemsTableTable> {
  $$PromotionItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get promotionId => $composableBuilder(
    column: $table.promotionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priceType =>
      $composableBuilder(column: $table.priceType, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<bool> get isConditional => $composableBuilder(
    column: $table.isConditional,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get conditionType => $composableBuilder(
    column: $table.conditionType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantityLimit => $composableBuilder(
    column: $table.quantityLimit,
    builder: (column) => column,
  );
}

class $$PromotionItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PromotionItemsTableTable,
          PromotionItemsTableData,
          $$PromotionItemsTableTableFilterComposer,
          $$PromotionItemsTableTableOrderingComposer,
          $$PromotionItemsTableTableAnnotationComposer,
          $$PromotionItemsTableTableCreateCompanionBuilder,
          $$PromotionItemsTableTableUpdateCompanionBuilder,
          (
            PromotionItemsTableData,
            BaseReferences<
              _$AppDatabase,
              $PromotionItemsTableTable,
              PromotionItemsTableData
            >,
          ),
          PromotionItemsTableData,
          PrefetchHooks Function()
        > {
  $$PromotionItemsTableTableTableManager(
    _$AppDatabase db,
    $PromotionItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromotionItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromotionItemsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PromotionItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> promotionId = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<int> discountType = const Value.absent(),
                Value<int> priceType = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<bool> isConditional = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<int> conditionType = const Value.absent(),
                Value<double> quantityLimit = const Value.absent(),
              }) => PromotionItemsTableCompanion(
                id: id,
                promotionId: promotionId,
                productId: productId,
                discountType: discountType,
                priceType: priceType,
                value: value,
                isConditional: isConditional,
                quantity: quantity,
                conditionType: conditionType,
                quantityLimit: quantityLimit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int promotionId,
                required int productId,
                Value<int> discountType = const Value.absent(),
                Value<int> priceType = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<bool> isConditional = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<int> conditionType = const Value.absent(),
                Value<double> quantityLimit = const Value.absent(),
              }) => PromotionItemsTableCompanion.insert(
                id: id,
                promotionId: promotionId,
                productId: productId,
                discountType: discountType,
                priceType: priceType,
                value: value,
                isConditional: isConditional,
                quantity: quantity,
                conditionType: conditionType,
                quantityLimit: quantityLimit,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PromotionItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PromotionItemsTableTable,
      PromotionItemsTableData,
      $$PromotionItemsTableTableFilterComposer,
      $$PromotionItemsTableTableOrderingComposer,
      $$PromotionItemsTableTableAnnotationComposer,
      $$PromotionItemsTableTableCreateCompanionBuilder,
      $$PromotionItemsTableTableUpdateCompanionBuilder,
      (
        PromotionItemsTableData,
        BaseReferences<
          _$AppDatabase,
          $PromotionItemsTableTable,
          PromotionItemsTableData
        >,
      ),
      PromotionItemsTableData,
      PrefetchHooks Function()
    >;
typedef $$ProductCommentsTableTableCreateCompanionBuilder =
    ProductCommentsTableCompanion Function({
      Value<int> id,
      required int companyId,
      required int productId,
      required String comment,
      required DateTime lastModified,
    });
typedef $$ProductCommentsTableTableUpdateCompanionBuilder =
    ProductCommentsTableCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<int> productId,
      Value<String> comment,
      Value<DateTime> lastModified,
    });

class $$ProductCommentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductCommentsTableTable> {
  $$ProductCommentsTableTableFilterComposer({
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

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductCommentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductCommentsTableTable> {
  $$ProductCommentsTableTableOrderingComposer({
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

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductCommentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductCommentsTableTable> {
  $$ProductCommentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );
}

class $$ProductCommentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductCommentsTableTable,
          ProductCommentsTableData,
          $$ProductCommentsTableTableFilterComposer,
          $$ProductCommentsTableTableOrderingComposer,
          $$ProductCommentsTableTableAnnotationComposer,
          $$ProductCommentsTableTableCreateCompanionBuilder,
          $$ProductCommentsTableTableUpdateCompanionBuilder,
          (
            ProductCommentsTableData,
            BaseReferences<
              _$AppDatabase,
              $ProductCommentsTableTable,
              ProductCommentsTableData
            >,
          ),
          ProductCommentsTableData,
          PrefetchHooks Function()
        > {
  $$ProductCommentsTableTableTableManager(
    _$AppDatabase db,
    $ProductCommentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductCommentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductCommentsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProductCommentsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<String> comment = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
              }) => ProductCommentsTableCompanion(
                id: id,
                companyId: companyId,
                productId: productId,
                comment: comment,
                lastModified: lastModified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required int productId,
                required String comment,
                required DateTime lastModified,
              }) => ProductCommentsTableCompanion.insert(
                id: id,
                companyId: companyId,
                productId: productId,
                comment: comment,
                lastModified: lastModified,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductCommentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductCommentsTableTable,
      ProductCommentsTableData,
      $$ProductCommentsTableTableFilterComposer,
      $$ProductCommentsTableTableOrderingComposer,
      $$ProductCommentsTableTableAnnotationComposer,
      $$ProductCommentsTableTableCreateCompanionBuilder,
      $$ProductCommentsTableTableUpdateCompanionBuilder,
      (
        ProductCommentsTableData,
        BaseReferences<
          _$AppDatabase,
          $ProductCommentsTableTable,
          ProductCommentsTableData
        >,
      ),
      ProductCommentsTableData,
      PrefetchHooks Function()
    >;
typedef $$CompaniesTableTableCreateCompanionBuilder =
    CompaniesTableCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> taxNumber,
      Value<String?> address,
      Value<String?> phone,
      Value<String?> localLogoPath,
      required DateTime lastModified,
    });
typedef $$CompaniesTableTableUpdateCompanionBuilder =
    CompaniesTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> taxNumber,
      Value<String?> address,
      Value<String?> phone,
      Value<String?> localLogoPath,
      Value<DateTime> lastModified,
    });

class $$CompaniesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CompaniesTableTable> {
  $$CompaniesTableTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxNumber => $composableBuilder(
    column: $table.taxNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localLogoPath => $composableBuilder(
    column: $table.localLogoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompaniesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CompaniesTableTable> {
  $$CompaniesTableTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxNumber => $composableBuilder(
    column: $table.taxNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localLogoPath => $composableBuilder(
    column: $table.localLogoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompaniesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompaniesTableTable> {
  $$CompaniesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get taxNumber =>
      $composableBuilder(column: $table.taxNumber, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get localLogoPath => $composableBuilder(
    column: $table.localLogoPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );
}

class $$CompaniesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompaniesTableTable,
          CompaniesTableData,
          $$CompaniesTableTableFilterComposer,
          $$CompaniesTableTableOrderingComposer,
          $$CompaniesTableTableAnnotationComposer,
          $$CompaniesTableTableCreateCompanionBuilder,
          $$CompaniesTableTableUpdateCompanionBuilder,
          (
            CompaniesTableData,
            BaseReferences<
              _$AppDatabase,
              $CompaniesTableTable,
              CompaniesTableData
            >,
          ),
          CompaniesTableData,
          PrefetchHooks Function()
        > {
  $$CompaniesTableTableTableManager(
    _$AppDatabase db,
    $CompaniesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompaniesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompaniesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompaniesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> taxNumber = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> localLogoPath = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
              }) => CompaniesTableCompanion(
                id: id,
                name: name,
                taxNumber: taxNumber,
                address: address,
                phone: phone,
                localLogoPath: localLogoPath,
                lastModified: lastModified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> taxNumber = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> localLogoPath = const Value.absent(),
                required DateTime lastModified,
              }) => CompaniesTableCompanion.insert(
                id: id,
                name: name,
                taxNumber: taxNumber,
                address: address,
                phone: phone,
                localLogoPath: localLogoPath,
                lastModified: lastModified,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompaniesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompaniesTableTable,
      CompaniesTableData,
      $$CompaniesTableTableFilterComposer,
      $$CompaniesTableTableOrderingComposer,
      $$CompaniesTableTableAnnotationComposer,
      $$CompaniesTableTableCreateCompanionBuilder,
      $$CompaniesTableTableUpdateCompanionBuilder,
      (
        CompaniesTableData,
        BaseReferences<_$AppDatabase, $CompaniesTableTable, CompaniesTableData>,
      ),
      CompaniesTableData,
      PrefetchHooks Function()
    >;
typedef $$PosOrdersTableTableCreateCompanionBuilder =
    PosOrdersTableCompanion Function({
      required String localId,
      Value<int?> serverId,
      required int companyId,
      required int userId,
      Value<int?> tableId,
      required int serviceType,
      Value<int> serviceStatus,
      Value<String?> orderName,
      required DateTime openedAt,
      Value<DateTime?> closedAt,
      Value<int> status,
      Value<double?> total,
      Value<double> discount,
      Value<int> discountType,
      required int warehouseId,
      Value<int?> paymentTypeId,
      Value<double?> amountPaid,
      Value<int?> customerId,
      Value<String> syncStatus,
      Value<String?> syncError,
      required DateTime lastModified,
      Value<int> rowid,
    });
typedef $$PosOrdersTableTableUpdateCompanionBuilder =
    PosOrdersTableCompanion Function({
      Value<String> localId,
      Value<int?> serverId,
      Value<int> companyId,
      Value<int> userId,
      Value<int?> tableId,
      Value<int> serviceType,
      Value<int> serviceStatus,
      Value<String?> orderName,
      Value<DateTime> openedAt,
      Value<DateTime?> closedAt,
      Value<int> status,
      Value<double?> total,
      Value<double> discount,
      Value<int> discountType,
      Value<int> warehouseId,
      Value<int?> paymentTypeId,
      Value<double?> amountPaid,
      Value<int?> customerId,
      Value<String> syncStatus,
      Value<String?> syncError,
      Value<DateTime> lastModified,
      Value<int> rowid,
    });

final class $$PosOrdersTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PosOrdersTableTable,
          PosOrdersTableData
        > {
  $$PosOrdersTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $PosOrderItemsTableTable,
    List<PosOrderItemsTableData>
  >
  _posOrderItemsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.posOrderItemsTable,
        aliasName: $_aliasNameGenerator(
          db.posOrdersTable.localId,
          db.posOrderItemsTable.orderId,
        ),
      );

  $$PosOrderItemsTableTableProcessedTableManager get posOrderItemsTableRefs {
    final manager =
        $$PosOrderItemsTableTableTableManager(
          $_db,
          $_db.posOrderItemsTable,
        ).filter(
          (f) => f.orderId.localId.sqlEquals($_itemColumn<String>('local_id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _posOrderItemsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PosOrderItemTaxesTableTable,
    List<PosOrderItemTaxesTableData>
  >
  _posOrderItemTaxesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.posOrderItemTaxesTable,
        aliasName: $_aliasNameGenerator(
          db.posOrdersTable.localId,
          db.posOrderItemTaxesTable.orderId,
        ),
      );

  $$PosOrderItemTaxesTableTableProcessedTableManager
  get posOrderItemTaxesTableRefs {
    final manager =
        $$PosOrderItemTaxesTableTableTableManager(
          $_db,
          $_db.posOrderItemTaxesTable,
        ).filter(
          (f) => f.orderId.localId.sqlEquals($_itemColumn<String>('local_id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _posOrderItemTaxesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PosOrdersTableTableFilterComposer
    extends Composer<_$AppDatabase, $PosOrdersTableTable> {
  $$PosOrdersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tableId => $composableBuilder(
    column: $table.tableId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serviceStatus => $composableBuilder(
    column: $table.serviceStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderName => $composableBuilder(
    column: $table.orderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentTypeId => $composableBuilder(
    column: $table.paymentTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> posOrderItemsTableRefs(
    Expression<bool> Function($$PosOrderItemsTableTableFilterComposer f) f,
  ) {
    final $$PosOrderItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.posOrderItemsTable,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PosOrderItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.posOrderItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> posOrderItemTaxesTableRefs(
    Expression<bool> Function($$PosOrderItemTaxesTableTableFilterComposer f) f,
  ) {
    final $$PosOrderItemTaxesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.localId,
          referencedTable: $db.posOrderItemTaxesTable,
          getReferencedColumn: (t) => t.orderId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PosOrderItemTaxesTableTableFilterComposer(
                $db: $db,
                $table: $db.posOrderItemTaxesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PosOrdersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PosOrdersTableTable> {
  $$PosOrdersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tableId => $composableBuilder(
    column: $table.tableId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serviceStatus => $composableBuilder(
    column: $table.serviceStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderName => $composableBuilder(
    column: $table.orderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentTypeId => $composableBuilder(
    column: $table.paymentTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PosOrdersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PosOrdersTableTable> {
  $$PosOrdersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get tableId =>
      $composableBuilder(column: $table.tableId, builder: (column) => column);

  GeneratedColumn<int> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serviceStatus => $composableBuilder(
    column: $table.serviceStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orderName =>
      $composableBuilder(column: $table.orderName, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<int> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paymentTypeId => $composableBuilder(
    column: $table.paymentTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  Expression<T> posOrderItemsTableRefs<T extends Object>(
    Expression<T> Function($$PosOrderItemsTableTableAnnotationComposer a) f,
  ) {
    final $$PosOrderItemsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.localId,
          referencedTable: $db.posOrderItemsTable,
          getReferencedColumn: (t) => t.orderId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PosOrderItemsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.posOrderItemsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> posOrderItemTaxesTableRefs<T extends Object>(
    Expression<T> Function($$PosOrderItemTaxesTableTableAnnotationComposer a) f,
  ) {
    final $$PosOrderItemTaxesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.localId,
          referencedTable: $db.posOrderItemTaxesTable,
          getReferencedColumn: (t) => t.orderId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PosOrderItemTaxesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.posOrderItemTaxesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PosOrdersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PosOrdersTableTable,
          PosOrdersTableData,
          $$PosOrdersTableTableFilterComposer,
          $$PosOrdersTableTableOrderingComposer,
          $$PosOrdersTableTableAnnotationComposer,
          $$PosOrdersTableTableCreateCompanionBuilder,
          $$PosOrdersTableTableUpdateCompanionBuilder,
          (PosOrdersTableData, $$PosOrdersTableTableReferences),
          PosOrdersTableData,
          PrefetchHooks Function({
            bool posOrderItemsTableRefs,
            bool posOrderItemTaxesTableRefs,
          })
        > {
  $$PosOrdersTableTableTableManager(
    _$AppDatabase db,
    $PosOrdersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PosOrdersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PosOrdersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PosOrdersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int?> tableId = const Value.absent(),
                Value<int> serviceType = const Value.absent(),
                Value<int> serviceStatus = const Value.absent(),
                Value<String?> orderName = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<double?> total = const Value.absent(),
                Value<double> discount = const Value.absent(),
                Value<int> discountType = const Value.absent(),
                Value<int> warehouseId = const Value.absent(),
                Value<int?> paymentTypeId = const Value.absent(),
                Value<double?> amountPaid = const Value.absent(),
                Value<int?> customerId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PosOrdersTableCompanion(
                localId: localId,
                serverId: serverId,
                companyId: companyId,
                userId: userId,
                tableId: tableId,
                serviceType: serviceType,
                serviceStatus: serviceStatus,
                orderName: orderName,
                openedAt: openedAt,
                closedAt: closedAt,
                status: status,
                total: total,
                discount: discount,
                discountType: discountType,
                warehouseId: warehouseId,
                paymentTypeId: paymentTypeId,
                amountPaid: amountPaid,
                customerId: customerId,
                syncStatus: syncStatus,
                syncError: syncError,
                lastModified: lastModified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<int?> serverId = const Value.absent(),
                required int companyId,
                required int userId,
                Value<int?> tableId = const Value.absent(),
                required int serviceType,
                Value<int> serviceStatus = const Value.absent(),
                Value<String?> orderName = const Value.absent(),
                required DateTime openedAt,
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<double?> total = const Value.absent(),
                Value<double> discount = const Value.absent(),
                Value<int> discountType = const Value.absent(),
                required int warehouseId,
                Value<int?> paymentTypeId = const Value.absent(),
                Value<double?> amountPaid = const Value.absent(),
                Value<int?> customerId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                required DateTime lastModified,
                Value<int> rowid = const Value.absent(),
              }) => PosOrdersTableCompanion.insert(
                localId: localId,
                serverId: serverId,
                companyId: companyId,
                userId: userId,
                tableId: tableId,
                serviceType: serviceType,
                serviceStatus: serviceStatus,
                orderName: orderName,
                openedAt: openedAt,
                closedAt: closedAt,
                status: status,
                total: total,
                discount: discount,
                discountType: discountType,
                warehouseId: warehouseId,
                paymentTypeId: paymentTypeId,
                amountPaid: amountPaid,
                customerId: customerId,
                syncStatus: syncStatus,
                syncError: syncError,
                lastModified: lastModified,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PosOrdersTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                posOrderItemsTableRefs = false,
                posOrderItemTaxesTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (posOrderItemsTableRefs) db.posOrderItemsTable,
                    if (posOrderItemTaxesTableRefs) db.posOrderItemTaxesTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (posOrderItemsTableRefs)
                        await $_getPrefetchedData<
                          PosOrdersTableData,
                          $PosOrdersTableTable,
                          PosOrderItemsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$PosOrdersTableTableReferences
                              ._posOrderItemsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PosOrdersTableTableReferences(
                                db,
                                table,
                                p0,
                              ).posOrderItemsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderId == item.localId,
                              ),
                          typedResults: items,
                        ),
                      if (posOrderItemTaxesTableRefs)
                        await $_getPrefetchedData<
                          PosOrdersTableData,
                          $PosOrdersTableTable,
                          PosOrderItemTaxesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$PosOrdersTableTableReferences
                              ._posOrderItemTaxesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PosOrdersTableTableReferences(
                                db,
                                table,
                                p0,
                              ).posOrderItemTaxesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderId == item.localId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PosOrdersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PosOrdersTableTable,
      PosOrdersTableData,
      $$PosOrdersTableTableFilterComposer,
      $$PosOrdersTableTableOrderingComposer,
      $$PosOrdersTableTableAnnotationComposer,
      $$PosOrdersTableTableCreateCompanionBuilder,
      $$PosOrdersTableTableUpdateCompanionBuilder,
      (PosOrdersTableData, $$PosOrdersTableTableReferences),
      PosOrdersTableData,
      PrefetchHooks Function({
        bool posOrderItemsTableRefs,
        bool posOrderItemTaxesTableRefs,
      })
    >;
typedef $$PosOrderItemsTableTableCreateCompanionBuilder =
    PosOrderItemsTableCompanion Function({
      required String localId,
      required String orderId,
      required int productId,
      required double quantity,
      required double unitPrice,
      Value<double> discount,
      Value<int> discountType,
      Value<double> taxRate,
      Value<String?> taxesJson,
      Value<String?> comment,
      required int warehouseId,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$PosOrderItemsTableTableUpdateCompanionBuilder =
    PosOrderItemsTableCompanion Function({
      Value<String> localId,
      Value<String> orderId,
      Value<int> productId,
      Value<double> quantity,
      Value<double> unitPrice,
      Value<double> discount,
      Value<int> discountType,
      Value<double> taxRate,
      Value<String?> taxesJson,
      Value<String?> comment,
      Value<int> warehouseId,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$PosOrderItemsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PosOrderItemsTableTable,
          PosOrderItemsTableData
        > {
  $$PosOrderItemsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PosOrdersTableTable _orderIdTable(_$AppDatabase db) =>
      db.posOrdersTable.createAlias(
        $_aliasNameGenerator(
          db.posOrderItemsTable.orderId,
          db.posOrdersTable.localId,
        ),
      );

  $$PosOrdersTableTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<String>('order_id')!;

    final manager = $$PosOrdersTableTableTableManager(
      $_db,
      $_db.posOrdersTable,
    ).filter((f) => f.localId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PosOrderItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PosOrderItemsTableTable> {
  $$PosOrderItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxRate => $composableBuilder(
    column: $table.taxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxesJson => $composableBuilder(
    column: $table.taxesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$PosOrdersTableTableFilterComposer get orderId {
    final $$PosOrdersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.posOrdersTable,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PosOrdersTableTableFilterComposer(
            $db: $db,
            $table: $db.posOrdersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PosOrderItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PosOrderItemsTableTable> {
  $$PosOrderItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxRate => $composableBuilder(
    column: $table.taxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxesJson => $composableBuilder(
    column: $table.taxesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$PosOrdersTableTableOrderingComposer get orderId {
    final $$PosOrdersTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.posOrdersTable,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PosOrdersTableTableOrderingComposer(
            $db: $db,
            $table: $db.posOrdersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PosOrderItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PosOrderItemsTableTable> {
  $$PosOrderItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<int> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxRate =>
      $composableBuilder(column: $table.taxRate, builder: (column) => column);

  GeneratedColumn<String> get taxesJson =>
      $composableBuilder(column: $table.taxesJson, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$PosOrdersTableTableAnnotationComposer get orderId {
    final $$PosOrdersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.posOrdersTable,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PosOrdersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.posOrdersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PosOrderItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PosOrderItemsTableTable,
          PosOrderItemsTableData,
          $$PosOrderItemsTableTableFilterComposer,
          $$PosOrderItemsTableTableOrderingComposer,
          $$PosOrderItemsTableTableAnnotationComposer,
          $$PosOrderItemsTableTableCreateCompanionBuilder,
          $$PosOrderItemsTableTableUpdateCompanionBuilder,
          (PosOrderItemsTableData, $$PosOrderItemsTableTableReferences),
          PosOrderItemsTableData,
          PrefetchHooks Function({bool orderId})
        > {
  $$PosOrderItemsTableTableTableManager(
    _$AppDatabase db,
    $PosOrderItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PosOrderItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PosOrderItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PosOrderItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> discount = const Value.absent(),
                Value<int> discountType = const Value.absent(),
                Value<double> taxRate = const Value.absent(),
                Value<String?> taxesJson = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<int> warehouseId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PosOrderItemsTableCompanion(
                localId: localId,
                orderId: orderId,
                productId: productId,
                quantity: quantity,
                unitPrice: unitPrice,
                discount: discount,
                discountType: discountType,
                taxRate: taxRate,
                taxesJson: taxesJson,
                comment: comment,
                warehouseId: warehouseId,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                required String orderId,
                required int productId,
                required double quantity,
                required double unitPrice,
                Value<double> discount = const Value.absent(),
                Value<int> discountType = const Value.absent(),
                Value<double> taxRate = const Value.absent(),
                Value<String?> taxesJson = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                required int warehouseId,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PosOrderItemsTableCompanion.insert(
                localId: localId,
                orderId: orderId,
                productId: productId,
                quantity: quantity,
                unitPrice: unitPrice,
                discount: discount,
                discountType: discountType,
                taxRate: taxRate,
                taxesJson: taxesJson,
                comment: comment,
                warehouseId: warehouseId,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PosOrderItemsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable:
                                    $$PosOrderItemsTableTableReferences
                                        ._orderIdTable(db),
                                referencedColumn:
                                    $$PosOrderItemsTableTableReferences
                                        ._orderIdTable(db)
                                        .localId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PosOrderItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PosOrderItemsTableTable,
      PosOrderItemsTableData,
      $$PosOrderItemsTableTableFilterComposer,
      $$PosOrderItemsTableTableOrderingComposer,
      $$PosOrderItemsTableTableAnnotationComposer,
      $$PosOrderItemsTableTableCreateCompanionBuilder,
      $$PosOrderItemsTableTableUpdateCompanionBuilder,
      (PosOrderItemsTableData, $$PosOrderItemsTableTableReferences),
      PosOrderItemsTableData,
      PrefetchHooks Function({bool orderId})
    >;
typedef $$PosOrderItemTaxesTableTableCreateCompanionBuilder =
    PosOrderItemTaxesTableCompanion Function({
      required String localId,
      required String orderId,
      required int productId,
      required int taxRateId,
      required double taxAmount,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$PosOrderItemTaxesTableTableUpdateCompanionBuilder =
    PosOrderItemTaxesTableCompanion Function({
      Value<String> localId,
      Value<String> orderId,
      Value<int> productId,
      Value<int> taxRateId,
      Value<double> taxAmount,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$PosOrderItemTaxesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PosOrderItemTaxesTableTable,
          PosOrderItemTaxesTableData
        > {
  $$PosOrderItemTaxesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PosOrdersTableTable _orderIdTable(_$AppDatabase db) =>
      db.posOrdersTable.createAlias(
        $_aliasNameGenerator(
          db.posOrderItemTaxesTable.orderId,
          db.posOrdersTable.localId,
        ),
      );

  $$PosOrdersTableTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<String>('order_id')!;

    final manager = $$PosOrdersTableTableTableManager(
      $_db,
      $_db.posOrdersTable,
    ).filter((f) => f.localId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PosOrderItemTaxesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PosOrderItemTaxesTableTable> {
  $$PosOrderItemTaxesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxRateId => $composableBuilder(
    column: $table.taxRateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$PosOrdersTableTableFilterComposer get orderId {
    final $$PosOrdersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.posOrdersTable,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PosOrdersTableTableFilterComposer(
            $db: $db,
            $table: $db.posOrdersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PosOrderItemTaxesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PosOrderItemTaxesTableTable> {
  $$PosOrderItemTaxesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxRateId => $composableBuilder(
    column: $table.taxRateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$PosOrdersTableTableOrderingComposer get orderId {
    final $$PosOrdersTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.posOrdersTable,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PosOrdersTableTableOrderingComposer(
            $db: $db,
            $table: $db.posOrdersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PosOrderItemTaxesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PosOrderItemTaxesTableTable> {
  $$PosOrderItemTaxesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get taxRateId =>
      $composableBuilder(column: $table.taxRateId, builder: (column) => column);

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$PosOrdersTableTableAnnotationComposer get orderId {
    final $$PosOrdersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.posOrdersTable,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PosOrdersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.posOrdersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PosOrderItemTaxesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PosOrderItemTaxesTableTable,
          PosOrderItemTaxesTableData,
          $$PosOrderItemTaxesTableTableFilterComposer,
          $$PosOrderItemTaxesTableTableOrderingComposer,
          $$PosOrderItemTaxesTableTableAnnotationComposer,
          $$PosOrderItemTaxesTableTableCreateCompanionBuilder,
          $$PosOrderItemTaxesTableTableUpdateCompanionBuilder,
          (PosOrderItemTaxesTableData, $$PosOrderItemTaxesTableTableReferences),
          PosOrderItemTaxesTableData,
          PrefetchHooks Function({bool orderId})
        > {
  $$PosOrderItemTaxesTableTableTableManager(
    _$AppDatabase db,
    $PosOrderItemTaxesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PosOrderItemTaxesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PosOrderItemTaxesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PosOrderItemTaxesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<int> taxRateId = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PosOrderItemTaxesTableCompanion(
                localId: localId,
                orderId: orderId,
                productId: productId,
                taxRateId: taxRateId,
                taxAmount: taxAmount,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                required String orderId,
                required int productId,
                required int taxRateId,
                required double taxAmount,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PosOrderItemTaxesTableCompanion.insert(
                localId: localId,
                orderId: orderId,
                productId: productId,
                taxRateId: taxRateId,
                taxAmount: taxAmount,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PosOrderItemTaxesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable:
                                    $$PosOrderItemTaxesTableTableReferences
                                        ._orderIdTable(db),
                                referencedColumn:
                                    $$PosOrderItemTaxesTableTableReferences
                                        ._orderIdTable(db)
                                        .localId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PosOrderItemTaxesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PosOrderItemTaxesTableTable,
      PosOrderItemTaxesTableData,
      $$PosOrderItemTaxesTableTableFilterComposer,
      $$PosOrderItemTaxesTableTableOrderingComposer,
      $$PosOrderItemTaxesTableTableAnnotationComposer,
      $$PosOrderItemTaxesTableTableCreateCompanionBuilder,
      $$PosOrderItemTaxesTableTableUpdateCompanionBuilder,
      (PosOrderItemTaxesTableData, $$PosOrderItemTaxesTableTableReferences),
      PosOrderItemTaxesTableData,
      PrefetchHooks Function({bool orderId})
    >;
typedef $$StartingCashTableTableCreateCompanionBuilder =
    StartingCashTableCompanion Function({
      required String localId,
      Value<int?> serverId,
      required int companyId,
      required int userId,
      required double amount,
      required String type,
      Value<String?> note,
      required DateTime createdAt,
      Value<int?> zReportNumber,
      Value<String> syncStatus,
      Value<String?> syncError,
      Value<int> rowid,
    });
typedef $$StartingCashTableTableUpdateCompanionBuilder =
    StartingCashTableCompanion Function({
      Value<String> localId,
      Value<int?> serverId,
      Value<int> companyId,
      Value<int> userId,
      Value<double> amount,
      Value<String> type,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int?> zReportNumber,
      Value<String> syncStatus,
      Value<String?> syncError,
      Value<int> rowid,
    });

class $$StartingCashTableTableFilterComposer
    extends Composer<_$AppDatabase, $StartingCashTableTable> {
  $$StartingCashTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zReportNumber => $composableBuilder(
    column: $table.zReportNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StartingCashTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StartingCashTableTable> {
  $$StartingCashTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zReportNumber => $composableBuilder(
    column: $table.zReportNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StartingCashTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StartingCashTableTable> {
  $$StartingCashTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get zReportNumber => $composableBuilder(
    column: $table.zReportNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$StartingCashTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StartingCashTableTable,
          StartingCashTableData,
          $$StartingCashTableTableFilterComposer,
          $$StartingCashTableTableOrderingComposer,
          $$StartingCashTableTableAnnotationComposer,
          $$StartingCashTableTableCreateCompanionBuilder,
          $$StartingCashTableTableUpdateCompanionBuilder,
          (
            StartingCashTableData,
            BaseReferences<
              _$AppDatabase,
              $StartingCashTableTable,
              StartingCashTableData
            >,
          ),
          StartingCashTableData,
          PrefetchHooks Function()
        > {
  $$StartingCashTableTableTableManager(
    _$AppDatabase db,
    $StartingCashTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StartingCashTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StartingCashTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StartingCashTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> zReportNumber = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StartingCashTableCompanion(
                localId: localId,
                serverId: serverId,
                companyId: companyId,
                userId: userId,
                amount: amount,
                type: type,
                note: note,
                createdAt: createdAt,
                zReportNumber: zReportNumber,
                syncStatus: syncStatus,
                syncError: syncError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<int?> serverId = const Value.absent(),
                required int companyId,
                required int userId,
                required double amount,
                required String type,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<int?> zReportNumber = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StartingCashTableCompanion.insert(
                localId: localId,
                serverId: serverId,
                companyId: companyId,
                userId: userId,
                amount: amount,
                type: type,
                note: note,
                createdAt: createdAt,
                zReportNumber: zReportNumber,
                syncStatus: syncStatus,
                syncError: syncError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StartingCashTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StartingCashTableTable,
      StartingCashTableData,
      $$StartingCashTableTableFilterComposer,
      $$StartingCashTableTableOrderingComposer,
      $$StartingCashTableTableAnnotationComposer,
      $$StartingCashTableTableCreateCompanionBuilder,
      $$StartingCashTableTableUpdateCompanionBuilder,
      (
        StartingCashTableData,
        BaseReferences<
          _$AppDatabase,
          $StartingCashTableTable,
          StartingCashTableData
        >,
      ),
      StartingCashTableData,
      PrefetchHooks Function()
    >;
typedef $$ZReportsTableTableCreateCompanionBuilder =
    ZReportsTableCompanion Function({
      required String localId,
      Value<int?> serverId,
      required int companyId,
      required int userId,
      required double totalSales,
      required double totalCashIn,
      required double totalCashOut,
      required String paymentBreakdownJson,
      required DateTime closedAt,
      Value<String> syncStatus,
      Value<String?> syncError,
      Value<int> rowid,
    });
typedef $$ZReportsTableTableUpdateCompanionBuilder =
    ZReportsTableCompanion Function({
      Value<String> localId,
      Value<int?> serverId,
      Value<int> companyId,
      Value<int> userId,
      Value<double> totalSales,
      Value<double> totalCashIn,
      Value<double> totalCashOut,
      Value<String> paymentBreakdownJson,
      Value<DateTime> closedAt,
      Value<String> syncStatus,
      Value<String?> syncError,
      Value<int> rowid,
    });

class $$ZReportsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ZReportsTableTable> {
  $$ZReportsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalSales => $composableBuilder(
    column: $table.totalSales,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalCashIn => $composableBuilder(
    column: $table.totalCashIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalCashOut => $composableBuilder(
    column: $table.totalCashOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentBreakdownJson => $composableBuilder(
    column: $table.paymentBreakdownJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ZReportsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ZReportsTableTable> {
  $$ZReportsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalSales => $composableBuilder(
    column: $table.totalSales,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalCashIn => $composableBuilder(
    column: $table.totalCashIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalCashOut => $composableBuilder(
    column: $table.totalCashOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentBreakdownJson => $composableBuilder(
    column: $table.paymentBreakdownJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ZReportsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ZReportsTableTable> {
  $$ZReportsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get totalSales => $composableBuilder(
    column: $table.totalSales,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalCashIn => $composableBuilder(
    column: $table.totalCashIn,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalCashOut => $composableBuilder(
    column: $table.totalCashOut,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentBreakdownJson => $composableBuilder(
    column: $table.paymentBreakdownJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$ZReportsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ZReportsTableTable,
          ZReportsTableData,
          $$ZReportsTableTableFilterComposer,
          $$ZReportsTableTableOrderingComposer,
          $$ZReportsTableTableAnnotationComposer,
          $$ZReportsTableTableCreateCompanionBuilder,
          $$ZReportsTableTableUpdateCompanionBuilder,
          (
            ZReportsTableData,
            BaseReferences<
              _$AppDatabase,
              $ZReportsTableTable,
              ZReportsTableData
            >,
          ),
          ZReportsTableData,
          PrefetchHooks Function()
        > {
  $$ZReportsTableTableTableManager(_$AppDatabase db, $ZReportsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZReportsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZReportsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZReportsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<double> totalSales = const Value.absent(),
                Value<double> totalCashIn = const Value.absent(),
                Value<double> totalCashOut = const Value.absent(),
                Value<String> paymentBreakdownJson = const Value.absent(),
                Value<DateTime> closedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZReportsTableCompanion(
                localId: localId,
                serverId: serverId,
                companyId: companyId,
                userId: userId,
                totalSales: totalSales,
                totalCashIn: totalCashIn,
                totalCashOut: totalCashOut,
                paymentBreakdownJson: paymentBreakdownJson,
                closedAt: closedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<int?> serverId = const Value.absent(),
                required int companyId,
                required int userId,
                required double totalSales,
                required double totalCashIn,
                required double totalCashOut,
                required String paymentBreakdownJson,
                required DateTime closedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZReportsTableCompanion.insert(
                localId: localId,
                serverId: serverId,
                companyId: companyId,
                userId: userId,
                totalSales: totalSales,
                totalCashIn: totalCashIn,
                totalCashOut: totalCashOut,
                paymentBreakdownJson: paymentBreakdownJson,
                closedAt: closedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ZReportsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ZReportsTableTable,
      ZReportsTableData,
      $$ZReportsTableTableFilterComposer,
      $$ZReportsTableTableOrderingComposer,
      $$ZReportsTableTableAnnotationComposer,
      $$ZReportsTableTableCreateCompanionBuilder,
      $$ZReportsTableTableUpdateCompanionBuilder,
      (
        ZReportsTableData,
        BaseReferences<_$AppDatabase, $ZReportsTableTable, ZReportsTableData>,
      ),
      ZReportsTableData,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableTableCreateCompanionBuilder =
    SyncMetaTableCompanion Function({
      required String entity,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$SyncMetaTableTableUpdateCompanionBuilder =
    SyncMetaTableCompanion Function({
      Value<String> entity,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

class $$SyncMetaTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTableTable> {
  $$SyncMetaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTableTable> {
  $$SyncMetaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTableTable> {
  $$SyncMetaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$SyncMetaTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaTableTable,
          SyncMetaTableData,
          $$SyncMetaTableTableFilterComposer,
          $$SyncMetaTableTableOrderingComposer,
          $$SyncMetaTableTableAnnotationComposer,
          $$SyncMetaTableTableCreateCompanionBuilder,
          $$SyncMetaTableTableUpdateCompanionBuilder,
          (
            SyncMetaTableData,
            BaseReferences<
              _$AppDatabase,
              $SyncMetaTableTable,
              SyncMetaTableData
            >,
          ),
          SyncMetaTableData,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableTableManager(_$AppDatabase db, $SyncMetaTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaTableCompanion(
                entity: entity,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaTableCompanion.insert(
                entity: entity,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaTableTable,
      SyncMetaTableData,
      $$SyncMetaTableTableFilterComposer,
      $$SyncMetaTableTableOrderingComposer,
      $$SyncMetaTableTableAnnotationComposer,
      $$SyncMetaTableTableCreateCompanionBuilder,
      $$SyncMetaTableTableUpdateCompanionBuilder,
      (
        SyncMetaTableData,
        BaseReferences<_$AppDatabase, $SyncMetaTableTable, SyncMetaTableData>,
      ),
      SyncMetaTableData,
      PrefetchHooks Function()
    >;
typedef $$StocksTableTableCreateCompanionBuilder =
    StocksTableCompanion Function({
      Value<int> id,
      required int productId,
      required int warehouseId,
      required int companyId,
      Value<double> quantity,
      required DateTime lastModified,
    });
typedef $$StocksTableTableUpdateCompanionBuilder =
    StocksTableCompanion Function({
      Value<int> id,
      Value<int> productId,
      Value<int> warehouseId,
      Value<int> companyId,
      Value<double> quantity,
      Value<DateTime> lastModified,
    });

class $$StocksTableTableFilterComposer
    extends Composer<_$AppDatabase, $StocksTableTable> {
  $$StocksTableTableFilterComposer({
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

  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StocksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StocksTableTable> {
  $$StocksTableTableOrderingComposer({
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

  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StocksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StocksTableTable> {
  $$StocksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );
}

class $$StocksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StocksTableTable,
          StocksTableData,
          $$StocksTableTableFilterComposer,
          $$StocksTableTableOrderingComposer,
          $$StocksTableTableAnnotationComposer,
          $$StocksTableTableCreateCompanionBuilder,
          $$StocksTableTableUpdateCompanionBuilder,
          (
            StocksTableData,
            BaseReferences<_$AppDatabase, $StocksTableTable, StocksTableData>,
          ),
          StocksTableData,
          PrefetchHooks Function()
        > {
  $$StocksTableTableTableManager(_$AppDatabase db, $StocksTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StocksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StocksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StocksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<int> warehouseId = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
              }) => StocksTableCompanion(
                id: id,
                productId: productId,
                warehouseId: warehouseId,
                companyId: companyId,
                quantity: quantity,
                lastModified: lastModified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int productId,
                required int warehouseId,
                required int companyId,
                Value<double> quantity = const Value.absent(),
                required DateTime lastModified,
              }) => StocksTableCompanion.insert(
                id: id,
                productId: productId,
                warehouseId: warehouseId,
                companyId: companyId,
                quantity: quantity,
                lastModified: lastModified,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StocksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StocksTableTable,
      StocksTableData,
      $$StocksTableTableFilterComposer,
      $$StocksTableTableOrderingComposer,
      $$StocksTableTableAnnotationComposer,
      $$StocksTableTableCreateCompanionBuilder,
      $$StocksTableTableUpdateCompanionBuilder,
      (
        StocksTableData,
        BaseReferences<_$AppDatabase, $StocksTableTable, StocksTableData>,
      ),
      StocksTableData,
      PrefetchHooks Function()
    >;
typedef $$PendingVoidsTableTableCreateCompanionBuilder =
    PendingVoidsTableCompanion Function({
      required String localId,
      required int serverOrderId,
      required int companyId,
      required int userId,
      required String orderNumber,
      required int warehouseId,
      required String itemsJson,
      Value<String?> reason,
      required DateTime voidedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$PendingVoidsTableTableUpdateCompanionBuilder =
    PendingVoidsTableCompanion Function({
      Value<String> localId,
      Value<int> serverOrderId,
      Value<int> companyId,
      Value<int> userId,
      Value<String> orderNumber,
      Value<int> warehouseId,
      Value<String> itemsJson,
      Value<String?> reason,
      Value<DateTime> voidedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$PendingVoidsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PendingVoidsTableTable> {
  $$PendingVoidsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverOrderId => $composableBuilder(
    column: $table.serverOrderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingVoidsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingVoidsTableTable> {
  $$PendingVoidsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverOrderId => $composableBuilder(
    column: $table.serverOrderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingVoidsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingVoidsTableTable> {
  $$PendingVoidsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverOrderId => $composableBuilder(
    column: $table.serverOrderId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemsJson =>
      $composableBuilder(column: $table.itemsJson, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$PendingVoidsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingVoidsTableTable,
          PendingVoidsTableData,
          $$PendingVoidsTableTableFilterComposer,
          $$PendingVoidsTableTableOrderingComposer,
          $$PendingVoidsTableTableAnnotationComposer,
          $$PendingVoidsTableTableCreateCompanionBuilder,
          $$PendingVoidsTableTableUpdateCompanionBuilder,
          (
            PendingVoidsTableData,
            BaseReferences<
              _$AppDatabase,
              $PendingVoidsTableTable,
              PendingVoidsTableData
            >,
          ),
          PendingVoidsTableData,
          PrefetchHooks Function()
        > {
  $$PendingVoidsTableTableTableManager(
    _$AppDatabase db,
    $PendingVoidsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingVoidsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingVoidsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingVoidsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<int> serverOrderId = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> orderNumber = const Value.absent(),
                Value<int> warehouseId = const Value.absent(),
                Value<String> itemsJson = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> voidedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingVoidsTableCompanion(
                localId: localId,
                serverOrderId: serverOrderId,
                companyId: companyId,
                userId: userId,
                orderNumber: orderNumber,
                warehouseId: warehouseId,
                itemsJson: itemsJson,
                reason: reason,
                voidedAt: voidedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                required int serverOrderId,
                required int companyId,
                required int userId,
                required String orderNumber,
                required int warehouseId,
                required String itemsJson,
                Value<String?> reason = const Value.absent(),
                required DateTime voidedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingVoidsTableCompanion.insert(
                localId: localId,
                serverOrderId: serverOrderId,
                companyId: companyId,
                userId: userId,
                orderNumber: orderNumber,
                warehouseId: warehouseId,
                itemsJson: itemsJson,
                reason: reason,
                voidedAt: voidedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingVoidsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingVoidsTableTable,
      PendingVoidsTableData,
      $$PendingVoidsTableTableFilterComposer,
      $$PendingVoidsTableTableOrderingComposer,
      $$PendingVoidsTableTableAnnotationComposer,
      $$PendingVoidsTableTableCreateCompanionBuilder,
      $$PendingVoidsTableTableUpdateCompanionBuilder,
      (
        PendingVoidsTableData,
        BaseReferences<
          _$AppDatabase,
          $PendingVoidsTableTable,
          PendingVoidsTableData
        >,
      ),
      PendingVoidsTableData,
      PrefetchHooks Function()
    >;
typedef $$DocumentsTableTableCreateCompanionBuilder =
    DocumentsTableCompanion Function({
      required String localId,
      Value<int?> serverId,
      required int companyId,
      Value<int> documentTypeId,
      Value<String?> number,
      required int userId,
      required int warehouseId,
      Value<double> total,
      Value<double> discount,
      Value<int> discountType,
      Value<int?> customerId,
      Value<String?> orderNumber,
      Value<int> serviceType,
      Value<int> paidStatus,
      required DateTime date,
      Value<String> syncStatus,
      required DateTime lastModified,
      Value<int> rowid,
    });
typedef $$DocumentsTableTableUpdateCompanionBuilder =
    DocumentsTableCompanion Function({
      Value<String> localId,
      Value<int?> serverId,
      Value<int> companyId,
      Value<int> documentTypeId,
      Value<String?> number,
      Value<int> userId,
      Value<int> warehouseId,
      Value<double> total,
      Value<double> discount,
      Value<int> discountType,
      Value<int?> customerId,
      Value<String?> orderNumber,
      Value<int> serviceType,
      Value<int> paidStatus,
      Value<DateTime> date,
      Value<String> syncStatus,
      Value<DateTime> lastModified,
      Value<int> rowid,
    });

final class $$DocumentsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DocumentsTableTable,
          DocumentsTableData
        > {
  $$DocumentsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $DocumentItemsTableTable,
    List<DocumentItemsTableData>
  >
  _documentItemsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.documentItemsTable,
        aliasName: $_aliasNameGenerator(
          db.documentsTable.localId,
          db.documentItemsTable.documentId,
        ),
      );

  $$DocumentItemsTableTableProcessedTableManager get documentItemsTableRefs {
    final manager =
        $$DocumentItemsTableTableTableManager(
          $_db,
          $_db.documentItemsTable,
        ).filter(
          (f) =>
              f.documentId.localId.sqlEquals($_itemColumn<String>('local_id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _documentItemsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTableTable, List<PaymentsTableData>>
  _paymentsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.paymentsTable,
    aliasName: $_aliasNameGenerator(
      db.documentsTable.localId,
      db.paymentsTable.documentId,
    ),
  );

  $$PaymentsTableTableProcessedTableManager get paymentsTableRefs {
    final manager = $$PaymentsTableTableTableManager($_db, $_db.paymentsTable)
        .filter(
          (f) =>
              f.documentId.localId.sqlEquals($_itemColumn<String>('local_id')!),
        );

    final cache = $_typedResult.readTableOrNull(_paymentsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentsTableTable> {
  $$DocumentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get documentTypeId => $composableBuilder(
    column: $table.documentTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidStatus => $composableBuilder(
    column: $table.paidStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> documentItemsTableRefs(
    Expression<bool> Function($$DocumentItemsTableTableFilterComposer f) f,
  ) {
    final $$DocumentItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.documentItemsTable,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.documentItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsTableRefs(
    Expression<bool> Function($$PaymentsTableTableFilterComposer f) f,
  ) {
    final $$PaymentsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.paymentsTable,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableTableFilterComposer(
            $db: $db,
            $table: $db.paymentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentsTableTable> {
  $$DocumentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get documentTypeId => $composableBuilder(
    column: $table.documentTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidStatus => $composableBuilder(
    column: $table.paidStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentsTableTable> {
  $$DocumentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<int> get documentTypeId => $composableBuilder(
    column: $table.documentTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<int> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paidStatus => $composableBuilder(
    column: $table.paidStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  Expression<T> documentItemsTableRefs<T extends Object>(
    Expression<T> Function($$DocumentItemsTableTableAnnotationComposer a) f,
  ) {
    final $$DocumentItemsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.localId,
          referencedTable: $db.documentItemsTable,
          getReferencedColumn: (t) => t.documentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DocumentItemsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.documentItemsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> paymentsTableRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.paymentsTable,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentsTableTable,
          DocumentsTableData,
          $$DocumentsTableTableFilterComposer,
          $$DocumentsTableTableOrderingComposer,
          $$DocumentsTableTableAnnotationComposer,
          $$DocumentsTableTableCreateCompanionBuilder,
          $$DocumentsTableTableUpdateCompanionBuilder,
          (DocumentsTableData, $$DocumentsTableTableReferences),
          DocumentsTableData,
          PrefetchHooks Function({
            bool documentItemsTableRefs,
            bool paymentsTableRefs,
          })
        > {
  $$DocumentsTableTableTableManager(
    _$AppDatabase db,
    $DocumentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> documentTypeId = const Value.absent(),
                Value<String?> number = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> warehouseId = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<double> discount = const Value.absent(),
                Value<int> discountType = const Value.absent(),
                Value<int?> customerId = const Value.absent(),
                Value<String?> orderNumber = const Value.absent(),
                Value<int> serviceType = const Value.absent(),
                Value<int> paidStatus = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsTableCompanion(
                localId: localId,
                serverId: serverId,
                companyId: companyId,
                documentTypeId: documentTypeId,
                number: number,
                userId: userId,
                warehouseId: warehouseId,
                total: total,
                discount: discount,
                discountType: discountType,
                customerId: customerId,
                orderNumber: orderNumber,
                serviceType: serviceType,
                paidStatus: paidStatus,
                date: date,
                syncStatus: syncStatus,
                lastModified: lastModified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<int?> serverId = const Value.absent(),
                required int companyId,
                Value<int> documentTypeId = const Value.absent(),
                Value<String?> number = const Value.absent(),
                required int userId,
                required int warehouseId,
                Value<double> total = const Value.absent(),
                Value<double> discount = const Value.absent(),
                Value<int> discountType = const Value.absent(),
                Value<int?> customerId = const Value.absent(),
                Value<String?> orderNumber = const Value.absent(),
                Value<int> serviceType = const Value.absent(),
                Value<int> paidStatus = const Value.absent(),
                required DateTime date,
                Value<String> syncStatus = const Value.absent(),
                required DateTime lastModified,
                Value<int> rowid = const Value.absent(),
              }) => DocumentsTableCompanion.insert(
                localId: localId,
                serverId: serverId,
                companyId: companyId,
                documentTypeId: documentTypeId,
                number: number,
                userId: userId,
                warehouseId: warehouseId,
                total: total,
                discount: discount,
                discountType: discountType,
                customerId: customerId,
                orderNumber: orderNumber,
                serviceType: serviceType,
                paidStatus: paidStatus,
                date: date,
                syncStatus: syncStatus,
                lastModified: lastModified,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DocumentsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({documentItemsTableRefs = false, paymentsTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (documentItemsTableRefs) db.documentItemsTable,
                    if (paymentsTableRefs) db.paymentsTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (documentItemsTableRefs)
                        await $_getPrefetchedData<
                          DocumentsTableData,
                          $DocumentsTableTable,
                          DocumentItemsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableTableReferences
                              ._documentItemsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).documentItemsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.localId,
                              ),
                          typedResults: items,
                        ),
                      if (paymentsTableRefs)
                        await $_getPrefetchedData<
                          DocumentsTableData,
                          $DocumentsTableTable,
                          PaymentsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableTableReferences
                              ._paymentsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.localId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DocumentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentsTableTable,
      DocumentsTableData,
      $$DocumentsTableTableFilterComposer,
      $$DocumentsTableTableOrderingComposer,
      $$DocumentsTableTableAnnotationComposer,
      $$DocumentsTableTableCreateCompanionBuilder,
      $$DocumentsTableTableUpdateCompanionBuilder,
      (DocumentsTableData, $$DocumentsTableTableReferences),
      DocumentsTableData,
      PrefetchHooks Function({
        bool documentItemsTableRefs,
        bool paymentsTableRefs,
      })
    >;
typedef $$DocumentItemsTableTableCreateCompanionBuilder =
    DocumentItemsTableCompanion Function({
      required String localId,
      required String documentId,
      required int productId,
      required double quantity,
      required double unitPrice,
      Value<double> discount,
      Value<int> discountType,
      required double total,
      Value<double> taxAmount,
      Value<int> rowid,
    });
typedef $$DocumentItemsTableTableUpdateCompanionBuilder =
    DocumentItemsTableCompanion Function({
      Value<String> localId,
      Value<String> documentId,
      Value<int> productId,
      Value<double> quantity,
      Value<double> unitPrice,
      Value<double> discount,
      Value<int> discountType,
      Value<double> total,
      Value<double> taxAmount,
      Value<int> rowid,
    });

final class $$DocumentItemsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DocumentItemsTableTable,
          DocumentItemsTableData
        > {
  $$DocumentItemsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DocumentsTableTable _documentIdTable(_$AppDatabase db) =>
      db.documentsTable.createAlias(
        $_aliasNameGenerator(
          db.documentItemsTable.documentId,
          db.documentsTable.localId,
        ),
      );

  $$DocumentsTableTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableTableManager(
      $_db,
      $_db.documentsTable,
    ).filter((f) => f.localId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DocumentItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentItemsTableTable> {
  $$DocumentItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableTableFilterComposer get documentId {
    final $$DocumentsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documentsTable,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableTableFilterComposer(
            $db: $db,
            $table: $db.documentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentItemsTableTable> {
  $$DocumentItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableTableOrderingComposer get documentId {
    final $$DocumentsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documentsTable,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableTableOrderingComposer(
            $db: $db,
            $table: $db.documentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentItemsTableTable> {
  $$DocumentItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<int> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  $$DocumentsTableTableAnnotationComposer get documentId {
    final $$DocumentsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documentsTable,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.documentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentItemsTableTable,
          DocumentItemsTableData,
          $$DocumentItemsTableTableFilterComposer,
          $$DocumentItemsTableTableOrderingComposer,
          $$DocumentItemsTableTableAnnotationComposer,
          $$DocumentItemsTableTableCreateCompanionBuilder,
          $$DocumentItemsTableTableUpdateCompanionBuilder,
          (DocumentItemsTableData, $$DocumentItemsTableTableReferences),
          DocumentItemsTableData,
          PrefetchHooks Function({bool documentId})
        > {
  $$DocumentItemsTableTableTableManager(
    _$AppDatabase db,
    $DocumentItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> discount = const Value.absent(),
                Value<int> discountType = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentItemsTableCompanion(
                localId: localId,
                documentId: documentId,
                productId: productId,
                quantity: quantity,
                unitPrice: unitPrice,
                discount: discount,
                discountType: discountType,
                total: total,
                taxAmount: taxAmount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                required String documentId,
                required int productId,
                required double quantity,
                required double unitPrice,
                Value<double> discount = const Value.absent(),
                Value<int> discountType = const Value.absent(),
                required double total,
                Value<double> taxAmount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentItemsTableCompanion.insert(
                localId: localId,
                documentId: documentId,
                productId: productId,
                quantity: quantity,
                unitPrice: unitPrice,
                discount: discount,
                discountType: discountType,
                total: total,
                taxAmount: taxAmount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DocumentItemsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable:
                                    $$DocumentItemsTableTableReferences
                                        ._documentIdTable(db),
                                referencedColumn:
                                    $$DocumentItemsTableTableReferences
                                        ._documentIdTable(db)
                                        .localId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DocumentItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentItemsTableTable,
      DocumentItemsTableData,
      $$DocumentItemsTableTableFilterComposer,
      $$DocumentItemsTableTableOrderingComposer,
      $$DocumentItemsTableTableAnnotationComposer,
      $$DocumentItemsTableTableCreateCompanionBuilder,
      $$DocumentItemsTableTableUpdateCompanionBuilder,
      (DocumentItemsTableData, $$DocumentItemsTableTableReferences),
      DocumentItemsTableData,
      PrefetchHooks Function({bool documentId})
    >;
typedef $$PaymentsTableTableCreateCompanionBuilder =
    PaymentsTableCompanion Function({
      required String localId,
      required String documentId,
      required int paymentTypeId,
      required double amount,
      required int userId,
      required DateTime date,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$PaymentsTableTableUpdateCompanionBuilder =
    PaymentsTableCompanion Function({
      Value<String> localId,
      Value<String> documentId,
      Value<int> paymentTypeId,
      Value<double> amount,
      Value<int> userId,
      Value<DateTime> date,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$PaymentsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $PaymentsTableTable, PaymentsTableData> {
  $$PaymentsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DocumentsTableTable _documentIdTable(_$AppDatabase db) =>
      db.documentsTable.createAlias(
        $_aliasNameGenerator(
          db.paymentsTable.documentId,
          db.documentsTable.localId,
        ),
      );

  $$DocumentsTableTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableTableManager(
      $_db,
      $_db.documentsTable,
    ).filter((f) => f.localId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentTypeId => $composableBuilder(
    column: $table.paymentTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableTableFilterComposer get documentId {
    final $$DocumentsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documentsTable,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableTableFilterComposer(
            $db: $db,
            $table: $db.documentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentTypeId => $composableBuilder(
    column: $table.paymentTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableTableOrderingComposer get documentId {
    final $$DocumentsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documentsTable,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableTableOrderingComposer(
            $db: $db,
            $table: $db.documentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get paymentTypeId => $composableBuilder(
    column: $table.paymentTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$DocumentsTableTableAnnotationComposer get documentId {
    final $$DocumentsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documentsTable,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.documentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTableTable,
          PaymentsTableData,
          $$PaymentsTableTableFilterComposer,
          $$PaymentsTableTableOrderingComposer,
          $$PaymentsTableTableAnnotationComposer,
          $$PaymentsTableTableCreateCompanionBuilder,
          $$PaymentsTableTableUpdateCompanionBuilder,
          (PaymentsTableData, $$PaymentsTableTableReferences),
          PaymentsTableData,
          PrefetchHooks Function({bool documentId})
        > {
  $$PaymentsTableTableTableManager(_$AppDatabase db, $PaymentsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<int> paymentTypeId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsTableCompanion(
                localId: localId,
                documentId: documentId,
                paymentTypeId: paymentTypeId,
                amount: amount,
                userId: userId,
                date: date,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                required String documentId,
                required int paymentTypeId,
                required double amount,
                required int userId,
                required DateTime date,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsTableCompanion.insert(
                localId: localId,
                documentId: documentId,
                paymentTypeId: paymentTypeId,
                amount: amount,
                userId: userId,
                date: date,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable: $$PaymentsTableTableReferences
                                    ._documentIdTable(db),
                                referencedColumn: $$PaymentsTableTableReferences
                                    ._documentIdTable(db)
                                    .localId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTableTable,
      PaymentsTableData,
      $$PaymentsTableTableFilterComposer,
      $$PaymentsTableTableOrderingComposer,
      $$PaymentsTableTableAnnotationComposer,
      $$PaymentsTableTableCreateCompanionBuilder,
      $$PaymentsTableTableUpdateCompanionBuilder,
      (PaymentsTableData, $$PaymentsTableTableReferences),
      PaymentsTableData,
      PrefetchHooks Function({bool documentId})
    >;
typedef $$BarcodesTableTableCreateCompanionBuilder =
    BarcodesTableCompanion Function({
      required String localId,
      Value<int?> serverId,
      required int productId,
      required int companyId,
      required String value,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$BarcodesTableTableUpdateCompanionBuilder =
    BarcodesTableCompanion Function({
      Value<String> localId,
      Value<int?> serverId,
      Value<int> productId,
      Value<int> companyId,
      Value<String> value,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$BarcodesTableTableFilterComposer
    extends Composer<_$AppDatabase, $BarcodesTableTable> {
  $$BarcodesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BarcodesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BarcodesTableTable> {
  $$BarcodesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BarcodesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BarcodesTableTable> {
  $$BarcodesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$BarcodesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BarcodesTableTable,
          BarcodesTableData,
          $$BarcodesTableTableFilterComposer,
          $$BarcodesTableTableOrderingComposer,
          $$BarcodesTableTableAnnotationComposer,
          $$BarcodesTableTableCreateCompanionBuilder,
          $$BarcodesTableTableUpdateCompanionBuilder,
          (
            BarcodesTableData,
            BaseReferences<
              _$AppDatabase,
              $BarcodesTableTable,
              BarcodesTableData
            >,
          ),
          BarcodesTableData,
          PrefetchHooks Function()
        > {
  $$BarcodesTableTableTableManager(_$AppDatabase db, $BarcodesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BarcodesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BarcodesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BarcodesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BarcodesTableCompanion(
                localId: localId,
                serverId: serverId,
                productId: productId,
                companyId: companyId,
                value: value,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<int?> serverId = const Value.absent(),
                required int productId,
                required int companyId,
                required String value,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BarcodesTableCompanion.insert(
                localId: localId,
                serverId: serverId,
                productId: productId,
                companyId: companyId,
                value: value,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BarcodesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BarcodesTableTable,
      BarcodesTableData,
      $$BarcodesTableTableFilterComposer,
      $$BarcodesTableTableOrderingComposer,
      $$BarcodesTableTableAnnotationComposer,
      $$BarcodesTableTableCreateCompanionBuilder,
      $$BarcodesTableTableUpdateCompanionBuilder,
      (
        BarcodesTableData,
        BaseReferences<_$AppDatabase, $BarcodesTableTable, BarcodesTableData>,
      ),
      BarcodesTableData,
      PrefetchHooks Function()
    >;
typedef $$CustomerDiscountsTableTableCreateCompanionBuilder =
    CustomerDiscountsTableCompanion Function({
      Value<int> id,
      required int companyId,
      required int customerId,
      Value<int> type,
      Value<int> uid,
      Value<double> value,
      required DateTime lastModified,
      Value<String> syncStatus,
      Value<String?> syncError,
    });
typedef $$CustomerDiscountsTableTableUpdateCompanionBuilder =
    CustomerDiscountsTableCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<int> customerId,
      Value<int> type,
      Value<int> uid,
      Value<double> value,
      Value<DateTime> lastModified,
      Value<String> syncStatus,
      Value<String?> syncError,
    });

class $$CustomerDiscountsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerDiscountsTableTable> {
  $$CustomerDiscountsTableTableFilterComposer({
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

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomerDiscountsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerDiscountsTableTable> {
  $$CustomerDiscountsTableTableOrderingComposer({
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

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomerDiscountsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerDiscountsTableTable> {
  $$CustomerDiscountsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$CustomerDiscountsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerDiscountsTableTable,
          CustomerDiscountsTableData,
          $$CustomerDiscountsTableTableFilterComposer,
          $$CustomerDiscountsTableTableOrderingComposer,
          $$CustomerDiscountsTableTableAnnotationComposer,
          $$CustomerDiscountsTableTableCreateCompanionBuilder,
          $$CustomerDiscountsTableTableUpdateCompanionBuilder,
          (
            CustomerDiscountsTableData,
            BaseReferences<
              _$AppDatabase,
              $CustomerDiscountsTableTable,
              CustomerDiscountsTableData
            >,
          ),
          CustomerDiscountsTableData,
          PrefetchHooks Function()
        > {
  $$CustomerDiscountsTableTableTableManager(
    _$AppDatabase db,
    $CustomerDiscountsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerDiscountsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CustomerDiscountsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomerDiscountsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int> uid = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
              }) => CustomerDiscountsTableCompanion(
                id: id,
                companyId: companyId,
                customerId: customerId,
                type: type,
                uid: uid,
                value: value,
                lastModified: lastModified,
                syncStatus: syncStatus,
                syncError: syncError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required int customerId,
                Value<int> type = const Value.absent(),
                Value<int> uid = const Value.absent(),
                Value<double> value = const Value.absent(),
                required DateTime lastModified,
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
              }) => CustomerDiscountsTableCompanion.insert(
                id: id,
                companyId: companyId,
                customerId: customerId,
                type: type,
                uid: uid,
                value: value,
                lastModified: lastModified,
                syncStatus: syncStatus,
                syncError: syncError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomerDiscountsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerDiscountsTableTable,
      CustomerDiscountsTableData,
      $$CustomerDiscountsTableTableFilterComposer,
      $$CustomerDiscountsTableTableOrderingComposer,
      $$CustomerDiscountsTableTableAnnotationComposer,
      $$CustomerDiscountsTableTableCreateCompanionBuilder,
      $$CustomerDiscountsTableTableUpdateCompanionBuilder,
      (
        CustomerDiscountsTableData,
        BaseReferences<
          _$AppDatabase,
          $CustomerDiscountsTableTable,
          CustomerDiscountsTableData
        >,
      ),
      CustomerDiscountsTableData,
      PrefetchHooks Function()
    >;
typedef $$LoyaltyCardsTableTableCreateCompanionBuilder =
    LoyaltyCardsTableCompanion Function({
      Value<int> id,
      required int companyId,
      required int customerId,
      Value<String?> cardNumber,
      Value<double> points,
      required DateTime lastModified,
      Value<String> syncStatus,
      Value<String?> syncError,
    });
typedef $$LoyaltyCardsTableTableUpdateCompanionBuilder =
    LoyaltyCardsTableCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<int> customerId,
      Value<String?> cardNumber,
      Value<double> points,
      Value<DateTime> lastModified,
      Value<String> syncStatus,
      Value<String?> syncError,
    });

class $$LoyaltyCardsTableTableFilterComposer
    extends Composer<_$AppDatabase, $LoyaltyCardsTableTable> {
  $$LoyaltyCardsTableTableFilterComposer({
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

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardNumber => $composableBuilder(
    column: $table.cardNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LoyaltyCardsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LoyaltyCardsTableTable> {
  $$LoyaltyCardsTableTableOrderingComposer({
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

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardNumber => $composableBuilder(
    column: $table.cardNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LoyaltyCardsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoyaltyCardsTableTable> {
  $$LoyaltyCardsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cardNumber => $composableBuilder(
    column: $table.cardNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$LoyaltyCardsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoyaltyCardsTableTable,
          LoyaltyCardsTableData,
          $$LoyaltyCardsTableTableFilterComposer,
          $$LoyaltyCardsTableTableOrderingComposer,
          $$LoyaltyCardsTableTableAnnotationComposer,
          $$LoyaltyCardsTableTableCreateCompanionBuilder,
          $$LoyaltyCardsTableTableUpdateCompanionBuilder,
          (
            LoyaltyCardsTableData,
            BaseReferences<
              _$AppDatabase,
              $LoyaltyCardsTableTable,
              LoyaltyCardsTableData
            >,
          ),
          LoyaltyCardsTableData,
          PrefetchHooks Function()
        > {
  $$LoyaltyCardsTableTableTableManager(
    _$AppDatabase db,
    $LoyaltyCardsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoyaltyCardsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoyaltyCardsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoyaltyCardsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<String?> cardNumber = const Value.absent(),
                Value<double> points = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
              }) => LoyaltyCardsTableCompanion(
                id: id,
                companyId: companyId,
                customerId: customerId,
                cardNumber: cardNumber,
                points: points,
                lastModified: lastModified,
                syncStatus: syncStatus,
                syncError: syncError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required int customerId,
                Value<String?> cardNumber = const Value.absent(),
                Value<double> points = const Value.absent(),
                required DateTime lastModified,
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
              }) => LoyaltyCardsTableCompanion.insert(
                id: id,
                companyId: companyId,
                customerId: customerId,
                cardNumber: cardNumber,
                points: points,
                lastModified: lastModified,
                syncStatus: syncStatus,
                syncError: syncError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LoyaltyCardsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoyaltyCardsTableTable,
      LoyaltyCardsTableData,
      $$LoyaltyCardsTableTableFilterComposer,
      $$LoyaltyCardsTableTableOrderingComposer,
      $$LoyaltyCardsTableTableAnnotationComposer,
      $$LoyaltyCardsTableTableCreateCompanionBuilder,
      $$LoyaltyCardsTableTableUpdateCompanionBuilder,
      (
        LoyaltyCardsTableData,
        BaseReferences<
          _$AppDatabase,
          $LoyaltyCardsTableTable,
          LoyaltyCardsTableData
        >,
      ),
      LoyaltyCardsTableData,
      PrefetchHooks Function()
    >;
typedef $$TimeClockEntriesTableTableCreateCompanionBuilder =
    TimeClockEntriesTableCompanion Function({
      required String localId,
      Value<int?> serverId,
      required int companyId,
      required int userId,
      required DateTime clockInTime,
      Value<DateTime?> clockOutTime,
      Value<String> syncStatus,
      Value<String?> syncError,
      Value<int> rowid,
    });
typedef $$TimeClockEntriesTableTableUpdateCompanionBuilder =
    TimeClockEntriesTableCompanion Function({
      Value<String> localId,
      Value<int?> serverId,
      Value<int> companyId,
      Value<int> userId,
      Value<DateTime> clockInTime,
      Value<DateTime?> clockOutTime,
      Value<String> syncStatus,
      Value<String?> syncError,
      Value<int> rowid,
    });

class $$TimeClockEntriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $TimeClockEntriesTableTable> {
  $$TimeClockEntriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clockInTime => $composableBuilder(
    column: $table.clockInTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clockOutTime => $composableBuilder(
    column: $table.clockOutTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimeClockEntriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TimeClockEntriesTableTable> {
  $$TimeClockEntriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clockInTime => $composableBuilder(
    column: $table.clockInTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clockOutTime => $composableBuilder(
    column: $table.clockOutTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimeClockEntriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimeClockEntriesTableTable> {
  $$TimeClockEntriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get clockInTime => $composableBuilder(
    column: $table.clockInTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get clockOutTime => $composableBuilder(
    column: $table.clockOutTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$TimeClockEntriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimeClockEntriesTableTable,
          TimeClockEntriesTableData,
          $$TimeClockEntriesTableTableFilterComposer,
          $$TimeClockEntriesTableTableOrderingComposer,
          $$TimeClockEntriesTableTableAnnotationComposer,
          $$TimeClockEntriesTableTableCreateCompanionBuilder,
          $$TimeClockEntriesTableTableUpdateCompanionBuilder,
          (
            TimeClockEntriesTableData,
            BaseReferences<
              _$AppDatabase,
              $TimeClockEntriesTableTable,
              TimeClockEntriesTableData
            >,
          ),
          TimeClockEntriesTableData,
          PrefetchHooks Function()
        > {
  $$TimeClockEntriesTableTableTableManager(
    _$AppDatabase db,
    $TimeClockEntriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimeClockEntriesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TimeClockEntriesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TimeClockEntriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<DateTime> clockInTime = const Value.absent(),
                Value<DateTime?> clockOutTime = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimeClockEntriesTableCompanion(
                localId: localId,
                serverId: serverId,
                companyId: companyId,
                userId: userId,
                clockInTime: clockInTime,
                clockOutTime: clockOutTime,
                syncStatus: syncStatus,
                syncError: syncError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<int?> serverId = const Value.absent(),
                required int companyId,
                required int userId,
                required DateTime clockInTime,
                Value<DateTime?> clockOutTime = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimeClockEntriesTableCompanion.insert(
                localId: localId,
                serverId: serverId,
                companyId: companyId,
                userId: userId,
                clockInTime: clockInTime,
                clockOutTime: clockOutTime,
                syncStatus: syncStatus,
                syncError: syncError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimeClockEntriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimeClockEntriesTableTable,
      TimeClockEntriesTableData,
      $$TimeClockEntriesTableTableFilterComposer,
      $$TimeClockEntriesTableTableOrderingComposer,
      $$TimeClockEntriesTableTableAnnotationComposer,
      $$TimeClockEntriesTableTableCreateCompanionBuilder,
      $$TimeClockEntriesTableTableUpdateCompanionBuilder,
      (
        TimeClockEntriesTableData,
        BaseReferences<
          _$AppDatabase,
          $TimeClockEntriesTableTable,
          TimeClockEntriesTableData
        >,
      ),
      TimeClockEntriesTableData,
      PrefetchHooks Function()
    >;
typedef $$ShiftsTableTableCreateCompanionBuilder =
    ShiftsTableCompanion Function({
      required String localId,
      Value<int?> serverId,
      required int companyId,
      required int userId,
      Value<double> startingCash,
      Value<double?> actualEndingCash,
      Value<int> status,
      required DateTime openedAt,
      Value<DateTime?> closedAt,
      required DateTime lastModified,
      Value<bool> isDrawerShift,
      Value<String> syncStatus,
      Value<String?> syncError,
      Value<int> rowid,
    });
typedef $$ShiftsTableTableUpdateCompanionBuilder =
    ShiftsTableCompanion Function({
      Value<String> localId,
      Value<int?> serverId,
      Value<int> companyId,
      Value<int> userId,
      Value<double> startingCash,
      Value<double?> actualEndingCash,
      Value<int> status,
      Value<DateTime> openedAt,
      Value<DateTime?> closedAt,
      Value<DateTime> lastModified,
      Value<bool> isDrawerShift,
      Value<String> syncStatus,
      Value<String?> syncError,
      Value<int> rowid,
    });

class $$ShiftsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTableTable> {
  $$ShiftsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startingCash => $composableBuilder(
    column: $table.startingCash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualEndingCash => $composableBuilder(
    column: $table.actualEndingCash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDrawerShift => $composableBuilder(
    column: $table.isDrawerShift,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShiftsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTableTable> {
  $$ShiftsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startingCash => $composableBuilder(
    column: $table.startingCash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualEndingCash => $composableBuilder(
    column: $table.actualEndingCash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDrawerShift => $composableBuilder(
    column: $table.isDrawerShift,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTableTable> {
  $$ShiftsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get startingCash => $composableBuilder(
    column: $table.startingCash,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualEndingCash => $composableBuilder(
    column: $table.actualEndingCash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDrawerShift => $composableBuilder(
    column: $table.isDrawerShift,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$ShiftsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftsTableTable,
          ShiftsTableData,
          $$ShiftsTableTableFilterComposer,
          $$ShiftsTableTableOrderingComposer,
          $$ShiftsTableTableAnnotationComposer,
          $$ShiftsTableTableCreateCompanionBuilder,
          $$ShiftsTableTableUpdateCompanionBuilder,
          (
            ShiftsTableData,
            BaseReferences<_$AppDatabase, $ShiftsTableTable, ShiftsTableData>,
          ),
          ShiftsTableData,
          PrefetchHooks Function()
        > {
  $$ShiftsTableTableTableManager(_$AppDatabase db, $ShiftsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<double> startingCash = const Value.absent(),
                Value<double?> actualEndingCash = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<bool> isDrawerShift = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsTableCompanion(
                localId: localId,
                serverId: serverId,
                companyId: companyId,
                userId: userId,
                startingCash: startingCash,
                actualEndingCash: actualEndingCash,
                status: status,
                openedAt: openedAt,
                closedAt: closedAt,
                lastModified: lastModified,
                isDrawerShift: isDrawerShift,
                syncStatus: syncStatus,
                syncError: syncError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<int?> serverId = const Value.absent(),
                required int companyId,
                required int userId,
                Value<double> startingCash = const Value.absent(),
                Value<double?> actualEndingCash = const Value.absent(),
                Value<int> status = const Value.absent(),
                required DateTime openedAt,
                Value<DateTime?> closedAt = const Value.absent(),
                required DateTime lastModified,
                Value<bool> isDrawerShift = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsTableCompanion.insert(
                localId: localId,
                serverId: serverId,
                companyId: companyId,
                userId: userId,
                startingCash: startingCash,
                actualEndingCash: actualEndingCash,
                status: status,
                openedAt: openedAt,
                closedAt: closedAt,
                lastModified: lastModified,
                isDrawerShift: isDrawerShift,
                syncStatus: syncStatus,
                syncError: syncError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShiftsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftsTableTable,
      ShiftsTableData,
      $$ShiftsTableTableFilterComposer,
      $$ShiftsTableTableOrderingComposer,
      $$ShiftsTableTableAnnotationComposer,
      $$ShiftsTableTableCreateCompanionBuilder,
      $$ShiftsTableTableUpdateCompanionBuilder,
      (
        ShiftsTableData,
        BaseReferences<_$AppDatabase, $ShiftsTableTable, ShiftsTableData>,
      ),
      ShiftsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SecurityKeysTableTableTableManager get securityKeysTable =>
      $$SecurityKeysTableTableTableManager(_db, _db.securityKeysTable);
  $$PendingUserOpsTableTableTableManager get pendingUserOpsTable =>
      $$PendingUserOpsTableTableTableManager(_db, _db.pendingUserOpsTable);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db, _db.productsTable);
  $$TaxesTableTableTableManager get taxesTable =>
      $$TaxesTableTableTableManager(_db, _db.taxesTable);
  $$FloorPlansTableTableTableManager get floorPlansTable =>
      $$FloorPlansTableTableTableManager(_db, _db.floorPlansTable);
  $$FloorPlanTablesTableTableTableManager get floorPlanTablesTable =>
      $$FloorPlanTablesTableTableTableManager(_db, _db.floorPlanTablesTable);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db, _db.usersTable);
  $$AppPropertiesTableTableTableManager get appPropertiesTable =>
      $$AppPropertiesTableTableTableManager(_db, _db.appPropertiesTable);
  $$ProductGroupsTableTableTableManager get productGroupsTable =>
      $$ProductGroupsTableTableTableManager(_db, _db.productGroupsTable);
  $$PaymentTypesTableTableTableManager get paymentTypesTable =>
      $$PaymentTypesTableTableTableManager(_db, _db.paymentTypesTable);
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(_db, _db.customersTable);
  $$PromotionsTableTableTableManager get promotionsTable =>
      $$PromotionsTableTableTableManager(_db, _db.promotionsTable);
  $$PromotionItemsTableTableTableManager get promotionItemsTable =>
      $$PromotionItemsTableTableTableManager(_db, _db.promotionItemsTable);
  $$ProductCommentsTableTableTableManager get productCommentsTable =>
      $$ProductCommentsTableTableTableManager(_db, _db.productCommentsTable);
  $$CompaniesTableTableTableManager get companiesTable =>
      $$CompaniesTableTableTableManager(_db, _db.companiesTable);
  $$PosOrdersTableTableTableManager get posOrdersTable =>
      $$PosOrdersTableTableTableManager(_db, _db.posOrdersTable);
  $$PosOrderItemsTableTableTableManager get posOrderItemsTable =>
      $$PosOrderItemsTableTableTableManager(_db, _db.posOrderItemsTable);
  $$PosOrderItemTaxesTableTableTableManager get posOrderItemTaxesTable =>
      $$PosOrderItemTaxesTableTableTableManager(
        _db,
        _db.posOrderItemTaxesTable,
      );
  $$StartingCashTableTableTableManager get startingCashTable =>
      $$StartingCashTableTableTableManager(_db, _db.startingCashTable);
  $$ZReportsTableTableTableManager get zReportsTable =>
      $$ZReportsTableTableTableManager(_db, _db.zReportsTable);
  $$SyncMetaTableTableTableManager get syncMetaTable =>
      $$SyncMetaTableTableTableManager(_db, _db.syncMetaTable);
  $$StocksTableTableTableManager get stocksTable =>
      $$StocksTableTableTableManager(_db, _db.stocksTable);
  $$PendingVoidsTableTableTableManager get pendingVoidsTable =>
      $$PendingVoidsTableTableTableManager(_db, _db.pendingVoidsTable);
  $$DocumentsTableTableTableManager get documentsTable =>
      $$DocumentsTableTableTableManager(_db, _db.documentsTable);
  $$DocumentItemsTableTableTableManager get documentItemsTable =>
      $$DocumentItemsTableTableTableManager(_db, _db.documentItemsTable);
  $$PaymentsTableTableTableManager get paymentsTable =>
      $$PaymentsTableTableTableManager(_db, _db.paymentsTable);
  $$BarcodesTableTableTableManager get barcodesTable =>
      $$BarcodesTableTableTableManager(_db, _db.barcodesTable);
  $$CustomerDiscountsTableTableTableManager get customerDiscountsTable =>
      $$CustomerDiscountsTableTableTableManager(
        _db,
        _db.customerDiscountsTable,
      );
  $$LoyaltyCardsTableTableTableManager get loyaltyCardsTable =>
      $$LoyaltyCardsTableTableTableManager(_db, _db.loyaltyCardsTable);
  $$TimeClockEntriesTableTableTableManager get timeClockEntriesTable =>
      $$TimeClockEntriesTableTableTableManager(_db, _db.timeClockEntriesTable);
  $$ShiftsTableTableTableManager get shiftsTable =>
      $$ShiftsTableTableTableManager(_db, _db.shiftsTable);
}
