import 'package:cloud_firestore/cloud_firestore.dart';

class StorestaffModel {
  final String employeeId;
  final String shopId;
  final String fullName;
  final String? phoneNumber;
  final String email;
  final String roleIds;
  final String? nationalId; // căn cước công dận
  final String? nationalIdFront; // mặt trước căn cước công dân
  final String? nationalIdBack; // mặt sau căn cước công dân
  final DateTime createdAt;

  StorestaffModel({
    required this.employeeId,
    required this.shopId,
    required this.fullName,
    this.phoneNumber,
    required this.email,
    required this.roleIds,
    this.nationalId,
    this.nationalIdFront,
    this.nationalIdBack,
    required this.createdAt,
  });

  factory StorestaffModel.fromMap(Map<String, dynamic> map) {
  
    final dynamic createdAtRaw = map['createdAt'];
    DateTime createdAt;
    if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtRaw);
    } else if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else {
      // Fallback to now if the value is missing or of an unexpected type.
      createdAt = DateTime.now();
    }

    return StorestaffModel(
      employeeId: map['employeeId'] ?? '',
      shopId: map['shopId'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'],
      email: map['email'] ?? '',
      roleIds: map['roleIds'] ?? '',
      nationalId: map['nationalId'],
      nationalIdFront: map['nationalIdFront'],
      nationalIdBack: map['nationalIdBack'],
      createdAt: createdAt,
    );
  }
  Map<String, dynamic> toFirestoreMap({bool useServerTimestamp = true}) {
    return {
      'employeeId': employeeId,
      'shopId': shopId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'roleIds': roleIds,
      'nationalId': nationalId,
      'nationalIdFront': nationalIdFront,
      'nationalIdBack': nationalIdBack,
      'createdAt': useServerTimestamp ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt),
    };
  }

  StorestaffModel copyWith({
    String? employeeId,
    String? shopId,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? roleIds,
    String? nationalId,
    String? nationalIdFront,
    String? nationalIdBack,
    DateTime? createdAt,
    String? uid,
  }) {
    return StorestaffModel(
      employeeId: employeeId ?? this.employeeId,
      shopId: shopId ?? this.shopId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      roleIds: roleIds ?? this.roleIds,
      nationalId: nationalId ?? this.nationalId,
      nationalIdFront: nationalIdFront ?? this.nationalIdFront,
      nationalIdBack: nationalIdBack ?? this.nationalIdBack,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
