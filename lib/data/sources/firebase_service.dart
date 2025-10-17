import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/User.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _userCollection =>
      _firestore.collection('users');

  /// Tạo user mới
  Future<void> createUser(User user) async {
    try {
      print('FirebaseService.createUser: start for ${user.username}');
      await _userCollection.doc(user.id).set(user.toFirestore());
      print('FirebaseService.createUser: SUCCESS');
    } catch (e, st) {
      print('FirebaseService.createUser ERROR: $e');
      print(st);
      rethrow;
    }
  }

  /// Kiểm tra user tồn tại (username hoặc email)
  Future<bool> checkUserExists(String usernameOrEmail) async {
    try {
      final usernameQuery =
          await _userCollection
              .where('username', isEqualTo: usernameOrEmail)
              .limit(1)
              .get();
      if (usernameQuery.docs.isNotEmpty) return true;

      final emailQuery =
          await _userCollection
              .where('email', isEqualTo: usernameOrEmail)
              .limit(1)
              .get();
      return emailQuery.docs.isNotEmpty;
    } catch (e, st) {
      print('checkUserExists ERROR: $e');
      print(st);
      rethrow;
    }
  }

  /// Lấy user theo username hoặc email
  Future<User?> getUserByAccount(String usernameOrEmail) async {
    try {
      var snapshot =
          await _userCollection
              .where('username', isEqualTo: usernameOrEmail)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return User.fromFirestore(snapshot.docs.first);
      }

      snapshot =
          await _userCollection
              .where('email', isEqualTo: usernameOrEmail)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return User.fromFirestore(snapshot.docs.first);
      }

      return null;
    } catch (e, st) {
      print('getUserByAccount ERROR: $e');
      print(st);
      rethrow;
    }
  }

  /// Cập nhật user
  Future<void> updateUser(User user) async {
    try {
      await _userCollection.doc(user.id).update(user.toFirestore());
      print('updateUser: SUCCESS for ${user.id}');
    } catch (e, st) {
      print('updateUser ERROR: $e');
      print(st);
      rethrow;
    }
  }

  /// Xoá user
  Future<void> deleteUser(String userId) async {
    try {
      await _userCollection.doc(userId).delete();
      print('deleteUser: SUCCESS for $userId');
    } catch (e, st) {
      print('deleteUser ERROR: $e');
      print(st);
      rethrow;
    }
  }
}
