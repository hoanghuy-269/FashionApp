class ShopProductVariantModel {
  final String shopProductVariantID;
  final String colorID;
  final String sizeID;
  final int quantity;
  final double price; // giá bán
  final double costPrice; // giá vốn
  final String imageUrls;


  ShopProductVariantModel({
    required this.shopProductVariantID,
    required this.colorID,
    required this.sizeID,
    required this.quantity,
    required this.price,
    required this.costPrice,
    required this.imageUrls,
  });

  factory ShopProductVariantModel.fromMap(Map<String, dynamic> json, String id) {
    return ShopProductVariantModel(
      shopProductVariantID: id,
      colorID: json['colorID'] ?? '',
      sizeID: json['sizeID'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      imageUrls: json['imageUrls'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'shopProductVariantID': shopProductVariantID,
      'colorID': colorID,
      'sizeID': sizeID,
      'quantity': quantity,
      'price': price,
      'costPrice': costPrice,
      'imageUrls': imageUrls,
    };
  }
}
