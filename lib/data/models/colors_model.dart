class ColorsModel {
  final String colorID;
  final String name;

  ColorsModel({
    required this.colorID,
    required this.name,
  });
  factory ColorsModel.fromFirestore(Map<String, dynamic> json, String colorID) {
    return ColorsModel(
      colorID: colorID,
      name: json['name'] ?? '',
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}