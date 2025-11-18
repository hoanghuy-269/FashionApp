import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/shop_product_variant_model.dart';

class ShopProductVariantSource {
  final _firestore = FirebaseFirestore.instance;

  // Lấy variants của 1 product
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

Future<String> addVariant(String shopProductID, Map<String, dynamic> data) async {
  final ref = _firestore
      .collection('shop_products')
      .doc(shopProductID)
      .collection('shop_product_variants')
      .doc();

  data['shopProductVariantID'] = ref.id;
  await ref.set(data);
  return ref.id; 
}


  Future<void> updateVariant(String shopProductID, String variantID, Map<String, dynamic> data) async {
    await _firestore
        .collection('shop_products')
        .doc(shopProductID)
        .collection('shop_product_variants')
        .doc(variantID)
        .update(data);
  }

  Future<void> updateMultipleVariants(
    String shopProductID,
    Map<String, Map<String, dynamic>> dataToUpdate,
  ) async {
    try {
      final batch = _firestore.batch();

      final snapshot = await _firestore
          .collection('shop_products')
          .doc(shopProductID)
          .collection('shop_product_variants')
          .get();

      for (var doc in snapshot.docs) {
        if (dataToUpdate.containsKey(doc.id)) {
          batch.update(doc.reference, dataToUpdate[doc.id]!);
        }
      }

      await batch.commit();

      final variantsSnapshot = await _firestore
          .collection('shop_products')
          .doc(shopProductID)
          .collection('shop_product_variants')
          .get();

      int newTotalQuantity = 0;
      for (var doc in variantsSnapshot.docs) {
        newTotalQuantity += (doc.data()['quantity'] as int? ?? 0);
      }

      await _firestore.collection('shop_products').doc(shopProductID).update({
        'totalQuantity': newTotalQuantity,
      });
    } catch (e) {
      print('Error updating multiple variants: $e');
      rethrow;
    }
  }
  

  Future<void> deleteVariant(String shopProductID, String variantID) async {
    await _firestore
        .collection('shop_products')
        .doc(shopProductID)
        .collection('shop_product_variants')
        .doc(variantID)
        .delete();
  }

  

  

}
