class ProductSizeModel {
  final String sizeID;
  final int quantity;
  final double price; // giá bán
  final double costPrice; // giá vốn
  ProductSizeModel({
    required this.sizeID,
    required this.quantity,
    required this.price,
    required this.costPrice,
  });
  factory ProductSizeModel.fromMap(Map<String, dynamic> map) {
    return ProductSizeModel(
      sizeID: map['sizeID'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      costPrice: (map['costPrice'] ?? 0).toDouble(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'sizeID': sizeID,
      'quantity': quantity,
      'price': price,
      'costPrice': costPrice,
    };
  }
}
