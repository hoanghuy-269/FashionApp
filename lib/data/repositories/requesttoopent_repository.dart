import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/requesttoopentshop_model.dart';
import 'package:fashion_app/data/sources/requesttoopent_sources.dart';
// removed unused import

class RequestToOpenShopRepository {
  final RequestToOpenShopSource _resource = RequestToOpenShopSource();
  final String collection = "requesttoopentshops";

  Future<void> createRequest(RequesttoopentshopModel request) async {
    await _resource.create(request.toMap(), request.requestId);
  }

  Future<void> updateRequest(RequesttoopentshopModel request) async {
    await _resource.update(request.requestId, request.toMap());
  }

  Future<List<RequesttoopentshopModel>> getAllRequests() async {
    final snap = await _resource.getAll();
    return snap.docs.map((doc) {
      final data = doc.data();
      data['requestId'] = doc.id;
      return RequesttoopentshopModel.fromMap(data);
    }).toList();
  }

  Future<List<RequesttoopentshopModel>> getRequestsByUserId(
    String userId,
  ) async {
    final snap = await _resource.getByUser(userId);
    if (snap.docs.isEmpty) return [];

    return snap.docs.map((doc) {
      final data = doc.data();
      data['requestId'] = doc.id;
      return RequesttoopentshopModel.fromMap(data);
    }).toList();
  }

  Future<RequesttoopentshopModel?> getRequestById(String requestId) async {
    return await _resource.getRequestById(requestId);
  }

  Future<void> deleteRequest(String id) async {
    await _resource.delete(id);
  }

  Future<List<RequesttoopentshopModel>> fetchRequestsByStatus(
    String status,
  ) async {
    try {
      final snap = await _resource.getByStatus(status);
      return snap.docs.map((d) {
        final data = d.data();
        data['requestId'] = d.id;
        return RequesttoopentshopModel.fromMap(data);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRequestStatus(String id, String status) async {
    await FirebaseFirestore.instance.collection(collection).doc(id).update({
      'status': status,
    });
  }

  Future<void> updateRequestStatusWithShop(
    String id,
    String status,
    String shopId,
  ) async {
    await _resource.updateStatusWithShop(id, status, shopId);
  }

  Future<List<RequesttoopentshopModel>> getApprovedRequestsByUserId(
    String userId,
  ) async {
    try {
      return await _resource.fetchApprovedRequestsByUserId(userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Stream tất cả request của một user (bất kể trạng thái)
  Stream<List<RequesttoopentshopModel>> streamRequestsByUser(String userId) {
    return FirebaseFirestore.instance
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((d) {
                final data = d.data();
                data['requestId'] = d.id;
                return RequesttoopentshopModel.fromMap(data);
              }).toList(),
        );
  }
}
