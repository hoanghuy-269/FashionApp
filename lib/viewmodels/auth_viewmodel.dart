import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/storestaff_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:uuid/uuid.dart';
import '../data/models/User.dart';
import '../data/repositories/user_repository.dart';

class AuthViewModel {
  final UserRepository _userRepository = UserRepository();

  bool isLoading = false;
  String? message;
  User? currentUser;
  StorestaffModel? currentStaff;

  /// Đăng ký tài khoản (Auth + Firestore)
  Future<bool> registerUser({
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      isLoading = true;
      message = null;

      final newUser = User(
        id: const Uuid().v4(),
        name: null,
        email: email,
        avatar: null,
        phoneNumbers: [phone],
        addresses: [],
        loginMethodId: 'local',
        roleId: 'role002',
      );

      await _userRepository.registerUser(newUser, password);
      message = 'Đăng ký thành công!';
      return true;
    } catch (e) {
      message = 'Đăng ký thất bại: Tài khoản đã tồn tại!!!';
      return false;
    } finally {
      isLoading = false;
    }
  }

  /// Đăng nhập
  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading = true;
      message = null;

      final user = await _userRepository.login(email, password);
      if (user != null) {
        currentUser = user;
        message = 'Đăng nhập thành công!';
        return true;
      } else {
        message = 'Email hoặc mật khẩu không chính xác.';
        return false;
      }
    } catch (e) {
      message = 'Lỗi đăng nhập: $e';
      return false;
    } finally {
      isLoading = false;
    }
  }

  //Đăng nhập nhân viên
  Future<bool> loginStaff({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      message = null;

      final staff = await _userRepository.loginStaff(email, password);

      if (staff != null) {
        currentStaff = staff;
        message = 'Đăng nhập nhân viên thành công!';
        print(' Nhân viên: ${staff.fullName}, Shop: ${staff.shopId}');
        return true;
      } else {
        message = 'Không tìm thấy nhân viên.';
        return false;
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          message = 'Email không tồn tại trong hệ thống.';
          break;
        case 'wrong-password':
          message = 'Mật khẩu không đúng.';
          break;
        default:
          message = 'Lỗi đăng nhập Firebase: ${e.message}';
      }
      return false;
    } catch (e) {
      message = 'Lỗi không xác định: $e';
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      isLoading = true;
      message = null;

      final googleUser = await _userRepository.loginWithGoogle();

      if (googleUser == null) {
        message = 'Không thể đăng nhập bằng Google.';
        return false;
      }

      currentUser = googleUser;

      print(" Đăng nhập Google thành công: ${googleUser.email}");
      print(" currentUser: ${currentUser?.email}");

      message = 'Đăng nhập Google thành công!';
      return true;
    } catch (e) {
      print(" Lỗi loginWithGoogle: $e");
      message = 'Lỗi: $e';
      return false;
    } finally {
      isLoading = false;
    }
  }

  // 🔹 Login Facebook
  Future<bool> loginWithFacebook() async {
    try {
      isLoading = true;
      message = null;
      final user = await _userRepository.loginWithFacebook();
      if (user != null) {
        message = 'Đăng nhập Facebook thành công!';
        return true;
      } else {
        message = 'Không thể đăng nhập bằng Facebook.';
        return false;
      }
    } catch (e) {
      message = 'Lỗi: $e';
      return false;
    } finally {
      isLoading = false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      await _userRepository.logout();
      currentUser = null;
      message = 'Đã đăng xuất.';
    } catch (e) {
      message = 'Lỗi khi đăng xuất: $e';
    }
  }

  /// Kiểm tra người dùng hiện tại (nếu cần auto-login)
  Future<void> checkCurrentUser() async {
    final fbUser = _userRepository.currentUser;
    if (fbUser != null) {
      currentUser = await _userRepository.getUserById(fbUser.uid);
    }
  }

  Future<User?> FetchUserById(String userId) async {
    try {
      isLoading = true;
      message = null;
      final user = await _userRepository.getUserById(userId);
      if (user != null) {
        currentUser = user;
        return user;
      } else {
        message = 'Không tìm thấy người dùng.';
        return null;
      }
    } catch (e) {
      message = 'Lỗi khi lấy thông tin người dùng: $e';
      return null;
    } finally {
      isLoading = false;
    }
  }
}
