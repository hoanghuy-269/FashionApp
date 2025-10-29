import 'package:cloud_firestore/cloud_firestore.dart';

class RolessaffSources {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'storeroles';

  // 
 Future<Map<String, Map<String, dynamic>>> getRolesByIds(List<String> ids) async {
    final result = <String, Map<String, dynamic>>{};
    if (ids.isEmpty) return result;

    const chunkSize = 10; 
    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(i, (i + chunkSize).clamp(0, ids.length));
      final qs = await _db
          .collection(collectionPath )
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in qs.docs) {
        result[doc.id] = doc.data();
      }
    }
    return result;
 }
 
}