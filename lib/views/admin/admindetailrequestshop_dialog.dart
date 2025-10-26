import 'dart:io';

import 'package:fashion_app/core/utils/flushbar_extension.dart';
import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/viewmodels/requesttopent_viewmodel.dart';
import 'package:fashion_app/data/models/requesttoopentshop_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fashion_app/data/models/shop_model.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';

class AdmindetailrequestshopDialog extends StatefulWidget {
  final String? requestId;
  const AdmindetailrequestshopDialog({super.key, this.requestId});

  @override
  State<AdmindetailrequestshopDialog> createState() =>
      _AdmindetailrequestshopDialogState();
}

class _AdmindetailrequestshopDialogState
    extends State<AdmindetailrequestshopDialog> {
  // Constants
  static const String STATUS_APPROVED = 'approved';
  static const String STATUS_REJECTED = 'rejected';
  static const String ACTIVITY_STATUS_ACTIVE = 'active';
  static const int MAX_CCCD_LENGTH = 12;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cccdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // State
  bool _isLoading = false;
  RequesttoopentshopModel? _loadedRequest;

  // Images
  File? _frontIDFile;
  File? _backIDFile;
  File? _licenseFile;
  String? _frontIDUrl;
  String? _backIDUrl;
  String? _licenseUrl;

  @override
  void initState() {
    super.initState();
   WidgetsBinding.instance.addPostFrameCallback((_){
     if (widget.requestId != null && widget.requestId!.isNotEmpty) {
      _loadRequestData(widget.requestId!);
    }
   });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cccdController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadRequestData(String requestId) async {
    setState(() => _isLoading = true);

    try {
      final vm = Provider.of<RequestToOpenShopViewModel>(context, listen: false);
      final request = await vm.fetchRequestById(requestId);

      if (request != null && mounted) {
        _nameController.text = request.shopName;
        _cccdController.text = request.nationalId;
        _addressController.text = request.address;
        _loadedRequest = request;
        _frontIDUrl = request.idnationFront.isNotEmpty ? request.idnationFront : null;
        _backIDUrl = request.idnationBack.isNotEmpty ? request.idnationBack : null;
        _licenseUrl = request.businessLicense?.isNotEmpty == true ? request.businessLicense : null;
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading request: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage({
    bool isFront = false,
    bool isBack = false,
    bool isLicense = false,
  }) async {
    final image = await GalleryUtil.pickImageFromGallery();
    if (image != null && mounted) {
      setState(() {
        if (isFront) {
          _frontIDFile = image;
        } else if (isBack) {
          _backIDFile = image;
        } else if (isLicense) {
          _licenseFile = image;
        }
      });
    }
  }

  Future<void> _handleReject() async {
    if (_loadedRequest == null) {
      Navigator.of(context).pop();
      return;
    }

    final vm = Provider.of<RequestToOpenShopViewModel>(context, listen: false);
    await vm.updateStatus(_loadedRequest!.requestId, STATUS_REJECTED);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã từ chối yêu cầu')),
    );
    Navigator.of(context).pop(STATUS_REJECTED);
  }

  Future<void> _handleApprove() async {
    if (_loadedRequest == null) {
      if (!mounted) return;
      context.showSuccess('Gửi yêu cầu mở shop thành công');
      Navigator.of(context).pop('created');
      return;
    }

    final requestVm = Provider.of<RequestToOpenShopViewModel>(context, listen: false);
    final shopVm = Provider.of<ShopViewModel>(context, listen: false);

    final shopToCreate = ShopModel(
      shopId: '',
      userId: _loadedRequest!.userId,
      requestId: _loadedRequest!.requestId,
      shopName: _loadedRequest!.shopName,
      logo: null,
      phoneNumber: null,
      address: _loadedRequest!.address,
      businessLicense: _loadedRequest!.businessLicense,
      nationalId: _loadedRequest!.nationalId,
      idnationFront: _loadedRequest!.idnationFront,
      idnationBack: _loadedRequest!.idnationBack,
      activityStatusId: ACTIVITY_STATUS_ACTIVE,
    );

    try {
      final createdShop = await shopVm.createAndAddShop(shopToCreate);

      if (createdShop == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi tạo shop')),
        );
        return;
      }

      try {
        await requestVm.updateStatusWithShop(_loadedRequest!.requestId, STATUS_APPROVED, createdShop.shopId);
      } catch (e) {
        try {
          await shopVm.deleteShop(createdShop.shopId);
        } catch (ee) {
          debugPrint('Error deleting shop after failed request update: $ee');
        }
        rethrow;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã duyệt yêu cầu và tạo Shop')),
      );
      Navigator.of(context).pop(STATUS_APPROVED);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tạo shop')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      content: _isLoading ? _buildLoadingState() : _buildFormContent(),
      actions: [
        TextButton(
          onPressed: _handleReject,
          child: const Text('Từ chối'),
        ),
        ElevatedButton(
          onPressed: _handleApprove,
          child: Text(_loadedRequest != null ? 'Chấp nhận' : 'Gửi yêu cầu'),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      width: 300,
      height: 200,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogoSection(),
          const SizedBox(height: 12),
          _buildShopNameField(),
          const SizedBox(height: 10),
          _buildCCCDField(),
          const SizedBox(height: 10),
          _buildIDImagesRow(),
          const SizedBox(height: 10),
          _buildBusinessLicenseSection(),
          const SizedBox(height: 10),
          _buildAddressField(),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: GestureDetector(
        onTap: () {}, // Logo picker disabled for now
        child: const CircleAvatar(
          child: Icon(Icons.person, size: 50),
        ),
      ),
    );
  }

  Widget _buildShopNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nhập vào tên Shop",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_2_outlined, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            hintText: "Nhập vào tên Shop dự kiến",
          ),
        ),
      ],
    );
  }

  Widget _buildCCCDField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Căn cước công dân",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _cccdController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(MAX_CCCD_LENGTH),
          ],
          decoration: const InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.badge, color: Colors.blue),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            hintText: "Căn cước công dân",
          ),
        ),
      ],
    );
  }

  Widget _buildIDImagesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildImageBox(
          "Mặt trước",
          file: _frontIDFile,
          url: _frontIDUrl,
          onTap: () => _pickImage(isFront: true),
        ),
        _buildImageBox(
          "Mặt sau",
          file: _backIDFile,
          url: _backIDUrl,
          onTap: () => _pickImage(isBack: true),
        ),
      ],
    );
  }

  Widget _buildBusinessLicenseSection() {
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
        const SizedBox(height: 10),
        _buildImageBox(
          "Giấy phép kinh doanh",
          file: _licenseFile,
          url: _licenseUrl,
          onTap: () => _pickImage(isLicense: true),
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Địa chỉ",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.map, color: Colors.blue),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            hintText: "Địa chỉ shop",
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
    double width = 100,
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
          image: _getBoxImage(file, url),
        ),
        child: hasImage ? _buildImageOverlay(onTap) : _buildPlaceholder(label),
      ),
    );
  }

  DecorationImage? _getBoxImage(File? file, String? url) {
    if (file != null) {
      return DecorationImage(image: FileImage(file), fit: BoxFit.cover);
    }
    if (url != null) {
      return DecorationImage(image: NetworkImage(url), fit: BoxFit.cover);
    }
    return null;
  }

  Widget _buildImageOverlay(VoidCallback onTap) {
    return Stack(
      children: [
        Positioned(
          right: 5,
          top: 5,
          child: InkWell(
            onTap: onTap,
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.black54,
              child: Icon(Icons.edit, size: 15, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_a_photo, color: Colors.grey),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}