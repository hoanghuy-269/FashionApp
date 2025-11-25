import 'package:fashion_app/core/utils/flushbar_extension.dart';
import 'package:fashion_app/viewmodels/requesttopent_viewmodel.dart';
import 'package:fashion_app/data/models/requesttoopentshop_model.dart';
import 'package:flutter/material.dart';
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
  static const String STATUS_APPROVED = 'approved';
  static const String STATUS_REJECTED = 'rejected';
  static const String ACTIVITY_STATUS_ACTIVE = 'active';
  static const int MAX_CCCD_LENGTH = 12;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cccdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;
  RequesttoopentshopModel? _loadedRequest;

  String? _frontIDUrl;
  String? _backIDUrl;
  String? _licenseUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      final vm = Provider.of<RequestToOpenShopViewModel>(
        context,
        listen: false,
      );
      final request = await vm.fetchRequestById(requestId);

      if (request != null && mounted) {
        _nameController.text = request.shopName;
        _cccdController.text = request.nationalId;
        _addressController.text = request.address;
        _loadedRequest = request;

        _frontIDUrl =
            request.idnationFront.isNotEmpty ? request.idnationFront : null;
        _backIDUrl =
            request.idnationBack.isNotEmpty ? request.idnationBack : null;
        _licenseUrl =
            request.businessLicense?.isNotEmpty == true
                ? request.businessLicense
                : null;

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

  Future<void> _handleReject() async {
    if (_loadedRequest == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final vm = Provider.of<RequestToOpenShopViewModel>(
        context,
        listen: false,
      );

      // Update the request status by requestId (use the loaded request).
      await vm.updateStatus(_loadedRequest!.requestId, STATUS_REJECTED);

      if (!mounted) return;

      Navigator.of(context).pop(STATUS_REJECTED);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _handleApprove() async {
    if (_loadedRequest == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isLoading = true);

    final requestVm = Provider.of<RequestToOpenShopViewModel>(
      context,
      listen: false,
    );
    final shopVm = Provider.of<ShopViewModel>(context, listen: false);

    if (_loadedRequest?.userId.trim().isEmpty ?? true) {
      if (mounted) {
        try {
          context.showError('User ID của yêu cầu không tồn tại. Không thể tạo shop.');
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User ID của yêu cầu không tồn tại. Không thể tạo shop.')),
          );
        }
        setState(() => _isLoading = false);
      }
      return;
    }

    String generateShopId() {
      final now = DateTime.now();
      final formattedDate =
          "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
      final timestamp = now.millisecondsSinceEpoch.toString().substring(10);
      return 'Shop_${formattedDate}_$timestamp';
    }

    final shopToCreate = ShopModel(
      shopId: generateShopId(),
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
      print(" thogn Creating shop with data: ${_loadedRequest?.userId}");
      final createdShop = await shopVm.createAddShop(shopToCreate);

      if (createdShop == null) {
        if (!mounted) return;
        return;
      }

      try {
        await requestVm.updateStatusWithShop(
          _loadedRequest!.requestId,
          STATUS_APPROVED,
          createdShop.shopId,
        );
      } catch (e) {
        try {
          await shopVm.deleteShop(createdShop.shopId);
        } catch (e) {
          debugPrint('Error deleting shop after failed request update: $e');
        }
        rethrow;
      }
      if (!mounted) return;
      Navigator.of(context).pop(STATUS_APPROVED);
    } catch (e) {
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: _isLoading ? _buildLoadingState() : _buildFormContent(),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.store_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chi tiết yêu cầu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Xem xét thông tin đăng ký shop',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: Colors.grey[700],
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Đang tải dữ liệu...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShopNameField(),
          const SizedBox(height: 20),
          _buildCCCDField(),
          const SizedBox(height: 20),
          _buildIDImagesSection(),
          const SizedBox(height: 20),
          _buildBusinessLicenseSection(),
          const SizedBox(height: 20),
          _buildAddressField(),
        ],
      ),
    );
  }

  Widget _buildShopNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.store_outlined, size: 18, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text(
              "Tên Shop",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          enabled: false,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCCCDField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.credit_card_rounded, size: 18, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text(
              "Số CCCD/CMND",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _cccdController,
          enabled: false,
          keyboardType: TextInputType.phone,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIDImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.badge_outlined, size: 18, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text(
              "Ảnh CCCD/CMND",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildImageBox(
                "Mặt trước",
                url: _frontIDUrl,
                height: 140,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildImageBox(
                "Mặt sau",
                url: _backIDUrl,
                height: 140,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBusinessLicenseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description_outlined, size: 18, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text(
              "Giấy phép kinh doanh",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildImageBox(
          "Giấy phép kinh doanh",
          url: _licenseUrl,
          height: 180,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 18, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text(
              "Địa chỉ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _addressController,
          enabled: false,
          maxLines: 3,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageBox(
    String label, {
    String? url,
    double? width,
    double height = 120,
  }) {
    final hasImage = url != null && url.isNotEmpty;

    return GestureDetector(
      onTap: hasImage
          ? () {
              _showImageDialog(url);
            }
          : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage ? Colors.blue.shade200 : Colors.grey.shade300,
            width: 2,
          ),
          color: Colors.grey.shade50,
          image: hasImage
              ? DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: hasImage
            ? Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Xem',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chưa có $label',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: const BoxConstraints(
                maxHeight: 600,
                maxWidth: 500,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // cho phép phóng to hình ảnh
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
              color: Colors.white,
              iconSize: 32,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _handleReject,
              icon: const Icon(Icons.close_rounded),
              label: const Text('Từ chối'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleApprove,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Chấp nhận'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}