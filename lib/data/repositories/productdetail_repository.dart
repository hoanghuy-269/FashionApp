import 'package:fashion_app/data/sources/productdetal_source.dart';

class ProductDetailRepository {

  final ProductDetailSource repository = ProductDetailSource();

  Future<String> addProductDetail(String productId, Map<String, dynamic> productDetailData) async {
    return await repository.addProductDetail(productId, productDetailData);
  }

  Future<void> updateProductDetail(String productId, String productDetailId, Map<String, dynamic> updatedData) async {
    await repository.updateProductDetail(productId, productDetailId, updatedData);
  }

  Future<void> deleteProductDetail(String productId, String productDetailId) async {
    await repository.deleteProductDetail(productId, productDetailId);
  }
  Future<String?> getImageByID({
    required String productId,
    required String colorID,
  }) async {
    return await repository.getImageByColorID(
      productId: productId,
      colorID: colorID,
    );
  }

}