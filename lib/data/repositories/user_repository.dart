import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/User.dart';
import '../sources/firebase_service.dart';

class UserRepository {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseService _service = FirebaseService();

  /// Đăng ký người dùng mới (Firebase Auth + Firestore)
  Future<void> registerUser(User user, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: user.email!,
      password: password,
    );

    final uid = credential.user!.uid;

    final userWithUid = User(
      id: uid,
      name: user.name,
      email: user.email,
      avatar: user.avatar,
      phoneNumbers: user.phoneNumbers,
      addresses: user.addresses,
      loginMethodId: user.loginMethodId,
      roleId: user.roleId,
      createdAt: user.createdAt,
    );

    await _service.addOrUpdateUser(userWithUid);
  }

  /// Đăng nhập bằng email + password
  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Lấy thông tin người dùng trong Firestore
      final user = await _service.getUserById(uid);
      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      // Xử lý lỗi đăng nhập
      print('❌ Lỗi đăng nhập: ${e.message}');
      return null;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    await _service.signOut();
  }

  /// Kiểm tra người dùng hiện tại (đã đăng nhập chưa)
  fb_auth.User? get currentUser => _auth.currentUser;

  /// Các hàm thao tác Firestore
  Future<void> createUser(User user) => _service.addOrUpdateUser(user);
  Future<List<User>> fetchUsers() => _service.getAllUsers();
  Future<User?> getUserById(String id) => _service.getUserById(id);
  Future<void> updateUser(String id, Map<String, dynamic> data) =>
      _service.updateUser(id, data);
  Future<void> deleteUser(String id) => _service.deleteUser(id);
  Future<User?> loginWithGoogle() => _service.signInWithGoogle();
  Future<User?> loginWithFacebook() => _service.signInWithFacebook();
}