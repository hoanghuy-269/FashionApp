import 'package:cloud_firestore/cloud_firestore.dart';

class ShopProductVariantSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addShopProductVariant({
    required String shopProductID,
    required Map<String, dynamic> variantData,
  }) async {
    try {
      // Lấy tham chiếu đến subcollection
      final docRef = _firestore
          .collection('shop_products')
          .doc(shopProductID)
          .collection('shop_product_variants')
          .doc();

      // Gán id và lưu
      await docRef.set(variantData..['shopProductVariantID'] = docRef.id);
    } catch (e) {
      print(' Lỗi khi thêm biến thể sản phẩm shop: $e');
      rethrow;
    }
  }

  /// Lấy tất cả variant của 1 sản phẩm trong shop
  Future<List<Map<String, dynamic>>> getVariantsByShopProductID(String shopProductID) async {
    try {
      final querySnapshot = await _firestore
          .collection('shop_products')
          .doc(shopProductID)
          .collection('shop_product_variants')
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print(' Lỗi khi lấy biến thể sản phẩm shop: $e');
      rethrow;
    }
  }

  /// Sửa biến thể
  Future<void> updateShopProductVariant({
    required String shopProductID,
    required String variantID,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      await _firestore
          .collection('shop_products')
          .doc(shopProductID)
          .collection('shop_product_variants')
          .doc(variantID)
          .update(updatedData);
    } catch (e) {
      print(' Lỗi khi cập nhật biến thể: $e');
      rethrow;
    }
  }

  /// Xóa biến thể
  Future<void> deleteShopProductVariant({
    required String shopProductID,
    required String variantID,
  }) async {
    try {
      await _firestore
          .collection('shop_products')
          .doc(shopProductID)
          .collection('shop_product_variants')
          .doc(variantID)
          .delete();
    } catch (e) {
      print(' Lỗi khi xóa biến thể: $e');
      rethrow;
    }
  }
}
