import 'dart:async';
import 'dart:io';
import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/core/utils/pick_image_bottom_sheet.dart';
import 'package:fashion_app/data/models/User.dart';
import 'package:fashion_app/viewmodels/auth_viewmodel.dart';
import 'package:fashion_app/viewmodels/requesttopent_viewmodel.dart';
import 'package:fashion_app/views/login/change_password_screen.dart';
import 'package:fashion_app/views/login/login_screen.dart';
import 'package:fashion_app/views/shop/shop_screen.dart';
import 'package:fashion_app/views/user/approved_shop_dialog.dart';
import 'package:fashion_app/views/user/requesttoopentshop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserprofileScreen extends StatefulWidget {
  final String? idUser;
  const UserprofileScreen({super.key, this.idUser});

  @override
  State<UserprofileScreen> createState() => _UserprofileScreenState();
}

class _UserprofileScreenState extends State<UserprofileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  User? currentUser;
  bool isLoading = true;
  bool _isApprovedShop = false;

  File? avatarImage;
  String? avatarURL;

  StreamSubscription<User?>? _userSub;

  @override
  void initState() {
    super.initState();

    if (widget.idUser != null && widget.idUser!.isNotEmpty) {
      final authVM = AuthViewModel();
      _userSub = authVM.getUserById(widget.idUser!).listen((user) {
        if (user != null) {
          setState(() {
            currentUser = user;
            nameController.text = user.name ?? '';
            phoneController.text =
                user.phoneNumbers.isNotEmpty ? user.phoneNumbers[0] : '';
            addressController.text =
                user.addresses.isNotEmpty ? user.addresses[0] : '';
            avatarURL = user.avatar;
            emailController.text = user.email ?? '';
            isLoading = false; // ✅ Thêm dòng này
          });
        } else {
          setState(
            () => isLoading = false,
          ); // ✅ Dừng loading ngay cả khi user null
        }
      });
    } else {
      // Trường hợp không có idUser
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _userSub?.cancel(); // nhớ hủy stream khi widget bị dispose
    super.dispose();
  }

  Future<void> _navigateToShop() async {
    if (currentUser == null) return;
    try {
      final selected = await ApprovedShopDialog.show(context, currentUser!.id);
      if (selected != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShopScreen(idShop: selected.shopId),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  // ---------------- SHOW PROFILE POPUP ----------------
  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Your Profile", style: TextStyle(fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // ===========================
                // ✅ AVATAR
                // ===========================
                GestureDetector(
                  onTap: _handleAvatarPick,
                  child: Stack(
                    children: [
                      ClipOval(
                        child:
                            avatarImage != null
                                ? Image.file(
                                  avatarImage!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                )
                                : (avatarURL != null && avatarURL!.isNotEmpty
                                    ? Image.network(
                                      avatarURL!,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    )
                                    : Image.asset(
                                      'assets/images/logo_default.png',
                                      width: 90,
                                      height: 90,
                                    )),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: emailController,
                  readOnly: true,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1.4,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _buildDialogField("Họ và tên", nameController),
                const SizedBox(height: 12),

                _buildDialogField(
                  "Số điện thoại",
                  phoneController,
                  isPhone: true,
                ),
                const SizedBox(height: 12),

                _buildDialogField("Địa chỉ", addressController),
              ],
            ),
          ),

          // ===========================
          // ✅ BUTTON ACTIONS
          // ===========================
          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Cập nhật"),
              onPressed: () async {
                await _handleUpdate();
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // --------------- UPDATE PROFILE ------------------
  Future<void> _handleUpdate() async {
    if (currentUser == null) return;

    try {
      final authVM = AuthViewModel();

      await authVM.updateUserProfile(
        userId: currentUser!.id,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        avatar: avatarURL,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cập nhật thành công!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  // --------------- PICK NEW AVATAR ------------------
  Future<void> _handleAvatarPick() async {
    final image = await showPickImageBottomSheet(context);
    if (image != null) {
      setState(() => avatarImage = image);

      try {
        final url = await GalleryUtil.uploadImageToFirebase(image);
        setState(() => avatarURL = url);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi upload ảnh: $e")));
      }
    }
  }

  // ---------------- LOGOUT -----------------
  Future<void> _handleLogout() async {
    final confirm = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Đăng xuất"),
            content: const Text("Bạn có chắc muốn đăng xuất không?"),
            actions: [
              TextButton(
                child: const Text("Hủy"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text("Đăng xuất"),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final authVM = AuthViewModel();
      await authVM.logout();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  // ---------------- UI -----------------
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                RequestToOpenStoreScreen(uid: currentUser!.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Yêu cầu mở shop",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
             
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Navigator.pop(context);
                      _navigateToShop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Chọn shop",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                )
            ],
          ),

          const SizedBox(height: 20),

          _buildMenuItem(
            icon: Icons.person_outline,
            title: "Thông tin cá nhân",
            onTap: _showProfileDialog,
          ),

          _buildMenuItem(
            icon: Icons.credit_card,
            title: "Phương thức thanh toán",
          ),
          _buildMenuItem(icon: Icons.shopping_bag, title: "Đơn hàng của tôi"),
          _buildMenuItem(
            icon: Icons.settings,
            title: "Đổi mật khẩu",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),
          _buildMenuItem(icon: Icons.people, title: "Mời bạn bè"),

          const SizedBox(height: 20),
          _buildMenuItem(
            icon: Icons.logout,
            title: "Đăng xuất",
            color: Colors.red,
            onTap: _handleLogout,
          ),
        ],

      ),
    );
  }

  // ---------------- HEADER -----------------
  Widget _buildHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: _handleAvatarPick,
          child: Stack(
            children: [
              ClipOval(
                child:
                    avatarImage != null
                        ? Image.file(
                          avatarImage!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                        : (avatarURL != null
                            ? Image.network(
                              avatarURL!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                            : Image.asset(
                              'assets/images/logo_default.png',
                              width: 100,
                              height: 100,
                            )),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          currentUser?.name ?? "",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color color = Colors.black,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  // ---------------- DIALOG INPUT ----------------
  Widget _buildDialogField(
    String label,
    TextEditingController ctrl, {
    bool isPhone = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      inputFormatters:
          isPhone
              ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ]
              : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
