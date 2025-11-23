import 'dart:io';

import 'package:fashion_app/data/models/brands_model.dart';
import 'package:fashion_app/data/repositories/brand_reporitory.dart';
import 'package:fashion_app/data/sources/brand_sources.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class BrandViewmodel extends ChangeNotifier {
  final BrandReporitory _repository = BrandReporitory(BrandSources());

  bool _isLoading = false;
  List<BrandsModel> _brands = [];
  BrandsModel? _currentBrand;

  bool get isLoading => _isLoading;
  List<BrandsModel> get brands => _brands;
  BrandsModel? get currentBrand => _currentBrand;

  /// ✅ Lấy brand theo ID
  Future<BrandsModel?> fetchBrandById(String? id) async {
    if (id == null) return null;
    final brand = await _repository.getBrandById(id);
    _currentBrand = brand;
    notifyListeners();
    return brand;
  }

  /// ✅ Lấy tất cả brand
  Future<void> fetchAllBrands() async {
    _isLoading = true;
    notifyListeners();

    _brands = await _repository.getAllBrands();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBrandWithImage(String name, File? imageFile) async {
    try {
      _isLoading = true;
      notifyListeners();

      String imageUrl = "";

      if (imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("brand_logos")
            .child("brand_${DateTime.now().millisecondsSinceEpoch}.jpg");

        await storageRef.putFile(imageFile);
        imageUrl = await storageRef.getDownloadURL();
      }

      await _repository.addBrand(name, imageUrl);
      await fetchAllBrands();
    } catch (e) {
      print("🔥 ERROR addBrandWithImage: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ THÊM BRAND
  Future<void> addBrand(String name, String logoUrl) async {
    await _repository.addBrand(name, logoUrl);
    await fetchAllBrands(); // refresh lại danh sách
  }

  /// ✅ SỬA BRAND
  Future<void> updateBrand(String id, String name, String logoUrl) async {
    await _repository.updateBrand(id, name, logoUrl);
    await fetchAllBrands();
  }

  /// ✅ XÓA BRAND
  Future<void> deleteBrand(String id) async {
    await _repository.deleteBrand(id);
    await fetchAllBrands();
  }

  Future<void> updateBrandWithImage(
    String brandID,
    String name,
    File? newImageFile,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      String? uploadedUrl;

      // ✅ chỉ upload nếu có ảnh mới
      if (newImageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("brand_logos")
            .child("brand_${DateTime.now().millisecondsSinceEpoch}.jpg");

        await storageRef.putFile(newImageFile);
        uploadedUrl = await storageRef.getDownloadURL();
      }

      // ✅ Nếu có ảnh mới → update kèm ảnh
      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        await _repository.updateBrand(brandID, name, uploadedUrl);
      }
      // ✅ Nếu không có ảnh → update tên thôi, logo giữ nguyên
      else {
        final oldBrand = _brands.firstWhere((e) => e.brandID == brandID);
        await _repository.updateBrand(brandID, name, oldBrand.logoUrl);
      }

      await fetchAllBrands();
    } catch (e) {
      print("🔥 ERROR updateBrandWithImage: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

 
}
