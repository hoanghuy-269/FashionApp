import 'dart:io';
import 'package:fashion_app/core/utils/flushbar_extension.dart';
import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/data/models/shopstaff_model.dart';
import 'package:fashion_app/viewmodels/rolestaff_viewmodel.dart';
import 'package:fashion_app/viewmodels/shopstaff_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ShopAddemployCreen extends StatefulWidget {
  const ShopAddemployCreen({super.key});

  @override
  State<ShopAddemployCreen> createState() => _ShopAddemployCreenState();
}

class _ShopAddemployCreenState extends State<ShopAddemployCreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController acountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cccdControler = TextEditingController();
  String selectedRole = "";
  File? frontID;
  File? backID;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final roleVm = Provider.of<RolestaffViewmodel>(context, listen: false);
        roleVm.fetchRoles();

    });
  }

  bool validatEmploy() {
    if (nameController.text.trim().isEmpty ||
        acountController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        cccdControler.text.trim().isEmpty ||
        frontID == null ||
        backID == null) {
      context.showError('Vui lòng điền đầy đủ thông tin');
      return false;
    }
    if (selectedRole.isEmpty) {
      context.showError('Vui lòng chọn chức vụ');
      return false;
    }
    context.showSuccess('Thêm nhân viên thành công');
    return true;
  }

  Future<void> pickImage(bool isFront) async {
    final File? image = await GalleryUtil.pickImageFromGallery();
    if (image != null) {
      setState(() {
        if (isFront) {
          frontID = image;
        } else {
          backID = image;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
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
              _buildInputField(
                "Tên nhân viên",
                nameController,
                hintText: "Nhập vào tên đầy dủ",
                prefixIcon: Icons.person,
              ),
              _buildInputField(
                "Tài khoản",
                acountController,
                hintText: "Nhập vào tài khoản",
                prefixIcon: Icons.person,
              ),
              _buildInputField(
                "Mật khẩu ",
                passwordController,
                hintText: "Nhập vào mật khẩu ",
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),

              const SizedBox(height: 5),
              _buildInputField(
                'Căn cước công dân',
                cccdControler,
                hintText: 'Nhập vào 12 số CCCD',
                prefixIcon: Icons.badge,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildImageBox(
                    "Mặt trước",
                    frontID,
                    onTap: () => pickImage(true),
                  ),
                  buildImageBox(
                    "Mặt sau",
                    backID,
                    onTap: () => pickImage(false),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                "Chức vụ ",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Consumer<RolestaffViewmodel>(
                  builder: (context, sfroles, _) {
                    return Row(
                      children: sfroles.roles
                          .map((role) => _buildRoleOption(role.roleName, role.roleId))
                          .toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(10),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        " Hủy ",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.30,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(10),
                      ),
                      onPressed: () async {
                        if (!validatEmploy()) return;

                        final staffVm = Provider.of<ShopStaffViewmodel>(context, listen: false);
                        final shopVm = Provider.of<ShopViewModel>(context, listen: false);
                        final shopId = shopVm.currentShop?.shopId;
                        if (shopId == null || shopId.isEmpty) {
                          context.showError('Không có cửa hàng đang được chọn. Vui lòng tạo hoặc chọn cửa hàng.');
                          return;
                        }

                        final model = ShopstaffModel(
                          employeeId: '', // let viewmodel generate id
                          shopId: shopId,
                          fullName: nameController.text.trim(),
                          password: passwordController.text.trim(),
                          nameaccount: acountController.text.trim(),
                          nationalId: cccdControler.text.trim(),
                          nationalIdFront: null,
                          nationalIdBack: null,
                          roleIds: selectedRole,
                          createdAt: DateTime.now(),
                        );

                        try {
                          await staffVm.saveStaff(model, front: frontID, back: backID);
                          if (!mounted) return;
                          Navigator.of(context).pop();
                          print("  Thêm nhân viên thành công");
                        } catch (e) {
                          if (!mounted) return;
                        print("  Lưu thất bại: $e");
                        }
                      },
                      child: Text(
                        "Thêm",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // giao diện cccd 2 ảnh

  Widget buildImageBox(
    String label,
    File? file, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: file != null ? Colors.blue.shade300 : Colors.grey.shade300,
            width: 1.3,
          ),
          image:
              file != null
                  ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                  : null,
          color: Colors.white,
        ),
        child:
            file == null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo, color: Colors.grey, size: 28),
                    const SizedBox(height: 8),
                    Text(label, style: const TextStyle(color: Colors.grey)),
                  ],
                )
                : Stack(
                  children: [
                    Positioned(
                      right: 6,
                      top: 6,
                      child: InkWell(
                        onTap:
                            () => setState(() {
                              if (label.contains("trước")) frontID = null;
                              if (label.contains("sau")) backID = null;
                            }),
                        child: const CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
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
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              prefixIcon:
                  prefixIcon != null
                      ? Icon(prefixIcon, color: Colors.blue)
                      : null,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.black, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.black, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(
    String roleName,
    String roleId, {
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    final isSelected = selectedRole == roleId;

    return GestureDetector(
      onTap: onTap ?? () => setState(() => selectedRole = roleId),
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey,
            width: 1.5,
          ),
        ),
        child: Text(
          roleName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
