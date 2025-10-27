import 'dart:io';

import 'package:fashion_app/core/utils/flushbar_extension.dart';
import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:fashion_app/core/widget/vaidatedtextfielfromrequest.dart';
import 'package:fashion_app/viewmodels/requesttopent_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:fashion_app/data/models/requesttoopentshop_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RequestToOpenStoreScreen extends StatefulWidget {
  final String? uid;
  const RequestToOpenStoreScreen({super.key, this.uid});

  @override
  State<RequestToOpenStoreScreen> createState() =>
      _RequestToOpenStoreScreenState();
}

class _RequestToOpenStoreScreenState extends State<RequestToOpenStoreScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneControler = TextEditingController();
  final TextEditingController cccdControler = TextEditingController();
  final TextEditingController addressControler = TextEditingController();
  final GalleryUtil galleryUti = GalleryUtil();
  bool inited = false;
  bool isLoading = false;
  File? logo;
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
  String? frontError;
  String? backError;
  String? licenseError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (inited) return;
    inited = true;
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
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: isLoading
          ? null
          : AppBar(
              title: const Text("Đăng kí Shop "),
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
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        await pickImage(isLogo: true);
                      },
                      child: CircleAvatar(child: Icon(Icons.person, size: 50)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ValidatedTextFieldFromRequest(
                    controller: nameController,
                    label: "Tên shop ",
                    hint: "Nhập tên shop ",
                    icon: Icons.store,
          
                    keyboardType: TextInputType.text,
                    hasError: nameError != null,
                    errorMessage: nameError ?? "Tên shop không được để trống ",
                    onChanged: (value) {
                      setState(() {
                        nameController.text = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  ValidatedTextFieldFromRequest(
                    controller: phoneControler,
                    label: "Số điện thoại ",
                    hint: "Nhập số điện thoại ",
                    icon: Icons.phone,
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    hasError: phoneError != null,
                    errorMessage:
                        phoneError ??
                        "vui lòng nhập đúng định dạng số điện thoại  ",
                    onChanged: (value) {
                      setState(() {
                        if (phoneControler.text.length == 10) {
                          phoneControler.text = value;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  ValidatedTextFieldFromRequest(
                    controller: cccdControler,
                    label: "Số CCCD/CMND ",
                    hint: "Nhập số CCCD/CMND ",
                    icon: Icons.credit_card,
                    maxLength: 12,
                    keyboardType: TextInputType.number,
                    hasError: cccdError != null,
                    errorMessage:
                        cccdError ?? "Vui lòng nhập đúng định dạng CCCD/CMND  ",
                    onChanged: (value) {
                      setState(() {
                        if (cccdControler.text.length == 12) {
                          cccdControler.text = value;
                        }
                      });
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
                        error: frontError,
                        onTap: () => pickImage(isFront: true),
                      ),
                      buildImageBox(
                        "Mặt sau",
                        file: backID,
                        url: backUrl,
                        error: backError,
                        onTap: () => pickImage(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Giáy phép kinh doanh",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildImageBox(
                    "Giấ phép kinh doanh ",
                    file: license,
                    url: licenseUrl,
                    onTap: () => pickImage(isLiscense: true),
                    error: licenseError,
                    width: double.infinity,
                  ),
          
                  const SizedBox(height: 10),
                  ValidatedTextFieldFromRequest(
                    controller: addressControler,
                    label: "Địa chỉ shop ",
                    hint: "Nhập địa chỉ shop ",
                    icon: Icons.location_on,
                    keyboardType: TextInputType.text,
                    hasError: addressError != null,
                    errorMessage:
                        addressError ?? "Địa chỉ shop không được để trống ",
                    onChanged: (value) {
                      setState(() {
                        addressControler.text = value;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        final requestVm = Provider.of<RequestToOpenShopViewModel>(
                          context,
                          listen: false,
                        );
          
                        // gather inputs
                        final shopName = nameController.text.trim();
                        final nationalId = cccdControler.text.trim();
          
                        // upload images if present
                        String? uploadedFront;
                        String? uploadedBack;
                        String? uploadedLicense;
                        if (frontID != null) {
                          uploadedFront = await GalleryUtil.uploadImageToFirebase(
                            frontID!,
                          );
                        }
                        if (backID != null) {
                          uploadedBack = await GalleryUtil.uploadImageToFirebase(
                            backID!,
                          );
                        }
                        if (license != null) {
                          uploadedLicense = await GalleryUtil.uploadImageToFirebase(
                            license!,
                          );
                        }
                        String generateRequestId() {
                          final now = DateTime.now();
                          final formattedDate = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
                          final timestamp = now.millisecondsSinceEpoch.toString().substring(10);
                          return 'RQ_${formattedDate}_$timestamp';
                        }
          
                        final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid ?? '';
                        
                        final request = RequesttoopentshopModel(
                          requestId: generateRequestId(),
                          userId: uid,
                          shopName: shopName,
                          businessLicense: uploadedLicense,
                          address: addressControler.text.trim(),
                          nationalId: nationalId,
                          idnationFront: uploadedFront ?? '',
                          idnationBack: uploadedBack ?? '',
                          status: 'pending',
                          rejectionReason: null,
                          createdAt: DateTime.now(),
                          approvedAt: null,
                        );
          
                        await requestVm.createRequest(request);
          
                        if (!mounted) return;
                        setState(() {
                          isLoading = false;
                        });

                        Navigator.of(context).pop(true);
                        
                      },
          
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "Gửi yêu cầu mở shop ",
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
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
    
  }

  Widget buildImageBox(
    String label, {
    File? file,
    String? url,
    String? error,
    required VoidCallback onTap,
    double width = 150,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: error != null ? Colors.red : Colors.grey.shade400,
              ),
              image:
                  file != null
                      ? DecorationImage(
                        image: FileImage(file),
                        fit: BoxFit.cover,
                      )
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
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
