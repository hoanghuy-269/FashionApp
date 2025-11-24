import 'package:fashion_app/data/repositories/productdetail_repository.dart';
import 'package:flutter/material.dart';

class ProductDetailViewModel extends ChangeNotifier {
  final ProductDetailRepository _productDetailRepository =
      ProductDetailRepository();
  bool isLoading = false;

  Future<String> addProductDetail(
    String productId,
    Map<String, dynamic> productDetailData,
  ) async {
    isLoading = true;
    notifyListeners();
    String id = "";
    try {
      id = await _productDetailRepository.addProductDetail(
        productId,
        productDetailData,
      );
    } catch (e) {
      print('Lỗi khi thêm chi tiết sản phẩm: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return id;
  }

  Future<void> updateProductdetail(
    String productId,
    String productdetailId,
    Map<String, dynamic> updatedData,
  ) async {
    isLoading = true;
    notifyListeners();
    try {
      await _productDetailRepository.updateProductDetail(
        productId,
        productdetailId,
        updatedData,
      );
    } catch (e) {
      print('Lỗi khi cập nhật chi tiết sản phẩm: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteProductdetail(
    String productId,
    String productdetailId,
  ) async {
    isLoading = true;
    notifyListeners();
    try {
      await _productDetailRepository.deleteProductDetail(
        productId,
        productdetailId,
      );
    } catch (e) {
      print('Lỗi khi xóa chi tiết sản phẩm: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<String?> getImageByID({
    required String productId,
    required String productDetailId,
  }) async {
    isLoading = true;
    notifyListeners();
    String? imageUrl;
    try {
      imageUrl = await _productDetailRepository.getImageByID(
        productId: productId,
        colorID: productDetailId,
      );
    } catch (e) {
      print('Lỗi khi lấy ảnh chi tiết sản phẩm: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return imageUrl;
  }
}
