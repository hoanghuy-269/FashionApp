import 'package:fashion_app/viewmodels/auth_viewmodel.dart';
import 'package:fashion_app/views/login/login_screen.dart';
import 'package:flutter/material.dart';

class OtpRequestScreen extends StatefulWidget {
  const OtpRequestScreen({super.key});

  @override
  State<OtpRequestScreen> createState() => _OtpRequestScreenState();
}

class _OtpRequestScreenState extends State<OtpRequestScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _auth_model = AuthViewModel();

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập số điện thoại hợp lệ")),
      );
      return;
    }

    // TODO: Gọi API gửi OTP ở đây
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Đã gửi mã OTP đến số $phone")));

    // Chuyển sang màn hình nhập OTP
    // Navigator.push(context, MaterialPageRoute(builder: (_) => VerificationScreen(phoneNumber: phone)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 73, 118, 187),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Hộp trắng cong viền trên
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _auth_model.logout();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.blue.shade50,
                          child: const Icon(Icons.login, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Icon khóa
                      Image.asset('assets/icons/lock.png', height: 100),
                      const SizedBox(height: 30),

                      // Tiêu đề
                      const Text(
                        "Xác nhận OTP",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),

                      const Text(
                        "Vui lòng nhập số điện thoại để xác nhận mã OTP",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),

                      const SizedBox(height: 40),

                      // Ô nhập số điện thoại
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "Nhập số điện thoại",
                          prefixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 10),
                              Image.asset(
                                'assets/icons/vietnam.png',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '+84',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3F3F3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              74,
                              116,
                              231,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            "Lấy mã OTP",
                            style: TextStyle(
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
            ),
          ],
        ),
      ),
    );
  }
}
