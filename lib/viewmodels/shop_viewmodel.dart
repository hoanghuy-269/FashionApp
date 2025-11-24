import 'package:fashion_app/data/models/shop_model.dart';
import 'package:fashion_app/data/repositories/shop_repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopViewModel extends ChangeNotifier {
  final ShopRepositories _repo = ShopRepositories();
  List<ShopModel> shops = [];
  ShopModel? currentShop;
  int staffCount = 0 ;

  bool isLoading = false;

  Future<void> addNewShop(ShopModel shop) async {
    await _repo.addShop(shop);
    shops.add(shop);
    notifyListeners();
  }

  Future<ShopModel?> createAddShop(ShopModel shop) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;

      final ownerId =
          shop.userId.trim().isNotEmpty
              ? shop.userId.trim()
              : (user?.uid ?? '');

      final ownerEmail =
          shop.ownerEmail?.isNotEmpty == true ? shop.ownerEmail : user?.email;

      final data = shop.toMap();
      data['userId'] = ownerId;
      data['ownerEmail'] = ownerEmail;

      final generatedShopId = await _repo.createShopFromMap(data);

      final createdShop = ShopModel(
        shopId: generatedShopId,
        userId: ownerId,
        requestId: shop.requestId,
        shopName: shop.shopName,
        logo: shop.logo,
        businessLicense: shop.businessLicense,
        nationalId: shop.nationalId,
        idnationFront: shop.idnationFront,
        idnationBack: shop.idnationBack,
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

  // update shop
  Future<void> updateShop(ShopModel updatedShop) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repo.updateShop(updatedShop);

      // cập nhật dữ liệu trong RAM
      final index = shops.indexWhere((s) => s.shopId == updatedShop.shopId);
      if (index != -1) {
        shops[index] = updatedShop;
      }

      if (currentShop?.shopId == updatedShop.shopId) {
        currentShop = updatedShop;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi cập nhật shop: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteShop(String shopId) async {
    try {
      isLoading = true;
      notifyListeners();

      await _repo.deleteShop(shopId);
      shops.removeWhere((s) => s.shopId == shopId);
      if (currentShop?.shopId == shopId) currentShop = null;
    } catch (e) {
      debugPrint('Lỗi xóa shop: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // lấy theo id trên firebase
  Future<ShopModel?> fetchShopForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    print('fetchShopForCurrentUser: currentUser=${user.uid}');

    isLoading = true;
    notifyListeners();

    try {
      final shop = await _repo.getShopByOwnerId(user.uid);
      print('fetchShopForCurrentUser: fetched shop=$shop');
      currentShop = shop;
      return shop;
    } catch (e) {
      print('fetchShopForCurrentUser error: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<ShopModel?> fetchShopById(String shopId) async {
    if (shopId.isEmpty) return null;
    isLoading = true;
    notifyListeners();

    try {
      final shop = await _repo.getShopById(shopId);
      currentShop = shop;
      return shop;
    } catch (e) {
      debugPrint('Lỗi fetchShopById: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<ShopModel?> fetchShopByUserId(String userId) async {
    if (userId.isEmpty) return null;

    isLoading = true;
    notifyListeners();

    try {
      final shop = await _repo.getShopByOwnerId(userId);
      currentShop = shop;
      return shop;
    } catch (e) {
      debugPrint('Lỗi fetchShopByUserId: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ShopModel>> fetchShopsByUserId(String userId) async {
    if (userId.isEmpty) return [];

    isLoading = true;
    notifyListeners();

    try {
      final result = await _repo.getShopsByOwnerId(userId);

      return result;
    } catch (e) {
      debugPrint('Lỗi fetchShopsByUserId: $e');
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  // Đếm số nhân viên trong shop
  Future<int> countStaffInShop(String shopId) async {
    if (shopId.isEmpty) return 0;

    isLoading = true;
    notifyListeners();

    try {
      final count = await _repo.countStaffByShop(shopId);
      return count;
    } catch (e) {
      debugPrint('Lỗi countStaffInShop: $e');
      return 0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> loadStaffCount(String shopId) async {
  if (shopId.isEmpty) return;

  isLoading = true;
  notifyListeners();

  try {
    staffCount = await _repo.countStaffByShop(shopId);
  } catch (e) {
    staffCount = 0;
    debugPrint('Lỗi loadStaffCount: $e');
  } finally {
    isLoading = false;
    notifyListeners();
  }
}


}
