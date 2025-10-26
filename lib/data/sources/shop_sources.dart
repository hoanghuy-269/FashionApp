import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/shop_model.dart';

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


  Future<int> _getNextShopSequence() async {
    final counterRef = _db.collection('counters').doc('shops');

    final next = await _db.runTransaction<int>((tx) async {
      final snapshot = await tx.get(counterRef);
      int nextVal = 1;
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['last'] is int) {
          nextVal = (data['last'] as int) + 1;
          tx.update(counterRef, {'last': nextVal});
        } else {
          nextVal = 1;
          tx.set(counterRef, {'last': nextVal});
        }
      } else {
        tx.set(counterRef, {'last': nextVal});
      }
      return nextVal;
    });

    return next;
  }


  Future<String> createShopFromMap(Map<String, dynamic> shopData) async {
    final seq = await _getNextShopSequence();
    final shopId = seq.toString().padLeft(5, '0');

    if (shopData['createdAt'] is DateTime) {
      shopData['createdAt'] = (shopData['createdAt'] as DateTime).toIso8601String();
    }

    shopData['shopId'] = shopId;
    await _db.collection('shops').doc(shopId).set(shopData);
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
    final query = await _db.collection('shops').where('userId', isEqualTo: ownerId).limit(1).get();
    if (query.docs.isNotEmpty) {
      final e = query.docs.first;
      final data = e.data();
      data['shopId'] = e.id;
      return ShopModel.fromtoMap(data);
    }
    return null;
  }

  Future<List<ShopModel>> getShopsByOwnerId(String ownerId) async {
    final query = await _db.collection('shops').where('userId', isEqualTo: ownerId).get();
    return query.docs.map((e) {
      final data = e.data();
      data['shopId'] = e.id;
      return ShopModel.fromtoMap(data);
    }).toList();
  }
}
