class BarcodeModel {
  final int id;
  final String value;
  final int productId;
  final String productName;

  BarcodeModel({
    required this.id,
    required this.value,
    required this.productId,
    required this.productName,
  });

  factory BarcodeModel.fromJson(Map<String, dynamic> json) {
    return BarcodeModel(
      id: json['id'] ?? 0,
      value: json['value'] ?? '',
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
    );
  }
}
