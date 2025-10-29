import 'dart:io';

import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

enum ImageType { front, back, license }

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cccdController = TextEditingController();
  final _addressController = TextEditingController();

  File? _frontID;
  File? _backID;
  File? _license;

  String? _frontUrl;
  String? _backUrl;
  String? _licenseUrl;

  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;
    _isInitialized = true;
    _loadShopData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cccdController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadShopData() {
    final shopVm = context.read<ShopViewModel>();
    final shop = shopVm.currentShop;

    if (shop == null) return;

    _nameController.text = shop.shopName;
    _phoneController.text = shop.phoneNumber?.toString() ?? '';
    _cccdController.text = shop.nationalId;
    _addressController.text = shop.address ?? '';

    setState(() {
      _frontUrl =
          shop.idnationFront.isNotEmpty
              ? "${shop.idnationFront}?ts=${DateTime.now().millisecondsSinceEpoch}"
              : null;
      _backUrl =
          shop.idnationBack.isNotEmpty
              ? "${shop.idnationBack}?ts=${DateTime.now().millisecondsSinceEpoch}"
              : null;
      _licenseUrl = shop.businessLicense;
    });
  }

  Future<void> _pickImage(ImageType type) async {
    final image = await GalleryUtil.pickImageFromGallery();
    if (image != null && mounted) {
      setState(() {
        switch (type) {
          case ImageType.front:
            _frontID = image;
            break;
          case ImageType.back:
            _backID = image;
            break;
          case ImageType.license:
            _license = image;
            break;
        }
      });
    }
  }

  Future<String?> _uploadImageIfNeeded(File? file, String currentUrl) async {
    if (file == null) return currentUrl;
    final uploadedUrl = await GalleryUtil.uploadImageToFirebase(file);
    return uploadedUrl ?? currentUrl;
  }

  Future<void> _updateShopProfile() async {
    if (_isLoading) return;

    final shopVm = context.read<ShopViewModel>();
    final currentShop = shopVm.currentShop;

    if (currentShop == null) return;

    setState(() => _isLoading = true);

    try {
      // Upload các ảnh mới nếu có
      final frontUrl = await _uploadImageIfNeeded(
        _frontID,
        currentShop.idnationFront,
      );
      final backUrl = await _uploadImageIfNeeded(
        _backID,
        currentShop.idnationBack,
      );
      final licenseUrl = await _uploadImageIfNeeded(
        _license,
        currentShop.businessLicense ?? '',
      );

      // Tạo shop đã update
      final updatedShop = currentShop.copyWith(
        shopName: _nameController.text.trim(),
        phoneNumber: int.tryParse(_phoneController.text.trim()),
        address: _addressController.text.trim(),
        nationalId: _cccdController.text.trim(),
        idnationFront: frontUrl,
        idnationBack: backUrl,
        businessLicense: licenseUrl,
      );

      await shopVm.updateShop(updatedShop);

      if (!mounted) return;

      _showSnackBar("Cập nhật thông tin thành công", Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Lỗi: ${e.toString()}", Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileAvatar(),
              const SizedBox(height: 20),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildPhoneField(),
              const SizedBox(height: 16),
              _buildCCCDField(),
              const SizedBox(height: 16),
              _buildIDImagesSection(),
              const SizedBox(height: 16),
              _buildLicenseSection(),
              const SizedBox(height: 16),
              _buildAddressField(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Cập nhật thông tin",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
      ),
      actions: [
        IconButton(
          onPressed: () {
            _updateShopProfile();
          },
          icon: Icon(
            Icons.save,
            color: _isLoading ? Colors.grey : Colors.black,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return const Center(
      child: CircleAvatar(radius: 40, child: Icon(Icons.person, size: 50)),
    );
  }

  Widget _buildNameField() {
    return _buildTextField(
      label: "Họ và tên",
      controller: _nameController,
      icon: Icons.person_2_outlined,
      hint: "Hiển thị tên Shop",
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      label: "Số điện thoại",
      controller: _phoneController,
      icon: Icons.phone,
      hint: "Hiển thị số điện thoại",
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12),
      ],
    );
  }

  Widget _buildCCCDField() {
    return _buildTextField(
      label: "Căn cước công dân",
      controller: _cccdController,
      icon: Icons.badge,
      hint: "Căn cước công dân",
      readOnly: true,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildIDImagesSection() {
    return Row(
      children: [
        Expanded(
          child: _buildImageBox(
            "Mặt trước",
            file: _frontID,
            url: _frontUrl,
            onTap: () => _pickImage(ImageType.front),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildImageBox(
            "Mặt sau",
            file: _backID,
            url: _backUrl,
            onTap: () => _pickImage(ImageType.back),
          ),
        ),
      ],
    );
  }

  Widget _buildLicenseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Giấy phép kinh doanh",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildImageBox(
          "Giấy phép kinh doanh",
          file: _license,
          url: _licenseUrl,
          onTap: () => _pickImage(ImageType.license),
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return _buildTextField(
      label: "Địa chỉ",
      controller: _addressController,
      icon: Icons.map,
      hint: "Hiển thị địa chỉ",
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
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
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blueAccent),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            hintText: hint,
          ),
        ),
      ],
    );
  }

  Widget _buildImageBox(
    String label, {
    File? file,
    String? url,
    required VoidCallback onTap,
    double? width,
  }) {
    final hasImage = file != null || url != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
          image:
              file != null
                  ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                  : (url != null
                      ? DecorationImage(
                        image: NetworkImage(url),
                        fit: BoxFit.cover,
                      )
                      : null),
        ),
        child: hasImage ? _buildEditIcon(onTap) : _buildPlaceholder(label),
      ),
    );
  }

  Widget _buildEditIcon(VoidCallback onTap) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: InkWell(
          onTap: onTap,
          child: const CircleAvatar(
            radius: 12,
            backgroundColor: Colors.black54,
            child: Icon(Icons.edit, size: 15, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_a_photo, color: Colors.grey),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
