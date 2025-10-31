class SizesModel {
  final String sizeID;
  final String name;

  SizesModel({required this.sizeID, required this.name});
  
  factory SizesModel.fromFirestore(Map<String, dynamic> json, String sizeID) {
    return SizesModel(sizeID: sizeID, name: json['name'] ?? '');
  }
  Map<String, dynamic> toFirestore() {
    return {'name': name};
  }
}