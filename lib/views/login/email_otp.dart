import 'dart:async';
import 'package:fashion_app/views/login/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/flushbar_extension.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../views/login/email_otp_service.dart';

class EmailOtpScreen extends StatefulWidget {
  final String email;
  final EmailOtpService otpService;
  final String password;
  final String phone;

  const EmailOtpScreen({
    super.key,
    required this.email,
    required this.otpService,
    required this.password,
    required this.phone,
  });

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  final _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isVerifying = false;
  int _secondsRemaining = 60;
  bool _canResend = false;
  String? _otpCode;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _sendOtpAndSave();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _otpCode != null) {
        _openMailApp();
      }
    });
  }

  Future<void> _sendOtpAndSave() async {
    _otpCode = await widget.otpService.sendOtp(widget.email);
    if (_otpCode != null) {
      print('Đã tạo OTP: $_otpCode');
    } else {
      context.showError('Không thể tạo mã OTP.');
    }
  }

  void _startCountdown() {
    _secondsRemaining = 60;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _openMailApp() async {
    if (_otpCode == null) {
      context.showError('Chưa có mã OTP để gửi.');
      return;
    }

    final String subject = Uri.encodeComponent('Mã xác nhận OTP');
    final String body = Uri.encodeComponent(
      'Xin chào,\n\nMã OTP của bạn là: $_otpCode\n\nVui lòng nhập mã này vào ứng dụng để xác minh tài khoản.',
    );

    final Uri emailUri = Uri.parse(
      'mailto:${widget.email}?subject=$subject&body=$body',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      context.showError('Không thể mở ứng dụng email.');
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      context.showError('Vui lòng nhập mã OTP.');
      return;
    }

    setState(() => _isVerifying = true);
    final success = await widget.otpService.verifyOtp(widget.email, otp);
    setState(() => _isVerifying = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xác minh email thành công!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        print("POP true");
        Navigator.pop(context, true);
      }
    } else {
      context.showError('Mã OTP không chính xác hoặc đã hết hạn.');
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    _otpCode = await widget.otpService.sendOtp(widget.email);
    if (_otpCode != null) {
      context.showSuccess('Mã OTP mới đã được gửi!');
      _startCountdown();
    } else {
      context.showError('Không thể gửi lại OTP.');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác minh Email a'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nhập mã xác nhận đã gửi đến:\n${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              focusNode: _focusNode,
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Nhập mã OTP',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child:
                  _isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Xác minh OTP'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _canResend ? _resendOtp : null,
              child: Text(
                _canResend
                    ? 'Gửi lại mã OTP'
                    : 'Gửi lại sau $_secondsRemaining giây',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
