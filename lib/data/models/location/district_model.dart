import 'package:fashion_app/data/models/location/ward_model.dart';

class District {
  final String name;
  final int code;
  final List<WardModel> wards;

  District({required this.name, required this.code, required this.wards});

  factory District.fromJson(Map<String, dynamic> json) {
    var wardList = <WardModel>[];
    if (json['wards'] != null) {
      wardList = List<WardModel>.from(
          json['wards'].map((x) => WardModel.fromJson(x)));
    }
    return District(
      name: json['name'],
      code: json['code'],
      wards: wardList,
    );
  }
}