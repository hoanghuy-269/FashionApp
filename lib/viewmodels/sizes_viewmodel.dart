import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/sizes_model.dart';
import 'package:fashion_app/data/repositories/size_reporitory.dart';
import 'package:flutter/material.dart';

class SizesViewmodel extends ChangeNotifier {
  final SizeReporitory _sizes = SizeReporitory();

  List<SizesModel> sizesList = [];
  bool isLoading = false;

  Future<void> fetchSizes(String categoryId) async {
    isLoading = true;
    notifyListeners();

    try {
      print(" $categoryId");
      sizesList = await _sizes.getSizesByCategoryId(categoryId);
      print("Sizes loaded: ${sizesList.length}");
    } catch (e) {
      debugPrint("Lỗi khi load sizes: $e");
      sizesList = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addSize(SizesModel size) async {
    isLoading = true;
    notifyListeners();

    try {
      await _sizes.addSize(size);
      sizesList.add(size);
    } catch (e) {
      debugPrint('Lỗi khi thêm size: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> generateSizeId() async {
    final snapshot = await FirebaseFirestore.instance.collection('sizes').get();
    final count = snapshot.docs.length + 1;
    return 'size_${count.toString().padLeft(3, '0')}';
  }
  
  // kiêm tra tên size đã tồn tại chưa
  Future<bool> isSizeNameExists(String name, String categoryId) async {
    return await _sizes.isSizeNameExists(name, categoryId);
  }

  // lấy size theo ID
  Future<SizesModel?> getSizeById(String sizeID) async {
    try {
      return await _sizes.getSizeById(sizeID);
    } catch (e) {
      debugPrint('Lỗi khi lấy size theo ID: $e');
      return null;
    }
  }
  
  
}
