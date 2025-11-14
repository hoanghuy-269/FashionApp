import 'package:cloud_firestore/cloud_firestore.dart'; 

class ProductRequestModel {
  final String productRequestID;
  final String shopProductID;
  final String shopID;
  final String userID;
  final int quantity;
  final String note;
  final String? status;
  final DateTime createdAt;

  ProductRequestModel({
    required this.productRequestID,
    required this.shopProductID,
    required this.shopID,
    required this.userID,
    required this.quantity,
     this.status,
    required this.note,
    required this.createdAt,
  });

  factory ProductRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductRequestModel(
      productRequestID: id,
      shopProductID: map['shopProductID'] ?? '',
      userID: map['userID'] ?? '',
      shopID: map['shopID'] ?? '',
      quantity: map['quantity'] ?? 0,
      note: map['note'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopProductID': shopProductID,
      'userID': userID,
      'shopID': shopID,
      'quantity': quantity,
      'status': status,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}