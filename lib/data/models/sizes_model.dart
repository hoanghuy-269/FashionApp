class SizesModel {
  final String sizeID;
  final String categoryID;
  final String name;

  SizesModel({required this.sizeID, required this.categoryID, required this.name});

  factory SizesModel.fromFirestore(Map<String, dynamic> json, String sizeID) {
    return SizesModel(
      sizeID: sizeID,
      categoryID: json['categoryID'] ?? '',
      name: json['name'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'sizeID': sizeID,
      'categoryID': categoryID,
      'name': name,
    };
  }
}