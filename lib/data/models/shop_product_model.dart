class ShopProductModel {
  final String shopproductID; 
  final String shopId;
  final String name;
  final String productID;     
  final int totalQuantity;
  final String imageUrls;
  final int? rating;  // đánh giá                        
  final int? sold;  // đã bán  
  final String description;    
  final double? totalPrice;  // thêm trường giá

  ShopProductModel({
    required this.shopproductID,
    required this.shopId,
    required this.productID,
    required this.totalQuantity,
    required this.name,
    this.rating,
    required this.imageUrls,
    this.sold,
    required this.description,
    this.totalPrice,
  });

  factory ShopProductModel.fromMap(Map<String, dynamic> json, String id) {
    return ShopProductModel(
      shopproductID: id,
      shopId: json['shopId'] ?? '',
      productID: json['productID'] ?? '',
      totalQuantity: json['totalQuantity'] ?? 0,
      name: json['name'] ?? '',
      rating: json['rating'],
      imageUrls: json['imageUrls'] ?? '',
      sold: json['sold'],
      description: json['description'] ?? '',
      totalPrice: (json['totalPrice'] != null) ? (json['totalPrice'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopproductID': shopproductID,
      'shopId': shopId,
      'productID': productID,
      'totalQuantity': totalQuantity,
      'name': name,
      'rating': rating,
      'imageUrls': imageUrls,
      'sold': sold,
      'description': description,
      'totalPrice': totalPrice,
    };
  }
}
