class DocumentDto {
  final String number;
  final int userId;
  final int customerId;
  final String date;
  final double total;
  final int documentTypeId; // Hardcoded to 1 (Receipt)
  final int warehouseId; // Hardcoded to 5 (Main Warehouse)
  final int paidStatus; // 1 = Paid
  final int companyId;

  DocumentDto({
    required this.number,
    required this.userId,
    required this.customerId,
    required this.date,
    required this.total,
    this.documentTypeId = 1,
    this.warehouseId = 5,
    this.paidStatus = 1,
    this.companyId = 2,
  });

  Map<String, dynamic> toJson() {
    return {
      // "Id": 0, // Removed to prevent DB conflict
      "Number": number,
      "UserId": userId,
      "CustomerId": customerId,
      "Date": date,
      "Total": total,
      "DocumentTypeId": documentTypeId,
      "WarehouseId": warehouseId,
      "PaidStatus": paidStatus,
      "CompanyId": companyId,
      // Default fields required by your API structure
      "OrderNumber": number,
      "StockDate": date,
      "DueDate": date,
      "Status": 0,
      "Discount": 0,
      "DiscountType": 0,
      "IsClockedOut": false,
      "InternalNote": "POS Sale",
      "Note": ""
    };
  }
}

class DocumentItemDto {
  final int documentId;
  final int productId;
  final double quantity;
  final double price;
  final double total;

  DocumentItemDto({
    required this.documentId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      // "Id": 0, // Removed
      "DocumentId": documentId,
      "ProductId": productId,
      "Quantity": quantity,
      "Price": price,
      "Total": total,
      "Discount": 0,
      "DiscountType": 0,
      "ProductCost": 0,
      "TaxRate": 0,
      "PriceBeforeTaxAfterDiscount": price,
      "PriceAfterDiscount": price,
      "TotalAfterDocumentDiscount": total
    };
  }
}
