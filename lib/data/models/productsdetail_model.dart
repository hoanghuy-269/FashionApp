class ProductsdetailModel {
  final String productsDetailID;
  final String productID;
  final String sizeID;
  final String colorID;
  final String imageUrls;

  ProductsdetailModel({
    required this.productsDetailID,
    required this.productID,
    required this.sizeID,
    required this.colorID,
    required this.imageUrls,
  });
  factory ProductsdetailModel.fromMap(
      Map<String, dynamic> json, String productsDetailID) {
    return ProductsdetailModel(
      productsDetailID: productsDetailID,
      productID: json['productID'] ?? '',
      sizeID: json['sizeID'] ?? '',
      colorID: json['colorID'] ?? '',
      imageUrls: json['imageUrls'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'productsDetailID': productsDetailID,
      'productID': productID,
      'sizeID': sizeID,
      'colorID': colorID,
      'imageUrls': imageUrls,
    };
  }
  ProductsdetailModel copyWith({
    String? productsDetailID,
    String? productID,
    String? sizeID,
    String? colorID,
    List<String>? imageUrls,
  }) {
    return ProductsdetailModel(
      productsDetailID: productsDetailID ?? this.productsDetailID,
      productID: productID ?? this.productID,
      sizeID: sizeID ?? this.sizeID,
      colorID: colorID ?? this.colorID,
      imageUrls: imageUrls?.join(',') ?? this.imageUrls,
    );
  }
}