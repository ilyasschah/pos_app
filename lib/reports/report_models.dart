class SalesByProductRow {
  final String? code;
  final String product;
  final double quantity;
  final String uom;
  final double totalBeforeTax;
  final double total;

  const SalesByProductRow({
    required this.code,
    required this.product,
    required this.quantity,
    required this.uom,
    required this.totalBeforeTax,
    required this.total,
  });

  factory SalesByProductRow.fromJson(Map<String, dynamic> j) =>
      SalesByProductRow(
        code: j['code'] as String?,
        product: j['product'] as String? ?? '',
        quantity: (j['quantity'] as num).toDouble(),
        uom: j['uom'] as String? ?? '',
        totalBeforeTax: (j['totalBeforeTax'] as num).toDouble(),
        total: (j['total'] as num).toDouble(),
      );
}

class SalesByProductGroupRow {
  final String productGroup;
  final double quantity;
  final double totalBeforeTax;
  final double total;

  const SalesByProductGroupRow({
    required this.productGroup,
    required this.quantity,
    required this.totalBeforeTax,
    required this.total,
  });

  factory SalesByProductGroupRow.fromJson(Map<String, dynamic> j) =>
      SalesByProductGroupRow(
        productGroup: j['productGroup'] as String? ?? '',
        quantity: (j['quantity'] as num).toDouble(),
        totalBeforeTax: (j['totalBeforeTax'] as num).toDouble(),
        total: (j['total'] as num).toDouble(),
      );
}

class SalesByCustomerRow {
  final String customer;
  final double totalBeforeTax;
  final double total;

  const SalesByCustomerRow({
    required this.customer,
    required this.totalBeforeTax,
    required this.total,
  });

  factory SalesByCustomerRow.fromJson(Map<String, dynamic> j) =>
      SalesByCustomerRow(
        customer: j['customer'] as String? ?? '',
        totalBeforeTax: (j['totalBeforeTax'] as num).toDouble(),
        total: (j['total'] as num).toDouble(),
      );
}

class SalesByTaxRow {
  final String taxName;
  final double totalBeforeTax;
  final double taxAmount;
  final double total;

  const SalesByTaxRow({
    required this.taxName,
    required this.totalBeforeTax,
    required this.taxAmount,
    required this.total,
  });

  factory SalesByTaxRow.fromJson(Map<String, dynamic> j) => SalesByTaxRow(
        taxName: j['taxName'] as String? ?? '',
        totalBeforeTax: (j['totalBeforeTax'] as num).toDouble(),
        taxAmount: (j['taxAmount'] as num).toDouble(),
        total: (j['total'] as num).toDouble(),
      );
}

class ReportFilter {
  final DateTime startDate;
  final DateTime endDate;
  final int? customerId;
  final int? userId;
  final int? warehouseId;
  final int? productId;
  final int? productGroupId;
  final bool includeSubgroups;

  const ReportFilter({
    required this.startDate,
    required this.endDate,
    this.customerId,
    this.userId,
    this.warehouseId,
    this.productId,
    this.productGroupId,
    this.includeSubgroups = false,
  });

  ReportFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    Object? customerId = _sentinel,
    Object? userId = _sentinel,
    Object? warehouseId = _sentinel,
    Object? productId = _sentinel,
    Object? productGroupId = _sentinel,
    bool? includeSubgroups,
  }) =>
      ReportFilter(
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        customerId: customerId == _sentinel ? this.customerId : customerId as int?,
        userId: userId == _sentinel ? this.userId : userId as int?,
        warehouseId: warehouseId == _sentinel ? this.warehouseId : warehouseId as int?,
        productId: productId == _sentinel ? this.productId : productId as int?,
        productGroupId: productGroupId == _sentinel ? this.productGroupId : productGroupId as int?,
        includeSubgroups: includeSubgroups ?? this.includeSubgroups,
      );
}

class SalesByUserRow {
  final String user;
  final double totalBeforeTax;
  final double total;

  const SalesByUserRow({
    required this.user,
    required this.totalBeforeTax,
    required this.total,
  });

  factory SalesByUserRow.fromJson(Map<String, dynamic> j) => SalesByUserRow(
        user: j['user'] as String? ?? '',
        totalBeforeTax: (j['totalBeforeTax'] as num).toDouble(),
        total: (j['total'] as num).toDouble(),
      );
}

class PaymentTypesByCustomerRow {
  final String customerName;
  final String paymentTypeName;
  final double amount;

  const PaymentTypesByCustomerRow({
    required this.customerName,
    required this.paymentTypeName,
    required this.amount,
  });

  factory PaymentTypesByCustomerRow.fromJson(Map<String, dynamic> j) =>
      PaymentTypesByCustomerRow(
        customerName: j['customerName'] as String? ?? '',
        paymentTypeName: j['paymentTypeName'] as String? ?? '',
        amount: (j['amount'] as num).toDouble(),
      );
}

class PaymentTypesByUserRow {
  final String userName;
  final String paymentTypeName;
  final double amount;

  const PaymentTypesByUserRow({
    required this.userName,
    required this.paymentTypeName,
    required this.amount,
  });

  factory PaymentTypesByUserRow.fromJson(Map<String, dynamic> j) =>
      PaymentTypesByUserRow(
        userName: j['userName'] as String? ?? '',
        paymentTypeName: j['paymentTypeName'] as String? ?? '',
        amount: (j['amount'] as num).toDouble(),
      );
}

class SalesByPaymentTypeRow {
  final DateTime date;
  final String paymentTypeName;
  final double amount;

  const SalesByPaymentTypeRow({
    required this.date,
    required this.paymentTypeName,
    required this.amount,
  });

  factory SalesByPaymentTypeRow.fromJson(Map<String, dynamic> j) =>
      SalesByPaymentTypeRow(
        date: DateTime.parse(j['date'] as String),
        paymentTypeName: j['paymentTypeName'] as String? ?? '',
        amount: (j['amount'] as num).toDouble(),
      );
}

class SalesItemListRow {
  final String documentTypeName;
  final DateTime date;
  final DateTime dateCreated;
  final String documentNumber;
  final String? refNumber;
  final String? customerCode;
  final String customerName;
  final String? orderNumber;
  final String? productCode;
  final String productName;
  final double quantity;
  final String uom;
  final double totalBeforeTax;
  final double totalTax;
  final double total;

  const SalesItemListRow({
    required this.documentTypeName,
    required this.date,
    required this.dateCreated,
    required this.documentNumber,
    required this.refNumber,
    required this.customerCode,
    required this.customerName,
    required this.orderNumber,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.uom,
    required this.totalBeforeTax,
    required this.totalTax,
    required this.total,
  });

  factory SalesItemListRow.fromJson(Map<String, dynamic> j) => SalesItemListRow(
        documentTypeName: j['documentTypeName'] as String? ?? '',
        date: DateTime.parse(j['date'] as String),
        dateCreated: DateTime.parse(j['dateCreated'] as String),
        documentNumber: j['documentNumber'] as String? ?? '',
        refNumber: j['refNumber'] as String?,
        customerCode: j['customerCode'] as String?,
        customerName: j['customerName'] as String? ?? '',
        orderNumber: j['orderNumber'] as String?,
        productCode: j['productCode'] as String?,
        productName: j['productName'] as String? ?? '',
        quantity: (j['quantity'] as num).toDouble(),
        uom: j['uom'] as String? ?? '',
        totalBeforeTax: (j['totalBeforeTax'] as num).toDouble(),
        totalTax: (j['totalTax'] as num).toDouble(),
        total: (j['total'] as num).toDouble(),
      );
}

const Object _sentinel = Object();
