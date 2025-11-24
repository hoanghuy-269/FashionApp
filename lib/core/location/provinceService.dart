import 'dart:convert';

import 'package:fashion_app/data/models/location/province_model.dart';
import 'package:http/http.dart' as http;

class ProvinceService {
  
  static Future<List<ProvinceModel>> getAllProvinces() async {

    final url = Uri.parse("https://provinces.open-api.vn/api/?depth=3");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<ProvinceModel>.from(data.map((x) => ProvinceModel.fromJson(x)));
    } else {
      throw Exception('Failed to load provinces');
    }
  }
}