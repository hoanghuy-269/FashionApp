class CategoryModel {
  final String categoryID;   
  final String categoryName;
  final String logoUrl;

  CategoryModel({
    required this.categoryID,
    required this.categoryName,
    required this.logoUrl,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> json, String id) {
    return CategoryModel(
      categoryID: id,
      categoryName: json['categoryName'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
    );
  }

  get id => null;
  Map<String, dynamic> toMap() {
    return {
      'categoryID': categoryID,
      'categoryName': categoryName,
      'logoUrl': logoUrl,
    };
  }
}
