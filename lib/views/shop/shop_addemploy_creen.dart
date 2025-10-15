import 'package:flutter/material.dart';

class ShopAddemployCreen extends StatefulWidget {
  const ShopAddemployCreen({super.key});

  @override
  State<ShopAddemployCreen> createState() => _ShopAddemployCreenState();
}

class _ShopAddemployCreenState extends State<ShopAddemployCreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController acountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = "Ship";
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFE8F5FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: const Text(
                  "Thêm nhân viên ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField("Tên nhân viên", nameController,hintText: "Nhập vào tên đầy dủ",prefixIcon: Icons.person),
              _buildInputField("Tài khoản", acountController,hintText: "Nhập vào tài khoản",prefixIcon: Icons.person),
              _buildInputField("Mật khẩu ", passwordController,hintText: "Nhập vào mật khẩu ",prefixIcon: Icons.lock_outline),
              
              const SizedBox(height: 10),
              const Divider(thickness: 1),
              const SizedBox(height: 8),

              const Text(
                "Chức vụ ",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildRoleOption("Ship"),
                    _buildRoleOption("Thu Ngân"),
                    _buildRoleOption("Quản lí kho"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 1),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Tạo", style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // thêm nhân viên
Widget _buildInputField(
  String label,
  TextEditingController controller, {
  bool obscureText = false,
  String? hintText,
  IconData? prefixIcon,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.blue)
                : null,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 1.8),
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildRoleOption(String role) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: role,
          groupValue: selectedRole,
          onChanged: (String? value) {
            setState(() {
              selectedRole = value!;
            });
          },
        ),
        Text(role),
      ],
    );
  }
}
