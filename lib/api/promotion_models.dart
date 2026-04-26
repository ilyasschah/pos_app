import 'package:json_annotation/json_annotation.dart';

part 'promotion_models.g.dart';

@JsonSerializable(createFactory: false)
class PromotionDto {
  final int id;
  final int companyId;
  final String name;
  final DateTime? startDate;
  final String? startTime;
  final DateTime? endDate;
  final String? endTime;
  final int daysOfWeek;
  final bool isEnabled;
  final List<PromotionItemDto> items;

  PromotionDto({
    required this.id,
    required this.companyId,
    required this.name,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    required this.daysOfWeek,
    required this.isEnabled,
    this.items = const [],
  });

  factory PromotionDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null || val.toString().trim().isEmpty) return null;
      try { return DateTime.parse(val.toString()); } catch(_) { return null; }
    }
    return PromotionDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      companyId: (json['companyId'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? 'Unnamed',
      startDate: parseDate(json['startDate']),
      startTime: json['startTime']?.toString().isEmpty == true ? null : json['startTime']?.toString(),
      endDate: parseDate(json['endDate']),
      endTime: json['endTime']?.toString().isEmpty == true ? null : json['endTime']?.toString(),
      daysOfWeek: (json['daysOfWeek'] as num?)?.toInt() ?? 127,
      isEnabled: json['isEnabled'] == true,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => PromotionItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? const [],
    );
  }
  Map<String, dynamic> toJson() => _$PromotionDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class PromotionItemDto {
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

  PromotionItemDto({
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

  factory PromotionItemDto.fromJson(Map<String, dynamic> json) {
    return PromotionItemDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      promotionId: (json['promotionId'] as num?)?.toInt() ?? 0,
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      discountType: (json['discountType'] as num?)?.toInt() ?? 0,
      priceType: (json['priceType'] as num?)?.toInt() ?? 0,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      isConditional: json['isConditional'] == true,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      conditionType: (json['conditionType'] as num?)?.toInt() ?? 0,
      quantityLimit: (json['quantityLimit'] as num?)?.toDouble() ?? 0.0,
    );
  }
  Map<String, dynamic> toJson() => _$PromotionItemDtoToJson(this);
}

@JsonSerializable()
class CreatePromotionRequest {
  final String name;
  final int daysOfWeek;
  final DateTime? startDate;
  final String? startTime;
  final DateTime? endDate;
  final String? endTime;
  final List<CreatePromotionItemRequest> items;

  CreatePromotionRequest({
    required this.name,
    required this.daysOfWeek,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.items = const [],
  });

  factory CreatePromotionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePromotionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePromotionRequestToJson(this);
}

@JsonSerializable()
class CreatePromotionItemRequest {
  final int productId;
  final int discountType;
  final int priceType;
  final double value;
  final bool isConditional;
  final double quantity;
  final int conditionType;
  final double quantityLimit;

  CreatePromotionItemRequest({
    required this.productId,
    required this.discountType,
    required this.priceType,
    required this.value,
    required this.isConditional,
    required this.quantity,
    required this.conditionType,
    required this.quantityLimit,
  });

  factory CreatePromotionItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePromotionItemRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePromotionItemRequestToJson(this);
}

@JsonSerializable()
class UpdatePromotionRequest {
  final int id;
  final String name;
  final int daysOfWeek;
  final bool isEnabled;
  final DateTime? startDate;
  final String? startTime;
  final DateTime? endDate;
  final String? endTime;
  final List<UpdatePromotionItemRequest> items;

  UpdatePromotionRequest({
    required this.id,
    required this.name,
    required this.daysOfWeek,
    required this.isEnabled,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.items = const [],
  });

  factory UpdatePromotionRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePromotionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePromotionRequestToJson(this);
}

@JsonSerializable()
class UpdatePromotionItemRequest {
  final int id;
  final int productId;
  final int discountType;
  final int priceType;
  final double value;
  final bool isConditional;
  final double quantity;
  final int conditionType;
  final double quantityLimit;

  UpdatePromotionItemRequest({
    required this.id,
    required this.productId,
    required this.discountType,
    required this.priceType,
    required this.value,
    required this.isConditional,
    required this.quantity,
    required this.conditionType,
    required this.quantityLimit,
  });

  factory UpdatePromotionItemRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePromotionItemRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePromotionItemRequestToJson(this);
}
