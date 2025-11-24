// order_request_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/address.dart';
import 'package:fashion_app/data/models/cart_model.dart';

// order_request_model.dart
class OrderRequest {
  final String requestId;
  final String userId;
  final List<CartItem> items;
  final Address address;
  final String paymentMethodId;
  final String? voucherCode;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final DateTime createdAt;
  final String status; // pending, confirmed, cancelled

  OrderRequest({
    required this.requestId,
    required this.userId,
    required this.items,
    required this.address,
    required this.paymentMethodId,
    this.voucherCode,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'address': _addressToMap(address), // Sửa ở đây
      'paymentMethodId': paymentMethodId,
      'voucherCode': voucherCode,
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  // Hàm chuyển Address thành Map
  Map<String, dynamic> _addressToMap(Address address) {
    return {
      'id': address.id,
      'name': address.name,
      'phone': address.phone,
      'detail': address.detail,
      'ward': address.ward,
      'district': address.district,
      'province': address.province,
      'isDefault': address.isDefault,
      'createdAt': address.createdAt,
    };
  }

  static OrderRequest fromMap(Map<String, dynamic> map) {
    return OrderRequest(
      requestId: map['requestId'],
      userId: map['userId'],
      items:
          (map['items'] as List).map((item) => CartItem.fromMap(item)).toList(),
      address: _addressFromMap(map['address']), // Sửa ở đây
      paymentMethodId: map['paymentMethodId'],
      voucherCode: map['voucherCode'],
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      discountAmount: map['discountAmount']?.toDouble() ?? 0.0,
      finalAmount: map['finalAmount']?.toDouble() ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
    );
  }

  // Hàm tạo Address từ Map
  static Address _addressFromMap(Map<String, dynamic> addressMap) {
    return Address(
      id: addressMap['id'] ?? '',
      name: addressMap['name'] ?? '',
      phone: addressMap['phone'] ?? '',
      detail: addressMap['detail'] ?? '',
      ward: addressMap['ward'] ?? '',
      district: addressMap['district'] ?? '',
      province: addressMap['province'] ?? '',
      isDefault: addressMap['isDefault'] ?? false,
      createdAt: addressMap['createdAt'], // Giữ nguyên kiểu Timestamp
    );
  }
}
