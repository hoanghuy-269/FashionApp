import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item_model.dart';

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

  static Future<FashionOrder> fromFirestoreWithItems2(
    DocumentSnapshot doc,
  ) async {
    // First, create basic order from document
    final order = FashionOrder.fromFirestore(doc);

    try {
      // Lấy items từ subcollection 'order_items'
      final orderItemsSnap =
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(
                order.orderId,
              ) // Sử dụng orderId để truy cập subcollection
              .collection('order_items')
              .get();

      final items =
          orderItemsSnap.docs.map((itemDoc) {
            return OrderItem.fromFirestore(itemDoc);
          }).toList();

      return order.copyWith(items: items);
    } catch (e) {
      print(' Lỗi lấy order items: $e');
      return order; // Trả về order không có items nếu có lỗi
    }
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

  String getCalculatedStatus() {
    if (items.isEmpty) return 'status_001';

    final allStatuses = items.map((item) => item.itemStatus).toSet();

    // Nếu có item bị hủy
    if (allStatuses.contains('status_006')) {
      return 'status_006';
    }

    // Nếu có item hoàn thành hết
    if (allStatuses.every((status) => status == 'status_005')) {
      return 'status_005';
    }

    // Nếu có item đang giao hàng
    if (allStatuses.any((status) => status == 'status_004')) {
      return 'status_004';
    }

    // Nếu có item đang xử lý
    if (allStatuses.any((status) => status == 'status_003')) {
      return 'status_003';
    }

    // Nếu có item đã xác nhận
    if (allStatuses.any((status) => status == 'status_002')) {
      // Nếu tất cả đều đã xác nhận -> status_002, ngược lại status_001
      return allStatuses.every((status) => status == 'status_002')
          ? 'status_002'
          : 'status_001';
    }

    // Mặc định là đang chờ
    return 'status_001';
  }

  // Helper method để kiểm tra xem có nên hiển thị trạng thái tính toán không
  bool get shouldUseCalculatedStatus {
    // Chỉ tính toán khi có nhiều hơn 1 item
    return items.length > 1;
  }
}
