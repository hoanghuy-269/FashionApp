import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/requesttoopentshop_model.dart';
// removed unused flutter import

class RequestToOpenShopSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = "requesttoopentshops";

  Future<void> create(Map<String, dynamic> data, String id) async {
    await _firestore.collection(_collection).doc(id).set(data);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAll() async {
    return _firestore.collection(_collection).get();
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(id).update(data);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getByUser(String userId) async {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();
  }

  Future<RequesttoopentshopModel?> getRequestById(String requestId) async {
    final doc = await _firestore.collection(_collection).doc(requestId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    data['requestId'] = doc.id;
    return RequesttoopentshopModel.fromMap(data);
  }

  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getByStatus(String status) async {
    try {
      final snap =
          await _firestore
              .collection(_collection)
              .where('status', isEqualTo: status)
              // .orderBy('createdAt', descending: true)
              .get();

      return snap;
    } catch (e) {
      final snap =
          await _firestore
              .collection(_collection)
              .where('status', isEqualTo: status)
              .get();

      return snap;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    await _firestore.collection(_collection).doc(id).update({'status': status});
  }

  Future<void> updateStatusWithShop(
    String id,
    String status,
    String shopId,
  ) async {
    final data = {
      'status': status,
      'shopId': shopId,
      'approvedAt': FieldValue.serverTimestamp(),
    };
    await _firestore.collection(_collection).doc(id).update(data);
  }

  Stream<List<RequesttoopentshopModel>> streamRequestsByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        //  .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['requestId'] = doc.id;
                return RequesttoopentshopModel.fromMap(data);
              }).toList(),
        );
  }

  Future<List<RequesttoopentshopModel>> fetchApprovedRequestsByUserId(
    String userId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .where('status', isEqualTo: 'approved')
              .get();

      return snapshot.docs
          .map(
            (doc) => RequesttoopentshopModel.fromMap({
              ...doc.data(),
              'requestId': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Error fetching approved requests: $e');
    }
  }
}
