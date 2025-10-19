import 'package:fashion_app/data/models/shop_model.dart';
import 'package:fashion_app/data/repositories/shop_repositories.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<ShopModel?> createAndAddShop(ShopModel shop) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      final ownerId = user?.uid ?? shop.userId;
      final ownerEmail = user?.email ?? shop.ownerEmail;

      final data = shop.toMap();
      data['userId'] = ownerId;
      data['ownerEmail'] = ownerEmail;

      final generatedShopId = await _repo.createShopFromMap(data);

      final createdShop = ShopModel(
        shopId: generatedShopId,
        userId: ownerId,
        yeuCauMoShopId: shop.yeuCauMoShopId,
        shopName: shop.shopName,
        logo: shop.logo,
        phoneNumber: shop.phoneNumber,
        address: shop.address,
        totalProducts: shop.totalProducts,
        totalOrders: shop.totalOrders,
        revenue: shop.revenue,
        createdAt: DateTime.now(),
        activityStatusId: shop.activityStatusId,
        ownerEmail: ownerEmail,
      );
      shops.add(createdShop);

      currentShop = createdShop;
      isLoading = false;
      notifyListeners();

      return createdShop;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  Future<void> fetchShops() async {
    isLoading = true;
    notifyListeners();

    shops = await _repo.getShops();

    isLoading = false;
    notifyListeners();
  }

  // lấy theo id trên firebase
  Future<ShopModel?> fetchShopForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    isLoading = true;
    notifyListeners();

    try {
      final shop = await _repo.getShopByOwnerId(user.uid);
      currentShop = shop;
      return shop;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}