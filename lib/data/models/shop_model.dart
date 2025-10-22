class ShopModel {
  final String shopId;
  final String userId;
  final String? yeuCauMoShopId;
  final String shopName;
  final String? logo;
  final int? phoneNumber;
  final String? address;
  final String? ownerEmail;
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
      this.ownerEmail,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ShopModel.fromtoMap(Map<String, dynamic> json) {
    return ShopModel(
      shopId: json['shopId'],
      userId: json['userId'],
      yeuCauMoShopId: json['yeuCauMoShopId'],
      shopName: json['shopName'],
      logo: json['logo'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      ownerEmail: json['ownerEmail'],
      totalProducts: json['totalProducts'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      activityStatusId: json['activityStatusId'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'userId': userId,
      'yeuCauMoShopId': yeuCauMoShopId,
      'shopName': shopName,
      'logo': logo,
      'phoneNumber': phoneNumber,
      'address': address,
      'ownerEmail': ownerEmail,
      'totalProducts': totalProducts,
      'totalOrders': totalOrders,
      'revenue': revenue,
      'createdAt': createdAt.toIso8601String(),
      'activityStatusId': activityStatusId,
    };
  }

}

