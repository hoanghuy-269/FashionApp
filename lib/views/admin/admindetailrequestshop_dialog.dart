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
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      content: _isLoading ? _buildLoadingState() : _buildFormContent(),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _handleReject,
          child: const Text('Từ chối'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleApprove,
          child: const Text('Chấp nhận'),
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

  Widget _buildShopNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tên Shop",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _nameController,
          enabled: false,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.store, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
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
          enabled: false,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.badge, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIDImagesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildImageBox("Mặt trước", url: _frontIDUrl),
        _buildImageBox("Mặt sau", url: _backIDUrl),
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
          url: _licenseUrl,
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
          enabled: false,
          maxLines: 2,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.map, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageBox(String label, {String? url, double width = 100}) {
    return Container(
      width: width,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
        color: Colors.grey.shade100,
        image:
            url != null
                ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                : null,
      ),
      child:
          url == null
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_not_supported, color: Colors.grey),
                  const SizedBox(height: 5),
                  Text(
                    'Chưa có $label',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              )
              : null,
    );
  }
}
