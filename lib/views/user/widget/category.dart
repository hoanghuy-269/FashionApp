// categories_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getCategories() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'categoryID': data['categoryID'],
          'categoryName': data['categoryName'],
          'logoUrl': data['logoUrl'],
        };
      }).toList();
    });
  }
}

class BrandsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getBrands() {
    return _firestore.collection('brands').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'brandID': data['brandID'],
          'name': data['name'],
          'logoUrl': data['logoUrl'],
        };
      }).toList();
    });
  }
}
