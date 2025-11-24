// Thêm class Address
import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  final String id;
  final String name;
  final String phone;
  final String detail;
  final String ward;
  final String district;
  final String province;
  final bool isDefault;
  final Timestamp? createdAt;

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.detail,
    required this.ward,
    required this.district,
    required this.province,
    this.isDefault = false,
    this.createdAt,
  });

  factory Address.fromFirestore(Map<String, dynamic> data, String id) {
    return Address(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      detail: data['detail'] ?? '',
      ward: data['ward'] ?? '',
      district: data['district'] ?? '',
      province: data['province'] ?? '',
      isDefault: data['isDefault'] ?? false,
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'detail': detail,
      'ward': ward,
      'district': district,
      'province': province,
      'isDefault': isDefault,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  String get fullAddress {
    return '$detail, $ward, $district, $province';
  }
}
