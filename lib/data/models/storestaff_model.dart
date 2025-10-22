import 'package:cloud_firestore/cloud_firestore.dart';

class StorestaffModel {
  final String employeeId;
  final String shopId;
  final String fullName;
  final String? phoneNumber;
  final String email;
  final String password;
  final String roleIds;
  final String? nationalId; // căn cước công dận
  final String? nationalIdFront; // mặt trước căn cước công dân
  final String? nationalIdBack; // mặt sau căn cước công dân
  final DateTime createdAt;
  final String? uid; // Thêm trường uid nếu cần thiết

  StorestaffModel({
    required this.employeeId,
    required this.shopId,
    required this.fullName,
    this.phoneNumber,
    required this.email,
    required this.password,
    required this.roleIds,
    this.nationalId,
    this.nationalIdFront,
    this.nationalIdBack,
    required this.createdAt,
    this.uid,
  });

  factory StorestaffModel.fromMap(Map<String, dynamic> map) {
    // createdAt can be stored in Firestore as a Timestamp, as an ISO String,
    // or as an integer (millisecondsSinceEpoch). Handle the common types.
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
      password: map['password'] ?? '',
      roleIds: map['roleIds'] ?? '',
      nationalId: map['nationalId'],
      nationalIdFront: map['nationalIdFront'],
      nationalIdBack: map['nationalIdBack'],
      createdAt: createdAt,
      uid: map['uid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'shopId': shopId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
      'roleIds': roleIds,
      'nationalId': nationalId,
      'nationalIdFront': nationalIdFront,
      'nationalIdBack': nationalIdBack,
      'createdAt': createdAt.toIso8601String(),
      'uid': uid,
    };
  }
}
