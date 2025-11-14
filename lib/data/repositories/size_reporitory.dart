import 'package:fashion_app/data/models/sizes_model.dart';
import 'package:fashion_app/data/sources/size_source.dart';

class SizeReporitory {
  final SizeSource _sizeSource = SizeSource();
  Future<List<SizesModel>> getSizesByCategoryId(String categoryId) async {
    return await _sizeSource.getSizesByCategoryId(categoryId);
  }

  Future<void> addSize(SizesModel size) async {
    return await _sizeSource.addSize(size);
  }

  Future<String> getSizeName(String sizeID) async {
    return await _sizeSource.getSizeName(sizeID);
  }

  Future<Map<String, Map<String, dynamic>>> getAllSizes() async {
    return await _sizeSource.getAllSizes();
  }

  Future<bool> isSizeNameExists(String name, String categoryId) async {
    final sizes = await getSizesByCategoryId(categoryId);
    return sizes.any((size) => size.name.toLowerCase() == name.toLowerCase());
  }

  Future<SizesModel?> getSizeById(String sizeID) async {
    final allSizesMap = await getAllSizes();
    if (allSizesMap.containsKey(sizeID)) {
      final data = allSizesMap[sizeID]!;
      return SizesModel(
        sizeID: sizeID,
        name: data['name'] ?? '',
        categoryID: data['categoryId'] ?? '',
      );
    }
    return null;
  }
  
}
