import 'package:fashion_app/data/models/product_request_model.dart';
import 'package:fashion_app/data/repositories/product_request_repository.dart';
import 'package:flutter/material.dart';

class ShopProductRequestViewmodel extends ChangeNotifier{
 final ProductRequestRepository _repository = ProductRequestRepository();

 bool isLoading = false;
  List<ProductRequestModel> requests = [];
  

  // Lấy yêu cầu theo shopProductID cụ thể
  Future<void> fetchRequestsByShopProduct(String shopProductID) async {
    isLoading = true;
    notifyListeners();

    try {
      requests = await _repository.getRequestsByShopProduct(shopProductID);
    } catch (e) {
      requests = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

 

  // Thêm yêu cầu sản phẩm mới
  Future<String?> addProductRequest(ProductRequestModel model) async {
    try {
      final requestID = await _repository.addProductRequest(model);
      return requestID;
    } catch (e) {
      return null;
    }
  }

  // Cập nhật trạng thái
  Future<bool> updateStatus(String productRequestID, String status) async {
    try {
      await _repository.updateStatus(productRequestID, status);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Xóa yêu cầu sản phẩm
  Future<bool> deleteProductRequest(String productRequestID) async {
    try {
      await _repository.deleteProductRequest(productRequestID);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchAllRequestsByShop(String shopId) async {
    isLoading = true;
    notifyListeners();

    try {
      requests = await _repository.getAllRequestsByShop(shopId);
    } catch (e) {
      requests = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> approvedRequest(String productRequestID) async {
    try {
      await _repository.approvedRequest(productRequestID);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Stream to watch all requests for a shop in real-time
  Stream<List<ProductRequestModel>> getAllRequestsByShopStream(String shopId) {
    return _repository.getAllRequestsByShopStream(shopId);
  }
  // lấy tổng số lượng yêu cầu sản phẩm theo shopId
  Stream<int> getTotalProductRequestsByShopStream(String shopId) {
    try {
      return _repository.getTotalProductRequestsByShopStream(shopId);
    } catch (e) {
      return Stream.value(0);
      
    }
  }
}