import 'package:fashion_app/data/models/shop_model.dart';
import 'package:fashion_app/data/sources/shop_remote_sources.dart';

class ShopRepositories {
  final ShopRemoteSources _remoteSources = ShopRemoteSources();

 Future<void> addShop(ShopModel shop) => _remoteSources.addShop(shop);

  Future<String> createShopFromMap(Map<String, dynamic> shopData) => _remoteSources.createShopFromMap(shopData);

  Future<List<ShopModel>> getShops() => _remoteSources.getShops(); 

  Future<ShopModel?> getShopById(String shopId) =>_remoteSources.getShopById(shopId);
  
  Future<ShopModel?> getShopByOwnerId(String ownerId) => _remoteSources.getShopByOwnerId(ownerId);

  Future<void> deleteShop(String shopId) => _remoteSources.deleteShop(shopId);
}