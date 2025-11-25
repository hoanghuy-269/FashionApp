import 'package:fashion_app/data/models/products_model.dart';
import 'package:fashion_app/data/sources/product_source.dart';

class ProductsRepository {
  final ProductSource _productSource = ProductSource();

  Future<String> addProduct(Map<String, dynamic> productData) async {
    return await _productSource.addProduct(productData);
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> updatedData) async {
    await _productSource.updateProduct(productId, updatedData);
  }

  Future<void> deleteProduct(String productId) async {
    await _productSource.deleteProduct(productId);
  }
 Future<List<ProductsModel>> getProductsByBrandAndCategory(String brandID, String categoryID) async {
    return await _productSource.getProductsByBrandAndCategory(brandID, categoryID);
  }
}