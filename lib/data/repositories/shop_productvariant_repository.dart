import 'package:fashion_app/data/sources/shop_productvariant_source.dart';

class ShopProductvariantRepository {
  final ShopProductVariantSource _source = ShopProductVariantSource();

  Future<void> addShopProductVariant({
    required String shopProductID,
    required Map<String, dynamic> variantData,
  }) async {
    await _source.addShopProductVariant(
      shopProductID: shopProductID,
      variantData: variantData,
    );
  }

  Future<List<Map<String, dynamic>>> getVariantsByShopProductID(String shopProductID) async {
    return await _source.getVariantsByShopProductID(shopProductID);
  }

  Future<void> updateShopProductVariant({
    required String shopProductID,
    required String variantID,
    required Map<String, dynamic> updatedData,
  }) async {
    await _source.updateShopProductVariant(
      shopProductID: shopProductID,
      variantID: variantID,
      updatedData: updatedData,
    );
  }

  Future<void> deleteShopProductVariant({
    required String shopProductID,
    required String variantID,
  }) async {
    try {
      await _source.deleteShopProductVariant(
        shopProductID: shopProductID,
        variantID: variantID,
      );
    } catch (e) {
      print(' Lỗi khi xóa biến thể sản phẩm shop: $e');
      rethrow;
    }
  }
}