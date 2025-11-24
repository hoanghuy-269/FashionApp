import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/order_item_model.dart';
import 'package:fashion_app/data/models/order_model.dart'; // Không cần hide nữa

class OrderSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrder(FashionOrder order) async {
    try {
      final batch = _firestore.batch();

      // 1. Tạo document chính trong orders collection
      final orderRef = _firestore.collection('orders').doc(order.orderId);
      batch.set(orderRef, order.toMap());

      // 2. Tạo các order items trong subcollection
      for (final item in order.items) {
        final itemRef = _firestore
            .collection('orders')
            .doc(order.orderId)
            .collection('order_items')
            .doc(item.orderItemId);
        batch.set(itemRef, item.toMap());
      }

      await batch.commit();

      await removeCartItemsAfterOrder(order.items, order.userId);
      return order.orderId;
    } catch (e) {
      print(' Lỗi tạo đơn hàng: $e');
      rethrow;
    }
  }

  // Thêm vào OrderRepository hoặc CartRepository
  Future<void> removeCartItemsAfterOrder(
    List<OrderItem> orderItems,
    String userId,
  ) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final item in orderItems) {
        if (item.cartId != null && item.cartId!.isNotEmpty) {
          final cartItemRef = FirebaseFirestore.instance
              .collection('carts')
              .doc(userId)
              .collection('cart_items')
              .doc(item.cartId!);

          batch.delete(cartItemRef);
        }
      }

      await batch.commit();
      print(
        '✅ Đã xóa ${orderItems.where((item) => item.cartId != null).length} items khỏi giỏ hàng',
      );
    } catch (e) {
      print('❌ Lỗi xóa cart items: $e');
      // Không rethrow để không ảnh hưởng đến order
    }
  }

  Stream<List<FashionOrder>> getOrdersByUser(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final orders = <FashionOrder>[];

          for (final doc in snapshot.docs) {
            try {
              final order = await FashionOrder.fromFirestoreWithItems(doc);
              orders.add(order);
            } catch (e) {
              print('❌ Lỗi load order ${doc.id}: $e');
            }
          }

          return orders;
        });
  }

  // ==========================
  // 📥 LẤY ĐƠN HÀNG THEO SHOP
  // ==========================

  Stream<List<FashionOrder>> getOrdersByShop(String shopId) {
    return _firestore
        .collection('order_items')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .asyncMap((snapshot) async {
          final orderIds =
              snapshot.docs.map((doc) => doc['orderId'] as String).toSet();
          final orders = <FashionOrder>[];

          for (final orderId in orderIds) {
            try {
              final orderDoc =
                  await _firestore.collection('orders').doc(orderId).get();
              if (orderDoc.exists) {
                final order = await FashionOrder.fromFirestoreWithItems(
                  orderDoc,
                );
                // Filter items chỉ của shop này
                final shopItems =
                    order.items.where((item) => item.shopId == shopId).toList();
                orders.add(order.copyWith(items: shopItems));
              }
            } catch (e) {
              print('❌ Lỗi load order $orderId: $e');
            }
          }

          // Sort by createdAt descending
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  // ==========================
  // 🔍 LẤY CHI TIẾT ĐƠN HÀNG
  // ==========================

  Future<FashionOrder?> getOrderDetail(String orderId) async {
    try {
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) return null;

      return await FashionOrder.fromFirestoreWithItems(orderDoc);
    } catch (e) {
      print('❌ Lỗi lấy chi tiết đơn hàng: $e');
      return null;
    }
  }

  // ==========================
  // ✏️ CẬP NHẬT TRẠNG THÁI ĐƠN HÀNG
  // ==========================

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? cancellationReason,
  }) async {
    try {
      final updateData = {
        'orderStatus': newStatus,
        'updatedAt': Timestamp.now(),
      };

      if (cancellationReason != null) {
        updateData['cancellationReason'] = cancellationReason;
      }

      await _firestore.collection('orders').doc(orderId).update(updateData);
      print('✅ Đã cập nhật trạng thái đơn hàng $orderId → $newStatus');
    } catch (e) {
      print('❌ Lỗi cập nhật trạng thái đơn hàng: $e');
      rethrow;
    }
  }

  // ==========================
  // ✏️ CẬP NHẬT TRẠNG THÁI ORDER ITEM
  // ==========================

  Future<void> updateOrderItemStatus({
    required String orderItemId,
    required String newStatus,
  }) async {
    try {
      await _firestore.collection('order_items').doc(orderItemId).update({
        'itemStatus': newStatus,
      });
      print('✅ Đã cập nhật trạng thái item $orderItemId → $newStatus');
    } catch (e) {
      print('❌ Lỗi cập nhật trạng thái item: $e');
      rethrow;
    }
  }

  // ==========================
  // 🚚 GÁN SHIPPER CHO ĐƠN HÀNG
  // ==========================

  Future<void> assignShipper({
    required String orderId,
    required String shipperId,
  }) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'shipperId': shipperId,
        'updatedAt': Timestamp.now(),
      });
      print('✅ Đã gán shipper $shipperId cho đơn hàng $orderId');
    } catch (e) {
      print('❌ Lỗi gán shipper: $e');
      rethrow;
    }
  }

  // ==========================
  // 📊 THỐNG KÊ ĐƠN HÀNG
  // ==========================

  Future<Map<String, dynamic>> getOrderStats(String userId) async {
    try {
      final ordersSnap =
          await _firestore
              .collection('orders')
              .where('userId', isEqualTo: userId)
              .get();

      int totalOrders = ordersSnap.docs.length;
      int pendingCount = 0;
      int confirmedCount = 0;
      int shippingCount = 0;
      int deliveredCount = 0;
      int cancelledCount = 0;
      double totalSpent = 0;

      for (final doc in ordersSnap.docs) {
        final data = doc.data();
        final status = data['orderStatus'] as String? ?? '';
        final total = (data['finalTotal'] as num?)?.toDouble() ?? 0;

        switch (status) {
          case 'pending':
            pendingCount++;
            break;
          case 'confirmed':
            confirmedCount++;
            break;
          case 'shipping':
            shippingCount++;
            break;
          case 'delivered':
            deliveredCount++;
            totalSpent += total;
            break;
          case 'cancelled':
            cancelledCount++;
            break;
        }
      }

      return {
        'totalOrders': totalOrders,
        'pending': pendingCount,
        'confirmed': confirmedCount,
        'shipping': shippingCount,
        'delivered': deliveredCount,
        'cancelled': cancelledCount,
        'totalSpent': totalSpent,
      };
    } catch (e) {
      print('❌ Lỗi thống kê đơn hàng: $e');
      return {};
    }
  }
}
