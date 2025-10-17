import 'package:flutter/material.dart';
import '../data/models/User.dart';
import '../data/repositories/user_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthViewModel(this._userRepository);

  Future<String> register({
    required String username,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    if (username.trim().isEmpty || phone.trim().isEmpty || password.isEmpty) {
      return 'Please fill in all required fields';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username.trim(),
        password: password.trim(),
        email: null, // không dùng email cho local
        avatar: null,
        phoneNumbers: [phone.trim()],
        addresses: [],
        loginMethodId: "local", // hoặc 'google' / 'facebook'
        roleId: "customer",
      );

      final result = await _userRepository.registerUser(user);

      _isLoading = false;
      notifyListeners();

      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return 'Registration failed: $_errorMessage';
    }
  }
}
