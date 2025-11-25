import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/products_model.dart';

class ProductSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 Future<String> addProduct(Map<String, dynamic> productData) async {
  final collection = _firestore.collection('products');
  
  // Tạo document với auto ID
  final docRef = await collection.add(productData);
  
  // Cập nhật productID bằng ID thực tế
  await docRef.update({'productID': docRef.id});
  
  return docRef.id;
}

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> updatedData,
  ) async {
    final docRef = _firestore.collection('products').doc(productId);
    await docRef.update(updatedData);
  }

  Future<void> deleteProduct(String productId) async {
    final docRef = _firestore.collection('products').doc(productId);
    await docRef.delete();
  }

  // lấy Products theo Branch
  Future<List<ProductsModel>> getProductsByBrandAndCategory(
    String brandID,
    String categoryID,
  ) async {
    try {
      final query = _firestore
          .collection('products')
          .where('brandID', isEqualTo: brandID)
          .where('categoryID', isEqualTo: categoryID);

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        return ProductsModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print("Lỗi khi lấy sản phẩm theo brand & category: $e");
      return [];
    }
  }
}
