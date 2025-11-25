import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String cartItemId;
  final String productId;
  final String shopProductId; 
  final String productName;
  final String variantId;
  final String shopId;
  final String colorId;
  final String sizeId;
  final double price;
  final int quantity;
  final String imageUrl;
  final String userId;
  final DateTime addedAt;

  CartItem({
    required this.cartItemId,
    required this.productId,
    required this.shopProductId, 
    required this.productName,
    required this.variantId,
    required this.shopId,
    required this.colorId,
    required this.sizeId,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.userId,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'cartItemId': cartItemId,
      'productId': productId,
      'shopProductId': shopProductId, 
      'productName': productName,
      'variantId': variantId,
      'shopId': shopId,
      'colorId': colorId,
      'sizeId': sizeId,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'userId': userId,
      'addedAt': Timestamp.fromDate(addedAt),
      'updatedAt': Timestamp.now(),
    };
  }

  // Phương thức từ Map (cho cấu trúc mới)
  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      cartItemId: data['cartItemId'] ?? '',
      productId: data['productId'] ?? '',
      shopProductId: data['shopProductId'] ?? '', 
      productName: data['productName'] ?? '',
      variantId: data['variantId'] ?? '',
      shopId: data['shopId'] ?? '',
      colorId: data['colorId'] ?? '',
      sizeId: data['sizeId'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: data['quantity'] as int? ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      userId: data['userId'] ?? '',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem.fromMap(data);
  }

  String get uniqueKey => '$productId-$variantId-$sizeId';

  CartItem copyWith({
    String? cartItemId,
    String? productId,
    String? shopProductId,
    String? productName,
    String? variantId,
    String? shopId,
    String? colorId,
    String? sizeId,
    double? price,
    int? quantity,
    String? imageUrl,
    String? userId,
    DateTime? addedAt,
  }) {
    return CartItem(
      cartItemId: cartItemId ?? this.cartItemId,
      productId: productId ?? this.productId,
      shopProductId: shopProductId ?? this.shopProductId,
      productName: productName ?? this.productName,
      variantId: variantId ?? this.variantId,
      shopId: shopId ?? this.shopId,
      colorId: colorId ?? this.colorId,
      sizeId: sizeId ?? this.sizeId,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
