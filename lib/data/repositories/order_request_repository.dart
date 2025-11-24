import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/order_request.dart';

class OrderRequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tạo order request mới
  Future<bool> createOrderRequest(OrderRequest request) async {
    try {
      await _firestore
          .collection('order_requests')
          .doc(request.requestId)
          .set(request.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Lấy order requests theo user ID
  Stream<List<OrderRequest>> getOrderRequestsByUserId(String userId) {
    return _firestore
        .collection('order_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => OrderRequest.fromMap(doc.data()))
                  .toList(),
        );
  }

  // Xác nhận order request
  Future<bool> confirmOrderRequest(String requestId) async {
    try {
      await _firestore.collection('order_requests').doc(requestId).update({
        'status': 'confirmed',
      });
      return true;
    } catch (e) {
      print('❌ Lỗi xác nhận order request: $e');
      return false;
    }
  }

  // Hủy order request
  Future<bool> cancelOrderRequest(String requestId) async {
    try {
      await _firestore.collection('order_requests').doc(requestId).update({
        'status': 'cancelled',
      });
      return true;
    } catch (e) {
      print('❌ Lỗi hủy order request: $e');
      return false;
    }
  }
}
