import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  final String smtpServer;
  final String username;
  final String password;
  final int port;
  final bool isSSL;

  EmailService({
    required this.smtpServer,
    required this.username,
    required this.password,
    this.port = 587,
    this.isSSL = false,
  });

  // Tạo SMTP server
  SmtpServer get _smtpServer {
    if (isSSL) {
      return SmtpServer(
        smtpServer,
        username: username,
        password: password,
        port: port,
        ssl: true,
      );
    } else {
      return SmtpServer(
        smtpServer,
        username: username,
        password: password,
        port: port,
      );
    }
  }

  // Gửi OTP email
  Future<String?> sendOtp(String recipientEmail) async {
    try {
      final otpCode = _generateOtp();

      final message =
          Message()
            ..from = Address(username, 'Fashion App')
            ..recipients.add(recipientEmail)
            ..subject = 'Mã xác nhận OTP - Fashion App'
            ..html = '''
          <html>
            <body>
              <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <h2 style="color: #333; text-align: center;">Xác nhận địa chỉ email</h2>
                <p>Xin chào,</p>
                <p>Bạn đang thực hiện xác minh email cho tài khoản Fashion App.</p>
                <div style="background-color: #f8f9fa; padding: 20px; border-radius: 10px; text-align: center; margin: 25px 0; border: 2px dashed #dee2e6;">
                  <h1 style="color: #e44d67; font-size: 36px; margin: 0; font-weight: bold; letter-spacing: 5px;">$otpCode</h1>
                </div>
                <p style="text-align: center;">Mã OTP có hiệu lực trong vòng <strong style="color: #dc3545;">5 phút</strong>.</p>
                <p style="color: #6c757d; text-align: center;">Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email này.</p>
                <hr style="border: none; border-top: 1px solid #eee; margin: 25px 0;">
                <p style="color: #6c757d; font-size: 12px; text-align: center;">Đây là email tự động, vui lòng không trả lời.</p>
              </div>
            </body>
          </html>
        ''';

      print('📧 Sending email details:');
      print('   - From: $username');
      print('   - To: $recipientEmail');
      print('   - OTP: $otpCode');
      print('   - SMTP Server: $smtpServer:$port');

      final sendReport = await send(message, _smtpServer);
      print('✅ Email sent successfully!');

      return otpCode;
    } catch (e) {
      print('❌ Error sending email: $e');
      return null;
    }
  }

  String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}
