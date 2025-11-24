import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/cart_model.dart';

class CartSource extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ID người dùng hiện tại (SET bên ngoài)
  String? _currentUserId;

  void setUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  Stream<List<CartItem>> getCartByUser(String userId) {
    return _firestore
        .collection('carts')
        .doc(userId)
        .collection('cart_items')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => CartItem.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addOrUpdateCartItem(CartItem item) async {
    print("🟢 addOrUpdateCartItem: ${item.productName}");

    try {
      final userCart = _firestore
          .collection('carts')
          .doc(item.userId)
          .collection('cart_items');

      final query =
          await userCart
              .where('productId', isEqualTo: item.productId)
              .where('variantId', isEqualTo: item.variantId)
              .where('sizeId', isEqualTo: item.sizeId)
              .limit(1)
              .get();

      print("🔍 Query found: ${query.docs.length} items");

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final currentQty = doc['quantity'] ?? 0;
        final newQty = currentQty + item.quantity;

        await doc.reference.update({
          'quantity': newQty,
          'updatedAt': Timestamp.now(),
        });

        print("✅ Cập nhật số lượng: $currentQty + ${item.quantity} = $newQty");
      } else {
        await userCart.doc(item.cartItemId).set(item.toMap());
        print("🆕 Thêm sản phẩm mới vào giỏ");
      }

      notifyListeners();
    } catch (e) {
      print("❌ Lỗi addOrUpdateCartItem: $e");
      rethrow;
    }
  }

  Future<void> updateCartItemQuantity(
    String userId,
    String cartItemId,
    int quantity,
  ) async {
    try {
      final ref = _firestore
          .collection('carts')
          .doc(userId)
          .collection('cart_items')
          .doc(cartItemId);

      await ref.update({'quantity': quantity, 'updatedAt': Timestamp.now()});

      print("🔄 Đã cập nhật số lượng item $cartItemId → $quantity");

      notifyListeners();
    } catch (e) {
      print("❌ Lỗi updateCartItemQuantity: $e");
    }
  }

  Future<void> deleteCartItem(String userId, String cartItemId) async {
    try {
      await _firestore
          .collection('carts')
          .doc(userId)
          .collection('cart_items')
          .doc(cartItemId)
          .delete();

      print("🗑️ Đã xoá item $cartItemId");

      notifyListeners();
    } catch (e) {
      print("❌ Lỗi deleteCartItem: $e");
    }
  }

  Future<void> clearCartByUser(String userId) async {
    try {
      final cartRef = _firestore
          .collection('carts')
          .doc(userId)
          .collection('cart_items');

      final items = await cartRef.get();

      for (var doc in items.docs) {
        await doc.reference.delete();
      }

      print("🧹 Đã xoá toàn bộ giỏ hàng của $userId");

      notifyListeners();
    } catch (e) {
      print("❌ Lỗi clearCartByUser: $e");
    }
  }

  // LẤY TỔNG SỐ LƯỢNG ITEM TRONG GIỎ
  Stream<int> getCartItemCount(String userId) {
    return _firestore
        .collection('carts')
        .doc(userId)
        .collection('cart_items')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }
}
