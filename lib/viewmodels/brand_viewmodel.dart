import 'package:fashion_app/data/models/brands_model.dart';
import 'package:fashion_app/data/repositories/brand_reporitory.dart';
import 'package:fashion_app/data/sources/brand_sources.dart';
import 'package:flutter/material.dart';

class BrandViewmodel extends ChangeNotifier {
  final BrandReporitory _repository = BrandReporitory(BrandSources());

  bool _isLoading = false;
  BrandsModel? _currentBrand;
  List<BrandsModel> _brands = [];

  bool get isLoading => _isLoading;
  BrandsModel? get currentBrand => _currentBrand;
  List<BrandsModel> get brands => _brands;

  /// Lấy brand theo ID
  Future<BrandsModel?> fetchBrandById(String? id) async {
    if (id == null) return null;
    final brand = await _repository.getBrandById(id);
    _currentBrand = brand;
    notifyListeners();
    return brand;
  }
  
  /// Lấy tất cả brand
  Future<void> fetchAllBrands() async {
    _isLoading = true;
    notifyListeners();

    _brands = await _repository.getAllBrands();

    _isLoading = false;
    notifyListeners();
  }
  
}