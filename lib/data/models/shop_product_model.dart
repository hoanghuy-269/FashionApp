class ShopProductModel {
  final String shopproductID; 
  final String shopId;               
  final String productID;     
  final int totalQuantity;                
  final int? rating;  // đánh giá                        
  final int? sold;  // đã bán                   

  ShopProductModel({
    required this.shopproductID,
    required this.shopId,
    required this.productID,
    required this.totalQuantity,
    this.rating,
    this.sold,
  });

  factory ShopProductModel.fromMap(Map<String, dynamic> json, String id) {
    return ShopProductModel(
      shopproductID: id,
      shopId: json['shopId'] ?? '',
      productID: json['productID'] ?? '',
      totalQuantity: json['totalQuantity'] ?? 0,
      rating: json['rating'],
      sold: json['sold'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopproductID': shopproductID,
      'shopId': shopId,
      'productID': productID,
      'totalQuantity': totalQuantity,
      'rating': rating,
      'sold': sold,
    };
  }
}
