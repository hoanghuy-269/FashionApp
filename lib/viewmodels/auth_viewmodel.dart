import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/data/models/storestaff_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';
import '../data/models/User.dart';
import '../data/repositories/user_repository.dart';
import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
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
    final fcmToken = await FirebaseMessaging.instance.getToken();
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
        notificationToken: fcmToken,
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
      notifyListeners();
      message = null;

      final user = await _userRepository.login(email, password);
      if (user == null) {
        message = 'Email hoặc mật khẩu không chính xác.';
        isLoading = false;
        notifyListeners();
        return false;
      }
     

      print('🔒 User status: ${user.status}');

      if (user.status == false) {
        message = 'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ hỗ trợ.';
        isLoading = false;
        notifyListeners();
        return false;
      }

      currentUser = user;
      message = 'Đăng nhập thành công!';
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      message = 'Lỗi đăng nhập: $e';
      isLoading = false;
      notifyListeners();
      return false;
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
      currentUser = await _userRepository.getUserById(fbUser.uid).first;
    }
  }

  Stream<User?> getUserById(String userId) {
    try {
      return _userRepository.getUserById(userId);
    } catch (e) {
      message = 'Lỗi khi lấy thông tin người dùng: $e';
      return const Stream.empty();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> usersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots(includeMetadataChanges: true);
  }

  Future<List<User?>> getAllUsers() async {
    try {
      isLoading = true;
      message = null;

      // Lấy danh sách người dùng từ repository
      final users = await _userRepository.fetchUsers();

      // Kiểm tra xem dữ liệu có null không và xử lý
      if (users != null) {
        return users;
      } else {
        // Nếu users là null, trả về danh sách rỗng
        return [];
      }
    } catch (e) {
      // Nếu có lỗi xảy ra, hiển thị thông báo lỗi
      message = 'Lỗi khi lấy tất cả người dùng: $e';
      return [];
    } finally {
      // Đảm bảo isLoading được cập nhật sau khi hoàn thành
      isLoading = false;
    }
  }

  /// 🔒 Khóa tài khoản
  Future<void> lockUser(String userId) async {
    try {
      isLoading = true;
      message = null;

      await _userRepository.lockAccount(userId);
      message = 'Khóa tài khoản thành công!';
    } catch (e) {
      message = 'Lỗi khi khóa tài khoản: $e';
    } finally {
      isLoading = false;
    }
  }

  // 🔓 Mở khóa tài khoản
  Future<void> unlockUser(String userId) async {
    try {
      isLoading = true;
      message = null;

      await _userRepository.unlockAccount(userId);
      message = 'Mở khóa tài khoản thành công!';
    } catch (e) {
      message = 'Lỗi khi mở khóa tài khoản: $e';
    } finally {
      isLoading = false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      isLoading = true;
      message = null;

      await _userRepository.changePassword(newPassword);

      message = "Đổi mật khẩu thành công!";
      return true;
    } catch (e) {
      message = "Đổi mật khẩu thất bại: $e";
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required String name,
    required String phone,
    required String address,
    required String? avatar,
  }) async {
    final data = {
      "name": name,
      "phoneNumbers": [phone],
      "addresses": [address],
      "avatar": avatar,
    };

    await _userRepository.updateUser(userId, data);
  }

  // getUserNameById
  Future<String> getUserNameById(String userId) async {
    return await _userRepository.getUserNameById(userId);
  }

  Future<void> updateNotificationToken(String userId, String token) async {
    try {
      await _userRepository.updateNotificationToken(userId, token);
      if (currentUser != null && currentUser!.id == userId) {
        currentUser = currentUser!.copyWith(notificationToken: token);
      }
    } catch (e) {
      print(' Lỗi khi cập nhật notification token: $e');
    }
  }
  Future<void> resetNotificationToken(String userId) async {
    try {
      await _userRepository.resetNotificationToken(userId);
      if (currentUser != null && currentUser!.id == userId) {
        currentUser = currentUser!.copyWith(notificationToken: null);
      }
    } catch (e) {
      print(' Lỗi khi reset notification token: $e');
    }
  }

  
}
