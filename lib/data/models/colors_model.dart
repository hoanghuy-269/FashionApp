class ColorsModel {
  final String colorID;
  final String name;
  final String hexCode;

  ColorsModel({
    required this.colorID,
    required this.name,
    required this.hexCode,
  });
  factory ColorsModel.fromFirestore(Map<String, dynamic> json, String colorID) {
    return ColorsModel(
      colorID: json['colorID'] ?? colorID,
      name: json['name'] ?? '',
      hexCode: json['hexCode'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'colorID': colorID,
      'name': name,
      'hexCode': hexCode,
    };
  }

  copyWith({
    String? colorID,
    String? name,
    String? hexCode, 
  }) {
    return ColorsModel(
      colorID: colorID ?? this.colorID,
      name: name ?? this.name,
      hexCode: hexCode ?? this.hexCode,
    );
  }
}