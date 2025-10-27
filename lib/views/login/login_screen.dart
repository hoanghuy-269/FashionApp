import 'package:fashion_app/viewmodels/role_viewmodel.dart';
import 'package:fashion_app/views/admin/adminrequestshop_screen.dart';
import 'package:fashion_app/views/shop/shop_screen.dart';
import 'package:fashion_app/views/user/userprofile_screen.dart';
import 'package:flutter/material.dart';
import '../../viewmodels/auth_viewmodel.dart';
import './enter_phonenumber_screen.dart';
import '.././login/register_screen.dart';
import '.././login/forgot_password_screen.dart';
import '../../core/utils/validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isShopLogin = false;
  final AuthViewModel _authViewModel = AuthViewModel();
  final RoleViewModel _roleViewModel = RoleViewModel();
  bool _emailError = false;
  bool _passwordError = false;
  bool _isLoading = false;

  Future<void> _login() async {
    final username = _accountController.text.trim();
    final password = _passwordController.text.trim();
    const roleAdmin = 'role001';
    const roleCustomer = 'role002';
    const roleShop = 'role003';

    // ⚠️ Kiểm tra hợp lệ
    if (username.isEmpty || !Validator.isValidEmail(username)) {
      setState(() => _emailError = true);
      _showError('Email không hợp lệ');
      return;
    }

    if (password.isEmpty || !Validator.isValidPassword(password)) {
      setState(() => _passwordError = true);
      _showError(
        'Mật khẩu phải có ít nhất 6 ký tự, chữ hoa, số và ký tự đặc biệt',
      );
      return;
    }

    // Bật loading toàn màn hình
    setState(() => _isLoading = true);

    // Gọi hàm đăng nhập
    final user = await _authViewModel.login(
      email: username,
      password: password,
    );

    // Tắt loading
    setState(() => _isLoading = false);

    if (user != null) {
      await _roleViewModel.fetchRoleById(_authViewModel.currentUser?.roleId);
      final role = _roleViewModel.currentRole;

      if (role == null) {
        _showError('Không tìm thấy quyền của người dùng!');
        return;
      }

      // Điều hướng theo role
      if (role.id.toLowerCase() == roleCustomer) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    UserprofileScreen(idUser: _authViewModel.currentUser?.id),
          ),
        );
      } else if (role.id.toLowerCase() == roleShop) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ShopScreen(idUser: _authViewModel.currentUser?.id),
          ),
        );
      } else if (role.id.toLowerCase() == roleAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminrequestshopScreen()),
        );
      } else {
        _showError('Không xác định được quyền đăng nhập');
      }

      _showSuccess('Đăng nhập thành công!');
    } else {
      _showError(_authViewModel.message ?? 'Đăng nhập thất bại');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      'ĐĂNG NHẬP',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Đăng nhập vào tài khoản của bạn',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: _isShopLogin,
                        onChanged: (value) {
                          setState(() => _isShopLogin = false);
                        },
                      ),
                      const Text('Người dùng'),

                      const SizedBox(width: 50),

                      Radio<bool>(
                        value: true,
                        groupValue: _isShopLogin,
                        onChanged: (value) {
                          setState(() => _isShopLogin = true);
                        },
                      ),
                      const Text('Cửa hàng'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tài khoản',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(255, 82, 80, 80),
                    ),
                  ),
                  TextField(
                    controller: _accountController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      hintText: 'Nhập tài khoản...',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _emailError ? Colors.red : Colors.deepPurple,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _emailError ? Colors.red : Colors.grey,
                          width: 1.5,
                        ),
                      ),
                      errorText:
                          _emailError ? '⚠️ Vui lòng nhập email hợp lệ' : null,
                    ),
                    onChanged: (_) {
                      setState(() {
                        _emailError = false;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Mật khẩu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(255, 82, 80, 80),
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Nhập mật khẩu',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              _passwordError ? Colors.red : Colors.deepPurple,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _passwordError ? Colors.red : Colors.grey,
                          width: 1.5,
                        ),
                      ),
                      errorText:
                          _passwordError
                              ? '⚠️ Vui lòng nhập mật khẩu đúng định dạng'
                              : null,
                    ),
                    onChanged: (_) {
                      setState(() {
                        _passwordError = false;
                      });
                    },
                  ),

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Quên mật khẩu?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF208AE0),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  if (!_isShopLogin) ...[
                    const SizedBox(height: 30),
                    Row(
                      children: const [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey,
                            endIndent: 10,
                          ),
                        ),
                        Text('Hoặc', style: TextStyle(color: Colors.grey)),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey,
                            indent: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Nút Facebook
                    OutlinedButton.icon(
                      onPressed: () async {
                        final success =
                            await _authViewModel.loginWithFacebook();
                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OtpRequestScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _authViewModel.message ?? 'Đăng nhập thất bại',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.facebook,
                        color: Colors.white,
                        size: 28,
                      ),
                      label: const Text(
                        "Tiếp tục với Facebook",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color(0xFF1877F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: Colors.black45,
                      ),
                    ),

                    const SizedBox(height: 20),

                    OutlinedButton.icon(
                      onPressed: () async {
                        final success = await _authViewModel.loginWithGoogle();
                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OtpRequestScreen(),
                            ),
                          );
                          print("huy");
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _authViewModel.message ?? 'Đăng nhập thất bại',
                              ),
                            ),
                          );
                        }
                      },
                      icon: Image.asset(
                        'assets/icons/google.png',
                        height: 24,
                        width: 24,
                      ),
                      label: const Text(
                        "Tiếp tục với Google    ",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        shadowColor: Colors.black12,
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Bạn chưa có tài khoản?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Color.fromARGB(255, 82, 80, 80),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            ' Đăng ký',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Overlay loading toàn màn hình
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
