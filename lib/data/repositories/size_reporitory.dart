import 'dart:ui';

import 'package:fashion_app/data/models/sizes_model.dart';
import 'package:fashion_app/data/sources/size_source.dart';

class SizeReporitory {
  final SizeSource _sizeSource = SizeSource();

 Future<List<SizesModel>> getSizesByCategoryId(String categoryId) {
    return _sizeSource.getSizesByCategoryId(categoryId);
  }
  
  Future<void> addSize(SizesModel size) {
    return _sizeSource.addSize(size);
  }
}