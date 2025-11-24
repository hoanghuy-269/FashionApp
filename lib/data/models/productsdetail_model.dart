class ProductsdetailModel {
  final String productsDetailID;
  final String productID;
  final List<String> sizeIDs;
  final String colorID;
  final String imageUrls;

  ProductsdetailModel({
    required this.productsDetailID,
    required this.productID,
    required this.sizeIDs,
    required this.colorID,
    required this.imageUrls,
  });
  factory ProductsdetailModel.fromMap(
      Map<String, dynamic> json, String productsDetailID) {
    return ProductsdetailModel(
      productsDetailID: productsDetailID,
      productID: json['productID'] ?? '',
      // support both old Map<String,bool> representation and new List<String>
      sizeIDs: (() {
        final raw = json['sizeIDs'];
        if (raw == null) return <String>[];
        if (raw is List) return raw.map((e) => e.toString()).toList();
        if (raw is Map) {
          try {
            final map = Map<String, dynamic>.from(raw);
            return map.entries
                .where((e) => e.value == true || e.value == 'true' || e.value == 1)
                .map((e) => e.key.toString())
                .toList();
          } catch (_) {
            return raw.keys.map((k) => k.toString()).toList();
          }
        }
        return <String>[];
      })(),
      colorID: json['colorID'] ?? '',
      imageUrls: json['imageUrls'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'productsDetailID': productsDetailID,
      'productID': productID,
      'sizeIDs': sizeIDs,
      'colorID': colorID,
      'imageUrls': imageUrls,
    };
  }
  ProductsdetailModel copyWith({
    String? productsDetailID,
    String? productID,
    List<String>? sizeIDs,
    String? colorID,
    List<String>? imageUrls,
  }) {
    return ProductsdetailModel(
      productsDetailID: productsDetailID ?? this.productsDetailID,
      productID: productID ?? this.productID,
      sizeIDs: sizeIDs ?? this.sizeIDs,
      colorID: colorID ?? this.colorID,
      imageUrls: imageUrls?.join(',') ?? this.imageUrls,
    );
  }
}