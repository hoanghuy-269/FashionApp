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

  static Future<File?> pickImageFromCamera() async{
    if(_isPicking) return null;
    _isPicking = true;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
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
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
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
  static Future<List<String>> uploadProductImages({
    required String productId,
    required String detailId,
    required List<File> images,
    Function(int current, int total)? onProgress,
  }) async {
    List<String> uploadedUrls = [];

    try {
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'image_${i + 1}_$timestamp.jpg';
        final path = 'products/$productId/$detailId/$fileName';

        // Upload file
        final ref = FirebaseStorage.instance.ref().child(path);
        await ref.putFile(file);

        // Lấy download URL
        final downloadUrl = await ref.getDownloadURL();
        uploadedUrls.add(downloadUrl);

        onProgress?.call(i + 1, images.length);

        print(' Uploaded (${i + 1}/${images.length}): $fileName');
      }
    } catch (e) {
      print(' Lỗi upload ảnh sản phẩm: $e');
      rethrow;
    }

    return uploadedUrls;
  }
  
  static Future<void> deleteImageByUrl(String imageUrl) async {
      try {
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        await ref.delete();
        print('🗑️ Deleted image: ${ref.name}');
      } catch (e) {
        print('❌ Lỗi xóa ảnh: $e');
      }
    }

}
