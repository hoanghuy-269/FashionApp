import 'package:fashion_app/data/models/shop_product_model.dart';
import 'package:fashion_app/data/sources/shopproduct_source.dart';

class ShopProductRepository {
  final ShopproductSource _source = ShopproductSource();

  Future<String> addShopProduct(ShopProductModel model) async {
    return await _source.addShopProduct(model);
  }
  Future<List<ShopProductModel>> getShopProductsByShop(String shopId) async {
    return await _source.getShopProductsByShop(shopId);
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
  
  
}