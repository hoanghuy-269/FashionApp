import 'package:fashion_app/data/models/cart_model.dart';
import 'package:fashion_app/data/sources/cart_source.dart';

class CartRepository {
  final CartSource _source;

  CartRepository(this._source);

  /// Lấy giỏ hàng theo user
  Stream<List<CartItem>> getCart(String userId) {
    return _source.getCartByUser(userId);
  }

  /// Thêm item mới (nếu chưa tồn tại)
  Future<void> addCart(CartItem item) async {
    // KHÔNG KHÔNG KHÔNG dùng addCartItem nữa (vì nó thêm document thẳng)
    // Chỉ giữ lại nếu bạn thực sự cần thêm item mà không kiểm tra tồn tại.
    // Nếu muốn an toàn → LUÔN dùng addOrUpdateItem
    await _source.addOrUpdateCartItem(item);
  }

  /// Thêm hoặc cập nhật item (chuẩn nhất)
  Future<void> addOrUpdateItem(CartItem item) async {
    await _source.addOrUpdateCartItem(item);
  }

  /// Cập nhật số lượng → cần userId + cartItemId
  Future<void> updateQuantity({
    required String userId,
    required String cartItemId,
    required int quantity,
  }) async {
    await _source.updateCartItemQuantity(userId, cartItemId, quantity);
  }

  /// Xoá 1 sản phẩm trong giỏ → cần userId + cartItemId
  Future<void> deleteCart({
    required String userId,
    required String cartItemId,
  }) async {
    await _source.deleteCartItem(userId, cartItemId);
  }

  /// Xoá toàn bộ giỏ của 1 user
  Future<void> clearCart(String userId) async {
    await _source.clearCartByUser(userId);
  }
}
