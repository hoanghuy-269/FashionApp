import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/shop_product_variant_model.dart';
import 'package:fashion_app/data/repositories/shop_productvariant_repository.dart';
import 'package:flutter/material.dart';

class ShopProductVariantViewModel extends ChangeNotifier {
  final _repo = ShopProductvariantRepository();
  final _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  List<ShopProductVariantModel> variants = [];

  Future<void> fetchVariants(String shopProductID) async {
    isLoading = true;
    notifyListeners();

    try {
      variants = await _repo.getVariants(shopProductID);
    } catch (e) {
      debugPrint('Error fetching variants: $e');
      variants = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> addVariant(String shopProductID, Map<String, dynamic> data) async {
    final variantId = await _repo.addVariant(shopProductID, data);
    await fetchVariants(shopProductID);
    return variantId;
  }

  Future<void> updateVariant(String shopProductID, String variantID, Map<String, dynamic> data) async {
    await _repo.updateVariant(shopProductID, variantID, data);
    await fetchVariants(shopProductID);
  }

  Future<void> updateMultipleVariants(
      String shopProductID, Map<String, Map<String, dynamic>> dataToUpdate) async {
    await _repo.updateMultipleVariants(shopProductID, dataToUpdate);
    await fetchVariants(shopProductID);
  }

  Future<void> deleteVariant(String shopProductID, String variantID) async {
    await _repo.deleteVariant(shopProductID, variantID);
    variants.removeWhere((v) => v.shopProductVariantID == variantID);
    notifyListeners();
  }

  Future<String?> getColorName(String? colorID) async {
    if (colorID == null || colorID.isEmpty) return null;
    
    try {
      final doc = await _firestore.collection('colors').doc(colorID).get();
      
      if (doc.exists) {
        final data = doc.data();
        return data?['name'] ?? data?['name'] ?? colorID;
      }
      
      return colorID;
    } catch (e) {
      debugPrint('Error fetching color name: $e');
      return colorID;
    }
  }
  void clear() {
    variants.clear();
    notifyListeners();
  }
}