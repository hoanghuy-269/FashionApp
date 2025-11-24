import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String orderItemId;
  final String productId;
  final String productName;
  final String variantId;
  final String shopId;
  final String colorId;
  final String sizeId;
  final double price;
  final int quantity;
  final double totalPrice;
  final String itemStatus;
  final String voucherId;
  final String imageUrl;
  final String? cartId;

  OrderItem({
    required this.orderItemId,
    required this.productId,
    required this.productName,
    required this.variantId,
    required this.shopId,
    required this.colorId,
    required this.sizeId,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.itemStatus,
    required this.voucherId,
    required this.imageUrl,
    this.cartId,
  });

  factory OrderItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderItem(
      orderItemId: data['orderItemId'] ?? doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      variantId: data['variantId'] ?? '',
      shopId: data['shopId'] ?? '',
      colorId: data['colorId'] ?? '',
      sizeId: data['sizeId'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: data['quantity'] as int? ?? 0,
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      itemStatus: data['itemStatus'] ?? '',
      voucherId: data['voucherId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      cartId: data['cartId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderItemId': orderItemId,
      'productId': productId,
      'productName': productName,
      'variantId': variantId,
      'shopId': shopId,
      'colorId': colorId,
      'sizeId': sizeId,
      'price': price,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'itemStatus': itemStatus,
      'voucherId': voucherId,
      'imageUrl': imageUrl,
      'cartId': cartId,
      'createdAt': Timestamp.now(),
    };
  }
}
