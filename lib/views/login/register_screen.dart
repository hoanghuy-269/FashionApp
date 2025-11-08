import 'package:fashion_app/views/login/email_otp.dart';
import 'package:fashion_app/views/login/email_otp_service.dart';
import 'package:flutter/material.dart';
import '../../core/utils/validator.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/utils/flushbar_extension.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _emailError = false;
  bool _phoneError = false;
  bool _passwordError = false;
  bool _confirmError = false;

  final EmailOtpService _otpService = EmailOtpService();
  bool _isOtpVerified = false;
  bool _isLoading = false;

  final AuthViewModel _authViewModel = AuthViewModel();

  Future<void> _handleVerifyEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final phone = _phoneController.text.trim();

    if (email.isEmpty || password.isEmpty || phone.isEmpty) {
      context.showError('Vui lòng nhập đầy đủ thông tin!');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Gửi OTP lên Firebase
      await _otpService.sendOtp(email);

      // Chuyển qua màn hình nhập OTP
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (_) => EmailOtpScreen(
                email: email,
                otpService: _otpService,
                password: password,
                phone: phone,
              ),
        ),
      );

      debugPrint("Nhận result từ OTP Screen: $result");

      if (result == true) {
        if (mounted) {
          setState(() {
            _isOtpVerified = true;
          });
        }
      } else if (result == false) {
        context.showError('Xác minh OTP thất bại hoặc bị hủy.');
      }
    } catch (e) {
      context.showError('Lỗi khi gửi OTP: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _emailError = !Validator.isValidEmail(email);
      _phoneError = !Validator.isValidPhone(phone);
      _passwordError = !Validator.isValidPassword(password);
      _confirmError = password != confirmPassword;
    });

    if (_emailError || _phoneError || _passwordError || _confirmError) return;

    if (!_isOtpVerified) {
      context.showError('Vui lòng xác minh email trước khi đăng ký.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await _authViewModel.registerUser(
        email: email,
        password: password,
        phone: phone,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo tài khoản thành công!')),
        );

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        context.showError(
          _authViewModel.message ?? 'Đăng ký thất bại, vui lòng thử lại.',
        );
      }
    } catch (e) {
      context.showError('Lỗi khi tạo tài khoản: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ĐĂNG KÝ',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildValidatedField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                error: _emailError,
                errorMessage: 'Email không hợp lệ',
                validator: Validator.isValidEmail,
                onChanged: () => setState(() => _emailError = false),
              ),
              const SizedBox(height: 20),

              _buildValidatedField(
                label: 'Số điện thoại',
                controller: _phoneController,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                error: _phoneError,
                errorMessage: 'Số điện thoại không hợp lệ',
                validator: Validator.isValidPhone,
                onChanged: () => setState(() => _phoneError = false),
              ),
              const SizedBox(height: 20),

              _buildValidatedField(
                label: 'Mật khẩu',
                controller: _passwordController,
                icon: Icons.lock,
                isPassword: true,
                obscureText: _obscurePassword,
                toggleObscure:
                    () => setState(() => _obscurePassword = !_obscurePassword),
                error: _passwordError,
                errorMessage: 'Mật khẩu không đúng định dạng',
                validator: Validator.isValidPassword,
                onChanged: () => setState(() => _passwordError = false),
              ),
              const SizedBox(height: 20),

              _buildValidatedField(
                label: 'Xác nhận mật khẩu',
                controller: _confirmPasswordController,
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                toggleObscure:
                    () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                error: _confirmError,
                errorMessage: 'Mật khẩu không khớp',
                validator: (v) => v == _passwordController.text,
                onChanged: () => setState(() => _confirmError = false),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            if (!_isOtpVerified) {
                              await _handleVerifyEmail();
                            } else {
                              await _handleRegister();
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isOtpVerified ? Colors.green : const Color(0xFFEE9F38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            _isOtpVerified ? 'Tạo tài khoản' : 'Xác minh Email',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidatedField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required bool error,
    required String errorMessage,
    required bool Function(String) validator,
    required VoidCallback onChanged,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: 'Nhập $label',
            prefixIcon: Icon(icon),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: toggleObscure,
                    )
                    : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error ? Colors.red : Colors.deepPurple,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error ? Colors.red : Colors.grey,
                width: 1.5,
              ),
            ),
            errorText: error ? errorMessage : null,
          ),
        ),
      ],
    );
  }
}
