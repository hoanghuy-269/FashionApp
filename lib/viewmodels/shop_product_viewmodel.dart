import 'package:fashion_app/data/models/brands_model.dart';
import 'package:fashion_app/data/models/category_model.dart';
import 'package:fashion_app/data/models/products_model.dart';
import 'package:fashion_app/data/models/shop_product_with_detail.dart';
import 'package:flutter/material.dart';
import 'package:fashion_app/data/models/shop_product_model.dart';
import 'package:fashion_app/data/repositories/shop_product_repository.dart';

class ShopProductViewModel extends ChangeNotifier {
  final ShopProductRepository _repository = ShopProductRepository();

  List<ShopProductModel> _shopProducts = [];
  List<ShopProductModel> get shopProducts => _shopProducts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // lấy name của branch
  Map<String, BrandsModel> branchNameCache = {};
  String? getBranchNameCacher(String id) => branchNameCache[id]?.name;

  // Lấy tên thương hiệu từ cache
  Map<String, CategoryModel> categoryNameCache = {};
  String? getCategoryrNameCacher(String id) =>
      categoryNameCache[id]?.categoryName;
  
  Map<String, ProductsModel> productNameCache = {};
  ProductsModel? getProductNameCacher(String id) => productNameCache[id];

  ProductsModel? product;
  String? _error;
  String? get error => _error;

  //  Fetch sản phẩm theo ShopID
 Future<void> fetchShopProducts(String shopId) async {
  if(productNameCache.containsKey(shopId)){
    product = productNameCache[shopId];
    notifyListeners();
    return;
  }
  try {
      _isLoading = true;
  notifyListeners();
    _shopProducts = await _repository.getShopProductsByShop(shopId);
    _error = null;

    for (var p in _shopProducts) {
      productNameCache[p.productID] = ProductsModel(
        productID: p.productID,
        name: p.name,
        brandID: '',
        categoryID: '',
      );
    }
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
        description: model.description,
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
  
  Future<void> updateQuantity(String shopProductID, int additionalQty) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.incrementTotalQuantity(shopProductID, additionalQty);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<Map<String, dynamic>>> getShopProductsStream(String shopId) {
    return _repository.getProductsByShopProduct(shopId);
  }

  Stream<List<ShopProductWithDetail>> getAllShopProductsStream() {
    return _repository.getAllShopProductsWithDetail();
  }

  // Expose stream for real-time shop products
  Stream<List<ShopProductModel>> getShopProductsByShopStream(String shopId) {
    return _repository.getShopProductsByShopStream(shopId);
  }

  Future<void> getProductByShopProductID(String shopProductID) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _repository.getProductByShopProductID(shopProductID);

      product = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBranchName(String id) async {
    if (!branchNameCache.containsKey(id)) {
      final name = await _repository.getNameBranch(id);
      if (name != null) {
        branchNameCache[id] = BrandsModel(
          brandID: id,
          name: name,
          logoUrl: '',
        );
        notifyListeners(); 
      }
    }
  }

  Future<void> fetchCategoryName(String id) async {
    if (!categoryNameCache.containsKey(id)) {
      final name = await _repository.getNameCategory(id);
      if (name != null) {
        categoryNameCache[id] = CategoryModel(
          categoryID: id,
          categoryName: name,
          logoUrl: '',
        );
        notifyListeners(); 
      }
    }
  }
}
