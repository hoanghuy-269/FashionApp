import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/sizes_model.dart';

class SizeSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy size theo ID category
Future<List<SizesModel>> getSizesByCategoryId(String categoryId) async {
  final querySnapshot = await _firestore
    .collection('sizes')
    .where('categoryID', isEqualTo: categoryId)
    .get();

   final sizes = querySnapshot.docs.map((doc) {
    return SizesModel.fromFirestore(doc.data(), doc.id);
  }).toList();

  sizes.sort((a, b) => a.name.compareTo(b.name));
  return sizes;
}

// adđ size mới
  Future<void> addSize(SizesModel size) async {
    await _firestore.collection('sizes').doc(size.sizeID).set(size.toMap());
  }

}