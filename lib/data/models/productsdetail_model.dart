class ProductsdetailModel {
  final String productsDetailID;
  final String productID;
  final String sizeID;
  final String colorID;
  final String imageID;

  ProductsdetailModel({
    required this.productsDetailID,
    required this.productID,
    required this.sizeID,
    required this.colorID,
    required this.imageID,
  });
  factory ProductsdetailModel.fromFirestore(
      Map<String, dynamic> json, String productsDetailID) {
    return ProductsdetailModel(
      productsDetailID: productsDetailID,
      productID: json['productID'] ?? '',
      sizeID: json['sizeID'] ?? '',
      colorID: json['colorID'] ?? '',
      imageID: json['imageID'] ?? '',
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'productID': productID,
      'sizeID': sizeID,
      'colorID': colorID,
      'imageID': imageID,
    };
  }
}