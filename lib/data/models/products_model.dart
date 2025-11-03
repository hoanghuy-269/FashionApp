class ProductsModel {
  final String productID;
  final String name;
  final String categoryID;
  final String brandID;
  final String description;

  ProductsModel({
    required this.productID,
    required this.name,
    required this.categoryID,
    required this.brandID,
    required this.description,
  });
  factory ProductsModel.fromFirestore(
      Map<String, dynamic> json, String productID) {
    return ProductsModel(
      productID: productID,
      name: json['name'] ?? '',
      categoryID: json['categoryID'] ?? '',
      brandID: json['brandID'] ?? '',
      description: json['description'] ?? '',
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'categoryID': categoryID,
      'brandID': brandID,
      'description': description,
    };
  }
}
