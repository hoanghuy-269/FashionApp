import 'dart:io';
import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/core/utils/pick_image_bottom_sheet.dart';
import 'package:fashion_app/core/widget/vaidatedtextfielfromrequest.dart';
import 'package:fashion_app/data/models/storestaff_model.dart';
import 'package:fashion_app/viewmodels/employeerole_viewmodel.dart';
import 'package:fashion_app/viewmodels/storestaff_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShopAddemployCreen extends StatefulWidget {
  final String? shopId;
  const ShopAddemployCreen({super.key, this.shopId});

  @override
  State<ShopAddemployCreen> createState() => _ShopAddemployCreenState();
}

class _ShopAddemployCreenState extends State<ShopAddemployCreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cccdControler = TextEditingController();
  String okAction = "OKE";
  String continueAction = "CONTINUE";

  String selectedRole = "";
  bool isLoading = false;

  File? frontID;
  File? backID;

  String? roleError;
  String? nameError;
  String? emailError;
  String? cccdError;
  String? passwordError;
  String? frontError;
  String? backError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roleVm = Provider.of<EmployeeRoleViewmodel>(context, listen: false);
      roleVm.fetchRoles();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    cccdControler.dispose();
    super.dispose();
  }

  Future<void> pickImage(bool isFront) async {
    final File? image = await showPickImageBottomSheet(context);  
    if (image != null) {
      setState(() {
        if (isFront) {
          frontID = image;
          frontError = null;
        } else {
          backID = image;
          backError = null;
        }
      });
    }
  }

  bool validateFields() {
    bool isValid = true;
    
    // Reset tất cả lỗi trước
    nameError = null;
    emailError = null;
    passwordError = null;
    roleError = null;
    cccdError = null;
    frontError = null;
    backError = null;

    if (nameController.text.trim().isEmpty) {
      nameError = "Tên nhân viên không được để trống";
      isValid = false;
    }

    if (emailController.text.trim().isEmpty) {
      emailError = "Email không được để trống";
      isValid = false;
    } else if (!emailController.text.contains("@")) {
      emailError = "Email không hợp lệ";
      isValid = false;
    }

    if (passwordController.text.trim().isEmpty) {
      passwordError = "Mật khẩu không được để trống";
      isValid = false;
    } else if (passwordController.text.length < 6) {
      passwordError = "Mật khẩu phải ít nhất 6 ký tự";
      isValid = false;
    }

    if (selectedRole.trim().isEmpty) {
      roleError = "Vui lòng chọn chức vụ cho nhân viên";
      isValid = false;
    }

    if (cccdControler.text.trim().isEmpty) {
      cccdError = "CCCD không được để trống";
      isValid = false;
    }

    if (frontID == null) {
      frontError = "Ảnh mặt trước không được để trống";
      isValid = false;
    }

    if (backID == null) {
      backError = "Ảnh mặt sau không được để trống";
      isValid = false;
    }

    if (!isValid) {
      setState(() {});
    }

    return isValid;
  }
  void clearFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    cccdControler.clear();
    selectedRole = "";
    frontID = null;
    backID = null;

    nameError = null;
    emailError = null;
    passwordError = null;
    roleError = null;
    cccdError = null;
    frontError = null;
    backError = null;

    setState(() {});
  }

 Future<void> _handleAddEmployee() async {
  if (!validateFields()) return;

  setState(() => isLoading = true);

  try {
    final staffVm = Provider.of<StorestaffViewmodel>(context, listen: false);
    final shopVm = Provider.of<ShopViewModel>(context, listen: false);
    final shopId = shopVm.currentShop?.shopId;
    if (shopId == null) {
      throw Exception('Không tìm thấy cửa hàng hiện tại.');
    }
      String generateRequestId() {
      final now = DateTime.now();
      final formattedDate = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
      final timestamp = now.millisecondsSinceEpoch.toString().substring(10);
      return 'staff_${formattedDate}_$timestamp';
      }

    final model = StorestaffModel(
      employeeId: generateRequestId(),
      shopId: shopId,
      fullName: nameController.text.trim(),
      email: emailController.text.trim(),
      nationalId: cccdControler.text.trim(),
      nationalIdFront: null,
      nationalIdBack: null,
      roleIds: selectedRole,
      createdAt: DateTime.now(),
    );

    await staffVm.saveStaffWithAuth(
      model,
      password: passwordController.text.trim(),
      front: frontID,
      back: backID,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    // Hiển thị AlertDialog thành công
    final action = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thành công'),
        content: const Text('Thêm nhân viên thành công'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(okAction),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(continueAction),
                child: const Text('Tiếp tục'),
              ),
            ],
          )
        ],
      ),
    );

    if (!mounted) return;
    if (action == okAction) {
      Navigator.of(context).pop(true);
    } else if (action == continueAction) {
      clearFields();
    }

  } catch (e) {
    if (!mounted) return;
    setState(() => isLoading = false);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Lỗi'),
        content: Text(e.toString().replaceAll('Exception: ', '')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildNameField(),
                  _buildEmailField(),
                  _buildPasswordField(),
                  const SizedBox(height: 5),
                  _buildCCCDField(),
                  const SizedBox(height: 10),
                  _buildImageSection(),
                  const SizedBox(height: 20),
                  _buildRoleSection(),
                ],
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          color: Colors.black,
          iconSize: 26,
        ),
        const Text(
          "Thêm nhân viên",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        IconButton(
          onPressed: _handleAddEmployee,
          icon: const Icon(Icons.person_add),
          color: Colors.blue,
          iconSize: 26,
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return ValidatedTextFieldFromRequest(
      controller: nameController,
      label: "Họ và tên",
      hint: "Nhập vào họ và tên",
      icon: Icons.person,
      keyboardType: TextInputType.name,
      hasError: nameError != null,
      errorMessage: nameError ?? "Tên nhân viên không được để trống",
      onChanged: (value) {
        if (nameError != null) {
          setState(() => nameError = null);
        }
      },
    );
  }

  Widget _buildEmailField() {
    return ValidatedTextFieldFromRequest(
      controller: emailController,
      label: "Email",
      hint: "Nhập vào email",
      icon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      hasError: emailError != null,
      errorMessage: emailError ?? "Email không được để trống",
      onChanged: (value) {
        if (emailError != null) {
          setState(() => emailError = null);
        }
      },
    );
  }

  Widget _buildPasswordField() {
    return ValidatedTextFieldFromRequest(
      controller: passwordController,
      label: "Mật khẩu",
      hint: "Nhập vào mật khẩu",
      icon: Icons.lock,
      keyboardType: TextInputType.visiblePassword,
      hasError: passwordError != null,
      errorMessage: passwordError ?? "Mật khẩu không được để trống",
      onChanged: (value) {
        if (passwordError != null) {
          setState(() => passwordError = null);
        }
      },
    );
  }

  Widget _buildCCCDField() {
    return ValidatedTextFieldFromRequest(
      controller: cccdControler,
      label: "CCCD",
      hint: "Nhập vào số CCCD",
      icon: Icons.credit_card,
      maxLength: 12,
      keyboardType: TextInputType.phone,
      hasError: cccdError != null,
      errorMessage: cccdError ?? "CCCD không được để trống",
      onChanged: (value) {
        if (cccdError != null) {
          setState(() => cccdError = null);
        }
      },
    );
  }

  Widget _buildImageSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: buildImageBox(
            "Mặt trước",
            file: frontID,
            error: frontError,
            onTap: () => pickImage(true),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: buildImageBox(
            "Mặt sau",
            file: backID,
            error: backError,
            onTap: () => pickImage(false),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Chức vụ",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Consumer<EmployeeRoleViewmodel>(
            builder: (context, sfroles, _) {
              return Row(
                children: sfroles.roles
                    .map((role) => _buildRoleOption(role.roleName, role.roleId))
                    .toList(),
              );
            },
          ),
        ),
        if (roleError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              roleError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget buildImageBox(
    String label, {
    File? file,
    String? url,
    String? error,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: error != null ? Colors.red : Colors.grey.shade400,
              ),
              image: file != null
                  ? DecorationImage(
                      image: FileImage(file),
                      fit: BoxFit.cover,
                    )
                  : (url != null
                      ? DecorationImage(
                          image: NetworkImage(url),
                          fit: BoxFit.cover,
                        )
                      : null),
            ),
            child: (file == null && url == null)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo, color: Colors.grey),
                      const SizedBox(height: 5),
                      Text(
                        label,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Positioned(
                        right: 5,
                        top: 5,
                        child: InkWell(
                          onTap: onTap,
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(String roleName, String roleId) {
    final isSelected = selectedRole == roleId;

    return GestureDetector(
      onTap: () => setState(() {
        selectedRole = roleId;
        roleError = null;
      }),
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