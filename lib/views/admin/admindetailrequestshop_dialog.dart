import 'dart:io';
import 'package:fashion_app/core/utils/flushbar_extension.dart';
import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/viewmodels/requesttopent_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneControler = TextEditingController();
  final TextEditingController cccdControler = TextEditingController();
  final TextEditingController addressControler = TextEditingController();
  final GalleryUtil galleryUti = GalleryUtil();
  bool inited = false;
  bool _loading = false;
  File? logo;
  File? frontID;
  File? backID;
  File? license;
  String? frontUrl;
  String? backUrl;
  String? licenseUrl;
  RequesttoopentshopModel? _loadedRequest;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (inited) return;
    inited = true;
    if (widget.requestId != null && widget.requestId!.isNotEmpty) {
      _loadRequest(widget.requestId!);
    }
  }

  Future<void> _loadRequest(String requestId) async {
    setState(() {
      _loading = true;
    });
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final vm = Provider.of<RequestToOpenShopViewModel>(
          context,
          listen: false,
        );
        final req = await vm.fetchRequestById(requestId);
        if (req != null && mounted) {
          nameController.text = req.shopName;
          cccdControler.text = req.nationalId;
          addressControler.text = req.address;
          _loadedRequest = req;
          frontUrl = req.idnationFront.isNotEmpty ? req.idnationFront : null;
          backUrl = req.idnationBack.isNotEmpty ? req.idnationBack : null;
          licenseUrl = req.businessLicense != null && req.businessLicense!.isNotEmpty
              ? req.businessLicense
              : null;
          setState(() {});
        }
      });
    } catch (e) {
      debugPrint('AdmindetailrequestshopDialog._loadRequest error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneControler.dispose();
    cccdControler.dispose();
    addressControler.dispose();
    super.dispose();
  }

  Future<void> pickImage({
    bool isFront = false,
    bool isLogo = false,
    bool isLiscense = false,
  }) async {
    final File? image = await GalleryUtil.pickImageFromGallery();
    if (image != null) {
      if (!mounted) return;
      setState(() {
        if (isLogo) {
          logo = image;
        } else if (isLiscense) {
          license = image;
        } else if (isFront) {
          frontID = image;
        } else {
          backID = image;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      content:
          _loading
              ? const SizedBox(
                  width: 300,
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            await pickImage(isLogo: true);
                          },
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0xFFE0F7FA), // background color
                            child: Icon(Icons.person, size: 50, color: Colors.blue),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Nhập vào tên Shop",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.storefront, color: Colors.blue),
                          hintText: "Nhập vào tên Shop dự kiến",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Căn cước công dân",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: cccdControler,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                        ],
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.badge, color: Colors.blue),
                          hintText: "Căn cước công dân",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildImageBox(
                            "Mặt trước",
                            file: frontID,
                            url: frontUrl,
                            onTap: () => pickImage(isFront: true),
                          ),
                          buildImageBox(
                            "Mặt sau",
                            file: backID,
                            url: backUrl,
                            onTap: () => pickImage(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Giấy phép kinh doanh",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      buildImageBox(
                        "Giấy phép kinh doanh",
                        file: license,
                        url: licenseUrl,
                        onTap: () => pickImage(isLiscense: true),
                        width: double.infinity,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Địa chỉ",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: addressControler,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
                          hintText: "Địa chỉ shop",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      actions: [
        TextButton(
          onPressed: () async {
            final vm = Provider.of<RequestToOpenShopViewModel>(context, listen: false);
            if (_loadedRequest != null) {
              await vm.updateStatus(_loadedRequest!.requestId, 'rejected');
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy yêu cầu')));
              Navigator.of(context).pop('rejected');
            } else {
              Navigator.of(context).pop();
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, // Màu chữ trắng
            backgroundColor: const Color(0xFFE53935), // Màu đỏ
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: const Text('Từ chối'),
        ),
        ElevatedButton(
          onPressed: () async {
            final vm = Provider.of<RequestToOpenShopViewModel>(context, listen: false);
            if (_loadedRequest != null) {
              final shopVm = Provider.of<ShopViewModel>(context, listen: false);
              final req = _loadedRequest!;
              final shopToCreate = ShopModel(
                shopId: '',
                userId: req.userId,
                requestId: req.requestId,
                shopName: req.shopName,
                logo: null,
                phoneNumber: null,
                address: req.address,
                businessLicense: req.businessLicense,
                nationalId: req.nationalId,
                idnationFront: req.idnationFront,
                idnationBack: req.idnationBack,
                activityStatusId: 'active',
              );

              try {
                await shopVm.createAndAddShop(shopToCreate);
                await vm.updateStatus(req.requestId, 'approved');
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã duyệt yêu cầu và tạo Shop')));
                Navigator.of(context).pop('approved');
                return;
              } catch (e) {
                debugPrint('Error creating shop from request: $e');
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi tạo shop')));
                return;
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Màu xanh nước biển
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: const Text('Chấp nhận'),
        ),
      ],
    );
  }

  Widget buildImageBox(
    String label, {
    File? file,
    String? url,
    required VoidCallback onTap,
    double width = 100,
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
                    Text(label, style: const TextStyle(color: Colors.grey)),
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
                          backgroundColor: Colors.black,
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
    );
  }
}
