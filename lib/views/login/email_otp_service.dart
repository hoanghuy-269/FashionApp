import 'dart:math';
import 'package:fashion_app/views/login/email_service.dart';

class EmailOtpService {
  final Map<String, String> _otpStorage = {};
  final Map<String, DateTime> _otpCreationTime = {};
  final EmailService? _emailService;

  static EmailOtpService? _instance;

  // Private constructor
  EmailOtpService._internal({EmailService? emailService})
    : _emailService = emailService;

  // Factory constructor - SINGLETON PATTERN
  factory EmailOtpService({EmailService? emailService}) {
    if (_instance == null) {
      _instance = EmailOtpService._internal(emailService: emailService);
      print('🔄 Created NEW EmailOtpService instance');
    }
    return _instance!;
  }

  // Getter
  EmailService? get emailService => _emailService;
  bool get hasEmailService => _emailService != null;

  Future<String?> sendOtp(String email) async {
    try {
      print('🎯 EmailOtpService.sendOtp called for: $email');
      print('🔧 _emailService is null: ${_emailService == null}');

      if (_emailService != null) {
        print('📧 EmailService username: ${_emailService!.username}');
        print('🚀 Using REAL email service...');

        final emailResult = await _emailService!.sendOtp(email);
        if (emailResult == null) {
          print('❌ Không thể gửi email OTP');
          return null;
        }

        final otpCode = emailResult;
        print('✅ Đã gửi email OTP thật: $otpCode');

        // LƯU OTP VÀ THỜI GIAN TẠO
        _otpStorage[email] = otpCode;
        _otpCreationTime[email] = DateTime.now();
        print('⏰ OTP stored for verification: $otpCode');

        // Tự động xóa OTP sau 5 phút
        Future.delayed(const Duration(minutes: 5), () {
          _otpStorage.remove(email);
          _otpCreationTime.remove(email);
          print('🗑️ OTP expired for: $email');
        });

        return otpCode;
      } else {
        // Chế độ debug
        final otpCode = _generateOtp();
        print('🐛 DEBUG MODE - OTP: $otpCode');

        // Vẫn lưu OTP để test
        _otpStorage[email] = otpCode;
        _otpCreationTime[email] = DateTime.now();

        return otpCode;
      }
    } catch (e) {
      print('❌ Error in sendOtp: $e');
      return null;
    }
  }

  String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<bool> verifyOtp(String email, String otp) async {
    final storedOtp = _otpStorage[email];
    final creationTime = _otpCreationTime[email];

    print('🔍 Verifying OTP:');
    print('   - Email: $email');
    print('   - OTP nhập: $otp');
    print('   - OTP lưu: $storedOtp');
    print('   - Thời gian tạo: $creationTime');

    // Kiểm tra OTP có tồn tại không
    if (storedOtp == null) {
      print('❌ OTP không tồn tại hoặc đã hết hạn');
      return false;
    }

    // Kiểm tra OTP hết hạn (5 phút)
    if (creationTime != null) {
      final now = DateTime.now();
      final difference = now.difference(creationTime);
      print('   - Thời gian hiện tại: $now');
      print('   - Khoảng cách: ${difference.inSeconds} giây');

      if (difference.inMinutes >= 5) {
        _otpStorage.remove(email);
        _otpCreationTime.remove(email);
        print('❌ OTP đã hết hạn (quá 5 phút)');
        return false;
      }
    }

    // So sánh OTP
    final isMatch = storedOtp == otp;
    print('✅ OTP ${isMatch ? 'KHỚP' : 'KHÔNG KHỚP'}');

    if (isMatch) {
      // Xóa OTP sau khi xác minh thành công
      _otpStorage.remove(email);
      _otpCreationTime.remove(email);
      print('🗑️ Đã xóa OTP sau khi xác minh thành công');
    }

    return isMatch;
  }

  // Hàm debug để kiểm tra OTP hiện tại
  void debugOtp(String email) {
    print('🐛 DEBUG OTP:');
    print('   - Email: $email');
    print('   - OTP stored: ${_otpStorage[email]}');
    print('   - Creation time: ${_otpCreationTime[email]}');
  }
}
