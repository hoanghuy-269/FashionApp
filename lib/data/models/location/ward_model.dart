class WardModel {
  final String name;
  final int code;

  WardModel({required this.name, required this.code});
  factory WardModel.fromJson(Map<String, dynamic> json) {
    return WardModel(
      name: json['name'],
      code: json['code'],
    );
  }
  
}