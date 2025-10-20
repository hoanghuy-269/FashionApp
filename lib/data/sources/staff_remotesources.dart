import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/storestaff_model.dart';

class StaffRemotesources {
  final _db = FirebaseFirestore.instance;

  Future<void> addStaff(StorestaffModel staff) async {
    await _db.collection('storestaffs').doc(staff.employeeId).set(staff.toMap());
  }
  
  Future<void> updateStaff(StorestaffModel staff) async {
    await _db.collection('storestaffs').doc(staff.employeeId).update(staff.toMap());
  }

  Future<List<StorestaffModel>> getStaffs() async {
    final query = await _db.collection("storestaffs").get();
    return query.docs.map((e) {
      final data = e.data();
      data['employeeId'] = e.id;
      return StorestaffModel.fromMap(data);
    }).toList();
  }

  Future<StorestaffModel?> getStaffById(String employeeId) async {
    final doc = await _db.collection('storestaffs').doc(employeeId).get();

    if (doc.exists) {
      final data = doc.data()!;
      data['employeeId'] = doc.id;
      return StorestaffModel.fromMap(data);
    }
    return null;
  }
  Future<List<StorestaffModel>> getStaffsByShop(String shopId) async {
    final q = await _db.collection('storestaffs').where('shopId', isEqualTo: shopId).get();
    return q.docs.map((e) {
      final data = e.data();
      data['employeeId'] = e.id;
      return StorestaffModel.fromMap(data);
    }).toList();
  }
  Future<void> deleteStaff(String employeeId) async {
    await _db.collection('storestaffs').doc(employeeId).delete();
  }
}
