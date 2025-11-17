import 'package:fashion_app/data/models/brands_model.dart';
import 'package:fashion_app/data/sources/brand_sources.dart';

class BrandReporitory {
  final BrandSources _source;
  
  BrandReporitory(this._source);

  Future<BrandsModel?> getBrandById(String brandId) async {
    try {
      return await _source.getBrandById(brandId);
    } catch (e) {
      print('Error fetching brand: $e');
      return null;
    }
  }

  Future<List<BrandsModel>> getAllBrands() async {
    try {
      return await _source.getAllBrands();
    } catch (e) {
      print('Error fetching all brands: $e');
      return [];
    }
  }

  // ✅ THÊM BRAND
  Future<void> addBrand(String name, String logo) async {
    try {
      await _source.addBrand(name, logo);
    } catch (e) {
      print("Add brand error: $e");
    }
  }

  // ✅ SỬA BRAND
  Future<void> updateBrand(String id, String name, String logo) async {
    try {
      await _source.updateBrand(id, name, logo);
    } catch (e) {
      print("Update brand error: $e");
    }
  }

  // ✅ XÓA BRAND
  Future<void> deleteBrand(String id) async {
    try {
      await _source.deleteBrand(id);
    } catch (e) {
      print("Delete brand error: $e");
    }
  }  
}
