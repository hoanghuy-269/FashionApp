import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/category_model.dart';

class CategorySource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;


  // lay tat ca category
  Future<List<CategoryModel>> getAllCategories() async {
    final query = await firestore.collection('categories').get();
    return query.docs
        .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

}