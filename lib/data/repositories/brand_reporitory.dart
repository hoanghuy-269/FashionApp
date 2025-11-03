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
}