// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
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
    price,
    cost,
    barcode,
    productGroupId,
    isService,
    colorHex,
    localImagePath,
    lastModified,
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
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
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
  final DateTime lastModified;
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
    required this.lastModified,
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
    map['last_modified'] = Variable<DateTime>(lastModified);
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
      lastModified: Value(lastModified),
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
      'price': serializer.toJson<double>(price),
      'cost': serializer.toJson<double>(cost),
      'barcode': serializer.toJson<String?>(barcode),
      'productGroupId': serializer.toJson<int?>(productGroupId),
      'isService': serializer.toJson<bool>(isService),
      'colorHex': serializer.toJson<String?>(colorHex),
      'localImagePath': serializer.toJson<String?>(localImagePath),
      'lastModified': serializer.toJson<DateTime>(lastModified),
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
    DateTime? lastModified,
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
    lastModified: lastModified ?? this.lastModified,
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
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
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
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
    lastModified,
  );
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
          other.lastModified == this.lastModified);
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
  final Value<DateTime> lastModified;
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
    this.lastModified = const Value.absent(),
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
    required DateTime lastModified,
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
    Expression<DateTime>? lastModified,
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
      if (lastModified != null) 'last_modified': lastModified,
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
    Value<DateTime>? lastModified,
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
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
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
          ..write('lastModified: $lastModified')
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
  final DateTime lastModified;
  const TaxesTableData({
    required this.id,
    required this.companyId,
    required this.name,
    required this.rate,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['name'] = Variable<String>(name);
    map['rate'] = Variable<double>(rate);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  TaxesTableCompanion toCompanion(bool nullToAbsent) {
    return TaxesTableCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      rate: Value(rate),
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
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  TaxesTableData copyWith({
    int? id,
    int? companyId,
    String? name,
    double? rate,
    DateTime? lastModified,
  }) => TaxesTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    rate: rate ?? this.rate,
    lastModified: lastModified ?? this.lastModified,
  );
  TaxesTableData copyWithCompanion(TaxesTableCompanion data) {
    return TaxesTableData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      rate: data.rate.present ? data.rate.value : this.rate,
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
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, companyId, name, rate, lastModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaxesTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.rate == this.rate &&
          other.lastModified == this.lastModified);
}

class TaxesTableCompanion extends UpdateCompanion<TaxesTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String> name;
  final Value<double> rate;
  final Value<DateTime> lastModified;
  const TaxesTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.rate = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  TaxesTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required String name,
    required double rate,
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
    Expression<DateTime>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (rate != null) 'rate': rate,
      if (lastModified != null) 'last_modified': lastModified,
    });
  }

  TaxesTableCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<String>? name,
    Value<double>? rate,
    Value<DateTime>? lastModified,
  }) {
    return TaxesTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      rate: rate ?? this.rate,
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
  final String? pinHash;
  final int role;
  final bool isEnabled;
  final DateTime lastModified;
  const UsersTableData({
    required this.id,
    required this.companyId,
    required this.name,
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
    Value<String?> pinHash = const Value.absent(),
    int? role,
    bool? isEnabled,
    DateTime? lastModified,
  }) => UsersTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
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
          ..write('pinHash: $pinHash, ')
          ..write('role: $role, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, companyId, name, pinHash, role, isEnabled, lastModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.pinHash == this.pinHash &&
          other.role == this.role &&
          other.isEnabled == this.isEnabled &&
          other.lastModified == this.lastModified);
}

class UsersTableCompanion extends UpdateCompanion<UsersTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String> name;
  final Value<String?> pinHash;
  final Value<int> role;
  final Value<bool> isEnabled;
  final Value<DateTime> lastModified;
  const UsersTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.role = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  UsersTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required String name,
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
    Expression<String>? pinHash,
    Expression<int>? role,
    Expression<bool>? isEnabled,
    Expression<DateTime>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
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
    Value<String?>? pinHash,
    Value<int>? role,
    Value<bool>? isEnabled,
    Value<DateTime>? lastModified,
  }) {
    return UsersTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    value,
    lastModified,
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
  const AppPropertiesTableData({
    required this.id,
    required this.companyId,
    required this.name,
    this.value,
    required this.lastModified,
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
    };
  }

  AppPropertiesTableData copyWith({
    int? id,
    int? companyId,
    String? name,
    Value<String?> value = const Value.absent(),
    DateTime? lastModified,
  }) => AppPropertiesTableData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    value: value.present ? value.value : this.value,
    lastModified: lastModified ?? this.lastModified,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPropertiesTableData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, companyId, name, value, lastModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPropertiesTableData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.value == this.value &&
          other.lastModified == this.lastModified);
}

