import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/shop_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopSources {
  final _db = FirebaseFirestore.instance;

  Future<void> addShop(ShopModel shop) async {
    await _db.collection('shops').doc(shop.shopId).set(shop.toMap());
  }

  Future<void> deleteShop(String shopId) async {
    await _db.collection('shops').doc(shopId).delete();
  }

  Future<void> updateShop(ShopModel shop) async {
    await _db.collection('shops').doc(shop.shopId).update(shop.toMap());
  }

  Future<String> createShopFromMap(Map<String, dynamic> shopData) async {
    final docRef = _db.collection('shops').doc();
    final shopId = docRef.id;

    if (shopData['createdAt'] is DateTime) {
      shopData['createdAt'] =
          (shopData['createdAt'] as DateTime).toIso8601String();
    }

    shopData['shopId'] = shopId;
    await docRef.set(shopData);
    return shopId;
  }

  Future<List<ShopModel>> getShops() async {
    final query = await _db.collection('shops').get();

    return query.docs.map((e) {
      final data = e.data();
      data['shopId'] = e.id;
      return ShopModel.fromtoMap(data);
    }).toList();
  }

  Future<ShopModel?> getShopById(String shopId) async {
    final doc = await _db.collection('shops').doc(shopId).get();

    if (doc.exists) {
      final data = doc.data()!;
      data['shopId'] = doc.id;
      return ShopModel.fromtoMap(data);
    }
    return null;
  }

  Future<ShopModel?> getShopByOwnerId(String ownerId) async {
    final query =
        await _db
            .collection('shops')
            .where('userId', isEqualTo: ownerId)
            .limit(1)
            .get();
    if (query.docs.isNotEmpty) {
      final e = query.docs.first;
      final data = e.data();
      data['shopId'] = e.id;
      return ShopModel.fromtoMap(data);
    }
    return null;
  }
  Future<List<ShopModel>> getShopsByOwnerId(String ownerId) async {
    final query =
        await _db.collection('shops').where('userId', isEqualTo: ownerId).get();
    return query.docs.map((e) {
      final data = e.data();
      data['shopId'] = e.id;
      return ShopModel.fromtoMap(data);
    }).toList();
  }

  Future<int> countStaffByShop(String shopId) async {
    final q =
        await _db.collection('shops').doc(shopId).collection('staff').get();

    return q.size;
  }

}
