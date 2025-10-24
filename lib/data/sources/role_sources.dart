import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/role_model.dart';

class FirebaseRoleSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy Role theo ID
  Future<Role?> getRoleById(String roleId) async {
    final doc = await _firestore.collection('roles').doc(roleId).get();
    if (doc.exists) {
      return Role.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  /// Lấy tất cả Role
  Future<List<Role>> getAllRoles() async {
    final query = await _firestore.collection('roles').get();
    return query.docs
        .map((doc) => Role.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
