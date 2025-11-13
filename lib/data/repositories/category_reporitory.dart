
import 'dart:io';



import 'package:fashion_app/data/models/category_model.dart';
import 'package:fashion_app/data/sources/category_source.dart';

class CategoryReporitory {

  final CategorySource _remoteSource = CategorySource();

  Future<List<CategoryModel>> getAllCategories() => _remoteSource.getAllCategories();

  // ✅ gọi CRUD
  Future<void> addCategory(CategoryModel c) => _remoteSource.addCategory(c);

  Future<void> updateCategory(String id, CategoryModel c) =>
      _remoteSource.updateCategory(id, c);

  Future<void> deleteCategory(String id) => _remoteSource.deleteCategory(id);

  addCategoryWithImage(String name, File? imageFile) {}

  updateCategoryWithImage(String id, String name, File? newImageFile) {}
  
}
=======
  final  CategorySource _remoteSource = CategorySource();
  Future<List<CategoryModel>> getAllCategories() => _remoteSource.getAllCategories();
}

