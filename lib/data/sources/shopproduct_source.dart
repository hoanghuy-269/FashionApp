import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/products_model.dart';
import 'package:fashion_app/data/models/shop_product_model.dart';
import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'package:fashion_app/data/models/shop_product_with_detail.dart';
import 'package:rxdart/rxdart.dart';

class ShopproductSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'shop_products';

  Future<String> addShopProduct(ShopProductModel model) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      // ensure the stored document has the generated id
      final data = model.toMap()..['shopproductID'] = docRef.id;
      await docRef.set(data);
      return docRef.id;
    } catch (e) {
      print(' Lỗi khi thêm sản phẩm shop: $e');
      rethrow;
    }
  }

  Future<List<ShopProductModel>> getShopProductsByShop(String shopId) async {
    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('shopId', isEqualTo: shopId)
              .get();

      return snapshot.docs
          .map((doc) => ShopProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateShopProduct(ShopProductModel model) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(model.shopproductID)
          .update(model.toMap());
    } catch (e) {
      print(' Lỗi khi cập nhật sản phẩm shop: $e');
      rethrow;
    }
  }

  Future<void> deleteShopProduct(String shopProductID) async {
    try {
      await _firestore.collection(_collection).doc(shopProductID).delete();
    } catch (e) {
      print(' Lỗi khi xóa sản phẩm shop: $e');
      rethrow;
    }
  }

  Future<ShopProductModel?> getShopProductById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return ShopProductModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print(' Lỗi khi lấy chi tiết sản phẩm shop: $e');
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> getProductsByShopProduct(String shopId) {
    return _firestore
        .collection(_collection)
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> list = [];

          for (var doc in snapshot.docs) {
            final shopData = doc.data();
            final productID = shopData['productID'];

            try {
              final productDoc =
                  await _firestore.collection('products').doc(productID).get();
              final productData = productDoc.data();

              final combinedData = {
                'shopproductID': doc.id,
                'shop': shopData,
                'product': productData,
              };

              list.add(combinedData);
            } catch (e) {
              print('⚠️ Lỗi khi lấy dữ liệu productID: $productID → $e');
            }
          }

          return list;
        });
  }

  Stream<List<ShopProductWithDetail>> getAllShopProductsWithDetail() {
    final shopProductsRef = _firestore.collection(_collection);

    // Lắng nghe shop_products realtime
    return shopProductsRef.snapshots().switchMap((snapshot) {
      // Tạo danh sách Stream cho từng sản phẩm
      final List<Stream<ShopProductWithDetail?>> streams =
          snapshot.docs.map((doc) {
            final shopProduct = ShopProductModel.fromMap(doc.data(), doc.id);

            // Stream realtime cho product
            final productStream =
                _firestore
                    .collection('products')
                    .doc(shopProduct.productID)
                    .snapshots();

            // Stream realtime cho variants
            final variantsStream =
                _firestore
                    .collection('shop_products')
                    .doc(shopProduct.shopproductID)
                    .collection('shop_product_variants')
                    .snapshots();

            // Kết hợp product và variants
            return Rx.combineLatest2(productStream, variantsStream, (
              DocumentSnapshot productDoc,
              QuerySnapshot variantsSnapshot,
            ) {
              if (!productDoc.exists) return null;

              final product = ProductsModel.fromMap(
                productDoc.data()! as Map<String, dynamic>,
                productDoc.id,
              );

              final variants =
                  variantsSnapshot.docs.map((variantDoc) {
                    return ShopProductVariantModel.fromMap(
                      variantDoc.data() as Map<String, dynamic>,
                      variantDoc.id,
                    );
                  }).toList();

              final lowestPrice =
                  variants.isNotEmpty
                      ? variants
                          .map((v) => v.price)
                          .reduce((a, b) => a < b ? a : b)
                      : 0.0;

              return ShopProductWithDetail(
                shopProduct: shopProduct,
                productDetail: product,
                lowestPrice: lowestPrice,
              );
            });
          }).toList();

      // Kết hợp tất cả shop products thành 1 list
      return streams.isNotEmpty
          ? Rx.combineLatestList(
            streams,
          ).map((list) => list.whereType<ShopProductWithDetail>().toList())
          : Stream.value([]);
    });
  }
}
