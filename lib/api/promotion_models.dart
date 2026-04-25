import 'package:json_annotation/json_annotation.dart';

part 'promotion_models.g.dart';

@JsonSerializable()
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

  factory PromotionDto.fromJson(Map<String, dynamic> json) =>
      _$PromotionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PromotionDtoToJson(this);
}

@JsonSerializable()
class PromotionItemDto {
  final int id;
  final int promotionId;
  final int uid;
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
    required this.uid,
    required this.discountType,
    required this.priceType,
    required this.value,
    required this.isConditional,
    required this.quantity,
    required this.conditionType,
    required this.quantityLimit,
  });

  factory PromotionItemDto.fromJson(Map<String, dynamic> json) =>
      _$PromotionItemDtoFromJson(json);
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
  final int uid;
  final int discountType;
  final int priceType;
  final double value;
  final bool isConditional;
  final double quantity;
  final int conditionType;
  final double quantityLimit;

  CreatePromotionItemRequest({
    required this.uid,
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
  final int uid;
  final int discountType;
  final int priceType;
  final double value;
  final bool isConditional;
  final double quantity;
  final int conditionType;
  final double quantityLimit;

  UpdatePromotionItemRequest({
    required this.id,
    required this.uid,
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
