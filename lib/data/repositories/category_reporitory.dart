import 'package:fashion_app/data/models/category_model.dart';
import 'package:fashion_app/data/sources/category_source.dart';

class CategoryReporitory {
  final  CategorySource _remoteSource = CategorySource();
  Future<List<CategoryModel>> getAllCategories() => _remoteSource.getAllCategories();
}