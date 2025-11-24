import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/payment_model.dart';

class PaymentMethodRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'payment_methods';

  // Lấy tất cả payment methods đang hoạt động
  Stream<List<PaymentMethod>> getActivePaymentMethods() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        PaymentMethod.fromMap({'id': doc.id, ...doc.data()}),
                  )
                  .toList(),
        );
  }

  Future<List<PaymentMethod>> getActivePaymentMethodsFromServer() async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .get(const GetOptions(source: Source.server));

    return snapshot.docs
        .map((doc) => PaymentMethod.fromMap({'id': doc.id, ...doc.data()}))
        .toList();
  }

  // Lấy payment method theo ID
  Future<PaymentMethod?> getPaymentMethodById(String id) async {
    final doc = await _firestore.collection(_collectionName).doc(id).get();
    if (doc.exists) {
      return PaymentMethod.fromMap({'id': doc.id, ...doc.data()!});
    }
    return null;
  }

  // Thêm payment method mới
  Future<void> addPaymentMethod(PaymentMethod paymentMethod) async {
    await _firestore
        .collection(_collectionName)
        .doc(paymentMethod.id)
        .set(paymentMethod.toMap());
  }

  // Cập nhật payment method
  Future<void> updatePaymentMethod(PaymentMethod paymentMethod) async {
    await _firestore
        .collection(_collectionName)
        .doc(paymentMethod.id)
        .update(paymentMethod.toMap());
  }

  // Xóa payment method (soft delete)
  Future<void> deletePaymentMethod(String id) async {
    await _firestore.collection(_collectionName).doc(id).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }
}
