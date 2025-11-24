import 'package:fashion_app/data/models/product_request_model.dart';
import 'package:fashion_app/data/sources/shop_product_request_sources.dart';

class ProductRequestRepository {
  final ShopProductRequestSources _source = ShopProductRequestSources();

  Future<String> addProductRequest(model) => _source.addProductRequest(model);
  Future<void> updateStatus(String productRequestID, String status) =>
      _source.updateStatus(productRequestID, status);
  Future<void> deleteProductRequest(String productRequestID) =>
      _source.deleteProductRequest(productRequestID);
  Future<List<ProductRequestModel>> getRequestsByShopProduct(
    String shopProductID,
  ) => _source.getRequestsByShopProduct(shopProductID);
  Future<List<ProductRequestModel>> getAllRequestsByShop(String shopId) =>
      _source.getAllRequestsByShop(shopId);

  // Expose stream from source for real-time updates
  Stream<List<ProductRequestModel>> getAllRequestsByShopStream(String shopId) =>
      _source.getAllRequestsByShopStream(shopId);

  Future<void> approvedRequest(String productRequestID) =>
      _source.approvedRequest(productRequestID);
  // lấy tổng số lượng yêu cầu sản phẩm theo shopId
  Stream<int> getTotalProductRequestsByShopStream(String shopId) {
    return _source.getTotalPendingRequestsByShopStream(shopId);
  }
}
