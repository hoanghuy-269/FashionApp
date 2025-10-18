import 'dart:io';

import 'package:fashion_app/core/utils/gallery_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneControler = TextEditingController();
  final TextEditingController cccdControler = TextEditingController();
  final TextEditingController addressControler = TextEditingController();

  File? frontID;
  File? backID;
  File? license;

  Future<void> pickImage(bool isFront, {bool isLiscense = false}) async {
    final File? image = await GalleryUtil.pickImageFromGallery();
    if (image != null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Cập nhật thông tin "),
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
                  child: CircleAvatar(child: Icon(Icons.person, size: 50)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Họ và tên ",
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
                  hintText: "Hiển thị tên Shop ",
                ),
              ),
              const SizedBox(height: 10),
              Text(
                " Hiển thị số điện thoại ",
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
                      "assets/images/logo_vietnam.png",
                      width: 24,
                      height: 24,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  hintText: "Hiển thị số điện thoại",
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
                readOnly: true,
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
                  hintText: "hiển thị căn cước công dân",
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildImageBox(
                    "Mặt trước",
                    frontID,
                    onTap: () => pickImage(true),
                  ),
                  buildImageBox(
                    "Mặt sau",
                    backID,
                    onTap: () => pickImage(false),
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
                license,
                onTap: () => pickImage(true, isLiscense: true),
                width: double.infinity,
              ),
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
                  hintText: "hiển thị địa chỉ",
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    "Cập nhật ",
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
    String label,
    File? file, {
    required VoidCallback onTap,
    double width = 150,
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
                  : null,
        ),
        child:
            file == null
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
                        onTap:
                            () => setState(() {
                              if (label.contains("trước")) frontID = null;
                              if (label.contains("sau")) backID = null;
                              if (label.contains("phép")) license = null;
                            }),
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
