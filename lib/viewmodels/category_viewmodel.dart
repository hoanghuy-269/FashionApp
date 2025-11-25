import 'dart:io';

import 'package:fashion_app/data/repositories/category_reporitory.dart';
import 'package:fashion_app/data/models/category_model.dart';
import 'package:flutter/foundation.dart';

class CategoryViewmodel extends ChangeNotifier {
  final CategoryReporitory _category = CategoryReporitory();

  List<CategoryModel> categoryList = [];
  bool isLoading = false;

  Future<void> fetchCategories() async {
    isLoading = true;
    notifyListeners();
    try {
      categoryList = await _category.getAllCategories();
    } catch (e) {
      debugPrint('Lỗi khi load danh mục: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  //  Thêm
  Future<void> addCategory(CategoryModel model) async {
    isLoading = true;
    notifyListeners();

    await _category.addCategory(model);
    await fetchCategories();

    isLoading = false;
    notifyListeners();
  }

  //  Sửa
  Future<void> updateCategory(CategoryModel model) async {
    isLoading = true;
    notifyListeners();

    await _category.updateCategory(model.id!, model);
    await fetchCategories();

    isLoading = false;
    notifyListeners();
  }

  //  Xóa
  Future<void> deleteCategory(String id) async {
    isLoading = true;
    notifyListeners();

    await _category.deleteCategory(id);
    await fetchCategories();

    isLoading = false;
    notifyListeners();
  }

  updateCategoryWithImage(param0, String trim, File? newImg) {}

  addCategoryWithImage(String trim, File? pickedImg) {}
}
