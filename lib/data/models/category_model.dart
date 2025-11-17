class CategoryModel {
  final String categoryID;   // chính là doc.id
  final String categoryName;
  final String logoUrl;

  CategoryModel({
    required this.categoryID,
    required this.categoryName,
    required this.logoUrl,
  });

  // Lấy từ Firestore
  factory CategoryModel.fromFirestore(Map<String, dynamic> json, String id) {
    return CategoryModel(
      categoryID: id,
      categoryName: json['categoryName'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'categoryID': categoryID,
      'categoryName': categoryName,
      'logoUrl': logoUrl,
    };
  }
}
