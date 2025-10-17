import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
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
  /// Upload ảnh lên Firebase Storage, trả về URL 
  static Future<String?> uploadImageToFirebase(File imageFile,
      {String folderName = 'uploads'}) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final ref = FirebaseStorage.instance.ref().child('$folderName/$fileName');

      // Upload ảnh lên Firebase Storage
      await ref.putFile(imageFile);

      // Lấy URL 
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Lỗi upload ảnh: $e');
      return null;
    }
  }
}
