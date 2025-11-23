import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item_model.dart';

// Đổi tên class thành FashionOrder hoặc đặt alias
class FashionOrder {
  final String orderId;
  final String userId;
  final String customerPhone;
  final String customerAddress;
  final double itemsTotal;
  final double shippingFee;
  final double discount;
  final double finalTotal;
  final String paymentMethodId;
  final String orderStatus;
  final DateTime createdAt;
  final List<OrderItem> items;

  final String? shipperId;
  final String? cancellationReason;
  final String? deliveryProofUrl;

  FashionOrder({
    required this.orderId,
    required this.userId,
    required this.customerPhone,
    required this.customerAddress,
    required this.itemsTotal,
    required this.shippingFee,
    required this.discount,
    required this.finalTotal,
    required this.paymentMethodId,
    required this.orderStatus,
    required this.createdAt,
    required this.items,
    this.shipperId,
    this.cancellationReason,
    this.deliveryProofUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'itemsTotal': itemsTotal,
      'shippingFee': shippingFee,
      'discount': discount,
      'finalTotal': finalTotal,
      'paymentMethodId': paymentMethodId,
      'orderStatus': orderStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.now(),
      'shipperId': shipperId,
      'cancellationReason': cancellationReason,
      'deliveryProofUrl': deliveryProofUrl,
    };
  }

  /// Factory thông thường không load items
  factory FashionOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FashionOrder(
      orderId: data['orderId'] ?? doc.id,
      userId: data['userId'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      customerAddress: data['customerAddress'] ?? '',
      itemsTotal: (data['itemsTotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (data['shippingFee'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      finalTotal: (data['finalTotal'] as num?)?.toDouble() ?? 0.0,
      paymentMethodId: data['paymentMethodId'] ?? '',
      orderStatus: data['orderStatus'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: [],
      shipperId: data['shipperId'],
      cancellationReason: data['cancellationReason'],
      deliveryProofUrl: data['deliveryProofUrl'],
    );
  }

  /// Factory mới: load cả items từ Firestore
  static Future<FashionOrder> fromFirestoreWithItems(
    DocumentSnapshot doc,
  ) async {
    final order = FashionOrder.fromFirestore(doc);

    final orderItemsSnap =
        await FirebaseFirestore.instance
            .collection('order_items')
            .where('orderId', isEqualTo: order.orderId)
            .get();

    final items =
        orderItemsSnap.docs.map((d) => OrderItem.fromFirestore(d)).toList();

    return order.copyWith(items: items);
  }

  // Copy with method
  FashionOrder copyWith({
    String? orderId,
    String? userId,
    String? customerPhone,
    String? customerAddress,
    double? itemsTotal,
    double? shippingFee,
    double? discount,
    double? finalTotal,
    String? paymentMethodId,
    String? orderStatus,
    DateTime? createdAt,
    List<OrderItem>? items,
    String? shipperId,
    String? cancellationReason,
    String? deliveryProofUrl,
  }) {
    return FashionOrder(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      itemsTotal: itemsTotal ?? this.itemsTotal,
      shippingFee: shippingFee ?? this.shippingFee,
      discount: discount ?? this.discount,
      finalTotal: finalTotal ?? this.finalTotal,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      orderStatus: orderStatus ?? this.orderStatus,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      shipperId: shipperId ?? this.shipperId,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      deliveryProofUrl: deliveryProofUrl ?? this.deliveryProofUrl,
    );
  }
}
