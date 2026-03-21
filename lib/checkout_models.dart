
// --- ORDER HEADER ---
class PosOrderDto {
  final int userId;
  final String number;
  final double discount;
  final int discountType;
  final double? total;
  final int? customerId;

  // These are optional context fields, not part of the core table,
  // but we keep them in the constructor if needed for UI.
  final String? userName;
  final String? customerName;

  PosOrderDto({
    required this.userId,
    required this.number,
    this.discount = 0,
    this.discountType = 0,
    this.total,
    this.customerId,
    this.userName,
    this.customerName,
  });

  Map<String, dynamic> toJson() {
    return {
      // FIX: Capitalized keys to match C# PosOrder class
      "Id": 0,
      "UserId": userId,
      "Number": number, // <--- Capital 'N' fixes the 400 error
      "Discount": discount,
      "DiscountType": discountType,
      "Total": total,
      "CustomerId": customerId,

      // If your API expects these as extra fields, keep them.
      // If strict, you might remove them. For now, we capitalize them too.
      "UserName": userName,
      "CustomerName": customerName,
    };
  }
}

// --- ORDER ITEMS ---
class PosOrderItemDto {
  final int posOrderId;
  final int productId;
  final String productName;
  final double quantity;
  final double price;
  final double discount;
  final int discountType;
  final bool isLocked;
  final bool isFeatured;

  PosOrderItemDto({
    required this.posOrderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.discount = 0.0,
    this.discountType = 0,
    this.isLocked = false,
    this.isFeatured = false,
  });

  Map<String, dynamic> toJson() {
    return {
      // FIX: Capitalized keys to match C# conventions
      "Id": 0,
      "PosOrderId": posOrderId,
      "ProductId": productId,
      "ProductName": productName,
      "RoundNumber": 0,
      "Quantity": quantity,
      "Price": price,
      "IsLocked": isLocked,
      "Discount": discount,
      "DiscountType": discountType,
      "IsFeatured": isFeatured,
      // DateCreated is usually auto-set by DB, but if required:
      "DateCreated": DateTime.now().toIso8601String(),
    };
  }
}
