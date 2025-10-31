class ShopProductsdetalModel {
  final String productID;
  final String shopId;
  final int quantity;
  final double price;
  final int rating;
  final int sold;

  ShopProductsdetalModel({
    required this.productID,
    required this.shopId,
    required this.quantity,
    required this.price,
    required this.rating,
    required this.sold,
  });

  factory ShopProductsdetalModel.fromtoMap(Map<String, dynamic> map) {
    return ShopProductsdetalModel(
      productID: map['productID'],
      shopId: map['shopId'],
      quantity: map['quantity'],
      price: (map['price'] ?? 0).toDouble(),
      rating: map['rating'],
      sold: map['sold'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'productID': productID,
      'shopId': shopId,
      'quantity': quantity,
      'price': price,
      'rating': rating,
      'sold': sold,
    };
  }
}
