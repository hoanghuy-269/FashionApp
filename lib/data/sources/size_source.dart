import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/sizes_model.dart';

class SizeSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy size theo ID category
  Future<List<SizesModel>> getSizesByCategoryId(String categoryId) async {
    final querySnapshot =
        await _firestore
            .collection('sizes')
            .where('categoryID', isEqualTo: categoryId)
            .get();

    final sizes =
        querySnapshot.docs.map((doc) {
          return SizesModel.fromFirestore(doc.data(), doc.id);
        }).toList();

    sizes.sort((a, b) => a.name.compareTo(b.name));
    return sizes;
  }

  // adđ size mới
  Future<void> addSize(SizesModel size) async {
    await _firestore.collection('sizes').doc(size.sizeID).set(size.toMap());
  }

  // Lấy tên size từ sizeID
  Future<String> getSizeName(String sizeID) async {
    try {
      final doc = await _firestore.collection('sizes').doc(sizeID).get();
      if (doc.exists) {
        return doc.data()?['name'] ?? sizeID;
      }
      return sizeID;
    } catch (e) {
      print('Error getting size name: $e');
      return sizeID;
    }
  }

  
 Future<Map<String, Map<String, dynamic>>> getAllSizes() async {
    try {
      final snapshot = await _firestore.collection('sizes').get();
      
      Map<String, Map<String, dynamic>> sizesMap = {};
      for (var doc in snapshot.docs) {
        sizesMap[doc.id] = {
          'name': doc.data()['name'] ?? '',
          'categoryId': doc.data()['categoryId'] ?? '',
        };
      }

      return sizesMap;
    } catch (e) {
      return {};
    }
  }

  // Future void 
  Future<SizesModel?> getSizeById(String sizeID) async {
    try {
      final doc = await _firestore.collection('sizes').doc(sizeID).get();
      if (doc.exists) {
        return SizesModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting size by ID: $e');
      return null;
    }
  }

 // kiem tra check name size da ton tai chua
  Future<bool> isSizeNameExists(String name, String categoryId) async {
    final querySnapshot = await _firestore
        .collection('sizes')
        .where('name', isEqualTo: name)
        .where('categoryID', isEqualTo: categoryId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}
