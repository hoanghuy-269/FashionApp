import 'dart:io';

import 'package:image_picker/image_picker.dart';

class GalleryUtil {
  static final ImagePicker _picker = ImagePicker();
  static bool _isPicking = false;
  static Future<File?> pickImageFromGallery() async {
    if (_isPicking) return null;
    _isPicking = true;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        return File(image.path);
      } else {
        return null;
      }
    } finally {
      _isPicking = false;
    }
  }
}
