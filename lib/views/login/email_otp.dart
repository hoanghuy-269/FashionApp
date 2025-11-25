import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/flushbar_extension.dart';
import '../../views/login/email_otp_service.dart';

class EmailOtpScreen extends StatefulWidget {
  final String email;
  final EmailOtpService otpService;
  final String password;
  final String phone;
  final String? initialOtp;

  const EmailOtpScreen({
    super.key,
    required this.email,
    required this.otpService,
    required this.password,
    required this.phone,
    this.initialOtp,
  });

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  int _secondsRemaining = 60;
  bool _canResend = false;
  String? _otpCode;
  late Timer _timer;
  bool _isSendingOtp = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    // DÙNG OTP ĐƯỢC TRUYỀN VÀO (nếu có)
    _otpCode = widget.initialOtp;
    if (_otpCode != null) {
      print('📧 Đã nhận OTP từ RegisterScreen: $_otpCode');
    }
  }

  Future<void> _sendOtp() async {
    setState(() => _isSendingOtp = true);
    try {
      _otpCode = await widget.otpService.sendOtp(widget.email);
      if (_otpCode != null) {
        if (mounted) {
          context.showSuccess('Mã OTP đã được gửi!');
        }
      } else {
        if (mounted) {
          context.showError('Không thể gửi mã OTP.');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showError('Lỗi khi gửi OTP: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingOtp = false);
      }
    }
  }

  void _startCountdown() {
    _secondsRemaining = 60;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        if (mounted) {
          setState(() => _canResend = true);
        }
      } else {
        if (mounted) {
          setState(() => _secondsRemaining--);
        }
      }
    });
  }

  Future<void> _openMailApp() async {
    try {
      final List<Uri> emailUris = [
        Uri.parse('googlegmail://'), // Gmail
        Uri.parse('googlemail://'), // Gmail alternative
        Uri.parse('ms-outlook://'), // Outlook
        Uri.parse('ymail://'), // Yahoo Mail
        Uri.parse('message://'), // Apple Mail (iOS)
        Uri.parse('mailto:'), // Fallback
      ];

      bool launched = false;
      for (final uri in emailUris) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          launched = true;
          break;
        }
      }

      if (!launched) {
        context.showError('Không thể mở ứng dụng email.');
      }
    } catch (e) {
      context.showError('Lỗi khi mở email: $e');
    }
  }

  Future<void> _copyOtpToClipboard() async {
    if (_otpCode == null) {
      context.showError('Chưa có mã OTP để copy.');
      return;
    }

    try {
      await Clipboard.setData(ClipboardData(text: _otpCode!));
      if (mounted) {
        context.showSuccess('Đã copy mã OTP: $_otpCode');
        _otpController.text = _otpCode!;
      }
    } catch (e) {
      if (mounted) {
        context.showError('Lỗi khi copy OTP: $e');
      }
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      context.showError('Vui lòng nhập mã OTP.');
      return;
    }

    if (otp.length != 6) {
      context.showError('Mã OTP phải có 6 chữ số.');
      return;
    }

    setState(() => _isVerifying = true);
    try {
      final success = await widget.otpService.verifyOtp(widget.email, otp);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xác minh email thành công!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );

          await Future.delayed(const Duration(seconds: 1));
          Navigator.pop(context, true);
        }
      } else {
        context.showError('Mã OTP không chính xác hoặc đã hết hạn.');
      }
    } catch (e) {
      context.showError('Lỗi khi xác minh OTP: $e');
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() => _isSendingOtp = true);
    try {
      _otpCode = await widget.otpService.sendOtp(widget.email);
      if (_otpCode != null) {
        context.showSuccess('Mã OTP mới đã được gửi!');
        _startCountdown();
      } else {
        context.showError('Không thể gửi lại OTP.');
      }
    } catch (e) {
      context.showError('Lỗi khi gửi lại OTP: $e');
    } finally {
      if (mounted) {
        setState(() => _isSendingOtp = false);
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác minh Email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),

              Text(
                'Mã xác nhận đã được gửi đến:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),

              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Mã OTP có hiệu lực trong 5 phút',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),

              // OTP Input
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: 'Nhập mã OTP',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
                onChanged: (value) {
                  if (value.length == 6) _verifyOtp();
                },
              ),
              const SizedBox(height: 10),

              // Nút Mở Email & Copy OTP
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _openMailApp,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Mở Email'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Nút Xác minh
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isVerifying
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Xác minh OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 20),

              // Nút Gửi lại
              _isSendingOtp
                  ? const CircularProgressIndicator()
                  : TextButton(
                    onPressed: _canResend ? _resendOtp : null,
                    child: Text(
                      _canResend
                          ? 'Gửi lại mã OTP'
                          : 'Gửi lại sau $_secondsRemaining giây',
                      style: TextStyle(
                        color: _canResend ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
