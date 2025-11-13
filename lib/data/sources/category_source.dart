import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/category_model.dart';

class CategorySource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;


  // Lấy hết


  // lay tat ca category

  Future<List<CategoryModel>> getAllCategories() async {
    final query = await firestore.collection('categories').get();
    return query.docs
        .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }


  // ✅ Thêm
  Future<void> addCategory(CategoryModel category) async {
    await firestore.collection('categories').add(category.toMap());
  }

  // ✅ Cập nhật
  Future<void> updateCategory(String id, CategoryModel category) async {
    await firestore.collection('categories').doc(id).update(category.toMap());
  }

  // ✅ Xóa
  Future<void> deleteCategory(String id) async {
    await firestore.collection('categories').doc(id).delete();
  }
}

}

