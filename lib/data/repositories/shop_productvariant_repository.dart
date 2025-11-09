import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'package:fashion_app/data/sources/shop_productvariant_source.dart';

class ShopProductvariantRepository {
  final ShopProductVariantSource _source = ShopProductVariantSource();

  /// Lấy danh sách biến thể theo ID sản phẩm
  Future<List<ShopProductVariantModel>> getVariants(String shopProductID) {
    return _source.getVariants(shopProductID);
  }

  /// Thêm biến thể mới
  Future<void> addVariant(String shopProductID, Map<String, dynamic> data) {
    return _source.addVariant(shopProductID, data);
  }

  /// Cập nhật biến thể
  Future<void> updateVariant(String shopProductID, String variantID, Map<String, dynamic> data) {
    return _source.updateVariant(shopProductID, variantID, data);
  }

  /// Xóa biến thể
  Future<void> deleteVariant(String shopProductID, String variantID) {
    return _source.deleteVariant(shopProductID, variantID);
  }

  
}
