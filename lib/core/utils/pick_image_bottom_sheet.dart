import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fashion_app/core/utils/gallery_util.dart';

Future<File?> showPickImageBottomSheet(BuildContext context) async {
  return await showModalBottomSheet<File?>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () async {
                final image = await GalleryUtil.pickImageFromGallery();
                Navigator.pop(context, image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh mới'),
              onTap: () async {
                final image = await GalleryUtil.pickImageFromCamera();
                Navigator.pop(context, image);
              },
            ),
          ],
        ),
      );
    },
  );
}
