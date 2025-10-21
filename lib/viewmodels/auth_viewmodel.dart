import 'package:uuid/uuid.dart';
import '../data/models/User.dart';
import '../data/repositories/user_repository.dart';

class AuthViewModel {
  final UserRepository _userRepository = UserRepository();

  bool isLoading = false;
  String? message;
  User? currentUser;

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
        id: const Uuid().v4(), // tạm thời, sẽ thay bằng UID của Firebase Auth
        name: null,
        email: email,
        password: password,
        avatar: null,
        phoneNumbers: [phone],
        addresses: [],
        loginMethodId: 'local',
        roleId: 'customer',
      );

      await _userRepository.registerUser(newUser, password);
      message = 'Đăng ký thành công!';
      return true;
    } catch (e) {
      message = 'Đăng ký thất bại: $e';
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

  // 🔹 Login Google
  Future<bool> loginWithGoogle() async {
    try {
      isLoading = true;
      message = null;
      final user = await _userRepository.loginWithGoogle();
      if (user != null) {
        message = 'Đăng nhập Google thành công!';
        print("huy ${user.email} ");

        return true;
      } else {
        message = 'Không thể đăng nhập bằng Google.';
        return false;
      }
    } catch (e) {
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
}
