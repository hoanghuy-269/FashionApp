import 'package:fashion_app/data/models/products_model.dart';
import 'package:fashion_app/data/repositories/products_repository.dart';
import 'package:flutter/material.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductsRepository _productsRepository = ProductsRepository();

  bool isLoading = false;
  List<ProductsModel> productList = [];

  Future<String> addProduct(Map<String, dynamic> productData) async {
    isLoading = true;
    notifyListeners();
    String id = "";
    try {
      id = await _productsRepository.addProduct(productData);
    } catch (e) {
      print('Lỗi khi thêm sản phẩm: $e');
    }
    isLoading = false;
    notifyListeners();
    return id;
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> updatedData,
  ) async {
    isLoading = true;
    notifyListeners();
    try {
      await _productsRepository.updateProduct(productId, updatedData);
    } catch (e) {
      print('Lỗi khi cập nhật sản phẩm: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    isLoading = true;
    notifyListeners();
    try {
      await _productsRepository.deleteProduct(productId);
    } catch (e) {
      print('Lỗi khi xóa sản phẩm: $e');
    }
    isLoading = false;
    notifyListeners();
  }

 Future<void> fetchProductsByBrandandCategory(String brandID, String categoryID) async {
    isLoading = true;
    notifyListeners();

    try {
      productList = await _productsRepository.getProductsByBrandAndCategory(brandID, categoryID);
    } catch (e) {
      print("Lỗi khi fetch sản phẩm: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
