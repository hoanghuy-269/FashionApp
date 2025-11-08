import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailOtpService {
  final _db = FirebaseDatabase.instance.ref();

  Future<String?> sendOtp(String email) async {
    try {
      final otp = _generateOtp();
      print('🔢 Mã OTP tạo ra: $otp');

      await _db.child('email_otps').child(_encodeEmail(email)).set({
        'otp': otp,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      return otp;
    } catch (e) {
      return null;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final ref = _db.child('email_otps').child(_encodeEmail(email));
      final snapshot = await ref.get();

      if (!snapshot.exists) return false;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final savedOtp = data['otp']?.toString();
      final timestamp = data['timestamp'] as int;

      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp > 5 * 60 * 1000) {
        await ref.remove(); // Xóa nếu hết hạn
        return false;
      }

      if (otp == savedOtp) {
        await ref.remove();
        return true;
      }
      return false;
    } catch (e) {
      print(' Lỗi khi xác minh OTP: $e');
      return false;
    }
  }

  String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  String _encodeEmail(String email) => email.replaceAll('.', ',');
}
