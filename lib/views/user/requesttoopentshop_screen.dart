import 'dart:io';

import 'package:fashion_app/core/utils/flushbar_extension.dart';
import 'package:fashion_app/core/utils/gallery_util.dart';
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
  File? logo;
  File? frontID;
  File? backID;
  File? license;
  String? frontUrl;
  String? backUrl;
  String? licenseUrl;

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

  Future<void> pickImage(
   { bool isFront = false,
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

      appBar: AppBar(
        title: const Text("Đăng kí Shop "),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap:  () async {
                    await pickImage(isLogo: true);
                  },
                  child: CircleAvatar(child: Icon(Icons.person, size: 50)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Nhập vào tên Shop ",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.person_2_outlined,
                    color: Colors.blueAccent,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  hintText: "Nhập vào tên Shop dự kiến ",
                ),
              ),
              const SizedBox(height: 10),
              Text(
                " số điện thoại ",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: phoneControler,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // nhập Số
                  LengthLimitingTextInputFormatter(12), // giới hạn
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  hintText: "Nhập vào số điện thoại shop ",
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Căn cước công dân",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: cccdControler,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.badge, color: Colors.blue),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  hintText: "Căn cước công dân ",
                ),
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
                width: double.infinity,
              ),

              const SizedBox(height: 10),
              Text(
                "Địa chỉ",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: addressControler,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.map, color: Colors.blue),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  hintText: "Địa chỉ shop ",
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
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

                    // build request model
                    final uid =
                        fb_auth.FirebaseAuth.instance.currentUser?.uid ?? '';
                    final requestId =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    final request = RequesttoopentshopModel(
                      requestId: requestId,
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
                     context.showSuccess("Gửi yêu cầu mở shop thành công ");
                    Future.delayed(const Duration(seconds: 2), () {
                      Navigator.of(context).pop('đang gửi yêu cầu ');
                    });
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
    );
  }

  Widget buildImageBox(
    String label, {
    File? file,
    String? url,
    required VoidCallback onTap,
    double width = 150,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 150,
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
