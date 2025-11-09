import 'package:flutter/material.dart';
import 'package:fashion_app/data/models/shop_product_model.dart';
import 'package:fashion_app/data/repositories/shop_product_repository.dart';

class ShopProductViewModel extends ChangeNotifier {
  final ShopProductRepository _repository = ShopProductRepository();

  List<ShopProductModel> _shopProducts = [];
  List<ShopProductModel> get shopProducts => _shopProducts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  //  Fetch sản phẩm theo ShopID
  Future<void> fetchShopProducts(String shopId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _shopProducts = await _repository.getShopProductsByShop(shopId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  //  Thêm sản phẩm
  Future<String?> addShopProduct(ShopProductModel model) async {
    _isLoading = true;
    notifyListeners();

    try {
      final createdId = await _repository.addShopProduct(model);
      // create a model instance with the generated id and same payload
      final createdModel = ShopProductModel(
        shopproductID: createdId,
        shopId: model.shopId,
        productID: model.productID,
        totalQuantity: model.totalQuantity,
        name: model.name,
        imageUrls: model.imageUrls,
        rating: model.rating,
        sold: model.sold,
      );
      _shopProducts.add(createdModel);
      _error = null;
      return createdId;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //  Cập nhật sản phẩm
  Future<void> updateShopProduct(ShopProductModel model) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateShopProduct(model);
      int index = _shopProducts.indexWhere(
        (p) => p.shopproductID == model.shopproductID,
      );
      if (index != -1) {
        _shopProducts[index] = model;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  //  Xóa sản phẩm
  Future<void> deleteShopProduct(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteShopProduct(id);
      _shopProducts.removeWhere((p) => p.shopproductID == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  //  Lấy chi tiết sản phẩm theo ID
  Future<ShopProductModel?> getShopProductById(String id) async {
    try {
      return await _repository.getShopProductById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
