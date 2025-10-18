import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/shopstaff_model.dart';

class StaffRemotesources {
  final _db = FirebaseFirestore.instance;

  Future<void> addStaff(ShopstaffModel staff) async {
    await _db.collection('shopstaffs').doc(staff.employeeId).set(staff.toMap());
  }

  Future<List<ShopstaffModel>> getStaffs() async {
    final query = await _db.collection("shopstaffs").get();
    return query.docs.map((e) {
      final data = e.data();
      data['employeeId'] = e.id;
      return ShopstaffModel.fromMap(data);
    }).toList();
  }

  Future<ShopstaffModel?> getStaffById(String employeeId) async {
    final doc = await _db.collection('shopstaffs').doc(employeeId).get();

    if (doc.exists) {
      final data = doc.data()!;
      data['employeeId'] = doc.id;
      return ShopstaffModel.fromMap(data);
    }
    return null;
  }
}
