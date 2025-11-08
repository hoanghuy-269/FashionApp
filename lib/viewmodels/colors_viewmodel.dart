import 'package:flutter/material.dart';
import 'package:fashion_app/data/models/colors_model.dart';
import 'package:fashion_app/data/repositories/color_repositories.dart';

class ColorsViewmodel extends ChangeNotifier {
  final ColorRepositories _repository = ColorRepositories();

  List<ColorsModel> _colors = [];
  bool _isLoading = false;

  List<ColorsModel> get colors => _colors;
  bool get isLoading => _isLoading;

  Future<void> fetchColors() async {
    _isLoading = true;
    notifyListeners();

    try {
      _colors = await _repository.getAllColors();
    } catch (e) {
      debugPrint('Lỗi khi load màu: $e');
    }

    _isLoading = false;
    notifyListeners();
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
}
