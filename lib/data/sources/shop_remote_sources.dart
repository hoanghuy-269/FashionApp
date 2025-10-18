import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/shop_model.dart';

class ShopRemoteSources {
  final _db = FirebaseFirestore.instance;

  Future<void> addShop(ShopModel shop) async {
    await _db.collection('shops').doc(shop.shopId).set(shop.toMap());
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
}
