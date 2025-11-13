class BrandsModel {
  final String brandID;
  final String name;
  final String logoUrl;

  BrandsModel({
    required this.brandID,
    required this.name,
    required this.logoUrl,
  });

  factory BrandsModel.fromFirestore(Map<String, dynamic> json, String brandID) {
    return BrandsModel(
      brandID: brandID,
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'brandID': brandID,
      'name': name,
      'logoUrl': logoUrl,
    };
  }
}