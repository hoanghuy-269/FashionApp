import 'package:flutter/material.dart';
import 'package:fashion_app/data/models/cart_model.dart';
import 'package:fashion_app/data/sources/cart_source.dart';

class CartViewModel extends ChangeNotifier {
  final CartSource _cartSource = CartSource();
  final String userId;

  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // Tổng số lượng sản phẩm (tính tổng quantity của tất cả items)
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // Tổng số loại sản phẩm (số document trong cart)
  int get uniqueItemCount => _items.length;

  CartViewModel({required this.userId}) {
    _cartSource.setUser(userId);
    _listenCartItems();
  }

  void _listenCartItems() {
    _cartSource.getCartByUser(userId).listen((cartItems) {
      _items = cartItems;
      notifyListeners();
    });
  }

  Future<void> addOrUpdateItem(CartItem item) async {
    try {
      await _cartSource.addOrUpdateCartItem(item);
    } catch (e) {
      debugPrint("❌ Error addOrUpdateItem: $e");
    }
  }

  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      await _cartSource.updateCartItemQuantity(userId, cartItemId, quantity);
    } catch (e) {
      debugPrint("❌ Error updateQuantity: $e");
    }
  }

  Future<void> deleteItem(String cartItemId) async {
    try {
      await _cartSource.deleteCartItem(userId, cartItemId);
    } catch (e) {
      debugPrint("❌ Error deleteItem: $e");
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartSource.clearCartByUser(userId);
    } catch (e) {
      debugPrint("❌ Error clearCart: $e");
    }
  }
}
