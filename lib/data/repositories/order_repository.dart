import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/order_item_model.dart';
import 'package:fashion_app/data/models/order_model.dart';
import 'package:fashion_app/data/sources/order_source.dart';

class OrderRepository {
  final OrderSource _source;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  OrderRepository(this._source);

  Future<String> createOrder(FashionOrder order) => _source.createOrder(order);

  Stream<List<FashionOrder>> getUserOrders(String userId) =>
      _source.getOrdersByUser(userId);

  Stream<List<FashionOrder>> getShopOrders(String shopId) =>
      _source.getOrdersByShop(shopId);

  Future<FashionOrder?> getOrderDetail(String orderId) =>
      _source.getOrderDetail(orderId);

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? cancellationReason,
  }) => _source.updateOrderStatus(
    orderId: orderId,
    newStatus: newStatus,
    cancellationReason: cancellationReason,
  );

  Future<void> updateOrderItemStatus({
    required String orderItemId,
    required String newStatus,
  }) => _source.updateOrderItemStatus(
    orderItemId: orderItemId,
    newStatus: newStatus,
  );


  

  Future<void> assignShipper({
    required String orderId,
    required String shipperId,
  }) => _source.assignShipper(orderId: orderId, shipperId: shipperId);

  Future<Map<String, dynamic>> getOrderStats(String userId) =>
      _source.getOrderStats(userId);

  Stream<List<FashionOrder>> getOrdersByUserId(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          // Dùng Future.wait để load items cho tất cả orders song song
          final orders = await Future.wait(
            snapshot.docs.map(
              (doc) => FashionOrder.fromFirestoreWithItems2(doc),
            ),
          );
          return orders;
        });
  }

  Stream<List<FashionOrder>> getOrdersByStatus(String userId, String statusId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('orderStatus', isEqualTo: statusId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          // Dùng Future.wait để load items cho tất cả orders song song
          final orders = await Future.wait(
            snapshot.docs.map(
              (doc) => FashionOrder.fromFirestoreWithItems2(doc),
            ),
          );
          return orders;
        });
  }

  Future<FashionOrder?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();

      if (doc.exists) {
        return await FashionOrder.fromFirestoreWithItems2(doc);
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  // Có thể xóa hàm này vì không cần dùng nữa
  Future<Map<String, List<OrderItem>>> getAllItemsOfUser(String userId) async {
    try {
      final snap =
          await _firestore
              .collectionGroup('order_items')
              .where('userId', isEqualTo: userId)
              .get();

      final map = <String, List<OrderItem>>{};

      for (final doc in snap.docs) {
        final orderId = doc['orderId'] as String? ?? '';
        if (orderId.isNotEmpty) {
          map.putIfAbsent(orderId, () => []);
          map[orderId]!.add(OrderItem.fromFirestore(doc));
        }
      }

      return map;
    } catch (e) {
      print('Error getting all items of user: $e');
      return {};
    }
  }

  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      final batch = _firestore.batch();
      final timestamp = FieldValue.serverTimestamp();

      // 1. Lấy thông tin order và order_items
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) {
        throw Exception('Order không tồn tại');
      }

      final orderItemsSnapshot =
          await _firestore
              .collection('orders')
              .doc(orderId)
              .collection('order_items')
              .get();


      // 2. Cập nhật order chính
      final orderRef = _firestore.collection('orders').doc(orderId);
      batch.update(orderRef, {
        'orderStatus': 'status_005',
        'cancellationReason': reason,
        'cancelledAt': timestamp,
        'updatedAt': timestamp,
      });

      // 3. Cập nhật order_items và số lượng sản phẩm trong shop_products
      for (final doc in orderItemsSnapshot.docs) {
        final itemData = doc.data();
        final productId = itemData['productId'];
        final quantity = itemData['quantity'] ?? 1;
        final sizeId = itemData['sizeId'];
        final variantId = itemData['variantId'];


        // Cập nhật trạng thái order_item
        final itemRef = _firestore
            .collection('orders')
            .doc(orderId)
            .collection('order_items')
            .doc(doc.id);
        batch.update(itemRef, {
          'itemStatus': 'status_005',
          'cancellationReason': reason,
          'cancelledAt': timestamp,
          'updatedAt': timestamp,
        });

        // Cập nhật số lượng sản phẩm trong shop_products
        if (productId != null && sizeId != null && variantId != null) {
          await _updateShopProductQuantity(
            productId,
            variantId,
            sizeId,
            quantity,
            batch,
          );
        }
      }

      await batch.commit();
      print('✅ Đã hủy order $orderId và cập nhật số lượng sản phẩm');
      return true;
    } catch (e) {
      print('❌ Lỗi khi hủy đơn hàng $orderId: $e');
      throw Exception('Lỗi khi hủy đơn hàng: $e');
    }
  }

  // Hàm cập nhật số lượng trong shop_products
  Future<void> _updateShopProductQuantity(
    String shopProductId,
    String variantId,
    String sizeId,
    int quantity,
    WriteBatch batch,
  ) async {
    try {
      // Cập nhật số lượng trong product_sizes
      await _updateProductSizeQuantity(
        shopProductId,
        variantId,
        sizeId,
        quantity,
        batch,
      );

      // Cập nhật sold và totalQuantity trong shop_product
      await _updateShopProductSoldAndTotal(shopProductId, quantity, batch);
    } catch (e) {
      throw e;
    }
  }

  // Hàm cập nhật số lượng trong product_sizes
  Future<void> _updateProductSizeQuantity(
    String shopProductId,
    String variantId,
    String sizeId,
    int quantity,
    WriteBatch batch,
  ) async {
    try {
      final sizeRef = _firestore
          .collection('shop_products')
          .doc(shopProductId)
          .collection('shop_product_variants')
          .doc(variantId)
          .collection('product_sizes')
          .doc(sizeId);

  
      // Sử dụng transaction để đảm bảo tính nhất quán
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(sizeRef);

        if (!snapshot.exists) {
          throw Exception('Không tìm thấy size document cho sizeId: $sizeId');
        }

        final sizeData = snapshot.data() as Map<String, dynamic>;
        final currentQuantity = sizeData['quantity'] ?? 0;

     

        final newQuantity = currentQuantity + quantity;
        transaction.update(sizeRef, {
          'quantity': newQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });

      });
    } catch (e) {
      throw e;
    }
  }

  // Hàm cập nhật sold và totalQuantity trong shop_product
  Future<void> _updateShopProductSoldAndTotal(
    String shopProductId,
    int quantity,
    WriteBatch batch,
  ) async {
    try {
      final shopProductRef = _firestore
          .collection('shop_products')
          .doc(shopProductId);


      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(shopProductRef);

        if (!snapshot.exists) {
          throw Exception('Không tìm thấy shop_product: $shopProductId');
        }

        final shopProductData = snapshot.data() as Map<String, dynamic>;
        final currentSold = shopProductData['sold'] ?? 0;
        final currentTotalQuantity = shopProductData['totalQuantity'] ?? 0;

        // Khi hủy đơn: GIẢM sold và TĂNG totalQuantity
        final newSold = currentSold - quantity;
        final newTotalQuantity = currentTotalQuantity + quantity;

        // Đảm bảo không bị số âm
        if (newSold < 0) {
          throw Exception('Số lượng sold không thể âm: $newSold');
        }

        transaction.update(shopProductRef, {
          'sold': newSold,
          'totalQuantity': newTotalQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });

     
      });
    } catch (e) {
      print(' Lỗi khi cập nhật sold và totalQuantity: $e');
      throw e;
    }
  }

  // Hoặc phiên bản đơn giản hơn sử dụng batch (nếu không cần transaction)
  Future<void> _updateShopProductQuantitySimple(
    String shopProductId,
    String variantId,
    String sizeId,
    int quantity,
    WriteBatch batch,
  ) async {
    try {
      // 1. Cập nhật số lượng trong product_sizes
      final sizeRef = _firestore
          .collection('shop_products')
          .doc(shopProductId)
          .collection('shop_product_variants')
          .doc(variantId)
          .collection('product_sizes')
          .doc(sizeId);

      batch.update(sizeRef, {
        'quantity': FieldValue.increment(quantity),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Cập nhật sold và totalQuantity trong shop_product
      final shopProductRef = _firestore
          .collection('shop_products')
          .doc(shopProductId);

      batch.update(shopProductRef, {
        'sold': FieldValue.increment(-quantity),
        'totalQuantity': FieldValue.increment(quantity),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print(
        ' Đã thêm batch update cho shop_product $shopProductId: +$quantity quantity, -$quantity sold',
      );
    } catch (e) {
      print(' Lỗi khi thêm batch update: $e');
      throw e;
    }
  }
}
