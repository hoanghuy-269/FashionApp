import 'package:flutter/material.dart';
import 'package:fashion_app/data/models/colors_model.dart';
import 'package:fashion_app/data/repositories/color_repository.dart';

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

  Future<void> addColor(String name, String hexCode) async {
    try {
      final color = ColorsModel(
        colorID: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        hexCode: hexCode,
      );

      await _repository.addColor(color);

      _colors.add(color); 
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi khi thêm màu: $e');
    }
  }

  // lay ten mau theo ID
  String? getColorNameById(String colorID) {
    try {
      final color = _colors.firstWhere((c) => c.colorID == colorID);
      return color.name;
    } catch (e) {
      debugPrint('Lỗi khi lấy tên màu theo ID: $e');
      return null;
    }
  }
}
