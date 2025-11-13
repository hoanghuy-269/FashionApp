import 'package:fashion_app/data/models/sizes_model.dart';
import 'package:flutter/material.dart';
import 'package:fashion_app/data/models/product_size_model.dart';
import 'package:fashion_app/data/sources/product_size_source.dart';

class ProductSizeViewmodel extends ChangeNotifier {
  final ProductSizeSource _source = ProductSizeSource();

  List<ProductSizeModel> _sizes = [];
  List<ProductSizeModel> get sizes => _sizes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Lấy tất cả size (nếu cần dùng)
  Future<void> fetchAllSizes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _sizes = await _source.getAllSizes();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _sizes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  /// Thêm size mới
  Future<bool> addSize(String shopProductID, String variantID, ProductSizeModel size) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newId = await _source.addProductSize(shopProductID, variantID, size);
      final newSize = ProductSizeModel(
        sizeID: size.sizeID,
        quantity: size.quantity,
        price: size.price,
    
        costPrice: size.costPrice,
      );
      _sizes.add(newSize);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Xóa size khỏi danh sách local
  void removeSize(String sizeID) {
    _sizes.removeWhere((s) => s.sizeID == sizeID);
    notifyListeners();
  }

  /// Xóa lỗi
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Cập nhật size
  Future<void> updateSize(String shopProductID, String variantID, ProductSizeModel size) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _source.updateProductSize(shopProductID, variantID, size.sizeID, size);
      final index = _sizes.indexWhere((s) => s.sizeID == size.sizeID);
      if (index != -1) {
        _sizes[index] = size;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}