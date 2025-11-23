import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String? name;
  final String? email;
  final String? avatar;
  final List<String> phoneNumbers;
  final List<String> addresses;
  final String loginMethodId;
  final String roleId;
  final bool status;
  final Timestamp? createdAt;
  // thêm token sử lí thông báo 
  final String? notificationToken;
  
  User({
    required this.id,
    this.name,
    this.email,
    this.avatar,
    required this.phoneNumbers,
    required this.addresses,
    required this.loginMethodId,
    required this.roleId,
    this.createdAt,
    this.status = true,
    this.notificationToken,
   
  });

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return User(
      id: doc.id,
      name: data['name'],
      email: data['email'],
      avatar: data['avatar'],
      phoneNumbers: List<String>.from(data['phoneNumbers'] ?? []),
      addresses: List<String>.from(data['addresses'] ?? []),
      loginMethodId: data['loginMethodId'] ?? 'local',
      roleId: data['roleId'] ?? 'role002',
      createdAt: data['createdAt'],
      status: data['status'] ?? true,
      notificationToken: data['notificationToken'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'avatar': avatar,
      'phoneNumbers': phoneNumbers,
      'addresses': addresses,
      'loginMethodId': loginMethodId,
      'roleId': roleId,
      'status': status,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'notificationToken': notificationToken,
    };
  }

  copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    List<String>? phoneNumbers,
    List<String>? addresses,
    String? loginMethodId,
    String? roleId,
    bool? status,
    Timestamp? createdAt,
    String? notificationToken,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      addresses: addresses ?? this.addresses,
      loginMethodId: loginMethodId ?? this.loginMethodId,
      roleId: roleId ?? this.roleId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notificationToken: notificationToken ?? this.notificationToken,
    );
  }
}
