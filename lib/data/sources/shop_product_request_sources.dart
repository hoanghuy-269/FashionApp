import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/product_request_model.dart';

class ShopProductRequestSources {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'product_requests';

  // Thêm yêu cầu sản phẩm mới
  Future<String> addProductRequest(ProductRequestModel model) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(model.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi thêm yêu cầu: $e');
    }
  }
 // Tổng số yêu cầu pending theo shopId
Stream<int> getTotalPendingRequestsByShopStream(String shopId) {
  return _firestore
      .collection(_collection)
      .where('shopID', isEqualTo: shopId)
      .where('status', isEqualTo: 'pending') 
      .snapshots()
      .map((snapshot) => snapshot.docs.length); 
}


  // Cập nhật trạng thái
  Future<void> updateStatus(String productRequestID, String status) async {
    try {
      await _firestore.collection(_collection).doc(productRequestID).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái: $e');
    }
  }

  // Xóa yêu cầu sản phẩm
  Future<void> deleteProductRequest(String productRequestID) async {
    try {
      await _firestore.collection(_collection).doc(productRequestID).delete();
    } catch (e) {
      throw Exception('Lỗi xóa yêu cầu: $e');
    }
  }

  // Lấy yêu cầu theo shopProductID cụ thể
  Future<List<ProductRequestModel>> getRequestsByShopProduct(
    String shopProductID,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('shopProductID', isEqualTo: shopProductID)
              .get();

      return querySnapshot.docs
          .map((doc) => ProductRequestModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Lỗi tải yêu cầu: $e');
    }
  }

  Future<List<ProductRequestModel>> getAllRequestsByShop(String shopId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('shopID', isEqualTo: shopId)
              // .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => ProductRequestModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Lỗi tải tất cả yêu cầu theo shop: $e');
    }
  }

  Stream<List<ProductRequestModel>> getAllRequestsByShopStream(String shopId) {
    try {
      return _firestore
          .collection(_collection)
          .where('shopID', isEqualTo: shopId)
          .snapshots()
          .map((querySnap) => querySnap.docs
              .map((doc) => ProductRequestModel.fromMap(doc.data(), doc.id))
              .toList());
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> approvedRequest(String productRequestID) async {
    try {
      await _firestore.collection(_collection).doc(productRequestID).update({
        'status': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
        'note': FieldValue.delete(),
      });
    } catch (e) {
      throw Exception('Lỗi phê duyệt yêu cầu: $e');
    }
  }
}
