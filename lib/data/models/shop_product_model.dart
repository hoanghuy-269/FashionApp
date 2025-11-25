class ShopProductModel {
  final String shopproductID;
  final String shopId;
  final String name;
  final String productID;
  final double? totalPrice;
  final int totalQuantity;
  final String imageUrls;
  final double? rating;
  final int? sold;
  final String description;

  ShopProductModel({
    required this.shopproductID,
    required this.shopId,
    required this.productID,
    required this.totalQuantity,
    required this.totalPrice,
    required this.name,
    this.rating,
    required this.imageUrls,
    this.sold,
    required this.description,
  });

  factory ShopProductModel.fromMap(Map<String, dynamic> json, String id) {
    return ShopProductModel(
      shopproductID: id,
      shopId: json['shopId'] ?? '',
      productID: json['productID'] ?? '',
      totalQuantity: json['totalQuantity'] ?? 0,
      name: json['name'] ?? '',
      rating: (json['rating'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      imageUrls: json['imageUrls'] ?? '',
      sold: json['sold'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopproductID': shopproductID,
      'shopId': shopId,
      'productID': productID,
      'totalQuantity': totalQuantity,
      'totalPrice': totalPrice,
      'name': name,
      'rating': rating,
      'imageUrls': imageUrls,
      'sold': sold,
      'description': description,
    };
  }
}