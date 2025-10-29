import 'package:fashion_app/core/widget/validatedtextfield.dart';
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

  bool _isLoading = false;
  final AuthViewModel _authViewModel = AuthViewModel();

  Future<void> _register() async {
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

    setState(() => _isLoading = true);
    final success = await _authViewModel.registerUser(
      email: email,
      password: password,
      phone: phone,
    );
    setState(() => _isLoading = false);

    if (success) {
      _emailController.clear();
      _phoneController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      context.showSuccess('🎉 Tạo tài khoản thành công!');
    } else {
      context.showError(
        _authViewModel.message ?? 'Đăng ký thất bại, vui lòng thử lại.',
      );
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
              //Nhap email
              _buildValidatedField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                error: _emailError,
                errorMessage: '⚠️ Email không hợp lệ',
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
                errorMessage: '⚠️ Số điện thoại không hợp lệ',
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
                errorMessage: '⚠️ Mật khẩu không đúng định dạng',
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
                errorMessage: '⚠️ Mật khẩu không khớp',
                validator: (v) => v == _passwordController.text,
                onChanged: () => setState(() => _confirmError = false),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE9F38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Tạo tài khoản',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
