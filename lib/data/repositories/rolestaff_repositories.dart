import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/rolestaff_model.dart';

class RolestaffRepositories {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<RolestaffModel>> getRoles() async {
    final querySnapshot = await _firestore.collection('staffroles').get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['roleId'] = doc.id;
      return RolestaffModel.fromMap(data);
    }).toList();
  }
}