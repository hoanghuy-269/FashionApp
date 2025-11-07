import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addProductDetail(String productId, Map<String, dynamic> productDetailData) async {
    final collection = _firestore.collection('products').doc(productId).collection('product_details');

    final snapshot = await collection.get();
    final count = snapshot.docs.length + 1;

    final formattedId = 'product_detail_${count.toString().padLeft(3, '0')}';
    productDetailData['productsDetailID'] = formattedId;
    await collection.doc(formattedId).set(productDetailData);
    return formattedId;
  }

  Future<void> updateProductDetail(String productId, String productDetailId, Map<String, dynamic> updatedData) async {
    final docRef = _firestore.collection('products').doc(productId).collection('product_details').doc(productDetailId);
    await docRef.update(updatedData);
  }

  Future<void> deleteProductDetail(String productId, String productDetailId) async {
    final docRef = _firestore.collection('products').doc(productId).collection('product_details').doc(productDetailId);
    await docRef.delete();
  }

}