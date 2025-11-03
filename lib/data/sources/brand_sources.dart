import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/brands_model.dart';

class BrandSources {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // lấy brand theo ID
  Future<BrandsModel?> getBrandById(String brandId) async {
    final doc = await _firestore.collection('brands').doc(brandId).get();
    if (doc.exists) {
      return BrandsModel.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }
  // lấy tất cả brand
  Future<List<BrandsModel>> getAllBrands() async {
    final query = await _firestore.collection('brands').get();
    return query.docs
        .map((doc) => BrandsModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}