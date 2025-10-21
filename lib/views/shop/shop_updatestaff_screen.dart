import 'dart:io';
import 'package:fashion_app/core/utils/flushbar_extension.dart';
import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/data/models/shopstaff_model.dart';
import 'package:fashion_app/viewmodels/rolestaff_viewmodel.dart';
import 'package:fashion_app/viewmodels/shopstaff_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ShopUpdatestaffScreen extends StatefulWidget {
  const ShopUpdatestaffScreen({super.key, this.staffToEdit});

  final ShopstaffModel? staffToEdit;

  @override
  State<ShopUpdatestaffScreen> createState() => _ShopUpdatestaffScreenState();
}

class _ShopUpdatestaffScreenState extends State<ShopUpdatestaffScreen> {
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

    final s = widget.staffToEdit;
    if (s != null) {
      nameController.text = s.fullName;
      acountController.text = s.nameaccount;
      passwordController.text = s.password;
      cccdControler.text = s.nationalId ?? '';
      selectedRole = s.roleIds;
    }

    // tải danh sách vai trò nhân viên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roleVM = Provider.of<RolestaffViewmodel>(context, listen: false);
      roleVM.fetchRoles();
    });
  }

  bool _validateEmployee() {
    if (nameController.text.trim().isEmpty ||
        acountController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        cccdControler.text.trim().isEmpty) {
      context.showError('Vui lòng điền đầy đủ thông tin');
      return false;
    }

    // Kiểm tra ảnh: có file mới HOẶC có URL từ data cũ
    final hasFront = frontID != null || widget.staffToEdit?.nationalIdFront != null;
    final hasBack = backID != null || widget.staffToEdit?.nationalIdBack != null;
    
    if (!hasFront || !hasBack) {
      context.showError('Vui lòng tải đầy đủ hình ảnh CCCD (mặt trước và mặt sau)');
      return false;
    }

    if (selectedRole.isEmpty) {
      context.showError('Vui lòng chọn chức vụ');
      return false;
    }

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
    final shopVm = Provider.of<ShopStaffViewmodel>(context, listen: false);
    final isEditing = widget.staffToEdit != null;

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
                child: Text(
                  isEditing ? 'Cập nhật nhân viên' : 'Thêm nhân viên',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField(
                "Tên nhân viên",
                nameController,
                hintText: "Nhập vào tên đầy đủ",
                prefixIcon: Icons.person,
              ),
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
                  _buildImageBox(
                    "Mặt trước",
                    file: frontID,
                    imageUrl: widget.staffToEdit?.nationalIdFront,
                    onTap: () => pickImage(true),
                    onDelete: () => setState(() => frontID = null),
                  ),
                  _buildImageBox(
                    "Mặt sau",
                    file: backID,
                    imageUrl: widget.staffToEdit?.nationalIdBack,
                    onTap: () => pickImage(false),
                    onDelete: () => setState(() => backID = null),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Chức vụ",
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
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(10),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "Hủy",
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(10),
                      ),
                      onPressed: () async {
                        if (!_validateEmployee()) return;

                        final base = widget.staffToEdit;
                        final model = ShopstaffModel(
                          employeeId: base?.employeeId ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          shopId: base?.shopId ?? '123', 
                          fullName: nameController.text.trim(),
                          password: passwordController.text.trim(),
                          nameaccount: acountController.text.trim(),
                          nationalId: cccdControler.text.trim(),
                          nationalIdFront: base?.nationalIdFront,
                          nationalIdBack: base?.nationalIdBack,
                          roleIds: selectedRole,
                          createdAt: base?.createdAt ?? DateTime.now(),
                        );

                        try {
                          await shopVm.saveStaff(model, front: frontID, back: backID);
                          if (!mounted) return;
                          Navigator.of(context).pop();
                        } catch (e) {
                          if (!mounted) return;
                          context.showError('Lưu thất bại: $e');
                        }
                      },
                      child: Text(
                        isEditing ? "Cập nhật" : "Thêm mới",
                        style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildImageBox(
    String label, {
    File? file,
    String? imageUrl,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    final hasImage = file != null || (imageUrl != null && imageUrl.isNotEmpty);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasImage ? Colors.blue.shade300 : Colors.grey.shade300,
            width: 1.3,
          ),
          color: Colors.white,
        ),
        child: hasImage
            ? Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: file != null
                          ? Image.file(file, fit: BoxFit.cover)
                          : Image.network(imageUrl!, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: InkWell(
                      onTap: onDelete,
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo, color: Colors.grey, size: 28),
                  const SizedBox(height: 8),
                  Text(label, style: const TextStyle(color: Colors.grey)),
                ],
              ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    String? hintText,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.blue) : null,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 1),
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

  Widget _buildRoleOption(String roleName, String roleId) {
    final isSelected = selectedRole == roleId;

    return GestureDetector(
      onTap: () => setState(() => selectedRole = roleId),
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