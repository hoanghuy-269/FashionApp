import 'package:firebase_auth/firebase_auth.dart';

class PhoneOtpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  Future<void> sendOtp(String phoneNumber) async {
    // Đảm bảo số điện thoại có định dạng quốc tế (+84 cho Vietnam)
    String formattedPhone = phoneNumber;
    if (!phoneNumber.startsWith('+')) {
      formattedPhone = '+84${phoneNumber.substring(1)}';
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Tự động xác thực nếu không cần nhập OTP (trên một số thiết bị)
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('Lỗi xác thực: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<bool> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      throw Exception('Không tìm thấy verificationId. Vui lòng gửi lại OTP.');
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Đăng xuất ngay sau khi xác thực thành công vì chúng ta chỉ cần xác minh số điện thoại
      // và sẽ tạo tài khoản thực sự trong quá trình đăng ký
      if (userCredential.user != null) {
        await _auth.signOut();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Xác thực OTP thất bại: $e');
    }
  }

  // Hàm để gửi lại OTP
  Future<void> resendOtp(String phoneNumber) async {
    await sendOtp(phoneNumber);
  }
}
