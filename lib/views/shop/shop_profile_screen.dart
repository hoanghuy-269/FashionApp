import 'dart:io';

import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/core/utils/pick_image_bottom_sheet.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

enum ImageType { front, back, license, avatar }

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cccdController = TextEditingController();
  final _addressController = TextEditingController();

  final Map<ImageType, File?> _imageFiles = {
    ImageType.front: null,
    ImageType.back: null,
    ImageType.license: null,
    ImageType.avatar: null,
  };

  final Map<ImageType, String?> _imageUrls = {
    ImageType.front: null,
    ImageType.back: null,
    ImageType.license: null,
    ImageType.avatar: null,
  };

  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadShopData();
    }
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
    final shop = context.read<ShopViewModel>().currentShop;
    if (shop == null) return;

    _nameController.text = shop.shopName;
    _phoneController.text = shop.phoneNumber?.toString() ?? '';
    _cccdController.text = shop.nationalId;
    _addressController.text = shop.address ?? '';

    setState(() {
      _imageUrls[ImageType.front] = shop.idnationFront.isNotEmpty
          ? "${shop.idnationFront}?ts=${DateTime.now().millisecondsSinceEpoch}"
          : null;
      _imageUrls[ImageType.back] = shop.idnationBack.isNotEmpty
          ? "${shop.idnationBack}?ts=${DateTime.now().millisecondsSinceEpoch}"
          : null;
      _imageUrls[ImageType.license] = shop.businessLicense;
      _imageUrls[ImageType.avatar] = shop.logo; // Thêm avatar URL từ shop model
    });
  }

  Future<void> _pickImage(ImageType type) async {
    final image = await showPickImageBottomSheet(context);
    if (image != null && mounted) {
      setState(() => _imageFiles[type] = image);
    }
  }

  Future<String?> _uploadImage(File? file, String? currentUrl) async {
    if (file == null) return currentUrl;
    try {
      return await GalleryUtil.uploadImageToFirebase(file) ?? currentUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      return currentUrl;
    }
  }

  Future<void> _updateShopProfile() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    final shopVm = context.read<ShopViewModel>();
    final currentShop = shopVm.currentShop;
    if (currentShop == null) return;

    setState(() => _isLoading = true);

    try {
      // Upload tất cả ảnh song song để nhanh hơn
      final uploadFutures = <Future<String?>>[];
      final imageTypes = [
        ImageType.front,
        ImageType.back,
        ImageType.license,
        ImageType.avatar,
      ];

      for (var type in imageTypes) {
        final currentUrl = type == ImageType.front
            ? currentShop.idnationFront
            : type == ImageType.back
                ? currentShop.idnationBack
                : type == ImageType.license
                    ? currentShop.businessLicense ?? ''
                    : currentShop.logo ?? ''; // Avatar URL

        uploadFutures.add(_uploadImage(_imageFiles[type], currentUrl));
      }

      final results = await Future.wait(uploadFutures);

      // Tạo shop đã update với cả avatar
      final updatedShop = currentShop.copyWith(
        shopName: _nameController.text.trim(),
        phoneNumber: int.tryParse(_phoneController.text.trim()),
        address: _addressController.text.trim(),
        nationalId: _cccdController.text.trim(),
        idnationFront: results[0],
        idnationBack: results[1],
        businessLicense: results[2],
        logo: results[3], 
      );

      await shopVm.updateShop(updatedShop);

      if (!mounted) return;
      _showSnackBar("Cập nhật thông tin thành công! ✓", Colors.green);
      
      // Reset image files sau khi upload thành công
      setState(() {
        _imageFiles.updateAll((key, value) => null);
      });
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Lỗi: ${e.toString()}", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              backgroundColor == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileAvatar(
                        imageFile: _imageFiles[ImageType.avatar],
                        imageUrl: _imageUrls[ImageType.avatar],
                        onTap: () => _pickImage(ImageType.avatar),
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(title: "Thông tin cơ bản"),
                      const SizedBox(height: 12),
                      _ProfileTextField(
                        label: "Tên cửa hàng",
                        controller: _nameController,
                        icon: Icons.store,
                        hint: "Nhập tên cửa hàng",
                        validator: (val) =>
                            val?.isEmpty ?? true ? 'Vui lòng nhập tên' : null,
                      ),
                      const SizedBox(height: 16),
                      _ProfileTextField(
                        label: "Số điện thoại",
                        controller: _phoneController,
                        icon: Icons.phone,
                        hint: "Nhập số điện thoại",
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                        ],
                        validator: (val) {
                          if (val?.isEmpty ?? true) return 'Vui lòng nhập SĐT';
                          if (val!.length < 10) return 'SĐT không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _ProfileTextField(
                        label: "Căn cước công dân",
                        controller: _cccdController,
                        icon: Icons.badge,
                        hint: "Số CCCD",
                        readOnly: true,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _ProfileTextField(
                        label: "Địa chỉ",
                        controller: _addressController,
                        icon: Icons.location_on,
                        hint: "Nhập địa chỉ cửa hàng",
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(title: "Giấy tờ định danh"),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ImageBox(
                              label: "CCCD Mặt trước",
                              imageFile: _imageFiles[ImageType.front],
                              imageUrl: _imageUrls[ImageType.front],
                              onTap: () => _pickImage(ImageType.front),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ImageBox(
                              label: "CCCD Mặt sau",
                              imageFile: _imageFiles[ImageType.back],
                              imageUrl: _imageUrls[ImageType.back],
                              onTap: () => _pickImage(ImageType.back),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(title: "Giấy phép kinh doanh"),
                      const SizedBox(height: 12),
                      _ImageBox(
                        label: "Tải lên giấy phép",
                        imageFile: _imageFiles[ImageType.license],
                        imageUrl: _imageUrls[ImageType.license],
                        onTap: () => _pickImage(ImageType.license),
                        width: double.infinity,
                        height: 180,
                      ),                    
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Thông tin cửa hàng",
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
        ),
      ),
      actions: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          IconButton(
            onPressed: _updateShopProfile,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check, color: Colors.blue, size: 20),
            ),
          ),
      ],
    );
  }
}

// ===== PROFILE AVATAR =====
class _ProfileAvatar extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onTap;

  const _ProfileAvatar({
    required this.imageFile,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 3),
                ),
                child: ClipOval(
                  child: imageFile != null
                      ? Image.file(imageFile!, fit: BoxFit.cover)
                      : (imageUrl != null && imageUrl!.isNotEmpty
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _defaultAvatar(),
                            )
                          : _defaultAvatar()),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
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
      ),
    );
  }

  Widget _defaultAvatar() {
    return Image.asset(
      'assets/images/logo_default.png',
      fit: BoxFit.cover,
    );
  }
}

// ===== SECTION TITLE =====
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

// ===== PROFILE TEXT FIELD =====
class _ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final int maxLines;
  final String? Function(String?)? validator;

  const _ProfileTextField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.blue, size: 20),
            ),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _ImageBox extends StatelessWidget {
  final String label;
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onTap;
  final double? width;
  final double height;

  const _ImageBox({
    required this.label,
    required this.imageFile,
    required this.imageUrl,
    required this.onTap,
    this.width,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage ? Colors.blue : Colors.grey[300]!,
            width: hasImage ? 2 : 1,
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                imageFile != null
                    ? Image.file(imageFile!, fit: BoxFit.cover)
                    : Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
              else
                _placeholder(),
              if (hasImage)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add_photo_alternate, color: Colors.blue, size: 32),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
