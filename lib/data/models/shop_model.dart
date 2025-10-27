class ShopModel {
  final String shopId;
  final String userId;
  final String? requestId;
  final String shopName;
  final String? logo;
  final int? phoneNumber;
  final String? address;
  final String? businessLicense;
  final String nationalId;
  final String idnationFront;
  final String idnationBack;
  final String? ownerEmail;
  final int totalProducts;
  final int totalOrders;
  final double revenue;
  
  final DateTime createdAt;
  final String activityStatusId;

  ShopModel({
    required this.shopId,
    required this.userId,
    this.requestId,
    required this.shopName,
    this.logo,
    this.phoneNumber,
    this.address,
    this.businessLicense,
    this.nationalId = '',
    this.idnationFront = '',
    this.idnationBack = '',
    this.totalProducts = 0,
    this.totalOrders = 0,
    this.revenue = 0.0,
    DateTime? createdAt,
    required this.activityStatusId,
    this.ownerEmail,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ShopModel.fromtoMap(Map<String, dynamic> map) {
    return ShopModel(
      shopId: map['shopId'],
      userId: map['userId'],
      requestId: map['requestId'] ?? map['yeuCauMoShopId'],
      shopName: map['shopName'],
      logo: map['logo'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
  businessLicense: map['businessLicense'],
  nationalId: map['nationalId'] ?? '',
  idnationFront: map['idnationFront'] ?? '',
  idnationBack: map['idnationBack'] ?? '',
      ownerEmail: map['ownerEmail'],
      totalProducts: map['totalProducts'] ?? 0,
      totalOrders: map['totalOrders'] ?? 0,
      revenue: (map['revenue'] ?? 0).toDouble(),
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      activityStatusId: map['activityStatusId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'userId': userId,
      'requestId': requestId,
      'shopName': shopName,
      'logo': logo,
      'businessLicense': businessLicense,
      'phoneNumber': phoneNumber,
      'address': address,
      'nationalId': nationalId,
      'idnationFront': idnationFront,
      'idnationBack': idnationBack,
      'ownerEmail': ownerEmail,
      'totalProducts': totalProducts,
      'totalOrders': totalOrders,
      'revenue': revenue,
      'createdAt': createdAt.toIso8601String(),
      'activityStatusId': activityStatusId,
    };
  }
  ShopModel copyWith({
    String? shopId,
    String? userId,
    String? requestId,
    String? shopName,
    String? logo,
    int? phoneNumber,
    String? address,
    String? ownerEmail,
  String? businessLicense,
  String? nationalId,
  String? idnationFront,
  String? idnationBack,
    int? totalProducts,
    int? totalOrders,
    double? revenue,
    DateTime? createdAt,
    String? activityStatusId,
  }) {
    return ShopModel(
      shopId: shopId ?? this.shopId,
      userId: userId ?? this.userId,
      requestId: requestId ?? this.requestId,
      shopName: shopName ?? this.shopName,
      logo: logo ?? this.logo,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      ownerEmail: ownerEmail ?? this.ownerEmail,
  businessLicense: businessLicense ?? this.businessLicense,
  nationalId: nationalId ?? this.nationalId,
  idnationFront: idnationFront ?? this.idnationFront,
  idnationBack: idnationBack ?? this.idnationBack,
      totalProducts: totalProducts ?? this.totalProducts,
      totalOrders: totalOrders ?? this.totalOrders,
      revenue: revenue ?? this.revenue,
      createdAt: createdAt ?? this.createdAt,
      activityStatusId: activityStatusId ?? this.activityStatusId,
    );
  }
}
