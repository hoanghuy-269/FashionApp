import 'dart:io';
import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/core/widget/vaidatedtextfielfromrequest.dart';
import 'package:fashion_app/data/models/User.dart';
import 'package:fashion_app/viewmodels/requesttopent_viewmodel.dart';
import 'package:fashion_app/viewmodels/shop_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:fashion_app/data/models/requesttoopentshop_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestToOpenStoreScreen extends StatefulWidget {
  final String? uid;
  final String? shopId;
  const RequestToOpenStoreScreen({super.key, this.uid, this.shopId});

  @override
  State<RequestToOpenStoreScreen> createState() =>
      _RequestToOpenStoreScreenState();
}

class _RequestToOpenStoreScreenState extends State<RequestToOpenStoreScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneControler = TextEditingController();
  final TextEditingController cccdControler = TextEditingController();
  final TextEditingController addressControler = TextEditingController();

  bool isLoading = false;

  File? frontID;
  File? backID;
  File? license;

  String? frontUrl;
  String? backUrl;
  String? licenseUrl;

  String? nameError;
  String? phoneError;
  String? cccdError;
  String? addressError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadShopData();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneControler.dispose();
    cccdControler.dispose();
    addressControler.dispose();
    super.dispose();
  }

  Future<void> _loadShopData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final shopVM = context.read<ShopViewModel>();

      if (shopVM.currentShop == null && widget.shopId != null) {
        await shopVM.fetchShopById(widget.shopId!);
      }

      final shop = shopVM.currentShop;
      if (shop != null && mounted) {
        setState(() {
          nameController.text = shop.shopName;
          phoneControler.text = shop.phoneNumber?.toString() ?? '';
          cccdControler.text = shop.nationalId;
          addressControler.text = shop.address ?? '';

          frontUrl = shop.idnationFront;
          backUrl = shop.idnationBack;
          licenseUrl = shop.businessLicense;
        });
      }
    } catch (e) {
      debugPrint("Error loading shop data: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> pickImage({
    bool isFront = false,
    bool isLiscense = false,
  }) async {
    final File? image = await GalleryUtil.pickImageFromGallery();
    if (image != null && mounted) {
      setState(() {
        if (isLiscense) {
          license = image;
        } else if (isFront) {
          frontID = image;
        } else {
          backID = image;
        }
      });
    }
  }

  bool _validateForm() {
    setState(() {
      nameError =
          nameController.text.trim().isEmpty
              ? "Tên shop không được để trống"
              : null;

      phoneError =
          phoneControler.text.trim().length != 10
              ? "Số điện thoại phải có 10 số"
              : null;

      cccdError =
          cccdControler.text.trim().length != 12
              ? "CCCD/CMND phải có 12 số"
              : null;

      addressError =
          addressControler.text.trim().isEmpty
              ? "Địa chỉ shop không được để trống"
              : null;
    });

    return nameError == null &&
        phoneError == null &&
        cccdError == null &&
        addressError == null;
  }

  Future<void> _submitRequest() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final requestVm = Provider.of<RequestToOpenShopViewModel>(
        context,
        listen: false,
      );

      String? uploadedFront = frontUrl;
      String? uploadedBack = backUrl;
      String? uploadedLicense = licenseUrl;

      if (frontID != null) {
        uploadedFront = await GalleryUtil.uploadImageToFirebase(
          frontID!,
          folderName: 'requests/national_ids',
        );
      }

      if (backID != null) {
        uploadedBack = await GalleryUtil.uploadImageToFirebase(
          backID!,
          folderName: 'requests/national_ids',
        );
      }

      if (license != null) {
        uploadedLicense = await GalleryUtil.uploadImageToFirebase(
          license!,
          folderName: 'requests/licenses',
        );
      }

      String generateRequestId() {
        final now = DateTime.now();
        final formattedDate =
            "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
        final timestamp = now.millisecondsSinceEpoch.toString().substring(10);
        return 'RQ_${formattedDate}_$timestamp';
      }

      final uid = auth.FirebaseAuth.instance.currentUser?.uid ?? '';

      final request = RequesttoopentshopModel(
        requestId: generateRequestId(),
        userId: uid,
        shopName: nameController.text.trim(),
        businessLicense: uploadedLicense,
        address: addressControler.text.trim(),
        nationalId: cccdControler.text.trim(),
        idnationFront: uploadedFront ?? '',
        idnationBack: uploadedBack ?? '',
        status: 'pending',
        rejectionReason: null,
        createdAt: DateTime.now(),
        approvedAt: null,
      );

      await requestVm.createRequest(request);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gửi yêu cầu thành công!')));

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          isLoading
              ? null
              : AppBar(
                title: const Text("Đăng ký Shop"),
                centerTitle: true,
                backgroundColor: Colors.white,
              ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  ValidatedTextFieldFromRequest(
                    controller: nameController,
                    label: "Tên shop",
                    hint: "Nhập tên shop",
                    icon: Icons.store,
                    keyboardType: TextInputType.text,
                    hasError: nameError != null,
                    errorMessage: nameError ?? "",
                    onChanged: (value) {
                      if (nameError != null) {
                        setState(() => nameError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  ValidatedTextFieldFromRequest(
                    controller: phoneControler,
                    label: "Số điện thoại",
                    hint: "Nhập số điện thoại",
                    icon: Icons.phone,
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    hasError: phoneError != null,
                    errorMessage: phoneError ?? "",
                    onChanged: (value) {
                      if (phoneError != null) {
                        setState(() => phoneError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  ValidatedTextFieldFromRequest(
                    controller: cccdControler,
                    label: "Số CCCD/CMND",
                    hint: "Nhập số CCCD/CMND",
                    icon: Icons.credit_card,
                    maxLength: 12,
                    keyboardType: TextInputType.number,
                    hasError: cccdError != null,
                    errorMessage: cccdError ?? "",
                    onChanged: (value) {
                      if (cccdError != null) {
                        setState(() => cccdError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  const Text(
                    "Giấy phép kinh doanh (không bắt buộc)",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildImageBox(
                    "Giấy phép kinh doanh",
                    file: license,
                    url: licenseUrl,
                    onTap: () => pickImage(isLiscense: true),
                    width: double.infinity,
                  ),
                  const SizedBox(height: 10),
                  ValidatedTextFieldFromRequest(
                    controller: addressControler,
                    label: "Địa chỉ shop",
                    hint: "Nhập địa chỉ shop",
                    icon: Icons.location_on,
                    keyboardType: TextInputType.text,
                    hasError: addressError != null,
                    errorMessage: addressError ?? "",
                    onChanged: (value) {
                      if (addressError != null) {
                        setState(() => addressError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue,
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: const Text(
                        "Gửi yêu cầu mở shop",
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
          ),
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget buildImageBox(
    String label, {
    File? file,
    String? url,
    required VoidCallback onTap,
    double? width = 150,
  }) {
    final hasImage = file != null || (url != null && url.isNotEmpty);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child:
              !hasImage
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo, color: Colors.grey),
                      const SizedBox(height: 5),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                  : Stack(
                    fit: StackFit.expand,
                    children: [
                      // ✅ Hiển thị ảnh MỚI (File) hoặc ảnh CŨ (URL)
                      if (file != null)
                        Image.file(
                          file,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.error, color: Colors.red),
                            );
                          },
                        )
                      else if (url != null && url.isNotEmpty)
                        Image.network(
                          url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Không thể tải ảnh',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      // ✅ Nút xóa ảnh
                      Positioned(
                        right: 5,
                        top: 5,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (label.contains("trước")) {
                                frontID = null;
                                frontUrl = null;
                              } else if (label.contains("sau")) {
                                backID = null;
                                backUrl = null;
                              } else {
                                license = null;
                                licenseUrl = null;
                              }
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
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
      ),
    );
  }
}
