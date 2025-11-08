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
      print('Lỗi khi load danh mục: $e');
    }

    isLoading = false;
    notifyListeners();
  }

}