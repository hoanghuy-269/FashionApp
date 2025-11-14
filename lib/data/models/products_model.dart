class ProductsModel {
  final String productID;
  final String name;
  final String categoryID;
  final String brandID;

  ProductsModel({
    required this.productID,
    required this.name,
    required this.categoryID,
    required this.brandID,
  });
  factory ProductsModel.fromMap(Map<String, dynamic> json, String productID) {
    return ProductsModel(
      productID: productID,
      name: json['name'] ?? '',
      categoryID: json['categoryID'] ?? '',
      brandID: json['brandID'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productID': productID,
      'categoryID': categoryID,
      'brandID': brandID,
      'name': name,
    };
  }

  ProductsModel copyWith({
    String? productID,
    String? name,
    String? categoryID,
    String? brandID,
  }) {
    return ProductsModel(
      productID: productID ?? this.productID,
      name: name ?? this.name,
      categoryID: categoryID ?? this.categoryID,
      brandID: brandID ?? this.brandID,
    );
  }
}
