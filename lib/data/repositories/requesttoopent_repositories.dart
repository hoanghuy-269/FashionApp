import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/requesttoopentshop_model.dart';
import 'package:fashion_app/data/sources/requesttoopent_sources.dart';
import 'package:flutter/foundation.dart';

class RequestToOpenShopRepository {
  final RequestToOpenShopSource _source = RequestToOpenShopSource();

  Future<void> createRequest(RequesttoopentshopModel request) async {
    await _source.create(request.toMap(), request.requestId);
  }
  Future<void> updateRequest(RequesttoopentshopModel request) async {
    await _source.update(request.requestId, request.toMap());
  }

  Future<List<RequesttoopentshopModel>> getAllRequests() async {
    final snap = await _source.getAll();
    return snap.docs.map((doc) {
      final data = doc.data();
      data['requestId'] = doc.id;
      return RequesttoopentshopModel.fromMap(data);
    }).toList();
  }

  Future<RequesttoopentshopModel?> getRequestByUserId(String userId) async {
    final snap = await _source.getByUser(userId);
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    final data = doc.data();
    data['requestId'] = doc.id;
    return RequesttoopentshopModel.fromMap(data);
  }
  Future<RequesttoopentshopModel?> getRequestById(String requestId) async {
    return await _source.getRequestById(requestId);
  }

  Future<void> deleteRequest(String id) async {
    await _source.delete(id);
  }
  Future<List<RequesttoopentshopModel>> fetchRequestsByStatus(String status) async {
    try {
      final snap = await _source.getByStatus(status);
      // debug
      debugPrint('RequestToOpenShopRepository.fetchRequestsByStatus: status=$status, docs=${snap.docs.length}');
      return snap.docs.map((d) {
        final data = d.data();
        data['requestId'] = d.id;
        return RequesttoopentshopModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('RequestToOpenShopRepository.fetchRequestsByStatus: error=$e');
      rethrow;
    }
  }
  Future<void> updateRequestStatus(String id, String status) async {
  await FirebaseFirestore.instance
      .collection('requesttoopentshops')
      .doc(id)
      .update({'status': status});
}

}
