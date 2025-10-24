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
    // If dialog was opened with a requestId, load that request and populate fields
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
          // populate controllers and image urls
          nameController.text = req.shopName;
    cccdControler.text = req.nationalId;
    addressControler.text = req.address;
          _loadedRequest = req;
          frontUrl = req.idnationFront.isNotEmpty ? req.idnationFront : null;
          backUrl = req.idnationBack.isNotEmpty ? req.idnationBack : null;
          licenseUrl =
              req.businessLicense != null && req.businessLicense!.isNotEmpty
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
                          child: Icon(Icons.person, size: 50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                      controller: cccdControler,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12),
                      ],
                      decoration: const InputDecoration(
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
                      controller: addressControler,
                      decoration: const InputDecoration(
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
              if (!mounted) return;
            context.showSuccess('Gửi yêu cầu mở shop thành công');
            Navigator.of(context).pop('created');
          },
          child: Text(_loadedRequest != null ? 'Chấp nhận' : 'Gửi yêu cầu'),
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
