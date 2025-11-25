import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/product_size_model.dart';
import 'package:fashion_app/data/models/products_model.dart';
import 'package:fashion_app/data/models/shop_product_model.dart';
import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'package:fashion_app/data/models/shop_product_with_detail.dart';

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
  // lấy tổng các sản phẩm của shop
Stream<int> getTotalProductsByShopStream(String shopId) {
  return _firestore
      .collection(_collection)
      .where('shopId', isEqualTo: shopId)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
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



  // Real-time stream of shop products for a shop
  Stream<List<ShopProductModel>> getShopProductsByShopStream(String shopId) {
    try {
      return _firestore
          .collection(_collection)
          .where('shopId', isEqualTo: shopId)
          .snapshots()
          .map(
            (querySnap) =>
                querySnap.docs
                    .map((doc) => ShopProductModel.fromMap(doc.data(), doc.id))
                    .toList(),
          );
    } catch (e) {
      return Stream.value([]);
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

  Future<String?> getNameBranch(String id) async {
    final doc = await _firestore.collection('brands').doc(id).get();
    if (doc.exists) {
      return doc.data()!['name'];
    }
    return null;
  }

  Future<String?> getNameCategory(String id) async {
    final doc = await _firestore.collection('categories').doc(id).get();
    if (doc.exists) {
      return doc.data()!['categoryName'];
    }
    return null;
  }

  // lấy productis theo shopproductID
  Future<ProductsModel?> getProductOfShopProduct(String shopProductID) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(shopProductID).get();

      if (!doc.exists) return null;

      final shopProductData = doc.data()!;
      final productID = shopProductData['productID'];

      if (productID == null) return null;

      final productDoc =
          await _firestore.collection('products').doc(productID).get();

      if (!productDoc.exists) return null;

      return ProductsModel.fromMap(productDoc.data()!, productDoc.id);
    } catch (e) {
      print(' Lỗi lấy product theo shopProductID: $e');
      return null;
    }
  }

  // cập nhật totalQuantity
  Future<void> incrementTotalQuantity(
    String shopProductID,
    int additionalQty,
  ) async {
    try {
      await _firestore.collection(_collection).doc(shopProductID).update({
        'totalQuantity': FieldValue.increment(additionalQty),
      });
    } catch (e) {
      print('Lỗi khi increment totalQuantity: $e');
      rethrow;
    }
  }

  // ------------------------------- STREAMS -------------------------------//

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
              print(' Lỗi khi lấy dữ liệu productID: $productID → $e');
            }
          }

          return list;
        });
  }

  Stream<List<ShopProductWithDetail>> getAllShopProductsWithDetail() {
    try {
      print(' Bắt đầu lấy dữ liệu từ shop_products...');

      return _firestore.collection('shop_products').snapshots().asyncMap((
        shopProductsSnapshot,
      ) async {
        print(' Nhận được ${shopProductsSnapshot.docs.length} shop products');

        final List<ShopProductWithDetail> results = [];

        for (final shopProductDoc in shopProductsSnapshot.docs) {
          try {
            print('🔍 Xử lý shop product: ${shopProductDoc.id}');

            // Parse shop product data
            final shopProductData =
                shopProductDoc.data() as Map<String, dynamic>;
            final productId = shopProductData['productID'] as String?;

            if (productId == null || productId.isEmpty) {
              print(' Shop product ${shopProductDoc.id} thiếu productID');
              continue;
            }

            // Lấy product detail
            final productDoc =
                await _firestore.collection('products').doc(productId).get();
            if (!productDoc.exists) {
              print(' Không tìm thấy product với ID: $productId');
              continue;
            }

            final product = ProductsModel.fromMap(
              productDoc.data() as Map<String, dynamic>,
              productDoc.id,
            );

            print(' Product: ${product.name}');

            // Lấy tất cả variants của shop product này
            final variantsSnapshot =
                await _firestore
                    .collection('shop_products')
                    .doc(shopProductDoc.id)
                    .collection('shop_product_variants')
                    .get();

            print(' Số lượng variants: ${variantsSnapshot.docs.length}');

            // Xử lý từng variant
            double lowestPrice = double.maxFinite;
            bool hasValidPrice = false;
            List<ShopProductVariantModel> variants = []; 

            for (final variantDoc in variantsSnapshot.docs) {
              try {
                final variantData = variantDoc.data() as Map<String, dynamic>;
                print(' Variant ID: ${variantDoc.id}');
                print(' Variant data: $variantData');

                // TẠO VARIANT MODEL
                final variant = ShopProductVariantModel.fromMap(
                  variantData,
                  variantDoc.id,
                );
                variants.add(variant);

                // Lấy sizes cho variant này để tính giá
                final sizesSnapshot =
                    await _firestore
                        .collection('shop_products')
                        .doc(shopProductDoc.id)
                        .collection('shop_product_variants')
                        .doc(variantDoc.id)
                        .collection('product_sizes')
                        .get();

                print(
                  ' Số lượng sizes cho variant ${variantDoc.id}: ${sizesSnapshot.docs.length}',
                );

                // Tính lowest price từ sizes
                if (sizesSnapshot.docs.isNotEmpty) {
                  for (final sizeDoc in sizesSnapshot.docs) {
                    try {
                      final size = ProductSizeModel.fromMap(
                        sizeDoc.data() as Map<String, dynamic>,
                      );
                      if (size.price > 0 && size.price < lowestPrice) {
                        lowestPrice = size.price;
                        hasValidPrice = true;
                      }
                    } catch (e) {
                      print(' Lỗi parse size: $e');
                    }
                  }
                }
              } catch (e) {
                print(' Lỗi xử lý variant ${variantDoc.id}: $e');
              }
            }

            // Nếu không có price hợp lệ, set default
            if (!hasValidPrice) {
              lowestPrice = 0.0;
            }

            print(' Final lowest price: $lowestPrice');
            print(' Tổng số variants: ${variants.length}');

            // Tạo shop product model
            final shopProduct = ShopProductModel.fromMap(
              shopProductData,
              shopProductDoc.id,
            );

            results.add(
              ShopProductWithDetail(
                shopProduct: shopProduct,
                productDetail: product,
                lowestPrice: lowestPrice,
                variants: variants, // TRUYỀN VARIANTS
              ),
            );
          } catch (e) {
            print(' Lỗi xử lý shop product ${shopProductDoc.id}: $e');
          }
        }

        print(' Hoàn thành! Tổng sản phẩm: ${results.length}');
        return results;
      });
    } catch (e) {
      print(' Lỗi nghiêm trọng trong repository: $e');
      return Stream.value([]);
    }
  }
}
