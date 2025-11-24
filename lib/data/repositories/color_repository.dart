import 'package:fashion_app/data/models/colors_model.dart';
import 'package:fashion_app/data/sources/color_source.dart';

class ColorRepository {
  final ColorSource _remoteSource = ColorSource();

  Future<ColorsModel> addColor(ColorsModel color) async {
    return await _remoteSource.addColor(color);
  }
  Future<String> getColorName(String colorID) async {
    return await _remoteSource.getColorName(colorID);
  }
  Future<String> getColorHexCode(String colorID) async {
    return await _remoteSource.getColorHexCode(colorID);
  }
  Future<Map<String, Map<String, dynamic>>> getAllColors() async {
    return await _remoteSource.getAllColors();
  }

  // láu ten màu theo id
  Future<String> fetchColorName(String colorID) async {
    return await _remoteSource.getColorName(colorID);
  }
  

}
