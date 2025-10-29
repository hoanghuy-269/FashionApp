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
    };
  }
}
