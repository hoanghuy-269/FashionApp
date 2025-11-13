import 'package:fashion_app/viewmodels/role_viewmodel.dart';
import 'package:fashion_app/views/admin/admin_home_screen.dart';
import 'package:fashion_app/views/admin/adminrequestshop_screen.dart';
import 'package:fashion_app/views/login/staff_screen.dart';
import 'package:fashion_app/views/shop/shop_screen.dart';
import 'package:fashion_app/views/staff/warehouse_screen.dart';
import 'package:fashion_app/views/user/home_screen.dart';
import 'package:fashion_app/views/user/userprofile_screen.dart';
import 'package:flutter/material.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '.././login/register_screen.dart';
import '.././login/forgot_password_screen.dart';
import '../../core/utils/validator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authViewModel = AuthViewModel();
  final _roleViewModel = RoleViewModel();
  final _storage = const FlutterSecureStorage();

  bool _isShopLogin = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _emailError = false;
  bool _passwordError = false;
  List<String> _savedEmails = [];

  FocusNode _emailFocus = FocusNode();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _emailFocus.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_emailFocus);
    });
  }

  Future<void> _loadSavedLogin() async {
    final emails = await _storage.read(key: 'emails');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (emails != null && emails.isNotEmpty) {
          _savedEmails = emails.split(',');
        }
      });
    });
  }

  //  Khi đăng nhập
  Future<void> _login() async {
    final email = _accountController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !Validator.isValidEmail(email)) {
      setState(() => _emailError = true);
      return;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = true);
      return;
    }

    setState(() => _isLoading = true);

    bool isLogin = false;

    if (_isShopLogin) {
      // Nhân viên
      isLogin = await _authViewModel.loginStaff(
        email: email,
        password: password,
      );
    } else {
      // Người dùng (User / Shop / Admin)
      isLogin = await _authViewModel.login(email: email, password: password);
    }
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!isLogin) {
      _showError(_authViewModel.message ?? 'Đăng nhập thất bại');
      return;
    }
    final user = _authViewModel.currentUser;
    if (user != null && user.status == false) {
      _showError('Tài khoản của bạn đã bị khóa hoặc chưa được kích hoạt!');
      print('🔒 User status: ${user.status}');
      return; // Dừng lại, không chuyển trang
    }
    await _storage.write(key: 'pwd_$email', value: password);
    final existingEmails = await _storage.read(key: 'emails');
    List<String> emailList = existingEmails?.split(',') ?? [];

    if (!emailList.contains(email)) {
      emailList.add(email);
      await _storage.write(key: 'emails', value: emailList.join(','));
    }

    if (_isShopLogin) {
      final staff = _authViewModel.currentStaff;
      if (staff == null) {
        _showError('Không tìm thấy thông tin nhân viên!');
        return;
      }

      print('✅ Nhân viên: ${staff.fullName}, Shop: ${staff.shopId}');
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WarehouseScreen(shopID: staff.shopId)),
      );

      _showSuccess('Đăng nhập nhân viên thành công!');
      return;
    }

    if (user == null) {
      _showError('Không tìm thấy thông tin người dùng!');
      return;
    }

    await _roleViewModel.fetchRoleById(user.roleId);
    final role = _roleViewModel.currentRole;

    if (role == null) {
      _showError('Vui lòng đăng nhập đúng tài khoản!');
      return;
    }

    switch (role.id) {
      case 'role002':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(idUser: user.id)),
        );
        break;
      case 'role003':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ShopScreen(idUser: user.id)),
        );
        break;
      case 'role001':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
        );
        break;
      default:
        _showError('Không xác định được vai trò người dùng!');
        return;
    }

    _showSuccess('Đăng nhập thành công!');
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

  void _handleEmailSelected(String selectedEmail) async {
    _accountController.text = selectedEmail;

    final savedPassword = await _storage.read(key: 'pwd_$selectedEmail');
    if (savedPassword != null) {
      setState(() {
        _passwordController.text = savedPassword;
      });
    }

    print("➡️ Email đã chọn: $selectedEmail");
    final allData = await _storage.readAll();
    print("🔍 Dữ liệu hiện tại: $allData");
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
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      hintText: 'Nhập email',
                      prefixIcon: const Icon(Icons.email),
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
                      errorText: _emailError ? '⚠️ Email không hợp lệ' : null,
                    ),
                    onChanged: (_) => setState(() => _emailError = false),
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
                        if (!mounted) return;

                        if (success) {
                          final user = _authViewModel.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Không tìm thấy thông tin người dùng!',
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => UserprofileScreen(idUser: user.id),
                            ),
                          );

                          print("✅ Đăng nhập Google thành công: ${user.id}");
                        } else {
                          if (!mounted) return;
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
                        if (!mounted) return;

                        if (success) {
                          final user = _authViewModel.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Không tìm thấy thông tin người dùng!',
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => UserprofileScreen(idUser: user.id),
                            ),
                          );

                          print("✅ Đăng nhập Google thành công: ${user.id}");
                        } else {
                          if (!mounted) return;
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
                        const SizedBox(height: 20),
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
