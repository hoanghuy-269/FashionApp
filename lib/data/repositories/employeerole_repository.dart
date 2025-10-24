import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/employeerole_model.dart';

class EmployeeroleRepositories {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<EmployeeroleModel>> getRoles() async {
    final querySnapshot = await _firestore.collection('employeeroles').get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['roleId'] = doc.id;
      return EmployeeroleModel.fromMap(data);
    }).toList();
  }
  Future<void> addSampleRoles() async {
    final sampleRoles = [
      EmployeeroleModel(roleId: 'R01', roleName: 'Ship'),
      EmployeeroleModel(roleId: 'R02', roleName: 'Thu Ngân'),
      EmployeeroleModel(roleId: 'R03', roleName: 'Quản lí kho'),
    ];

    final collection = _firestore.collection('employeeroles');

    for (final role in sampleRoles) {
      await collection.doc(role.roleId).set(role.toMap());
    }

    print("✅ Đã thêm dữ liệu mẫu lên Firestore thành công!");
  }
}