import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/product_size_model.dart';

class ProductSizeSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ProductSizeModel>> getAllSizes() async {
    final query = await _firestore.collection('product_sizes').get();
    final List<ProductSizeModel> sizes = [];
    for (var doc in query.docs) {
      final data = doc.data();
      data['sizeID'] = doc.id;
      sizes.add(ProductSizeModel.fromMap(data));
    }
    return sizes;
  }

  Future<List<ProductSizeModel>> getSizesByVariant(
    String shopProductID,
    String variantID,
  ) async {
    final snapshot =
        await _firestore
            .collection('shop_products')
            .doc(shopProductID)
            .collection('shop_product_variants')
            .doc(variantID)
            .collection('product_sizes')
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['sizeID'] = doc.id;
      return ProductSizeModel.fromMap(data);
    }).toList();
  }

  Future<String> addProductSize(
    String shopProductID,
    String variantID,
    ProductSizeModel size,
  ) async {
    if (shopProductID.isEmpty) throw ArgumentError('shopProductID is required');
    if (variantID.isEmpty) throw ArgumentError('variantID is required');

    final ref = _firestore
        .collection('shop_products')
        .doc(shopProductID)
        .collection('shop_product_variants')
        .doc(variantID)
        .collection('product_sizes')
        .doc(size.sizeID);

    await ref.set(size.toMap());
    return size.sizeID;
  }

  Future<void> updateProductSize(
    String shopProductID,
    String variantID,
    String sizeID,
    ProductSizeModel size,
  ) async {
    if (shopProductID.isEmpty || variantID.isEmpty || sizeID.isEmpty)
      throw ArgumentError('ID không được để trống');

    await _firestore
        .collection('shop_products')
        .doc(shopProductID)
        .collection('shop_product_variants')
        .doc(variantID)
        .collection('product_sizes')
        .doc(sizeID)
        .update(size.toMap());
  }

  Future<void> deleteProductSize(
    String shopProductID,
    String variantID,
    String sizeID,
  ) async {
    if (shopProductID.isEmpty || variantID.isEmpty || sizeID.isEmpty)
      throw ArgumentError('ID không được để trống');

    await _firestore
        .collection('shop_products')
        .doc(shopProductID)
        .collection('shop_product_variants')
        .doc(variantID)
        .collection('product_sizes')
        .doc(sizeID)
        .delete();
  }
}
