import 'package:flutter/material.dart';
import 'package:fashion_app/data/repositories/shop_productvariant_repository.dart';

class ShopProductvariantViewmodel extends ChangeNotifier {
  final ShopProductvariantRepository _repository = ShopProductvariantRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _variants = [];
  List<Map<String, dynamic>> get variants => _variants;

  Future<void> addShopProductVariant({
    required String shopProductID,
    required Map<String, dynamic> variantData,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.addShopProductVariant(
        shopProductID: shopProductID,
        variantData: variantData,
      );

      await fetchVariants(shopProductID);
    } catch (e) {
      debugPrint(' Lỗi khi thêm biến thể: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchVariants(String shopProductID) async {
    try {
      _isLoading = true;
      notifyListeners();

      _variants = await _repository.getVariantsByShopProductID(shopProductID);
    } catch (e) {
      debugPrint(' Lỗi khi load biến thể: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVariant({
    required String shopProductID,
    required String variantID,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.updateShopProductVariant(
        shopProductID: shopProductID,
        variantID: variantID,
        updatedData: updatedData,
      );

      await fetchVariants(shopProductID);
    } catch (e) {
      debugPrint(' Lỗi khi cập nhật biến thể: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteVariant({
    required String shopProductID,
    required String variantID,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.deleteShopProductVariant(
        shopProductID: shopProductID,
        variantID: variantID,
      );

      _variants.removeWhere((v) => v['shopProductVariantID'] == variantID);
      notifyListeners();
    } catch (e) {
      debugPrint('🔥 Lỗi khi xóa biến thể: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearVariants() {
    _variants = [];
    notifyListeners();
  }
}
