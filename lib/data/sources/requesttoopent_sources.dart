import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/requesttoopentshop_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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
        .orderBy('createdAt', descending: true)
        .limit(1)
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
    final snap = await _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .get();

    return snap;
  } catch (e) {
    final snap = await _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .get();

    return snap;
  }
}


  Future<void> updateStatus(String id, String status) async {
    await _firestore.collection(_collection).doc(id).update({'status': status});
  }
}
