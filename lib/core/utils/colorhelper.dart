// utils/color_helper.dart
import 'package:flutter/material.dart';

class ColorHelper {
  static Color hexToColor(String hexCode) {
    try {
      // Loại bỏ # nếu có
      hexCode = hexCode.replaceAll('#', '');
      
      // Thêm FF (opacity) nếu chỉ có 6 ký tự
      if (hexCode.length == 6) {
        hexCode = 'FF$hexCode';
      }
      
      return Color(int.parse(hexCode, radix: 16));
    } catch (e) {
      print('Error parsing color: $hexCode - $e');
      return Colors.grey;
    }
  }
}