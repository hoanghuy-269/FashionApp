import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/rolestaff_model.dart';

class RolestaffRepositories {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<RolestaffModel>> getRoles() async {

    final snapshot = await _firestore.collection('staffroles').get();
    return snapshot.docs
        .map((doc) => RolestaffModel.fromMap(doc.data()))
        .toList();
  }
}