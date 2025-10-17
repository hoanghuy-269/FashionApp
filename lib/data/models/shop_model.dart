class ShopModel {
  final String shopId;
  final String userId;
  final String? yeuCauMoShopId;
  final String shopName;
  final String? logo;
  final int? phoneNumber;
  final String? address;
  final int totalProducts;
  final int totalOrders;
  final double revenue;
  final DateTime createdAt;
  final String activityStatusId;

  ShopModel({
    required this.shopId,
    required this.userId,
    this.yeuCauMoShopId,
    required this.shopName,
    this.logo,
    this.phoneNumber,
    this.address,
    this.totalProducts = 0,
    this.totalOrders = 0,
    this.revenue = 0.0,
    DateTime? createdAt,
    required this.activityStatusId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      shopId: json['shopId'],
      userId: json['userId'],
      yeuCauMoShopId: json['yeuCauMoShopId'],
      shopName: json['shopName'],
      logo: json['logo'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      totalProducts: json['totalProducts'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      activityStatusId: json['activityStatusId'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'userId': userId,
      'yeuCauMoShopId': yeuCauMoShopId,
      'shopName': shopName,
      'logo': logo,
      'phoneNumber': phoneNumber,
      'address': address,
      'totalProducts': totalProducts,
      'totalOrders': totalOrders,
      'revenue': revenue,
      'createdAt': createdAt.toIso8601String(),
      'activityStatusId': activityStatusId,
    };
  }
}

