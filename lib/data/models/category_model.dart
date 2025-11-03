class CategoryModel {
  final String categoryID;
  final String categoryName;
  final String logoUrl;

  CategoryModel({
    required this.categoryID,
    required this.categoryName,
    required this.logoUrl,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> json, String categoryID) {
    return CategoryModel(
      categoryID: categoryID,
      categoryName: json['categoryName'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'categoryName': categoryName,
      'logoUrl': logoUrl,
    };
  }
}
