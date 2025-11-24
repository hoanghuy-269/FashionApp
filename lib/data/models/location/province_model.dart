import 'package:fashion_app/data/models/location/district_model.dart';

class ProvinceModel {
  final String name;
  final int code;
  final List<District> districts;

  ProvinceModel({
    required this.name,
    required this.code,
    required this.districts,
  });
  factory ProvinceModel.fromJson(Map<String, dynamic> json) {
    var districtList = <District>[];
    if (json['districts'] != null) {
      districtList = List<District>.from(
        json['districts'].map((x) => District.fromJson(x)),
      );
    }
    return ProvinceModel(
      name: json['name'],
      code: json['code'],
      districts: districtList,
    );
  }
}
