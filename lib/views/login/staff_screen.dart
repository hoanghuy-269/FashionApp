import 'package:fashion_app/viewmodels/auth_viewmodel.dart';
import 'package:fashion_app/views/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _authViewModel = AuthViewModel();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Màn hình nhân viên',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Xác nhận'),
                      content: const Text('Bạn có chắc muốn đăng xuất không?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Đăng xuất'),
                        ),
                      ],
                    ),
              );

              if (confirm == true) {
                await _authViewModel.logout(); // Đăng xuất khỏi Firebase
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false, // Xóa toàn bộ stack
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin nhân viên
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  user?.email ?? 'Chưa có email',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Nhân viên cửa hàng'),
              ),
            ),
            const SizedBox(height: 30),

            // Các chức năng
            const Text(
              'Chức năng nhanh',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),

            _buildMenuButton(
              icon: Icons.receipt_long,
              title: 'Xem danh sách đơn hàng',
              onTap: () {
                // TODO: chuyển sang màn đơn hàng
              },
            ),
            _buildMenuButton(
              icon: Icons.verified,
              title: 'Xác nhận đơn hàng',
              onTap: () {
                // TODO: chuyển sang màn xác nhận đơn
              },
            ),
            _buildMenuButton(
              icon: Icons.store,
              title: 'Thông tin cửa hàng',
              onTap: () {
                // TODO: chuyển sang màn shop info
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper để tạo các nút chức năng
  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right),
        tileColor: Colors.deepPurple.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: onTap,
      ),
    );
  }
}
