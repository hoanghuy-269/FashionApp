import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String? name;
  final String? email;
  final String? password;
  final String? avatar;
  final List<String> phoneNumbers;
  final List<String> addresses;
  final String loginMethodId; // 'local' | 'google' | 'facebook'
  final String roleId; // 'customer' | 'admin' | ...
  final bool status;
  final Timestamp? createdAt;

  User({
    required this.id,
    this.name,
    this.email,
    this.password,
    this.avatar,
    required this.phoneNumbers,
    required this.addresses,
    required this.loginMethodId,
    required this.roleId,
    this.createdAt,
    this.status = true,
  });

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return User(
      id: doc.id,
      name: data['name'],
      email: data['email'],
      password: data['password'],
      avatar: data['avatar'],
      phoneNumbers: List<String>.from(data['phoneNumbers'] ?? []),
      addresses: List<String>.from(data['addresses'] ?? []),
      loginMethodId: data['loginMethodId'] ?? 'local',
      roleId: data['roleId'] ?? 'customer',
      createdAt: data['createdAt'],
      status: data['status'] ?? true,
    );
  }

  /// 🔹 Thêm hàm này để nhận dữ liệu từ Map (Google/Facebook)
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      avatar: data['avatar'],
      password: data['password'],
      phoneNumbers: List<String>.from(data['phoneNumbers'] ?? []),
      addresses: List<String>.from(data['addresses'] ?? []),
      loginMethodId: data['loginMethodId'] ?? 'local',
      roleId: data['roleId'] ?? 'customer',
      status: data['status'] ?? true,
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'avatar': avatar,
      'phoneNumbers': phoneNumbers,
      'addresses': addresses,
      'loginMethodId': loginMethodId,
      'roleId': roleId,
      'status': status,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, method: $loginMethodId, role: $roleId)';
  }
}
