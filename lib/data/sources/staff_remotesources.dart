import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/storestaff_model.dart';
import 'package:flutter/foundation.dart';

class StaffRemotesources {
  final _db = FirebaseFirestore.instance;

  Future<void> addStaff(StorestaffModel staff) async {
    final id = staff.employeeId;
    await _db
        .collection('shops')
        .doc(staff.shopId)
        .collection('staff')
        .doc(id)
        .set(staff.toFirestoreMap());
  }

  Future<void> updateStaff(StorestaffModel staff) async {
    final id = staff.employeeId;
    await _db
        .collection('shops')
        .doc(staff.shopId)
        .collection('staff')
        .doc(id)
        .update(staff.toFirestoreMap(useServerTimestamp: false));
  }

  Future<List<StorestaffModel>> getStaffs() async {
    final query = await _db.collectionGroup('staff').get();
    return query.docs.map((e) {
      final data = Map<String, dynamic>.from(e.data());
      data['employeeId'] = e.id;
      return StorestaffModel.fromMap(data);
    }).toList();
  }

  Future<StorestaffModel?> getStaffById(String employeeId) async {
    final snaps =
        await _db
            .collectionGroup('staff')
            .where(FieldPath.documentId, isEqualTo: employeeId)
            .get();
    if (snaps.docs.isEmpty) return null;
    final e = snaps.docs.first;
    final data = Map<String, dynamic>.from(e.data());
    data['employeeId'] = e.id;
    return StorestaffModel.fromMap(data);
  }

  Future<List<StorestaffModel>> getStaffsByShop(String shopId) async {
    try {
      final q =
          await _db.collection('shops').doc(shopId).collection('staff').get();

      return q.docs.map((e) {
        final data = Map<String, dynamic>.from(e.data());
        data['employeeId'] = e.id;
        return StorestaffModel.fromMap(data);
      }).toList();
    } catch (e, st) {
      debugPrint(' Lỗi khi getStaffsByShop: $e');
      debugPrint('StackTrace:\n$st');
      rethrow;
    }
  }

  Future<void> deleteStaff(String shopId, String employeeId) async {
    await _db
        .collection('shops')
        .doc(shopId)
        .collection('staff')
        .doc(employeeId)
        .delete();
  }

  Future<bool> isStaffEmailExists(String email, String shopId) async {
    final query =
        await _db
            .collection('shops')
            .doc(shopId)
            .collection('staff')
            .where('email', isEqualTo: email.trim())
            .limit(1)
            .get();

    return query.docs.isNotEmpty;
  }
}