class AppPropertiesTableCompanion
    extends UpdateCompanion<AppPropertiesTableData> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String> name;
  final Value<String?> value;
  final Value<DateTime> lastModified;
  const AppPropertiesTableCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  AppPropertiesTableCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required String name,
    this.value = const Value.absent(),
    required DateTime lastModified,
  }) : companyId = Value(companyId),
       name = Value(name),
       lastModified = Value(lastModified);
  static Insertable<AppPropertiesTableData> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<String>? name,
    Expression<String>? value,
    Expression<DateTime>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (lastModified != null) 'last_modified': lastModified,
    });
  }

  AppPropertiesTableCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<String>? name,
    Value<String?>? value,
    Value<DateTime>? lastModified,
  }) {
    return AppPropertiesTableCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      value: value ?? this.value,
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
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
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
    warehouseId,
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
      warehouseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warehouse_id'],
      )!,
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
  final int warehouseId;
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
    required this.warehouseId,
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
    map['warehouse_id'] = Variable<int>(warehouseId);
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
      warehouseId: Value(warehouseId),
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
      warehouseId: serializer.fromJson<int>(json['warehouseId']),
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
      'warehouseId': serializer.toJson<int>(warehouseId),
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
    int? warehouseId,
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
    warehouseId: warehouseId ?? this.warehouseId,
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
      warehouseId: data.warehouseId.present
          ? data.warehouseId.value
          : this.warehouseId,
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
          ..write('warehouseId: $warehouseId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
    warehouseId,
    syncStatus,
    syncError,
    lastModified,
  );
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
          other.warehouseId == this.warehouseId &&
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
  final Value<int> warehouseId;
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
    this.warehouseId = const Value.absent(),
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
    required int warehouseId,
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
    Expression<int>? warehouseId,
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
      if (warehouseId != null) 'warehouse_id': warehouseId,
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
    Value<int>? warehouseId,
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
      warehouseId: warehouseId ?? this.warehouseId,
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
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<int>(warehouseId.value);
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
          ..write('warehouseId: $warehouseId, ')
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
    taxRate,
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
    if (data.containsKey('tax_rate')) {
      context.handle(
        _taxRateMeta,
        taxRate.isAcceptableOrUnknown(data['tax_rate']!, _taxRateMeta),
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
      taxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_rate'],
      )!,
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
  final double taxRate;
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
    required this.taxRate,
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
    map['tax_rate'] = Variable<double>(taxRate);
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
      taxRate: Value(taxRate),
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
      taxRate: serializer.fromJson<double>(json['taxRate']),
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
      'taxRate': serializer.toJson<double>(taxRate),
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
    double? taxRate,
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
    taxRate: taxRate ?? this.taxRate,
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
      taxRate: data.taxRate.present ? data.taxRate.value : this.taxRate,
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
          ..write('taxRate: $taxRate, ')
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
    taxRate,
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
          other.taxRate == this.taxRate &&
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
  final Value<double> taxRate;
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
    this.taxRate = const Value.absent(),
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
    this.taxRate = const Value.absent(),
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
    Expression<double>? taxRate,
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
      if (taxRate != null) 'tax_rate': taxRate,
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
    Value<double>? taxRate,
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
      taxRate: taxRate ?? this.taxRate,
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
    if (taxRate.present) {
      map['tax_rate'] = Variable<double>(taxRate.value);
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
          ..write('taxRate: $taxRate, ')
          ..write('comment: $comment, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashMovementsTableTable extends CashMovementsTable
    with TableInfo<$CashMovementsTableTable, CashMovementsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashMovementsTableTable(this.attachedDatabase, [this._alias]);
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
    syncStatus,
    syncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashMovementsTableData> instance, {
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
  CashMovementsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashMovementsTableData(
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
  $CashMovementsTableTable createAlias(String alias) {
    return $CashMovementsTableTable(attachedDatabase, alias);
  }
}

class CashMovementsTableData extends DataClass
    implements Insertable<CashMovementsTableData> {
  final String localId;
  final int? serverId;
  final int companyId;
  final int userId;
  final double amount;
  final String type;
  final String? note;
  final DateTime createdAt;
  final String syncStatus;
  final String? syncError;
  const CashMovementsTableData({
    required this.localId,
    this.serverId,
    required this.companyId,
    required this.userId,
    required this.amount,
    required this.type,
    this.note,
    required this.createdAt,
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
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  CashMovementsTableCompanion toCompanion(bool nullToAbsent) {
    return CashMovementsTableCompanion(
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
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory CashMovementsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashMovementsTableData(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      companyId: serializer.fromJson<int>(json['companyId']),
      userId: serializer.fromJson<int>(json['userId']),
      amount: serializer.fromJson<double>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
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
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  CashMovementsTableData copyWith({
    String? localId,
    Value<int?> serverId = const Value.absent(),
    int? companyId,
    int? userId,
    double? amount,
    String? type,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    String? syncStatus,
    Value<String?> syncError = const Value.absent(),
  }) => CashMovementsTableData(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    companyId: companyId ?? this.companyId,
    userId: userId ?? this.userId,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
  );
  CashMovementsTableData copyWithCompanion(CashMovementsTableCompanion data) {
    return CashMovementsTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      userId: data.userId.present ? data.userId.value : this.userId,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashMovementsTableData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('companyId: $companyId, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
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
    syncStatus,
    syncError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashMovementsTableData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.companyId == this.companyId &&
          other.userId == this.userId &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError);
}

class CashMovementsTableCompanion
    extends UpdateCompanion<CashMovementsTableData> {
  final Value<String> localId;
  final Value<int?> serverId;
  final Value<int> companyId;
  final Value<int> userId;
  final Value<double> amount;
  final Value<String> type;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  final Value<int> rowid;
  const CashMovementsTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.userId = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashMovementsTableCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required int companyId,
    required int userId,
    required double amount,
    required String type,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       companyId = Value(companyId),
       userId = Value(userId),
       amount = Value(amount),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<CashMovementsTableData> custom({
    Expression<String>? localId,
    Expression<int>? serverId,
    Expression<int>? companyId,
    Expression<int>? userId,
    Expression<double>? amount,
    Expression<String>? type,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
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
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashMovementsTableCompanion copyWith({
    Value<String>? localId,
    Value<int?>? serverId,
    Value<int>? companyId,
    Value<int>? userId,
    Value<double>? amount,
    Value<String>? type,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<String>? syncStatus,
    Value<String?>? syncError,
    Value<int>? rowid,
  }) {
    return CashMovementsTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
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
    return (StringBuffer('CashMovementsTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('companyId: $companyId, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
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
  late final $PosOrdersTableTable posOrdersTable = $PosOrdersTableTable(this);
  late final $PosOrderItemsTableTable posOrderItemsTable =
      $PosOrderItemsTableTable(this);
  late final $CashMovementsTableTable cashMovementsTable =
      $CashMovementsTableTable(this);
  late final $ZReportsTableTable zReportsTable = $ZReportsTableTable(this);
  late final $SyncMetaTableTable syncMetaTable = $SyncMetaTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    productsTable,
    taxesTable,
    floorPlansTable,
    floorPlanTablesTable,
    usersTable,
    appPropertiesTable,
    posOrdersTable,
    posOrderItemsTable,
    cashMovementsTable,
    zReportsTable,
    syncMetaTable,
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
  ]);
}

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
      required DateTime lastModified,
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
      Value<DateTime> lastModified,
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

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
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

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
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

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );
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
                Value<DateTime> lastModified = const Value.absent(),
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
                lastModified: lastModified,
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
                required DateTime lastModified,
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
                lastModified: lastModified,
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
      required DateTime lastModified,
    });
typedef $$TaxesTableTableUpdateCompanionBuilder =
    TaxesTableCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<String> name,
      Value<double> rate,
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
                Value<DateTime> lastModified = const Value.absent(),
              }) => TaxesTableCompanion(
                id: id,
                companyId: companyId,
                name: name,
                rate: rate,
                lastModified: lastModified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required String name,
                required double rate,
                required DateTime lastModified,
              }) => TaxesTableCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                rate: rate,
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
                Value<String?> pinHash = const Value.absent(),
                Value<int> role = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
              }) => UsersTableCompanion(
                id: id,
                companyId: companyId,
                name: name,
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
                Value<String?> pinHash = const Value.absent(),
                Value<int> role = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                required DateTime lastModified,
              }) => UsersTableCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
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
    });
typedef $$AppPropertiesTableTableUpdateCompanionBuilder =
    AppPropertiesTableCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<String> name,
      Value<String?> value,
      Value<DateTime> lastModified,
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
              }) => AppPropertiesTableCompanion(
                id: id,
                companyId: companyId,
                name: name,
                value: value,
                lastModified: lastModified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required String name,
                Value<String?> value = const Value.absent(),
                required DateTime lastModified,
              }) => AppPropertiesTableCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                value: value,
                lastModified: lastModified,
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
      required int warehouseId,
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
      Value<int> warehouseId,
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

  ColumnFilters<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
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

  ColumnOrderings<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
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

  GeneratedColumn<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
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
          PrefetchHooks Function({bool posOrderItemsTableRefs})
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
                Value<int> warehouseId = const Value.absent(),
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
                warehouseId: warehouseId,
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
                required int warehouseId,
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
                warehouseId: warehouseId,
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
          prefetchHooksCallback: ({posOrderItemsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (posOrderItemsTableRefs) db.posOrderItemsTable,
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
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
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
      PrefetchHooks Function({bool posOrderItemsTableRefs})
    >;
typedef $$PosOrderItemsTableTableCreateCompanionBuilder =
    PosOrderItemsTableCompanion Function({
      required String localId,
      required String orderId,
      required int productId,
      required double quantity,
      required double unitPrice,
      Value<double> discount,
      Value<double> taxRate,
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
      Value<double> taxRate,
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

  ColumnFilters<double> get taxRate => $composableBuilder(
    column: $table.taxRate,
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

  ColumnOrderings<double> get taxRate => $composableBuilder(
    column: $table.taxRate,
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

  GeneratedColumn<double> get taxRate =>
      $composableBuilder(column: $table.taxRate, builder: (column) => column);

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
                Value<double> taxRate = const Value.absent(),
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
                taxRate: taxRate,
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
                Value<double> taxRate = const Value.absent(),
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
                taxRate: taxRate,
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
typedef $$CashMovementsTableTableCreateCompanionBuilder =
    CashMovementsTableCompanion Function({
      required String localId,
      Value<int?> serverId,
      required int companyId,
      required int userId,
      required double amount,
      required String type,
      Value<String?> note,
      required DateTime createdAt,
      Value<String> syncStatus,
      Value<String?> syncError,
      Value<int> rowid,
    });
typedef $$CashMovementsTableTableUpdateCompanionBuilder =
    CashMovementsTableCompanion Function({
      Value<String> localId,
      Value<int?> serverId,
      Value<int> companyId,
      Value<int> userId,
      Value<double> amount,
      Value<String> type,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<String> syncStatus,
      Value<String?> syncError,
      Value<int> rowid,
    });

class $$CashMovementsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CashMovementsTableTable> {
  $$CashMovementsTableTableFilterComposer({
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

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashMovementsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CashMovementsTableTable> {
  $$CashMovementsTableTableOrderingComposer({
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

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashMovementsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashMovementsTableTable> {
  $$CashMovementsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$CashMovementsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashMovementsTableTable,
          CashMovementsTableData,
          $$CashMovementsTableTableFilterComposer,
          $$CashMovementsTableTableOrderingComposer,
          $$CashMovementsTableTableAnnotationComposer,
          $$CashMovementsTableTableCreateCompanionBuilder,
          $$CashMovementsTableTableUpdateCompanionBuilder,
          (
            CashMovementsTableData,
            BaseReferences<
              _$AppDatabase,
              $CashMovementsTableTable,
              CashMovementsTableData
            >,
          ),
          CashMovementsTableData,
          PrefetchHooks Function()
        > {
  $$CashMovementsTableTableTableManager(
    _$AppDatabase db,
    $CashMovementsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashMovementsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashMovementsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashMovementsTableTableAnnotationComposer(
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
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashMovementsTableCompanion(
                localId: localId,
                serverId: serverId,
                companyId: companyId,
                userId: userId,
                amount: amount,
                type: type,
                note: note,
                createdAt: createdAt,
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
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashMovementsTableCompanion.insert(
                localId: localId,
                serverId: serverId,
                companyId: companyId,
                userId: userId,
                amount: amount,
                type: type,
                note: note,
                createdAt: createdAt,
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

typedef $$CashMovementsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashMovementsTableTable,
      CashMovementsTableData,
      $$CashMovementsTableTableFilterComposer,
      $$CashMovementsTableTableOrderingComposer,
      $$CashMovementsTableTableAnnotationComposer,
      $$CashMovementsTableTableCreateCompanionBuilder,
      $$CashMovementsTableTableUpdateCompanionBuilder,
      (
        CashMovementsTableData,
        BaseReferences<
          _$AppDatabase,
          $CashMovementsTableTable,
          CashMovementsTableData
        >,
      ),
      CashMovementsTableData,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
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
  $$PosOrdersTableTableTableManager get posOrdersTable =>
      $$PosOrdersTableTableTableManager(_db, _db.posOrdersTable);
  $$PosOrderItemsTableTableTableManager get posOrderItemsTable =>
      $$PosOrderItemsTableTableTableManager(_db, _db.posOrderItemsTable);
  $$CashMovementsTableTableTableManager get cashMovementsTable =>
      $$CashMovementsTableTableTableManager(_db, _db.cashMovementsTable);
  $$ZReportsTableTableTableManager get zReportsTable =>
      $$ZReportsTableTableTableManager(_db, _db.zReportsTable);
  $$SyncMetaTableTableTableManager get syncMetaTable =>
      $$SyncMetaTableTableTableManager(_db, _db.syncMetaTable);
}
