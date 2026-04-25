class ProductComment {
  final int id;
  final int productId;
  final String comment;

  ProductComment({
    required this.id,
    required this.productId,
    required this.comment,
  });

  factory ProductComment.fromJson(Map<String, dynamic> json) {
    return ProductComment(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      comment: json['comment'] ?? '',
    );
  }
}
