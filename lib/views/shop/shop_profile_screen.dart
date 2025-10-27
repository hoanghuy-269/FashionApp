import 'dart:io';

import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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

  Future<void> _loadShopData() async {
    final shopVm = context.read<ShopViewModel>();
    final shop = shopVm.currentShop;

    if (shop == null) return;

    _nameController.text = shop.shopName;
    _phoneController.text = shop.phoneNumber?.toString() ?? '';
    _addressController.text = shop.address ?? '';
    setState(() {
      _cccdController.text = shop.nationalId;
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cccdController.dispose();
    _addressController.dispose();
    super.dispose();
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

  Future<void> _updateShopProfile() async {
    if (_isLoading) return;

    final shopVm = context.read<ShopViewModel>();
    if (shopVm.currentShop == null) return;

    setState(() => _isLoading = true);

    try {
      // Cập nhật thông tin shop
      String frontUrl = shopVm.currentShop!.idnationFront;
      String backUrl = shopVm.currentShop!.idnationBack;
      String? licenseUrl = shopVm.currentShop!.businessLicense;

      // Upload ảnh mới nếu có
      if (_frontID != null) {
        final uploadedFront = await GalleryUtil.uploadImageToFirebase(
          _frontID!,
        );
        if (uploadedFront != null) frontUrl = uploadedFront;
      }

      if (_backID != null) {
        final uploadedBack = await GalleryUtil.uploadImageToFirebase(_backID!);
        if (uploadedBack != null) backUrl = uploadedBack;
      }

      if (_license != null) {
        final uploadedLicense = await GalleryUtil.uploadImageToFirebase(
          _license!,
        );
        if (uploadedLicense != null) licenseUrl = uploadedLicense;
      }

      final updatedShop = shopVm.currentShop!.copyWith(
        shopName: _nameController.text.trim(),
        phoneNumber: int.tryParse(_phoneController.text.trim()),
        address: _addressController.text.trim(),
        nationalId: _cccdController.text.trim(),
        idnationFront: frontUrl,
        idnationBack: backUrl,
        businessLicense: licenseUrl,
      );

      await shopVm.updateShop(updatedShop);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cập nhật thông tin thành công"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cập nhật thông tin"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 50),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: "Họ và tên",
                  controller: _nameController,
                  icon: Icons.person_2_outlined,
                  hint: "Hiển thị tên Shop",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: "Số điện thoại",
                  controller: _phoneController,
                  icon: Icons.phone,
                  hint: "Hiển thị số điện thoại",
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: "Căn cước công dân",
                  controller: _cccdController,
                  icon: Icons.badge,
                  hint: "Căn cước công dân",
                  readOnly: true,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                _buildTextField(
                  label: "Địa chỉ",
                  controller: _addressController,
                  icon: Icons.map,
                  hint: "Hiển thị địa chỉ",
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateShopProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              "Cập nhật",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        child:
            (file == null && url == null)
                ? Column(
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
                )
                : Align(
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
                ),
      ),
    );
  }
}

enum ImageType { front, back, license }
