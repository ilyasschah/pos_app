class PaymentType {
  final int id;
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

  PaymentType({
    required this.id,
    required this.name,
    this.code,
    this.isCustomerRequired = false,
    this.isFiscal = false,
    this.isSlipRequired = false,
    this.isChangeAllowed = false,
    this.ordinal = 0,
    this.isEnabled = true,
    this.isQuickPayment = false,
    this.openCashDrawer = false,
    this.shortcutKey,
    this.markAsPaid = false,
  });

  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'],
      isCustomerRequired: json['isCustomerRequired'] ?? false,
      isFiscal: json['isFiscal'] ?? false,
      isSlipRequired: json['isSlipRequired'] ?? false,
      isChangeAllowed: json['isChangeAllowed'] ?? false,
      ordinal: json['ordinal'] ?? 0,
      isEnabled: json['isEnabled'] ?? true,
      isQuickPayment: json['isQuickPayment'] ?? false,
      openCashDrawer: json['openCashDrawer'] ?? false,
      shortcutKey: json['shortcutKey'],
      markAsPaid: json['markAsPaid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'isCustomerRequired': isCustomerRequired,
        'isFiscal': isFiscal,
        'isSlipRequired': isSlipRequired,
        'isChangeAllowed': isChangeAllowed,
        'ordinal': ordinal,
        'isEnabled': isEnabled,
        'isQuickPayment': isQuickPayment,
        'openCashDrawer': openCashDrawer,
        'shortcutKey': shortcutKey,
        'markAsPaid': markAsPaid,
      };
}