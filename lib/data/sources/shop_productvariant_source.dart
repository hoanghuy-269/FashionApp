import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/shop_product_variant_model.dart';

class ShopProductVariantSource {
  final _firestore = FirebaseFirestore.instance;

  /// Thêm biến thể mới
  Future<void> addVariant(String shopProductID, Map<String, dynamic> data) async {
    final ref = _firestore
        .collection('shop_products')
        .doc(shopProductID)
        .collection('shop_product_variants')
        .doc();

    data['shopProductVariantID'] = ref.id;
    await ref.set(data);
  }

  /// Lấy danh sách biến thể của 1 sản phẩm
  Future<List<ShopProductVariantModel>> getVariants(String shopProductID) async {
    final snapshot = await _firestore
        .collection('shop_products')
        .doc(shopProductID)
        .collection('shop_product_variants')
        .get();

    return snapshot.docs
        .map((doc) => ShopProductVariantModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Cập nhật biến thể
  Future<void> updateVariant(
      String shopProductID, String variantID, Map<String, dynamic> data) async {
    await _firestore
        .collection('shop_products')
        .doc(shopProductID)
        .collection('shop_product_variants')
        .doc(variantID)
        .update(data);
  }

  /// Xóa biến thể
  Future<void> deleteVariant(String shopProductID, String variantID) async {
    await _firestore
        .collection('shop_products')
        .doc(shopProductID)
        .collection('shop_product_variants')
        .doc(variantID)
        .delete();
  }
}
