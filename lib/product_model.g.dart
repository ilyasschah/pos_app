// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      code: json['code'] as String?,
      price: (json['price'] as num).toDouble(),
      color: json['color'] as String?,
      productGroupId: (json['productGroupId'] as num?)?.toInt(),
      cost: (json['cost'] as num?)?.toDouble(),
      plu: (json['plu'] as num?)?.toInt(),
      measurementUnit: json['measurementUnit'] as String?,
      isTaxInclusivePrice: json['isTaxInclusivePrice'] as bool?,
      currencyId: (json['currencyId'] as num?)?.toInt(),
      isPriceChangeAllowed: json['isPriceChangeAllowed'] as bool?,
      isService: json['isService'] as bool?,
      isUsingDefaultQuantity: json['isUsingDefaultQuantity'] as bool?,
      isEnabled: json['isEnabled'] as bool?,
      description: json['description'] as String?,
      dateCreated: json['dateCreated'] as String?,
      dateUpdated: json['dateUpdated'] as String?,
      markup: (json['markup'] as num?)?.toDouble(),
      image: json['image'] as String?,
      ageRestriction: (json['ageRestriction'] as num?)?.toInt(),
      lastPurchasePrice: (json['lastPurchasePrice'] as num?)?.toDouble(),
      rank: (json['rank'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'price': instance.price,
      'color': instance.color,
      'productGroupId': instance.productGroupId,
      'cost': instance.cost,
      'plu': instance.plu,
      'measurementUnit': instance.measurementUnit,
      'isTaxInclusivePrice': instance.isTaxInclusivePrice,
      'currencyId': instance.currencyId,
      'isPriceChangeAllowed': instance.isPriceChangeAllowed,
      'isService': instance.isService,
      'isUsingDefaultQuantity': instance.isUsingDefaultQuantity,
      'isEnabled': instance.isEnabled,
      'description': instance.description,
      'dateCreated': instance.dateCreated,
      'dateUpdated': instance.dateUpdated,
      'markup': instance.markup,
      'image': instance.image,
      'ageRestriction': instance.ageRestriction,
      'lastPurchasePrice': instance.lastPurchasePrice,
      'rank': instance.rank,
    };
