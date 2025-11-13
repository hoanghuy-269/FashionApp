class ShopProductVariantModel {
  final String shopProductVariantID;
  final String colorID;
  final String imageUrls;


  ShopProductVariantModel({
    required this.shopProductVariantID,
    required this.colorID,
    required this.imageUrls,
  });

  factory ShopProductVariantModel.fromMap(Map<String, dynamic> json, String id) {
    return ShopProductVariantModel(
      shopProductVariantID: id,
      colorID: json['colorID'] ?? '',
      imageUrls: json['imageUrls'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'shopProductVariantID': shopProductVariantID,
      'colorID': colorID,
      'imageUrls': imageUrls,
    };
  }
}
