import 'package:fashion_app/data/models/shop_model.dart';
import 'package:fashion_app/data/repositories/shop_repositories.dart';
import 'package:flutter/material.dart';

class ShopViewModel extends ChangeNotifier {
  final  ShopRepositories _repo = ShopRepositories(); 
  List<ShopModel> shops = []; 
  ShopModel? currentShop;

  bool isLoading = false;

  Future<void> addNewShop(ShopModel shop) async {
    await _repo.addShop(shop);
    shops.add(shop);
    notifyListeners();
  }
  Future<void> fetchShops() async {
    isLoading = true;
    notifyListeners();

    shops = await _repo.getShops();

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchShopById(String shopId) async {
    isLoading = true;
    notifyListeners();

    final shop = await _repo.getShopById(shopId);
    if (shop != null) {
      currentShop = shop;
    } else {
      currentShop = null;
    }

    isLoading = false;
    notifyListeners();
  }
}