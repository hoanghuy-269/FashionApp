import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'package:fashion_app/data/sources/shop_productvariant_source.dart';

class ShopProductvariantRepository {
  final _source = ShopProductVariantSource();

  Future<List<ShopProductVariantModel>> getVariants(String shopProductID) {
    return _source.getVariants(shopProductID);
  }

  Future<String> addVariant(String shopProductID, Map<String, dynamic> data) {
    return _source.addVariant(shopProductID, data);
  }

  Future<void> updateVariant(String shopProductID, String variantID, Map<String, dynamic> data) {
    return _source.updateVariant(shopProductID, variantID, data);
  }
  Future<void> deleteVariant(String shopProductID, String variantID) {
    return _source.deleteVariant(shopProductID, variantID);
  }

  Future<void> updateMultipleVariants(String shopProductID, Map<String, Map<String, dynamic>> dataToUpdate) {
    return _source.updateMultipleVariants(shopProductID, dataToUpdate);
  }
  Future<String?> getVariantIdByColor(String shopProductId, String colorId) {
    return _source.getVariantIdByColor(shopProductId, colorId);
  }
}