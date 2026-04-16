// lib/checkout_models.dart

class MenuTax {
  final int id;
  final String name;
  final double rate;
  final bool isFixed;
  final bool isTaxOnTotal;

  MenuTax({
    required this.id,
    required this.name,
    required this.rate,
    required this.isFixed,
    required this.isTaxOnTotal,
  });

  factory MenuTax.fromJson(Map<String, dynamic> json) {
    return MenuTax(
      id: json['id'],
      name: json['name'] ?? '',
      rate: (json['rate'] ?? 0).toDouble(),
      isFixed: json['isFixed'] ?? false,
      isTaxOnTotal: json['isTaxOnTotal'] ?? false,
    );
  }
}

class MenuProduct {
  final int id;
  final String name;
  final double price;
  final bool isTaxInclusivePrice;
  final String color;
  final double stockQuantity;
  final List<MenuTax> taxes;
  // Note: We excluded the image byte array to keep the app lightning fast!

  MenuProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.isTaxInclusivePrice,
    required this.color,
    required this.stockQuantity,
    required this.taxes,
  });

  factory MenuProduct.fromJson(Map<String, dynamic> json) {
    return MenuProduct(
      id: json['id'],
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      isTaxInclusivePrice: json['isTaxInclusivePrice'] ?? true,
      color: json['color'] ?? 'Transparent',
      stockQuantity: (json['stockQuantity'] ?? 0).toDouble(),
      taxes:
          (json['taxes'] as List?)?.map((t) => MenuTax.fromJson(t)).toList() ??
              [],
    );
  }
}

class MenuCategory {
  final int id;
  final String name;
  final String color;
  final List<MenuProduct> products;

  MenuCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.products,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'],
      name: json['name'] ?? '',
      color: json['color'] ?? 'Transparent',
      products: (json['products'] as List?)
              ?.map((p) => MenuProduct.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class CartItem {
  int posOrderId;
  final int productId;
  int roundNumber;
  double quantity;
  double price;
  double discount;
  int discountType;
  String? comment;
  String? bundle;

  // --- UI ONLY FIELDS (Not sent to API) ---
  final String productName;
  final List<MenuTax> appliedTaxes;

  CartItem({
    required this.posOrderId,
    required this.productId,
    this.roundNumber = 1,
    this.quantity = 1,
    required this.price,
    this.discount = 0,
    this.discountType = 0,
    this.comment,
    this.bundle,
    required this.productName,
    required this.appliedTaxes,
  });

  // Only exports what the C# BulkAdd endpoint expects!
  Map<String, dynamic> toJson() {
    return {
      'posOrderId': posOrderId,
      'productId': productId,
      'roundNumber': roundNumber,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'discountType': discountType,
      'comment': comment,
      'bundle': bundle,
    };
  }
}

class CheckoutRequest {
  final int posOrderId;
  final int paymentTypeId;
  final double amountPaid;
  final int documentTypeId;
  final int warehouseId;

  CheckoutRequest({
    required this.posOrderId,
    required this.paymentTypeId,
    required this.amountPaid,
    required this.documentTypeId,
    required this.warehouseId,
  });

  Map<String, dynamic> toJson() {
    return {
      'posOrderId': posOrderId,
      'paymentTypeId': paymentTypeId,
      'amountPaid': amountPaid,
      'documentTypeId': documentTypeId,
      'warehouseId': warehouseId,
    };
  }
}
