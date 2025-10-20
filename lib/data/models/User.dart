import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String? name;
  final String? username;
  final String? email;
  final String? password;
  final String? avatar;
  final List<String> phoneNumbers;
  final List<String> addresses;
  final String loginMethodId; // 'local' | 'google' | 'facebook'
  final String roleId; // 'customer' | 'admin' | ...
  final Timestamp? createdAt;

  User({
    required this.id,
    this.name,
    this.username,
    this.email,
    this.password,
    this.avatar,
    required this.phoneNumbers,
    required this.addresses,
    required this.loginMethodId,
    required this.roleId,
    this.createdAt,
  });

  /// Dùng khi đọc dữ liệu từ Firestore
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return User(
      id: doc.id,
      name: data['name'],
      username: data['username'],
      email: data['email'],
      password: data['password'],
      avatar: data['avatar'],
      phoneNumbers: List<String>.from(data['phoneNumbers'] ?? []),
      addresses: List<String>.from(data['addresses'] ?? []),
      loginMethodId: data['loginMethodId'] ?? 'local',
      roleId: data['roleId'] ?? 'customer',
      createdAt: data['createdAt'],
    );
  }

  /// Dùng khi ghi dữ liệu lên Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'pazssword': password,
      'avatar': avatar,
      'phoneNumbers': phoneNumbers,
      'addresses': addresses,
      'loginMethodId': loginMethodId,
      'roleId': roleId,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, method: $loginMethodId, role: $roleId)';
  }
}
