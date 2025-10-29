import 'dart:io';

import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/core/utils/pick_image_bottom_sheet.dart';
import 'package:fashion_app/data/models/User.dart';
import 'package:fashion_app/data/models/requesttoopentshop_model.dart';
import 'package:fashion_app/viewmodels/auth_viewmodel.dart';
import 'package:fashion_app/viewmodels/requesttopent_viewmodel.dart';
import 'package:fashion_app/views/user/approved_shop_dialog.dart';
import 'package:fashion_app/views/shop/shop_screen.dart';
import 'package:fashion_app/views/user/requesttoopentshop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../login/login_screen.dart';

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
  
  User? currentUser;
  bool isLoading = true;
  bool isUpdating = false;
  String? errorMessage;
  String? avatarURL;
  File? avatarImage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (widget.idUser == null || widget.idUser!.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = "ID người dùng không hợp lệ";
      });
      return;
    }

    try {
      final authVM = AuthViewModel();
      final user = await authVM.FetchUserById(widget.idUser!);

      if (!mounted) return;

      if (user != null) {
        nameController.text = user.name ?? '';
        phoneController.text =
            user.phoneNumbers.isNotEmpty ? user.phoneNumbers[0] : '';
        addressController.text =
            user.addresses.isNotEmpty ? user.addresses[0] : '';
        avatarURL = user.avatar; // Giả sử User model có field avatar
      }

      setState(() {
        currentUser = user;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Lỗi khi lấy thông tin: $e";
        isLoading = false;
      });
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _handleAvatarPick() async {
    final image = await showPickImageBottomSheet(context);
    if (image != null) {
      setState(() {
        avatarImage = image;
      });

      try {
        final url = await GalleryUtil.uploadImageToFirebase(image);
        setState(() {
          avatarURL = url;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi upload ảnh: $e')),
        );
      }
    }
  }

  Future<void> _handleUpdate() async {
    if (currentUser == null) return;

    setState(() => isUpdating = true);

    try {
      final authVM = AuthViewModel();
            // await authVM.updateUser(
      //   userId: currentUser!.id,
      //   name: nameController.text.trim(),
      //   phone: phoneController.text.trim(),
      //   address: addressController.text.trim(),
      //   avatar: avatarURL,
      // );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh data
      await _initializeData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      final authVM = AuthViewModel();
      await authVM.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Thông tin người dùng'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Thông tin người dùng'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _initializeData();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin người dùng'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<RequesttoopentshopModel>>(
          stream: Provider.of<RequestToOpenShopViewModel>(context, listen: false)
              .streamUserRequests(currentUser!.id),
          builder: (context, snapshot) {
            final hasRequest = snapshot.hasData && snapshot.data!.isNotEmpty;
            final request = hasRequest ? snapshot.data!.first : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(request),
                  const SizedBox(height: 24),
                  _buildForm(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(RequesttoopentshopModel? request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _handleAvatarPick,
          child: Stack(
            children: [
              ClipOval(
                child: avatarImage != null
                    ? Image.file(
                        avatarImage!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : (avatarURL != null && avatarURL!.isNotEmpty
                        ? Image.network(
                            avatarURL!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/logo_default.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/images/logo_default.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RequestToOpenStoreScreen(uid: currentUser!.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Yêu cầu mở shop',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            if (request?.status == 'approved') ...[
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _navigateToShop,
                icon: const Icon(Icons.store, size: 16),
                label: const Text('Chọn shop', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildTextField(
          label: "Email",
          hintText: currentUser?.email ?? '',
          icon: Icons.email_outlined,
          enabled: false,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: "Họ và tên",
          controller: nameController,
          icon: Icons.person_2_outlined,
        ),
        const SizedBox(height: 16),
        _buildPhoneField(),
        const SizedBox(height: 16),
        _buildTextField(
          label: "Địa chỉ",
          controller: addressController,
          icon: Icons.location_on_outlined,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? hintText,
    IconData? icon,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Số điện thoại",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                "assets/icons/vietnam.png",
                width: 24,
                height: 24,
              ),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isUpdating ? null : () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "Hủy",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isUpdating ? null : _handleUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isUpdating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Cập nhật",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}