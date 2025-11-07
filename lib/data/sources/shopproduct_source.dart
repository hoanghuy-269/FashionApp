import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/shop_product_model.dart';

class ShopproductSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'shop_products'; 

  Future<String> addShopProduct(ShopProductModel model) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      // ensure the stored document has the generated id
      final data = model.toMap()..['shopproductID'] = docRef.id;
      await docRef.set(data);
      return docRef.id;
    } catch (e) {
      print(' Lỗi khi thêm sản phẩm shop: $e');
      rethrow;
    }
  }

  Future<List<ShopProductModel>> getShopProductsByShop(String shopId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('shopId', isEqualTo: shopId)
          .get();

      return snapshot.docs
          .map((doc) => ShopProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateShopProduct(ShopProductModel model) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(model.shopproductID)
          .update(model.toMap());
    } catch (e) {
      print(' Lỗi khi cập nhật sản phẩm shop: $e');
      rethrow;
    }
  }

  Future<void> deleteShopProduct(String shopProductID) async {
    try {
      await _firestore.collection(_collection).doc(shopProductID).delete();
    } catch (e) {
      print(' Lỗi khi xóa sản phẩm shop: $e');
      rethrow;
    }
  }

  Future<ShopProductModel?> getShopProductById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return ShopProductModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print(' Lỗi khi lấy chi tiết sản phẩm shop: $e');
      return null;
    }
  }
}
