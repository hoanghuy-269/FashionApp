import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/cart_model.dart';
import 'package:fashion_app/data/models/order_item_model.dart';
import 'package:fashion_app/data/models/order_model.dart';
import 'package:fashion_app/data/models/order_request.dart';
import 'package:fashion_app/data/repositories/order_request_repository.dart';
import 'package:fashion_app/viewmodels/order_viewmodel.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OrderViewModel _orderViewModel = OrderViewModel();
  final OrderRequestRepository _orderRequestRepo = OrderRequestRepository();

  Future<bool> confirmOrderAndCreate(String requestId) async {
    try {
      // Lấy order request
      final requestDoc =
          await _firestore.collection('order_requests').doc(requestId).get();

      if (!requestDoc.exists) {
        return false;
      }

      final requestData = requestDoc.data()!;
      final orderRequest = OrderRequest.fromMap(requestData);

      // Tạo đơn hàng thật
      final orderId =
          'ORD_${DateTime.now().millisecondsSinceEpoch}_${orderRequest.userId.substring(0, 6)}';

      final orderItems =
          orderRequest.items.map((cartItem) {
            return OrderItem(
              orderItemId:
                  'ITEM_${DateTime.now().millisecondsSinceEpoch}${cartItem.productId.substring(0, 6)}',
              productId: cartItem.productId,
              productName: cartItem.productName,
              variantId: cartItem.variantId ?? '',
              shopId: cartItem.shopId,
              colorId: cartItem.colorId ?? '',
              sizeId: cartItem.sizeId,
              price: cartItem.price,
              quantity: cartItem.quantity,
              totalPrice: cartItem.price * cartItem.quantity,
              itemStatus: 'status_001',
              voucherId: orderRequest.voucherCode ?? '',
              imageUrl: cartItem.imageUrl,
              cartId: cartItem.cartItemId,
              shopProductId: cartItem.shopProductId,
            );
          }).toList();

      // Tạo formatted address
      final formattedAddress =
          '${orderRequest.address.detail}, '
          '${orderRequest.address.ward}, '
          '${orderRequest.address.district}, '
          '${orderRequest.address.province}';

      final order = FashionOrder(
        orderId: orderId,
        userId: orderRequest.userId,
        customerPhone: orderRequest.address.phone,
        customerAddress: formattedAddress,
        itemsTotal: orderRequest.totalAmount,
        shippingFee: 0.0,
        discount: orderRequest.discountAmount,
        finalTotal: orderRequest.finalAmount,
        paymentMethodId: orderRequest.paymentMethodId,
        orderStatus: 'status_001',
        createdAt: DateTime.now(),
        items: orderItems,
      );

      // Tạo đơn hàng
      final success = await _orderViewModel.createOrder(order);

      if (success) {
        // CẬP NHẬT SỐ LƯỢNG VÀ SOLD
        await _updateProductQuantitiesAndSold(orderRequest.items);

        // Cập nhật trạng thái order request
        await _orderRequestRepo.confirmOrderRequest(requestId);

        return true;
      }

      return false;
    } catch (e) {
      print('❌ Lỗi xác nhận đơn hàng: $e');
      return false;
    }
  }

  Future<void> _updateProductQuantitiesAndSold(List<CartItem> items) async {
    for (var item in items) {
      try {
        final shopProductId = item.productId;

        // Cập nhật số lượng trong product_sizes
        await _updateSizeQuantity(
          shopProductId,
          item.variantId!,
          item.sizeId,
          item.quantity,
        );

        // Cập nhật sold trong shop_product
        await _updateShopProductSold(shopProductId, item.quantity);

        print('✅ Đã cập nhật thành công cho sản phẩm: ${item.productName}');
      } catch (e) {
        print('❌ Lỗi khi cập nhật item ${item.productId}: $e');
        throw e;
      }
    }
  }

  Future<void> _updateSizeQuantity(
    String shopProductId,
    String variantId,
    String sizeId,
    int quantity,
  ) async {
    final sizeRef = _firestore
        .collection('shop_products')
        .doc(shopProductId)
        .collection('shop_product_variants')
        .doc(variantId)
        .collection('product_sizes')
        .doc(sizeId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(sizeRef);

      if (!snapshot.exists) {
        throw Exception('Không tìm thấy size document');
      }

      final sizeData = snapshot.data() as Map<String, dynamic>;
      final currentQuantity = sizeData['quantity'] ?? 0;

      if (currentQuantity < quantity) {
        throw Exception('Số lượng sản phẩm không đủ');
      }

      final newQuantity = currentQuantity - quantity;
      transaction.update(sizeRef, {'quantity': newQuantity});
    });
  }

  Future<void> _updateShopProductSold(
    String shopProductId,
    int quantity,
  ) async {
    final shopProductRef = _firestore
        .collection('shop_products')
        .doc(shopProductId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(shopProductRef);

      if (!snapshot.exists) {
        throw Exception('Không tìm thấy shop_product');
      }

      final shopProductData = snapshot.data() as Map<String, dynamic>;
      final currentSold = shopProductData['sold'] ?? 0;
      final currentTotalQuantity = shopProductData['totalQuantity'] ?? 0;

      final newSold = currentSold + quantity;
      final newTotalQuantity = currentTotalQuantity + quantity;

      transaction.update(shopProductRef, {
        'sold': newSold,
        'totalQuantity': newTotalQuantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<String?> _findShopProductId(String productId, String shopId) async {
    try {
      final shopProductsSnapshot =
          await _firestore
              .collection('shop_products')
              .where('productID', isEqualTo: productId)
              .where('shopId', isEqualTo: shopId)
              .limit(1)
              .get();

      if (shopProductsSnapshot.docs.isNotEmpty) {
        return shopProductsSnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      print('❌ Lỗi khi tìm shopProductId: $e');
      return null;
    }
  }
}
