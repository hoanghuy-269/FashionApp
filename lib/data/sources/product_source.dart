import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/products_model.dart';

class ProductSource {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<String> addProduct(Map<String, dynamic> productData) async {
    final collection = _firestore.collection('products');

    // Lấy tổng số document
    final snapshot = await collection.get();
    final count = snapshot.docs.length + 1;

    final formattedId = 'product_${count.toString().padLeft(3, '0')}';
    productData['productID'] = formattedId;
    await collection.doc(formattedId).set(productData);
    return formattedId;
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> updatedData) async {
    final docRef = _firestore.collection('products').doc(productId);
    await docRef.update(updatedData);
  }
  Future<void> deleteProduct(String productId) async {
    final docRef = _firestore.collection('products').doc(productId);
    await docRef.delete();
  }
  // lấy Products theo Branch
   Future<List<ProductsModel>> getProductsByBrand(String brandID) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('brandID', isEqualTo: brandID)
          .get();

      return querySnapshot.docs.map((doc) {
        return ProductsModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print("Lỗi khi lấy sản phẩm theo brand: $e");
      return [];
    }
  }

}