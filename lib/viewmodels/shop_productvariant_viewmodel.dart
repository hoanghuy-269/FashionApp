import 'package:fashion_app/data/repositories/color_repository.dart';
import 'package:fashion_app/data/repositories/size_reporitory.dart';
import 'package:flutter/material.dart';
import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'package:fashion_app/data/repositories/shop_productvariant_repository.dart';

class ShopProductvariantViewmodel extends ChangeNotifier {
  final _repo = ShopProductvariantRepository();
  final _colorRepo = ColorRepository();
  final _sizeRepo = SizeReporitory();

  bool isLoading = false;
  List<ShopProductVariantModel> variants = [];
  
  Map<String, Map<String, dynamic>> _colorsCache = {}; 
  Map<String, Map<String, dynamic>> _sizesCache = {}; 

  String getColorName(String colorID) {
    final name = _colorsCache[colorID]?['name'];
    if (name == null) {
      debugPrint('⚠️ Color not found in cache: $colorID');
    }
    return name ?? 'Không rõ màu';
  }

  String getColorHex(String colorID) {
    final hex = _colorsCache[colorID]?['hexCode'];
    if (hex == null) {
      debugPrint(' Color hex not found in cache: $colorID');
    }
    return hex ?? '#808080';
  }

  String getSizeName(String sizeID) {
    final name = _sizesCache[sizeID]?['name'];
    if (name == null) {
      debugPrint('⚠️ Size not found in cache: $sizeID');
    }
    return name ?? 'Không rõ size';
  }

  Future<void> fetchVariants(String shopProductID) async {
    isLoading = true;
    notifyListeners();

    try {
      debugPrint('🔍 Fetching variants for: $shopProductID');
      
      // ✅ 1. Load colors và sizes TRƯỚC
      await _loadColorAndSizeData();
      
      // ✅ 2. Sau đó mới load variants
      variants = await _repo.getVariants(shopProductID);
      
      debugPrint('✅ Loaded ${variants.length} variants');
      debugPrint('✅ Colors cache: ${_colorsCache.length} items');
      debugPrint('✅ Sizes cache: ${_sizesCache.length} items');
      
    } catch (e) {
      debugPrint('❌ Error in fetchVariants: $e');
      variants = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Private method để load color và size data
  Future<void> _loadColorAndSizeData() async {
    try {
      debugPrint('📦 Loading colors and sizes...');
      
      // Load colors
      _colorsCache = await _colorRepo.getAllColors();
      debugPrint('✅ Loaded ${_colorsCache.length} colors');
      
      // Load sizes
      _sizesCache = await _sizeRepo.getAllSizes();
      debugPrint('✅ Loaded ${_sizesCache.length} sizes');
      
      // Debug: In ra một vài items để check
      if (_colorsCache.isNotEmpty) {
        final firstColor = _colorsCache.entries.first;
        debugPrint('   Sample color: ${firstColor.key} = ${firstColor.value}');
      }
      if (_sizesCache.isNotEmpty) {
        final firstSize = _sizesCache.entries.first;
        debugPrint('   Sample size: ${firstSize.key} = ${firstSize.value}');
      }
      
    } catch (e) {
      debugPrint('❌ Error loading color/size data: $e');
      _colorsCache = {};
      _sizesCache = {};
    }
  }

  /// Thêm biến thể mới
  Future<void> addVariant(String shopProductID, Map<String, dynamic> data) async {
    try {
      await _repo.addVariant(shopProductID, data);
      await fetchVariants(shopProductID);
    } catch (e) {
      debugPrint('❌ Error adding variant: $e');
      rethrow;
    }
  }

  /// Cập nhật biến thể
  Future<void> updateVariant(String shopProductID, String variantID, Map<String, dynamic> data) async {
    try {
      await _repo.updateVariant(shopProductID, variantID, data);
      await fetchVariants(shopProductID);
    } catch (e) {
      debugPrint('❌ Error updating variant: $e');
      rethrow;
    }
  }

  /// Xóa biến thể
  Future<void> deleteVariant(String shopProductID, String variantID) async {
    try {
      await _repo.deleteVariant(shopProductID, variantID);
      variants.removeWhere((v) => v.shopProductVariantID == variantID);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error deleting variant: $e');
      rethrow;
    }
  }

  /// Dọn sạch danh sách
  void clear() {
    variants.clear();
    _colorsCache.clear();
    _sizesCache.clear();
    notifyListeners();
  }

  /// ✅ BONUS: Method để refresh cache (nếu admin thêm màu/size mới)
  Future<void> refreshCache() async {
    await _loadColorAndSizeData();
    notifyListeners();
  }
}