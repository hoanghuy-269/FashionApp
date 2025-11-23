import 'package:fashion_app/data/models/product_size_model.dart';
import 'package:fashion_app/data/sources/product_size_source.dart';

class ProductSizeRepository {
  final ProductSizeSource _source = ProductSizeSource();

Future<List<ProductSizeModel>> getAllSizes() async {
  final rawSizes = await _source.getAllSizes();
  return rawSizes;
}


  /// Thêm size mới cho biến thể sản phẩm
  Future<String> addProductSize(
    String shopProductID,
    String variantID,
    ProductSizeModel size,
  ) async {
    final newId = await _source.addProductSize(
      shopProductID,
      variantID,
      size,
    );
    return newId;
  }

 Future<void> updateProductSize(
  String shopProductID,
  String variantID,
  String sizeID,
  ProductSizeModel size,
) async {
  await _source.updateProductSize(shopProductID, variantID, sizeID, size);
}

  /// Xóa size
  Future<void> deleteProductSize(
    String shopProductID,
    String variantID,
    String sizeID,
  ) async {
    await _source.deleteProductSize(shopProductID, variantID, sizeID);
  }

  // add or update size
  Future<String> addOrUpdateSize({
    required String shopProductID,
    required String variantID,
    required ProductSizeModel size,
  }) async {
    return await _source.addOrUpdateSize(
      shopProductID: shopProductID,
      variantID: variantID,
      size: size,
    );
  }
}
