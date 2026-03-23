class Document {
  final int id;
  final String number;
  final int userId;
  final String? userName;
  final int customerId;
  final String? customerName;
  final int companyId;
  final String? companyName;
  final int documentTypeId;
  final String? documentTypeName;
  final int warehouseId;
  final String? warehouseName;
  final String? orderNumber;
  final String date;
  final String? stockDate;
  final double total;
  final String? referenceDocumentNumber;
  final String? dateCreated;
  final String? dateUpdated;
  final String? internalNote;
  final String? note;
  final String? dueDate;
  final double discount;
  final int discountType;
  final int paidStatus;
  final bool discountApplyRule;
  final int serviceType;

  Document({
    required this.id,
    required this.number,
    required this.userId,
    this.userName,
    required this.customerId,
    this.customerName,
    required this.companyId,
    this.companyName,
    required this.documentTypeId,
    this.documentTypeName,
    required this.warehouseId,
    this.warehouseName,
    this.orderNumber,
    required this.date,
    this.stockDate,
    required this.total,
    this.referenceDocumentNumber,
    this.dateCreated,
    this.dateUpdated,
    this.internalNote,
    this.note,
    this.dueDate,
    this.discount = 0,
    this.discountType = 0,
    this.paidStatus = 0,
    this.discountApplyRule = true,
    this.serviceType = 0,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? 0,
      number: json['number'] ?? '',
      userId: json['userId'] ?? 0,
      userName: json['userName'],
      customerId: json['customerId'] ?? 0,
      customerName: json['customerName'],
      companyId: json['companyId'] ?? 0,
      companyName: json['companyName'],
      documentTypeId: json['documentTypeId'] ?? 0,
      documentTypeName: json['documentTypeName'],
      warehouseId: json['warehouseId'] ?? 0,
      warehouseName: json['warehouseName'],
      orderNumber: json['orderNumber'],
      date: json['date'] ?? '',
      stockDate: json['stockDate'],
      total: (json['total'] as num?)?.toDouble() ?? 0,
      referenceDocumentNumber: json['referenceDocumentNumber'],
      dateCreated: json['dateCreated'],
      dateUpdated: json['dateUpdated'],
      internalNote: json['internalNote'],
      note: json['note'],
      dueDate: json['dueDate'],
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      discountType: json['discountType'] ?? 0,
      paidStatus: json['paidStatus'] ?? 0,
      discountApplyRule: json['discountApplyRule'] ?? true,
      serviceType: json['serviceType'] ?? 0,
    );
  }
}

class DocumentType {
  final int id;
  final String name;
  final String? code;

  DocumentType({required this.id, required this.name, this.code});

  factory DocumentType.fromJson(Map<String, dynamic> json) {
    return DocumentType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'],
    );
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
