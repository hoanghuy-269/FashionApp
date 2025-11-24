import 'package:fashion_app/data/models/products_model.dart';
import 'package:fashion_app/data/models/shop_product_model.dart';
import 'package:fashion_app/data/models/shop_product_with_detail.dart';
import 'package:fashion_app/data/sources/shopproduct_source.dart';

class ShopProductRepository {
  final ShopproductSource _source = ShopproductSource();

  Future<String> addShopProduct(ShopProductModel model) async {
    return await _source.addShopProduct(model);
  }

  Future<List<ShopProductModel>> getShopProductsByShop(String shopId) async {
    return await _source.getShopProductsByShop(shopId);
  }

  // Expose real-time stream of shop products
  Stream<List<ShopProductModel>> getShopProductsByShopStream(String shopId) {
    return _source.getShopProductsByShopStream(shopId);
  }

  Future<void> updateShopProduct(ShopProductModel model) async {
    await _source.updateShopProduct(model);
  }

  Future<void> deleteShopProduct(String shopProductID) async {
    await _source.deleteShopProduct(shopProductID);
  }

  Future<ShopProductModel?> getShopProductById(String id) async {
    return await _source.getShopProductById(id);
  }

  Stream<List<Map<String, dynamic>>> getProductsByShopProduct(String shopId) {
    return _source.getProductsByShopProduct(shopId);
  }

  Stream<List<ShopProductWithDetail>> getAllShopProductsWithDetail() {
    return _source.getAllShopProductsWithDetail();
  }

  // lấy product theo shopProductID
  Future<ProductsModel?> getProductByShopProductID(String shopProductID) async {
    return await _source.getProductOfShopProduct(shopProductID);
  }

  Future<void> incrementTotalQuantity(String shopProductID, int additionalQty) async {
    await _source.incrementTotalQuantity(shopProductID, additionalQty);
  }

  Future<String?> getNameBranch(String id) async {
    try {
      return await _source.getNameBranch(id);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getNameCategory(String id) async {
    try {
      return await _source.getNameCategory(id);
    } catch (e) {
      return null;
    }
  }
  
  
  
}
