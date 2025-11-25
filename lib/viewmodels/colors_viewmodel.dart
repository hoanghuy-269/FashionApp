import 'package:fashion_app/core/utils/colorhelper.dart';
import 'package:flutter/material.dart';
import 'package:fashion_app/data/models/colors_model.dart';
import 'package:fashion_app/data/repositories/color_repository.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorsViewmodel extends ChangeNotifier {
  final ColorRepository _repository = ColorRepository();

  List<ColorsModel> _colors = [];
  bool _isLoading = false;

  List<ColorsModel> get colors => _colors;
  bool get isLoading => _isLoading;

  Future<void> fetchAllColors() async {
    _isLoading = true;
    notifyListeners();

    try {
      final colorsMap = await _repository.getAllColors();
      _colors = colorsMap.entries.map((entry) {
        return ColorsModel(
          colorID: entry.key,
          name: entry.value['name'],
          hexCode: entry.value['hexCode'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Lỗi khi lấy màu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addColor(String name, String hexCode) async {
    try {
      // Tạo color model
      final color = ColorsModel(
        colorID: '',
        name: name,
        hexCode: hexCode,
      );

      // Lưu thẳng vào Firebase
      await _repository.addColor(color);
      
      // Reload lại danh sách từ Firebase
      await fetchAllColors();
      
      debugPrint('Đã thêm màu thành công: $name');
      return true;
      
    } catch (e) {
      debugPrint('Lỗi khi thêm màu: $e');
      return false;
    }
  }

  Future<Color> getColorFromFirestore(String? colorID) async {
    if (colorID == null || colorID.isEmpty) return Colors.grey;
    
    try {
      final hexCode = await _repository.getColorHexCode(colorID);
      final color = ColorHelper.hexToColor(hexCode);
      return color;
    } catch (e) {
      print('Error fetching color $colorID: $e');
      return Colors.grey;
    }
  }

  // Lấy tên màu theo ID
String getColorNameById(String colorID) {
  try {
    final color = _colors.firstWhere(
      (c) => c.colorID == colorID,
      orElse: () => ColorsModel(colorID: '', name: 'Unknown' , hexCode: '#808080'),
    );
    return color.name;
  } catch (e) {
    debugPrint('Lỗi khi lấy tên màu theo ID: $e');
    return 'Unknown';
  }
}
  

  // Lấy tên màu theo id từ Firestore
  Future<String> fetchColorName(String colorID) async {
    return await _repository.fetchColorName(colorID);
  }
}