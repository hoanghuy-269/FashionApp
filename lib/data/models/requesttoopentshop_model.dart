import 'package:cloud_firestore/cloud_firestore.dart';

class RequesttoopentshopModel {
  final String requestId;
  final String userId;
  final String? shopId;
  final String shopName;
  final String? businessLicense; // giấy phép kinh doanh
  final String nationalId; // căn cước công dân
  final String idnationFront;
  final String idnationBack;
  final String address;
  final String status; // trạng thái yêu cầu
  final String? rejectionReason; // lý do từ chối
  final DateTime createdAt;
  final DateTime? approvedAt;

  RequesttoopentshopModel({
    required this.requestId,
    required this.userId,
    this.shopId,
    required this.shopName,
    this.businessLicense,
    required this.nationalId,
    required this.idnationFront,
    required this.idnationBack,
  required this.address,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.approvedAt,
  });

  factory RequesttoopentshopModel.fromMap(Map<String, dynamic> map) {
    return RequesttoopentshopModel(
      requestId: map['requestId'] ?? '',
      userId: map['userId'] ?? '',
      shopId: map['shopId'],
      shopName: map['shopName'] ?? '',
      businessLicense: map['businessLicense'],
      nationalId: map['nationalId'] ?? '',
      idnationFront: map['idnationFront'] ?? '',
      idnationBack: map['idnationBack'] ?? '',
  address: map['address'] ?? '',
      status: map['status'] ?? 'pending',
      rejectionReason: map['rejectionReason'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),

      approvedAt: map['approvedAt'] != null
          ? (map['approvedAt'] is Timestamp
              ? (map['approvedAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['approvedAt'].toString()))
          : null,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'userId': userId,
      'shopId': shopId,
      'shopName': shopName,
      'businessLicense': businessLicense,
      'address': address,
      'nationalId': nationalId,
      'idnationFront': idnationFront,
      'idnationBack': idnationBack,
      'status': status,
      'rejectionReason': rejectionReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }

  RequesttoopentshopModel copyWith({
    String? requestId,
    String? userId,
    String? shopId,
    String? shopName,
    String? businessLicense,
    String? nationalId,
    String? idnationFront,
    String? idnationBack,
  String? address,
    String? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? approvedAt,
  }) {
    return RequesttoopentshopModel(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
  shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      businessLicense: businessLicense ?? this.businessLicense,
      nationalId: nationalId ?? this.nationalId,
      idnationFront: idnationFront ?? this.idnationFront,
      idnationBack: idnationBack ?? this.idnationBack,
  address: address ?? this.address,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}
